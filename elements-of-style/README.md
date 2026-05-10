# elements-of-style

A Claude Code plugin that injects writing-style guidance from *The Elements of Style* (Strunk & White) at session start.

## What it does

On `SessionStart`, the plugin's hook reads `hooks/references/writing-style.md` and injects it as `additionalContext`. The guidance covers:

- Active voice and definite assertions
- Positive form over negation ("forgot" not "did not remember")
- Parallel structure for coordinate ideas
- Keeping subject and verb close
- Placing the emphatic word at the sentence end
- A list of cuttable constructions ("the fact that," "in the case of," "very," etc.)

The plugin ships no skills or agents. It is style guidance only.

## Installation

```bash
claude plugin install elements-of-style@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
