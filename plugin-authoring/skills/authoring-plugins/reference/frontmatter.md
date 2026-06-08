# SKILL.md frontmatter

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (matches the slash command, for Piece 3 or a main-agent task) |
| `description` | Yes | What the skill does and when to use it (third-person) |
| `context` | No | `fork` to run the skill body as a task prompt in a subagent (Piece 3 only — never on a main-agent task) |
| `agent` | No | Agent name to route to (requires `context: fork`) |
| `argument-hint` | No | Placeholder shown after `/<name>` in the slash menu; for any slash-invocable skill |
| `disable-model-invocation` | No | `true` for a user-only slash skill — Piece 3, or a main-agent task the user alone should trigger |
| `user-invocable` | No | `false` for Piece 2 — Claude reads it as guidance; user has no slash command |

## The two opt-out fields are not interchangeable

| Field | Effect | Used on |
|-------|--------|---------|
| `disable-model-invocation: true` | User can type `/<name>`; Claude must not auto-call | Piece 3, or a user-only main-agent task |
| `user-invocable: false` | Claude can read/apply; user has no slash command | Piece 2 (educational skill) |

Picking the wrong one is a common error: `disable-model-invocation` keeps the slash command but stops Claude auto-invoking; `user-invocable: false` removes the slash command but lets Claude read the skill as guidance. They are near-opposites, not synonyms.
