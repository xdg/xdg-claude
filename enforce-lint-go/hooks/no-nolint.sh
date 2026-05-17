#!/bin/bash
# Claude Code Hook: Reject lint-bypass attempts.
# Agents must fix lint issues properly or escalate to a human.
set -euo pipefail

input=$(timeout 3 cat 2>/dev/null) || true

ESCALATE="If you cannot fix the lint issue, STOP and ask the human for help. Do not attempt other workarounds."

# Block edits to .golangci.yml — adjusting lint config to suppress checks
# is the same evasion as //nolint. Only a human may change lint rules.
file_path=$(echo "$input" | jq -r ".tool_input.file_path // empty" 2>/dev/null) || true
if [[ "$file_path" == *".golangci.yml" || "$file_path" == *".golangci.yaml" || "$file_path" == *".golangci.toml" ]]; then
    echo "BLOCKED: Do not modify golangci-lint configuration to work around lint failures." >&2
    echo "$ESCALATE" >&2
    exit 1
fi

# Block lint-bypass comment directives in code.
# Covers: //nolint, // #nosec, //lint:ignore, //revive:disable, etc.
LINT_BYPASS_RE='//[[:space:]]*(nolint|#nosec|lint:(ignore|file-ignore)|revive:(disable|enable)|exhaustive:ignore|exhaustruct:ignore|nosemgrep|noinspection|nolintlint)\b'
for field in new_string content; do
    value=$(echo "$input" | jq -r ".tool_input.${field} // empty" 2>/dev/null) || true
    if echo "$value" | grep -qE "$LINT_BYPASS_RE"; then
        echo "BLOCKED: Do not add lint-bypass directives (nolint, nosec, revive:disable, etc.). Fix the underlying lint issue instead." >&2
        echo "$ESCALATE" >&2
        exit 1
    fi
done
