---
name: ask-opencode
description: Consult a model through opencode (headless `opencode run`) for an independent review of a design doc, spec, plan, PRD, decision, diff, or piece of code, then reconcile its findings with your own view. Handles picking the model when the user names one ("ask opencode Astra ...", "have opencode kimi review this"). Use ONLY when the user explicitly names opencode.
---

# Ask Opencode

Ask a different model, reached through opencode, to critique an artifact,
then report where it and you agree, disagree, and what changed your mind.
The value is independence: the reviewer has none of this conversation's
context, so it catches assumptions you and the user share without noticing.

This skill handles the opencode invocation details (read-only agent,
model resolution, timeout, session cleanup) that otherwise misbehave.

Do NOT use for generic requests for a second opinion, outside review, sanity
check, or another model; handle those yourself or ask which reviewer they
want. "Ask codex" belongs to the ask-codex skill.

## Invocation

Always go through the bundled script; never call `opencode run` directly.

```bash
scripts/ask-opencode.sh [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE
scripts/ask-opencode.sh -r MODEL      # resolve a model name only; no run
```

(`scripts/` is relative to this skill's directory.)

The script exists because headless opencode has sharp edges:

- **The default agent can edit files and run shell commands.** The built-in
  `plan` agent denies edits but still allows shell. The script injects its
  own agent through `OPENCODE_CONFIG_CONTENT` that allows only read, grep,
  glob, and list inside the working directory, denies reading `.env`
  files, and denies the `question` tool (nobody can answer it headless).
  opencode checks grep permission against the search pattern rather than
  the file, so grep can still return `.env` contents. The script prepends
  an instruction to every prompt telling the reviewer to keep `.env` and
  credential files out of its searches; that is a request, not
  enforcement. Do not point `-C` at a directory where a leaked secret
  would be serious without telling the user. This needs
  `--standalone`, because the background service never sees a per-process
  environment variable.
- **Every run is saved as a session.** The script deletes the session
  afterward.
- **Output is a JSON event stream** mixing narration, tool calls, and the
  answer. The script prints only the text of the final step. Any error
  event counts as failure: it exits nonzero and prints opencode's error
  message (e.g. "Variant unavailable ...") with any partial text.
- **No `timeout` on macOS.** The script bounds the run with `perl alarm`
  (default 600s). Set the Bash tool's own timeout at least as high.

Write the prompt to a file in the scratchpad directory and pass the path.
A long prompt on the command line is fragile (quoting, ARG_MAX).

`-C DIR` sets the working root; default is the current directory. The
reviewer resolves relative paths against it and cannot read outside it, so
point it at the repo root when the artifact references other files.

## Choosing the model

Opencode takes `--model provider/model#variant`. Bare names like `astra`
are rejected, so the script resolves short names against `opencode models`:

1. A value containing `/` passes through unchanged.
2. Otherwise it lowercases the name, turns spaces into `-`, and looks for
   a model whose last path segment equals it, then for IDs containing it.
   Exactly one hit wins.
3. Zero or several hits exit 3 with the candidate list.

Map what the user said to `-m`:

- **A model name in the request** ("ask opencode Astra ...", "opencode
  with GLM", "have opencode opus look"): pass the name as `-m`
  (`-m astra`, `-m "gpt 6 luna"`). Strip filler words like "the" or
  "model". If the user names a family and a version ("Sol 6.1"), pass the
  part most likely to be unique (`-m 6.1-sol`) or resolve first with `-r`.
- **No model named:** omit `-m`. The user's opencode default is deliberate.
- **Ambiguous (exit 3):** pick from the candidates only when one is
  clearly what the user meant:
  - Prefer the highest version when the user gave none (`gpt-6.1-sol`
    over `gpt-5.6-sol`).
  - Prefer `ai-gateway-*` providers over direct `fireworks-ai/...` entries
    for the same model.
  - Prefer plain model entries over `-priority`, `-spot`, `-fast`, and
    `routers/...` variants unless the user asked for one.

  If more than one candidate survives those rules (e.g. "kimi" covers both
  `kimi-k3` and `kimi-k2.7-code`), ask the user, listing the survivors.
  Then rerun with the full ID.
- **No match:** say so and show the closest entries from `opencode models`
  (e.g. `opencode models | rg -i <fragment>`); do not guess.

Always tell the user the full model ID you used, especially when you
picked it from candidates.

`-e EFFORT` sets the variant suffix (`#low`, `#medium`, `#high`, `#xhigh`,
`#max` on models that support reasoning effort). Use it only when the user
asks for an effort level ("ask opencode astra on max"); a `#variant`
already in `-m` wins. An unsupported variant fails with "Variant
unavailable"; report it rather than retrying with a different one.

## Writing the prompt

The reviewer starts cold. The prompt is the whole briefing. Include:

1. **Role and stance.** "You are an independent reviewer. Be direct and
   specific; do not soften findings. Skip praise." Without this, models
   tend toward balanced summaries that add nothing.
2. **The artifact.** Either the repo-relative path(s) to read, or the text
   inline for content that is not on disk (a plan from the conversation, a
   proposed API). For a diff: `git diff ... > scratch/change.diff` and name
   that file, which must sit under `-C DIR`. For code, name the files and
   the entry points; do not make it guess where to look.
3. **Enough context to judge.** The goal the artifact serves, the fixed
   constraints (language, stack, invariants), and the decisions already
   made and out of scope. Two or three sentences usually suffice; point to
   a doc (`docs/PRD.md`) rather than paraphrasing a long one.
4. **The specific questions.** Generic "review this" gets generic output.
   Ask what you are actually unsure about, and for the artifact type:
   - Design doc / spec / PRD: missing requirements, internal
     contradictions, unstated assumptions, simpler alternatives, failure
     modes at scale, what will be hard to change later. Also ask whether
     someone who knows the document above it, but not the code, could
     follow each decision and judge it right or wrong, and whether its
     claims about the existing code are true (run with `-C` on the repo).
   - Plan: wrong ordering, hidden dependencies, steps that will be much
     bigger than they look, missing verification, claims about existing
     code that the code contradicts.
   - Code / diff: correctness bugs, edge cases, concurrency, security,
     whether the change matches the stated intent, tests that are missing.
5. **Output shape.** Ask for a ranked list of findings, each with severity,
   location (file:line or section heading), the problem, and a concrete
   suggestion. Ask it to state confidence and to separate "this is wrong"
   from "I would do it differently". Cap the count (e.g. top 10) so it
   ranks instead of pads.

Tell it that it can only list, glob, grep, and read files (no
commands), so it does not spend steps trying. The script already adds
the `.env` instruction; do not repeat it.

## Before running

Tell the user you are about to consult opencode, which model, and what you
will ask; a one-line summary is enough. Runs take seconds to several
minutes and bill the user's provider accounts.

## Reporting back

Do not relay the output verbatim. You have the conversation context, so
reconcile:

- **Agree:** findings you think are right, especially ones you missed. Say
  what you would change as a result.
- **Disagree:** findings that are wrong or moot given context the reviewer
  lacked, with the reason. A cold reader often flags decisions the user
  already made deliberately; do not present those as new problems.
- **Uncertain:** findings you cannot settle, framed as questions for the
  user.

Name the model, and keep its severities and locations so the user can trace
each item. If the user wants the raw output, the script printed it to
stdout; save it to the scratchpad first when the run is long so you can
quote it later.

## Failure modes

- **Exit 3:** model name did not resolve; see "Choosing the model".
- **Exit 142 / "timed out":** raise `-t` or narrow the prompt.
- **Other nonzero exit:** usually auth (`opencode auth`), an unavailable
  variant, or a provider outage. Report the error line; do not retry
  blindly.
- **Answer reports "Permission denied: external_directory":** the
  artifact lives outside `-C DIR`. Rerun with a wider `-C` or copy the
  file under it.
- **Answer is a summary with no findings:** the prompt lacked specific
  questions or the "skip praise" stance. Tighten and rerun once.
- **Reviewer asks a clarifying question instead of answering:** there is
  no one to answer it. Fold the answer into the prompt and rerun.
