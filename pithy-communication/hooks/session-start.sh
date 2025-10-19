#!/usr/bin/env bash
# SessionStart hook to inject pithy communication style guidance

# Use CLAUDE_PLUGIN_ROOT for correct paths regardless of installation location
CONTENT_FILE="${CLAUDE_PLUGIN_ROOT}/hooks/references/communication-style.md"

# Read the content
if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Error: communication-style.md not found at $CONTENT_FILE" >&2
  exit 1
fi

CONTENT=$(cat "$CONTENT_FILE")

# Return JSON with additionalContext to inject into session
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(jq -Rs . <<< "$CONTENT")
  }
}
EOF
