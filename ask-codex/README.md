# ask-codex

A Claude Code plugin that gets a second opinion from OpenAI Codex on a design
doc, spec, plan, PRD, decision, diff, or piece of code.

## What it does

Ships a single skill that Claude uses only when you name codex ("ask codex",
"have codex review this"). Claude writes a self-contained review prompt, runs
`codex exec` headlessly, and reports back in three groups: findings it agrees
with, findings it rejects (usually decisions you already made that codex,
reading cold, could not know about), and open questions for you. It does not
relay codex's output verbatim.

Codex sees none of the conversation, so it catches assumptions you and Claude
share without noticing.

### The wrapper script

The skill always runs codex through `scripts/ask-codex.sh`, which handles the
sharp edges of headless codex from an agent:

- Closes stdin (`</dev/null`). `codex exec` otherwise blocks forever reading a
  non-TTY stdin.
- Runs with `-s read-only` and `--ephemeral`: codex can read the repo but not
  modify it, and leaves no session file.
- Bounds the run with a timeout via `perl alarm` (default 600s; macOS has no
  `timeout`).
- Prints only codex's final answer; the banner and stderr appear only on
  failure.

```
scripts/ask-codex.sh [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE
```

`-m` and `-e` override your `~/.codex/config.toml`; Claude omits them unless
you ask for a specific model or reasoning effort.

Runs take one to several minutes and use your OpenAI quota. Claude tells you
what it is about to ask before each run.

It runs in the main conversation. Invoke it directly with `/ask-codex` when
Claude does not offer.

## Requirements

- The [`codex` CLI](https://github.com/openai/codex) on `PATH`, logged in
  (`codex login`).
- `perl` (preinstalled on macOS and most Linux distributions).

## Installation

```bash
claude plugin install ask-codex@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
