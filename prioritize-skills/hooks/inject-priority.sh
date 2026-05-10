#!/usr/bin/env bash
# SessionStart / SubagentStart hook: inject directive prioritizing Skill use.

CONTENT_FILE="${CLAUDE_PLUGIN_ROOT}/hooks/references/prioritize-skills.md"

if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Error: prioritize-skills.md not found at $CONTENT_FILE" >&2
  exit 1
fi

# Strip leading YAML frontmatter (used for source attribution) before injection.
CONTENT=$(awk '
  NR==1 && /^---$/ { in_fm=1; next }
  in_fm && /^---$/ { in_fm=0; next }
  !in_fm { print }
' "$CONTENT_FILE")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(jq -Rs . <<< "$CONTENT")
  }
}
EOF
