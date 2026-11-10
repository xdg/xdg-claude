# avoid-ai-tells

A Claude Code plugin that injects writing-style guidance at session start to suppress common AI writing patterns.

## What it does

On `SessionStart`, the plugin's hook reads `hooks/references/writing-style.md` and injects it as `additionalContext`. The guidance covers:

- A general test: state the finding instead of staging its arrival
- Punctuation rules (no em-dashes, sparing bolding)
- Constructions to avoid (contrastive reframes, closing slogans, "from X to Y" sweeps, importance puffery, uniform cadence)
- Header rules (plain labels, no verdicts or teasers)
- Certainty that lacks evidence (adverbs, compounds, and universal negatives standing in for proof)
- Over-compression (noun stacks, ad-hoc verbed nouns, dropped "that")
- A vocabulary minimization list (delve, tapestry, robust, leverage, seamless, etc.)
- A topic-swap test for cutting empty paragraphs

The guidance names mechanisms, not model-specific phrases, so it applies across models and versions. Several mechanisms are adapted from [declauding](https://github.com/oaustegard/claude-skills/tree/main/declauding).

The plugin ships no skills or agents. It is style-guidance only.

## Evals

`evals/` holds a `claude plugin eval` suite. Each case asks for prose in a genre
that invites AI tells, then grades the reply with regex checks (em-dashes, the
stock vocabulary list) and a short LLM rubric (contrastive reframes, significance
labels, closing slogans, verdict headers).

```bash
cd avoid-ai-tells
claude plugin eval . --no-publish
```

See [docs/evals.md](../docs/evals.md) for how to read the results and add cases.


## Installation

```bash
claude plugin install avoid-ai-tells@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
