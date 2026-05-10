# code-review-agent

A Claude Code plugin that adds a code-review subagent and a `/code-review` slash command.

## What it does

Provides a specialized subagent that reviews code for correctness, security, performance, and maintainability. The user-entry skill forks into the subagent so the review runs in isolated context and only the report comes back to the main conversation.

- **Subagent** (`agents/code-review-agent.md`): Opus model. Tools: Bash, Glob, Grep, Read, Skill. Reviews the working set or a user-specified scope.
- **Slash command**: `/code-review [scope]` invokes the subagent. With no argument, reviews the current working tree against the merge base.

## Installation

```bash
claude plugin install code-review-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
