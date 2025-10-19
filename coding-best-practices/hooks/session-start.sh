#!/usr/bin/env bash
# SessionStart hook to inject coding best practices guidance

# Use CLAUDE_PLUGIN_ROOT for correct paths regardless of installation location
CONTENT_FILE="${CLAUDE_PLUGIN_ROOT}/hooks/references/coding-guidelines.md"

# Read the content
if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Error: coding-guidelines.md not found at $CONTENT_FILE" >&2
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
