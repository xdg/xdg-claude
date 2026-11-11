#!/usr/bin/env bash
# Repo whose history uses "JIRA-<n> <type>: <subject>", on a branch that names
# ticket JIRA-1234, with one uncommitted bug fix.
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
git add -A && git commit -q -m "JIRA-1101 feat: add fixed-window rate limiter"

echo "# gateway" > README.md
git add -A && git commit -q -m "JIRA-1102 docs: add README"

cat >> ratelimit/limiter.go <<'GO'

func (l *Limiter) Reset() { l.counts = map[string]int{} }
GO
git add -A && git commit -q -m "JIRA-1187 feat: add limiter reset"

git checkout -q -b jira-1234-limiter-off-by-one
sed 's/l.counts\[key\] < l.limit/l.counts[key] <= l.limit/' ratelimit/limiter.go > ratelimit/limiter.go.tmp && mv ratelimit/limiter.go.tmp ratelimit/limiter.go
