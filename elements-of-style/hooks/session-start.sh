#!/usr/bin/env bash
# SessionStart hook to inject Elements of Style writing guidance

# Read the writing style content from hooks/references/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_FILE="$SCRIPT_DIR/references/writing-style.md"

# Read the content
if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Error: writing-style.md not found at $CONTENT_FILE" >&2
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
