---
name: authoring-plugins
description: How to author Claude Code plugins (agents, skills, commands, hooks, MCP servers) and distribute them via a marketplace. Use when creating, structuring, or revising a plugin, deciding which skill pattern fits, or writing SKILL.md / agent / hook / manifest files.
---

# Authoring Claude Code plugins

A plugin is a Git-packaged collection of skills, agents, commands, hooks, and MCP servers, installed with `/plugin`. This skill is the decision layer; the bulky how-to lives in `reference/`, loaded only for the branch you hit.

## Component types

- **Skills** — user- or model-invoked capabilities. `skills/<name>/SKILL.md` plus optional `scripts/`, `reference/`, `assets/`. Lazily loaded. The default surface for new work.
- **Agents (subagents)** — specialized assistants with isolated context and their own tools. `agents/<name>.md`. Routed to via skill frontmatter (`agent`) or the Agent tool.
- **Commands** (legacy) — `commands/*.md`. Merged into skills as of Claude Code 2.1.3; prefer `skills/`.
- **Hooks** — shell commands at lifecycle events. `hooks/hooks.json` (+ optional `hooks/references/`). Validate, block, or inject context.
- **MCP servers** — external tool/service integrations via `.mcp.json`.

**Critical:** all component directories sit at plugin root, NOT inside `.claude-plugin/`.

```
plugin-name/
├── .claude-plugin/plugin.json   # required manifest
├── skills/<name>/SKILL.md       # + scripts/ reference/ assets/
├── agents/<name>.md
├── hooks/hooks.json             # + references/
└── .mcp.json
```

Skills, agents, and hooks under their standard dirs are auto-discovered — no manifest entry needed.

## Progressive disclosure

Skills load in three levels; this is the whole reason they beat always-on CLAUDE.md content:

1. **Metadata** (always loaded, ~100 words) — `name` + `description`. Enough for Claude to know when to reach for the skill.
2. **SKILL.md body** (loaded on trigger, target <5k words) — procedure and guidance.
3. **Bundled resources** (loaded on demand) — `scripts/` run without entering context, `reference/` read only when needed, `assets/` used in output.

Keep SKILL.md lean; push depth into `reference/`. If a reference exceeds ~10k words, put grep patterns in SKILL.md so Claude can target it.

## The three skill patterns (decide before writing files)

Two axes: is the value Claude *knowing* something or *doing* something, and — for a task — does it run in the **main agent** or a forked **subagent**? Invocation (model-triggered, `/slash`, or both) is a separate frontmatter choice layered on top.

- **Type 1 — Knowledge skill.** Reference content Claude reads and applies for the session: conventions, style guides, tool usage, domain knowledge. One `skills/<name>/SKILL.md`, no fork. Value = Claude knowing something while it works.
- **Type 2 — Main-agent task.** A workflow Claude runs *in the main conversation*, optionally spawning its own subagents. One `skills/<activity>/SKILL.md` whose body is the workflow; no `context: fork`. Use when the loop must stay in the main thread — human-in-the-loop pauses, or orchestration state that belongs in the main context.
- **Type 3 — Subagent task.** An activity Claude delegates to a forked subagent so its file reads and reasoning stay out of the main context. Built from a subagent (Piece 1) + an educational skill (Piece 2), plus an optional user-entry wrapper (Piece 3) for a `/<activity>` command. Use when output would clutter the main context or you want the harness to enforce a restricted toolset.

For the full pattern mechanics — slash commands on tasks, why two entry skills converge on one subagent, the three pieces, invocation paths, anti-patterns, the known `$ARGUMENTS` runtime bug — read `reference/skill-patterns.md`.

## Reference map

Load the file that matches your task:

- `reference/skill-patterns.md` — the three patterns in depth: slash-on-task, the convergence argument, Piece 1/2/3, `how-to-<activity>` description openers, invocation paths, UI rendering, anti-patterns, known runtime bug, writing guidelines.
- `reference/frontmatter.md` — SKILL.md frontmatter field table and the two opt-out fields (`disable-model-invocation` vs `user-invocable`).
- `reference/agents.md` — agent file structure, voice/tone, the tool-permission catalog, output specs, when-to-ask, naming conventions.
- `reference/hooks.md` — `hooks.json` shape, exit codes, the SessionStart-with-references pattern, `${CLAUDE_PLUGIN_ROOT}`.
- `reference/manifest-and-distribution.md` — `plugin.json` schema, `marketplace.json`, best-practices checklists (design, agents, skills, security, workflow).
- `reference/examples.md` — four complete worked plugins: `/commit` (Type 3, all pieces), `/adversarial-implementation` (Type 2), security-audit (Type 1), a code-quality hook.

## Authoring workflow

1. Classify the activity into a pattern (above) before creating any files.
2. Scaffold: `plugin.json` (see `reference/manifest-and-distribution.md`), then the component dirs.
3. Write the skill / agent / hook per the relevant reference file.
4. For distribution, register in `marketplace.json` and the README plugin table.

## Resources

- Plugins: https://docs.claude.com/en/docs/claude-code/plugins
- Skills: https://docs.claude.com/en/docs/claude-code/skills
- Marketplaces: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- Examples: https://github.com/anthropics/claude-code
