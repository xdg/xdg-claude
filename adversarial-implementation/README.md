# adversarial-implementation

A Claude Code plugin that executes a `TODO.md` plan one checkbox at a time, with
adversarial verification at every step.

## What it does

Ships a single skill exposed as the `/adversarial-implementation` slash command. It
drives a seven-phase loop over the next incomplete subsection of your `TODO.md`:

1. **Plan** — categorize each checkbox as automatable or human-required.
2. **Implement** — spawn an isolated subagent per automatable checkbox, with minimal context.
3. **Verify** — fresh, independent subagents run lint, tests, an acceptance-criteria review,
   and a code-smell review (faked tests, hardcoded returns, scope creep, stray TODOs).
4. **Iterate** — on failure, spawn a *new* subagent with stricter constraints; max 3 tries,
   then escalate.
5. **Code review** — a review subagent passes over the full diff; fixes loop until tests pass.
6. **Human verification** — prompt you to confirm any manual checkboxes before proceeding.
7. **Commit** — commit the subsection only once every checkbox is checked, then continue.

The orchestration loop runs in the main conversation so human-in-the-loop checks and
escalations stay interactive; the heavy work is isolated in the subagents it spawns.

It composes with sibling plugins when installed — [isolated-task-agent](../isolated-task-agent/README.md)
for implementation, [code-review-agent](../code-review-agent/README.md) for review, and
[git-commit-agent](../git-commit-agent/README.md) for commits — and falls back to general
subagents when they are absent.

## Usage

```
/adversarial-implementation
```

Run with no argument to take the next incomplete subsection of `TODO.md`, or pass a
specific task. The skill is user-invoked only — Claude will not launch this autonomous
loop on its own.

Pairs with the [todo-planner](../todo-planner/README.md) plugin, which produces plans in
the expected format.

## Installation

```bash
claude plugin install adversarial-implementation@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
