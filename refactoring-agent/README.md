# refactoring-agent

A Claude Code plugin that adds two refactoring subagents and matching slash commands: one to recommend refactorings, one to carry them out.

## What it does

Splits refactoring work into a planning step and an execution step so analysis and changes don't get tangled.

- **Subagent** `plan-refactor` (`agents/refactor-planning-agent.md`): Opus model. Tools: Read, Grep, Glob, Bash, AskUserQuestion, Skill, SlashCommand. Analyzes code and returns prioritized recommendations -- no code changes.
- **Subagent** `refactor` (`agents/refactoring-agent.md`): Sonnet model. Tools: Read, Edit, Write, Grep, Glob, Bash, NotebookEdit, Skill, SlashCommand. Executes one specific refactoring surgically. Requires the user to specify what to refactor.
- **Slash commands**: `/plan-refactor [scope]` for analysis, `/refactor <what to refactor>` for execution.

The split matches a common workflow: ask `/plan-refactor` what's worth doing, pick one item, hand it to `/refactor`.

## Installation

```bash
claude plugin install refactoring-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
