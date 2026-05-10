# refactoring-agent

A Claude Code plugin that adds two refactoring subagents and matching slash commands: one to recommend refactorings, one to carry them out.

## What it does

Splits refactoring work into a planning step and an execution step so analysis and changes don't get tangled. Each subagent follows the standard three-piece form (subagent + educational skill + slash command).

### `plan-refactor` — analysis

- **Subagent** (`agents/plan-refactor.md`): Opus model. Tools: Read, Grep, Glob, Bash, AskUserQuestion, Skill. Scans for code smells and returns prioritized recommendations under a strict 400-word budget. No code changes.
- **Educational skill** (`skills/how-to-plan-refactor/SKILL.md`): teaches Claude when to delegate vs. handle inline and how to craft the prompt. Not user-invocable.
- **Slash command** (`skills/plan-refactor/SKILL.md`): `/plan-refactor [scope]` forks into the subagent.

### `refactor` — execution

- **Subagent** (`agents/refactor.md`): Sonnet model. Tools: Read, Edit, Write, Grep, Glob, Bash, NotebookEdit, Skill. Executes one specific refactoring surgically; verifies behavior via tests; stops after one atomic change.
- **Educational skill** (`skills/how-to-refactor/SKILL.md`): teaches Claude when to delegate vs. handle inline and how to craft the prompt. Not user-invocable.
- **Slash command** (`skills/refactor/SKILL.md`): `/refactor <what to refactor>` forks into the subagent.

The split matches a common workflow: ask `/plan-refactor` what's worth doing, pick one item, hand it to `/refactor`.

## Installation

```bash
claude plugin install refactoring-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
