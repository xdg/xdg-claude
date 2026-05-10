# isolated-task-agent

A Claude Code plugin that adds a general-purpose isolated-execution subagent and an `/isolated` slash command.

## What it does

Provides a subagent that executes a focused task in a clean, forked context and returns a concise writeup. Use it to keep exploratory analysis, parallel work streams, experimental operations, and context-heavy investigations out of the main conversation history.

- **Subagent** (`agents/isolated-task-agent.md`): inherits the parent model. Tools: Bash, Glob, Grep, Read, Edit, Write, NotebookEdit, Skill, SlashCommand.
- **Slash command**: `/isolated <task description>` forks into the subagent with the task as its first user turn.

Unlike the topic-specific agents in this marketplace (code-review, commit, refactor), this one is deliberately general -- the value is the context isolation, not domain expertise.

## Why not just use the built-in `general-purpose` agent?

Claude Code ships a `general-purpose` subagent for the same broad use case. The system prompt is short -- a paragraph on strengths, a handful of search guidelines, two file-creation guardrails -- and it inherits the full toolset (`*`), including `Task` (nested delegation), `WebFetch`, and `WebSearch`. That's appropriate for one-off "go find this for me" calls. It's less appropriate when you want to forward arbitrary work into a forked context and trust what comes back.

This subagent tightens the contract along four axes:

- **Prescribed reporting shape.** The system prompt mandates a Key Findings / Recommendations / Blockers structure, caps the writeup at 2-5 paragraphs, and lists what NOT to include (working process, full file contents, unlabeled speculation). The general-purpose prompt asks for "a concise report" and leaves the rest to vibes -- in practice, return size and shape vary widely.
- **Anti-speculation rules.** Findings must be supported with specific evidence (file names, line numbers, error messages); facts, inferences, and uncertainties must be labeled distinctly; "never speculate" is explicit. The general-purpose prompt has no equivalent guardrail, so plausible-sounding fabrications can flow back to the parent unflagged.
- **Side-effect discipline.** Explicit instructions to clean up temporary artifacts and to avoid permanent changes unless instructed. The general-purpose prompt only addresses file/doc creation.
- **Narrower toolset.** No `Task` (no surprise nested delegation that re-pollutes the parent's token budget by way of grandchildren), no `WebFetch`/`WebSearch` (no off-machine calls unless the user opts in by switching agents). Tools are: `Bash`, `Glob`, `Grep`, `Read`, `Edit`, `Write`, `NotebookEdit`, `Skill`, `SlashCommand`.

The net effect: forking into this subagent gives you predictable return-context size, a lower fabrication rate, and tighter blast radius. Reach for `general-purpose` when you want maximum flexibility; reach for `/isolated` when you want a contract.

## Installation

```bash
claude plugin install isolated-task-agent@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
