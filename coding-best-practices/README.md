# coding-best-practices

A Claude Code plugin that injects coding guidelines at session start and on subagent dispatch.

## What it does

On `SessionStart` and `SubagentStart`, the plugin's hook reads `hooks/references/coding-guidelines.md` and injects it as `additionalContext`. The guidance distills:

- *Philosophy of Software Design* (Ousterhout): deep modules, information hiding, pulling complexity downward, defining errors out of existence.
- *The Art of Readable Code* (Boswell & Foucher): naming, comments, control flow, breaking down problems.
- A dependency-selection framework (when to add a dep vs. write the code).
- Test-isolation principles (hermetic tests, dynamic identifiers, no host-config pollution).

The plugin ships no skills or agents. It is guideline injection only.

## Installation

```bash
claude plugin install coding-best-practices@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
