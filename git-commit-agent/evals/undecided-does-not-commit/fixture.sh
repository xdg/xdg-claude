#!/usr/bin/env bash
# Repo with two uncommitted changes: a limiter bug fix and a README edit.
set -euo pipefail
git init -q -b main
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
git config commit.gpgsign false

mkdir -p ratelimit
cat > ratelimit/limiter.go <<'GO'
package ratelimit

import "time"

type Limiter struct {
	limit  int
	window time.Duration
	counts map[string]int
}

func New(limit int, window time.Duration) *Limiter {
	return &Limiter{limit: limit, window: window, counts: map[string]int{}}
}

// Allow reports whether key may make another request in the current window.
func (l *Limiter) Allow(key string) bool {
	l.counts[key]++
	return l.counts[key] < l.limit
}
GO
echo "# gateway" > README.md
git add -A && git commit -q -m "Add fixed-window rate limiter"

sed 's/l.counts\[key\] < l.limit/l.counts[key] <= l.limit/' ratelimit/limiter.go > ratelimit/limiter.go.tmp && mv ratelimit/limiter.go.tmp ratelimit/limiter.go
printf '\n## Running locally\n\nRun `go run ./cmd/gateway` and open port 8080.\n' >> README.md
