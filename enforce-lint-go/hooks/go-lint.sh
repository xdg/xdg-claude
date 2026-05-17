#!/bin/bash
# Claude Code Hook: Run golangci-lint in every Go module touched by current changes.
# Used for both Stop (instruct to fix) and PreToolUse/git commit (block commit).
#
# Discovery: find changed .go files (staged, unstaged, untracked), walk up from
# each to the nearest ancestor go.mod, dedupe, lint each module from its own dir.
# This handles root-level Go, single-subdir layouts (e.g. backend/), and
# multi-module monorepos with no configuration.
set -euo pipefail

# Consume stdin (required by hook protocol)
input=$(timeout 3 cat 2>/dev/null) || true

# Anchor at repo root so paths returned by git are interpretable.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo '{"continue": true}'
    exit 0
}
cd "$repo_root"

changed_files=$(
    {
        git diff --name-only --diff-filter=ACM 2>/dev/null | grep '\.go$' || true
        git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep '\.go$' || true
        git ls-files --other --exclude-standard 2>/dev/null | grep '\.go$' || true
    } | sort -u
)

if [ -z "$changed_files" ]; then
    echo '{"continue": true}'
    exit 0
fi

file_count=$(echo "$changed_files" | wc -l | tr -d ' ')

# Walk up from each changed file to its nearest ancestor go.mod directory.
# Output module dirs (relative to repo root), deduped.
module_dirs=$(
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        dir=$(dirname "$f")
        while :; do
            if [ -f "$dir/go.mod" ]; then
                echo "$dir"
                break
            fi
            [ "$dir" = "." ] && break
            parent=$(dirname "$dir")
            [ "$parent" = "$dir" ] && break
            dir=$parent
        done
    done <<< "$changed_files" | sort -u
)

if [ -z "$module_dirs" ]; then
    echo "{\"continue\": true, \"message\": \"$file_count changed Go file(s) but no enclosing go.mod found; skipping\"}"
    exit 0
fi

if ! command -v golangci-lint >/dev/null 2>&1; then
    echo '{"continue": true, "message": "golangci-lint not found; skipping"}'
    exit 0
fi

aggregate_output=""
aggregate_exit=0
while IFS= read -r mod_dir; do
    [ -z "$mod_dir" ] && continue
    out=""
    code=0
    out=$(cd "$mod_dir" && golangci-lint run ./... 2>&1) || code=$?
    if [ "$code" -ne 0 ]; then
        aggregate_exit=$code
        if [ -n "$aggregate_output" ]; then
            aggregate_output+=$'\n\n'
        fi
        aggregate_output+="=== $mod_dir ==="$'\n'"$out"
    fi
done <<< "$module_dirs"

mod_count=$(echo "$module_dirs" | wc -l | tr -d ' ')

if [ "$aggregate_exit" -ne 0 ] && [ -n "$aggregate_output" ]; then
    cat <<ENDJSON
{"decision": "block", "reason": "golangci-lint found issues across $mod_count module(s) covering $file_count changed Go file(s). Fix these before continuing:\n\n$( echo "$aggregate_output" | jq -Rs . | sed 's/^"//;s/"$//' )"}
ENDJSON
    exit 0
fi

echo "{\"continue\": true, \"message\": \"golangci-lint passed for $file_count changed Go file(s) across $mod_count module(s)\"}"
