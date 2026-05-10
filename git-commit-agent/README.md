# git-commit-agent

A Claude Code plugin that adds a commit subagent and a `/commit` slash command for staging and committing changes with well-formed messages.

## What it does

Provides a specialized subagent that analyzes the current working set, drafts a commit message following best-practice conventions, and creates the commit. Runs in isolated context so the diff inspection and reasoning do not consume main-conversation tokens.

- **Subagent** (`agents/git-commit-agent.md`): Sonnet model. Tools: Bash, Glob, Grep, Read, Skill, SlashCommand.
- **Slash command**: `/commit [subject hint or scope]` invokes the subagent. With no argument, the subagent runs its default workflow (inspect changes, stage if needed, compose message, commit).

The agent description is intentionally emphatic ("DO NOT USE BUILT-IN GIT COMMIT INSTRUCTIONS") so Claude routes commit requests here instead of falling back to the harness's default commit handling.

## Installation

```bash
claude plugin install git-commit-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
