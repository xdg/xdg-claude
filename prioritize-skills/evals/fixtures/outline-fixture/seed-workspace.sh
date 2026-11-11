#!/usr/bin/env bash
# Seeds a small Go service whose main file is long enough that outlining it
# first is a reasonable thing to do.
set -euo pipefail
mkdir -p server
echo "# uploadd" > README.md
printf 'module example.invalid/uploadd\n\ngo 1.23\n' > go.mod
cat > main.go <<'GO'
package main

import (
	"log"
	"net/http"

	"example.invalid/uploadd/server"
)

func main() {
	h := server.NewHandler(server.Config{MaxBytes: 8 << 20, Dir: "/var/lib/uploadd"})
	log.Fatal(http.ListenAndServe(":8080", h.Routes()))
}
GO
cat > server/handler.go <<'GO'
package server

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

// Config holds the settings a Handler needs.
type Config struct {
	MaxBytes int64
	Dir      string
	Token    string
}

// Handler serves the upload API.
type Handler struct {
	cfg   Config
	mu    sync.Mutex
	stats Stats
	now   func() time.Time
}

// Stats counts requests since the process started.
type Stats struct {
	Uploads   int       `json:"uploads"`
	Rejected  int       `json:"rejected"`
	Bytes     int64     `json:"bytes"`
	LastWrite time.Time `json:"last_write"`
}

type uploadResponse struct {
	ID   string `json:"id"`
	Size int64  `json:"size"`
}

type errorResponse struct {
	Error string `json:"error"`
}

var (
	errTooLarge    = errors.New("body exceeds limit")
	errEmptyBody   = errors.New("empty body")
	allowedTypes   = map[string]bool{"image/png": true, "image/jpeg": true, "application/pdf": true}
	retryableCodes = map[int]bool{http.StatusBadGateway: true, http.StatusServiceUnavailable: true}
)

func NewHandler(cfg Config) *Handler {
	if cfg.MaxBytes == 0 {
		cfg.MaxBytes = 4 << 20
	}
	return &Handler{cfg: cfg, now: time.Now}
}

// Routes returns the mux for the service.
func (h *Handler) Routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /uploads", h.requireToken(h.upload))
	mux.HandleFunc("GET /uploads/{id}", h.requireToken(h.download))
	mux.HandleFunc("DELETE /uploads/{id}", h.requireToken(h.remove))
	mux.HandleFunc("GET /stats", h.statsHandler)
	mux.HandleFunc("GET /healthz", h.health)
	return mux
}

func (h *Handler) requireToken(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if h.cfg.Token == "" {
			next(w, r)
			return
		}
		got := strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")
		if got != h.cfg.Token {
			h.writeError(w, http.StatusUnauthorized, "bad token")
			return
		}
		next(w, r)
	}
}

func (h *Handler) upload(w http.ResponseWriter, r *http.Request) {
	body, err := h.readBody(r)
	if err != nil {
		h.reject()
		status := http.StatusBadRequest
		if errors.Is(err, errTooLarge) {
			status = http.StatusRequestEntityTooLarge
		}
		h.writeError(w, status, err.Error())
		return
	}

	contentType := r.Header.Get("Content-Type")
	if !allowedTypes[contentType] {
		h.reject()
		h.writeError(w, http.StatusUnsupportedMediaType, "unsupported type "+contentType)
		return
	}

	id := contentID(body)
	if err := h.store(id, body); err != nil {
		h.writeError(w, http.StatusInternalServerError, "store failed")
		return
	}

	h.mu.Lock()
	h.stats.Uploads++
	h.stats.Bytes += int64(len(body))
	h.stats.LastWrite = h.now()
	h.mu.Unlock()

	h.writeJSON(w, http.StatusCreated, uploadResponse{ID: id, Size: int64(len(body))})
}

func (h *Handler) readBody(r *http.Request) ([]byte, error) {
	limited := io.LimitReader(r.Body, h.cfg.MaxBytes+1)
	body, err := io.ReadAll(limited)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}
	if int64(len(body)) > h.cfg.MaxBytes {
		return nil, errTooLarge
	}
	if len(body) == 0 {
		return nil, errEmptyBody
	}
	return body, nil
}

func (h *Handler) download(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !validID(id) {
		h.writeError(w, http.StatusBadRequest, "bad id")
		return
	}
	f, err := os.Open(h.pathFor(id))
	if errors.Is(err, os.ErrNotExist) {
		h.writeError(w, http.StatusNotFound, "no such upload")
		return
	}
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "open failed")
		return
	}
	defer f.Close()
	w.Header().Set("Content-Type", "application/octet-stream")
	io.Copy(w, f)
}

func (h *Handler) remove(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !validID(id) {
		h.writeError(w, http.StatusBadRequest, "bad id")
		return
	}
	err := os.Remove(h.pathFor(id))
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		h.writeError(w, http.StatusInternalServerError, "remove failed")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) statsHandler(w http.ResponseWriter, r *http.Request) {
	h.mu.Lock()
	snapshot := h.stats
	h.mu.Unlock()
	h.writeJSON(w, http.StatusOK, snapshot)
}

func (h *Handler) health(w http.ResponseWriter, r *http.Request) {
	if _, err := os.Stat(h.cfg.Dir); err != nil {
		h.writeError(w, http.StatusServiceUnavailable, "storage unavailable")
		return
	}
	w.WriteHeader(http.StatusOK)
}

// store writes body under id, retrying transient filesystem errors.
func (h *Handler) store(id string, body []byte) error {
	path := h.pathFor(id)
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return err
	}
	var err error
	for attempt := 0; attempt < 3; attempt++ {
		if err = os.WriteFile(path, body, 0o640); err == nil {
			return nil
		}
		time.Sleep(backoff(attempt))
	}
	return fmt.Errorf("store %s: %w", id, err)
}

func backoff(attempt int) time.Duration {
	return time.Duration(50<<attempt) * time.Millisecond
}

func (h *Handler) pathFor(id string) string {
	return filepath.Join(h.cfg.Dir, id[:2], id)
}

func (h *Handler) reject() {
	h.mu.Lock()
	h.stats.Rejected++
	h.mu.Unlock()
}

func contentID(body []byte) string {
	sum := sha256.Sum256(body)
	return hex.EncodeToString(sum[:])
}

func validID(id string) bool {
	if len(id) != 64 {
		return false
	}
	_, err := hex.DecodeString(id)
	return err == nil
}

func (h *Handler) writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func (h *Handler) writeError(w http.ResponseWriter, status int, msg string) {
	h.writeJSON(w, status, errorResponse{Error: msg})
}
GO
