# code-review-agent

A Claude Code plugin that adds a `code-review` subagent and a `/code-review` slash command.

## What it does

Provides a specialized subagent that reviews code for correctness, security, performance, and maintainability. Review runs in isolated context — diff reading and reasoning stay in the fork, only the report comes back to the main conversation.

The plugin follows the standard three-piece form:

- **Subagent** (`agents/code-review.md`): Opus model. Tools: Bash, Glob, Grep, Read, Skill. Reviews the working set against the merge base by default, or a user-specified scope.
- **Educational skill** (`skills/how-to-code-review/SKILL.md`): teaches Claude when to delegate to the subagent versus handle the request inline, and how to craft the delegation prompt. Not user-invocable.
- **Slash command** (`skills/code-review/SKILL.md`): `/code-review [scope]` forks into the subagent. With no argument, reviews the working tree against the merge base with the main branch.

## Installation

```bash
claude plugin install code-review-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
