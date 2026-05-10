# pithy-communication

A Claude Code plugin that injects communication-style guidance at session start, optimizing for high signal-to-noise output.

## What it does

On `SessionStart`, the plugin's hook reads `hooks/references/communication-style.md` and injects it as `additionalContext`. The guidance establishes:

- A "detailed but pithy" core directive: maximize signal-to-noise, dense information, minimal filler.
- Senior-colleague tone with radical candor: state disagreements plainly, skip validation filler.
- When to include risks/counterpoints (specific failure modes, edge cases) versus generic hedging.
- Clarifying-question discipline: ask when the answer would materially change approach; otherwise proceed on a reasonable interpretation.

The plugin ships no skills or agents. It is style guidance only.

## Installation

```bash
claude plugin install pithy-communication@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
