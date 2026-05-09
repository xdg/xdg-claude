#!/usr/bin/env bash
# SessionStart/SubagentStart hook to inject coding best practices guidance.

CONTENT_FILE="${CLAUDE_PLUGIN_ROOT}/hooks/references/coding-guidelines.md"

if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Error: coding-guidelines.md not found at $CONTENT_FILE" >&2
  exit 1
fi

EVENT=$(jq -r '.hook_event_name // empty')

if [[ -z "$EVENT" ]]; then
  echo "Error: hook_event_name missing from stdin" >&2
  exit 1
fi

CONTENT=$(cat "$CONTENT_FILE")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "$EVENT",
    "additionalContext": $(jq -Rs . <<< "$CONTENT")
  }
}
EOF
