#!/bin/bash
# Claude Code Hook: Block `git commit` if golangci-lint fails (PreToolUse on Bash).
set -euo pipefail

input=$(timeout 3 cat 2>/dev/null) || true

command_str=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || true

case "$command_str" in
    "git commit"*)
        exec "$(dirname "$0")/go-lint.sh" <<< ""
        ;;
    *)
        echo '{"continue": true}'
        exit 0
        ;;
esac
