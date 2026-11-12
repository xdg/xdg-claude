# ask-opencode

A Claude Code plugin that gets a second opinion on a design doc, spec, plan,
PRD, decision, diff, or piece of code from any model you have configured in
[opencode](https://opencode.ai).

## What it does

Ships a single skill that Claude uses only when you name opencode ("ask
opencode Astra to review this", "have opencode kimi check the plan"). Claude
writes a self-contained review prompt, runs `opencode run` headlessly with
the model you named, and reports back in three groups: findings it agrees
with, findings it rejects (usually decisions you already made that the
reviewer, reading cold, could not know about), and open questions for you.
It does not relay the output verbatim.

The reviewer sees none of the conversation, so it catches assumptions you and
Claude share without noticing.

### Model selection

`opencode run` needs a full `provider/model#variant` ID. The script resolves
short names against `opencode models`: `astra` becomes
`ai-gateway-openai/gpt-6-astra`, `"gpt 6 luna"` becomes
`ai-gateway-openai/gpt-6-luna`. When a name matches several models ("sol",
"kimi"), the script lists them; Claude picks the newest version on your
gateway provider when that is unambiguous and asks you otherwise. It always
tells you the full ID it used. With no model named, your opencode default
applies.

Ask for an effort level ("on max", "with high reasoning") and Claude adds the
`#variant` suffix.

### The wrapper script

The skill always runs opencode through `scripts/ask-opencode.sh`, which:

- Injects a read-only agent (read, grep, glob, list; no edits, shell, or
  web) through `OPENCODE_CONFIG_CONTENT` with `--standalone`. Your opencode
  config files are not touched. Reading `.env` files is denied, but opencode
  checks grep permission against the search pattern, not the file, so grep
  can still return `.env` contents. The script prepends an instruction
  telling the reviewer to keep `.env` and credential files out of its
  searches. That reduces the risk; it does not enforce anything.
- Bounds the run with a timeout via `perl alarm` (default 600s; macOS has no
  `timeout`).
- Prints only the final answer from the JSON event stream. Any error event is
  a failure: nonzero exit, opencode's error message, and any partial text.
- Deletes the session afterward (bounded at 30s, warning on failure) so runs
  do not pile up in `opencode session list`.

```
scripts/ask-opencode.sh [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE
scripts/ask-opencode.sh -r MODEL      # print the resolved model ID only
```

The skill runs in the main conversation. Invoke it directly with
`/ask-opencode` when Claude does not offer.

## Requirements

- The `opencode` CLI on `PATH` with at least one provider authenticated
  (`opencode auth`). Tested with opencode v2.2.5.
- `perl` with `JSON::PP` (core since Perl 5.14; preinstalled on macOS and
  most Linux distributions).

## Installation

```bash
claude plugin install ask-opencode@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
