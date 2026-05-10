# prioritize-skills

A Claude Code plugin that injects a directive at session start (and on subagent dispatch) requiring Claude to check for and invoke applicable skills before responding or acting.

## What it does

On `SessionStart` and `SubagentStart`, the plugin's hook reads `hooks/references/prioritize-skills.md` and injects it as `additionalContext`. The directive establishes:

- A "1% rule": if any installed skill might apply, invoke it via the `Skill` tool first.
- An instruction-priority ladder (user instructions > skills > default system prompt).
- A workflow: check skills, announce, follow the skill, then respond.
- A red-flag table of common rationalizations for skipping skill invocation.
- A process-skills-before-implementation-skills ordering.

The plugin ships no skills of its own. It is the prioritization layer; install whatever skills you actually want alongside it.

## Installation

This plugin is part of the `xdg-claude` marketplace. Install via `/plugin`.

## Files

- `.claude-plugin/plugin.json` -- manifest.
- `hooks/hooks.json` -- registers the hook for `SessionStart` and `SubagentStart`.
- `hooks/inject-priority.sh` -- emits the directive as `hookSpecificOutput.additionalContext`. Strips YAML frontmatter from the reference file before injection.
- `hooks/references/prioritize-skills.md` -- the directive text.

`SubagentStart` is Claude Code-specific; on platforms that lack the event the hook is harmless and only the session-level injection fires.

## Credits

The directive in `hooks/references/prioritize-skills.md` is adapted from [obra/superpowers](https://github.com/obra/superpowers), specifically `skills/using-superpowers/SKILL.md`. Superpowers is MIT-licensed. Modifications: removed superpowers-specific branding, dropped the `<SUBAGENT-STOP>` clause (this plugin intentionally primes subagents too), and adjusted phrasing to be platform-neutral.
