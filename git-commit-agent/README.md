# git-commit-agent

A Claude Code plugin that adds a `commit` subagent and a `/commit` slash command for staging and committing changes with well-formed messages.

## What it does

Provides a specialized subagent that analyzes the current working set, drafts a commit message following best-practice conventions, and creates the commit. Runs in isolated context so the diff inspection and reasoning do not consume main-conversation tokens.

The plugin follows the standard three-piece form:

- **Subagent** (`agents/commit.md`): Sonnet model. Tools: Bash, Glob, Grep, Read, Skill. Owns the full commit workflow — inspect changes, design boundaries, compose message, run `git commit`.
- **Educational skill** (`skills/how-to-commit/SKILL.md`): teaches Claude when to delegate to the subagent versus handle the request inline, and how to craft the delegation prompt. Not user-invocable.
- **Slash command** (`skills/commit/SKILL.md`): `/commit [subject hint or scope]` forks into the subagent. With no argument, the subagent runs its default workflow.

## Installation

```bash
claude plugin install git-commit-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
