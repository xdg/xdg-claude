# todo-planner

A Claude Code plugin that teaches Claude a consistent format for `TODO.md` implementation plans.

## What it does

Ships a single Type 1 (knowledge) skill. When you ask Claude to create or update an
implementation plan, project roadmap, or phased development plan, the skill loads a
format that emphasizes:

- **Phased tasks** with hierarchical sub-phase numbering (`1.1`, `5.6.3`), each sub-phase
  scoped to a single atomic commit.
- **A Testing Philosophy preamble** re-injected for context retention across long projects.
- **A Verification Checklist** of what must pass before a phase is marked complete.
- **A phase-dependency diagram** that surfaces parallelizable work and the critical path.
- **Explicit `**Test**:` tasks** so coverage is never overlooked, plus a deferred
  "Future Phases" section to capture scope creep.

The skill runs in the main conversation so planning stays collaborative — Claude
gathers your stack and build commands and shapes the plan with you, rather than handing
back a finished document.

It pairs naturally with the [adversarial-implementation](../adversarial-implementation/README.md)
plugin, which executes a `TODO.md` produced in this format.

## Installation

```bash
claude plugin install todo-planner@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
