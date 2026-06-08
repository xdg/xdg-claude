# plugin-authoring

A Claude Code plugin that teaches Claude how to author and distribute Claude Code plugins.

## What it does

Ships a single Type 1 (knowledge) skill, `authoring-plugins`. When you create, structure, or
revise a plugin — or need to decide which skill pattern fits — the skill loads a compact
decision layer in SKILL.md and fans out to `reference/` files for depth:

- **`skill-patterns.md`** — the three skill patterns (knowledge / main-agent task / subagent
  task), slash commands on tasks, the two-entry-skills convergence, Piece 1/2/3, invocation
  paths, anti-patterns, and the known `$ARGUMENTS` runtime bug.
- **`frontmatter.md`** — the SKILL.md frontmatter field table and the `disable-model-invocation`
  vs `user-invocable` distinction.
- **`agents.md`** — agent file structure, voice, the tool-permission catalog, output specs,
  naming conventions.
- **`hooks.md`** — `hooks.json`, exit codes, the SessionStart-with-references pattern.
- **`manifest-and-distribution.md`** — `plugin.json` and `marketplace.json` schemas plus
  best-practice checklists.
- **`examples.md`** — four complete worked plugins, one per pattern plus a hook.

This content previously lived in the repo's top-level `CLAUDE.md`, where it loaded into every
session regardless of relevance. As a lazily-loaded skill it costs ~100 metadata tokens until
you actually author a plugin, then arrives in task-relevant slices — the progressive-disclosure
discipline the skill itself documents.

## Installation

```bash
claude plugin install plugin-authoring@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
