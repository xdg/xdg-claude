# avoid-ai-tells

A Claude Code plugin that injects writing-style guidance at session start to suppress common AI writing patterns.

## What it does

On `SessionStart`, the plugin's hook reads `hooks/references/writing-style.md` and injects it as `additionalContext`. The guidance covers:

- Punctuation rules (no em-dashes, sparing bolding)
- Constructions to avoid (antithetical reframes, "from X to Y" sweeps, importance puffery, uniform cadence)
- A vocabulary minimization list (delve, tapestry, robust, leverage, seamless, etc.)
- A topic-swap test for cutting empty paragraphs

The plugin ships no skills or agents. It is style-guidance only.

## Installation

```bash
claude plugin install avoid-ai-tells@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
