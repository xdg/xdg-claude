#!/usr/bin/env bash
# SessionStart hook to inject AI-tells avoidance writing style guidance

CONTENT_FILE="${CLAUDE_PLUGIN_ROOT}/hooks/references/writing-style.md"

if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Error: writing-style.md not found at $CONTENT_FILE" >&2
  exit 1
fi

CONTENT=$(cat "$CONTENT_FILE")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(jq -Rs . <<< "$CONTENT")
  }
}
EOF
