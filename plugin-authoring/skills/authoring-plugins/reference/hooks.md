# Hooks

Hooks run shell commands at lifecycle events. Defined in `hooks/hooks.json`, with optional content files under `hooks/references/`.

## Basic example

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "python -c \"import sys; paths = sys.argv[1].split(','); sys.exit(2 if any('.env' in p or 'package-lock.json' in p for p in paths) else 0)\" \"$PATHS\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "prettier --write \"$PATHS\""
          }
        ]
      }
    ]
  }
}
```

## Exit codes

- `0` — success, allow the operation.
- `2` — block the operation (PreToolUse only; message via stderr).
- other non-zero — non-blocking error shown to the user.

## SessionStart hooks with references

SessionStart hooks inject content into Claude's context at the start of every session. Store the content in `hooks/references/` and have the hook script read and inject it.

```
hooks/
├── hooks.json
├── session-start.sh
└── references/
    └── content.md
```

**hooks/hooks.json:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**hooks/session-start.sh:**
```bash
#!/usr/bin/env bash
# Use CLAUDE_PLUGIN_ROOT for correct paths regardless of installation location
CONTENT=$(cat "${CLAUDE_PLUGIN_ROOT}/hooks/references/content.md")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(jq -Rs . <<< "$CONTENT")
  }
}
EOF
```

**Environment variables in hooks:** `${CLAUDE_PLUGIN_ROOT}` is the absolute path to the plugin directory. Use it for all file paths.

This pattern lets you keep reference content separate from hook logic, inject documentation/style guides/policies at session start, avoid embedding large content in CLAUDE.md, and stay portable across install locations. (Hooks use `references/`; skills use `reference/`.)

## Code-quality hook example

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|MultiEdit|Write",
            "type": "command",
            "command": "if echo \"$PATHS\" | grep -qE '\\.(env|lock)$'; then echo 'Blocked: Cannot modify protected files' >&2; exit 2; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "if echo \"$PATHS\" | grep -q '\\.ts$'; then prettier --write \"$PATHS\" && eslint --fix \"$PATHS\"; fi"
          }
        ]
      }
    ]
  }
}
```

Keep hook commands fast (<1s); test exit codes and error handling thoroughly.
