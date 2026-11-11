# git-commit-agent

A Claude Code plugin that adds a `commit` subagent and a `/commit` slash command for staging and committing changes with well-formed messages.

## What it does

Provides a specialized subagent that analyzes the current working set, drafts a commit message following best-practice conventions, and creates the commit. Runs in isolated context so the diff inspection and reasoning do not consume main-conversation tokens.

The plugin follows the standard three-piece form:

- **Subagent** (`agents/commit.md`): Sonnet model. Tools: Bash, Glob, Grep, Read. Owns the full commit workflow — inspect changes, design boundaries, compose message, run `git commit`.
- **Educational skill** (`skills/how-to-commit/SKILL.md`): teaches Claude when to delegate to the subagent versus handle the request inline, and how to craft the delegation prompt. Also directs Claude to run the subagent in the foreground, since commits write to shared git state and must not overlap with other agents. Not user-invocable.
- **Slash command** (`skills/commit/SKILL.md`): `/commit [subject hint or scope]` forks into the subagent. With no argument, the subagent runs its default workflow.

## Evals

`evals/` holds a `claude plugin eval` suite of three cases: derive a
`JIRA-<n> <type>:` subject from history and the branch name, keep an untracked
`.env` out of the index, and hold off committing while the user is still
deciding. Each case seeds a git repo with a fixture script and needs Bash,
which the make target grants:

```bash
make eval-git-commit-agent   # from the repo root
```

The graders check the `git add` and `git commit` commands the agent issues,
which carry the staging choice and the full message, rather than the resulting
history: commits land on macOS but the git directory was read-only on Linux.
Behavior that depends on a commit succeeding (splitting into several commits,
the HEAD guard) is not covered. Granting Bash requires `bubblewrap` and `socat`
on Linux. On macOS the suite needs Homebrew git at `/opt/homebrew/bin/git`,
because the Xcode `/usr/bin/git` shim fails inside the eval sandbox.

See [docs/evals.md](../docs/evals.md) for how to read the results and add cases.


## Installation

```bash
claude plugin install git-commit-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
