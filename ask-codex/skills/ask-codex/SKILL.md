---
name: ask-codex
description: Consult OpenAI Codex (headless `codex exec`) for an independent review of a design doc, spec, plan, PRD, decision, diff, or piece of code, then reconcile its findings with your own view. Use ONLY when the user explicitly names codex (e.g. "ask codex", "what would codex say", "have codex review this"). 
---

# Ask Codex

Ask a different model to critique an artifact, then report where it and you
agree, disagree, and what changed your mind. The value is independence: codex
has none of this conversation's context, so it catches assumptions you and the
user share without noticing.

This skill handles the codex invocation details (closed stdin, read-only
sandbox, timeout) that otherwise hang or misbehave.

Do NOT use for generic requests for a second opinion, outside review, sanity
check, or another model; handle those yourself or ask which reviewer they
want.

## Invocation

Always go through the bundled script; never call `codex exec` directly.

```bash
scripts/ask-codex.sh [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE
```

(`scripts/` is relative to this skill's directory.)

The script exists because headless codex has sharp edges:

- **`codex exec` reads stdin until EOF whenever stdin is not a TTY.** From an
  agent's Bash tool that means it blocks forever. The script redirects
  `</dev/null`; codex prints "Reading additional input from stdin...", sees
  EOF, and proceeds.
- **stdout mixes the answer with a banner** (version, workdir, model). The
  script uses `-o FILE` to capture only the final message and discards the
  rest; stderr is shown only on failure.
- **Codex can run shell commands.** The script pins `-s read-only` so a
  reviewer can read the repo but cannot modify it, and `--ephemeral` so no
  session file is left behind.
- **No `timeout` on macOS.** The script bounds the run with `perl alarm`
  (default 600s). Set the Bash tool's own timeout at least as high.

Write the prompt to a file in the scratchpad directory and pass the path.
A long prompt on the command line is fragile (quoting, ARG_MAX).

`-C DIR` sets codex's working root; default is the current directory. Codex
resolves relative paths in the prompt against it and can read any file
under it, so point it at the repo root when the artifact references
other files.

`-m MODEL` and `-e EFFORT` (reasoning effort, e.g. `low`, `medium`,
`high`) override the user's codex config (`~/.codex/config.toml`). Omit
both unless the user asks for a specific model or effort; their configured
defaults are deliberate.

## Writing the prompt

Codex starts cold. The prompt is the whole briefing. Include:

1. **Role and stance.** "You are an independent reviewer. Be direct and
   specific; do not soften findings. Skip praise." Without this codex tends
   toward balanced summaries that add nothing.
2. **The artifact.** Either the repo-relative path(s) to read, or the text
   inline for content that is not on disk (a plan from the conversation, a
   proposed API). For a diff: `git diff ... > scratch/change.diff` and name
   that file. For code, name the files and the entry points; do not make it
   guess where to look.
3. **Enough context to judge.** The goal the artifact serves, the constraints
   that are fixed (language, stack, invariants), and what decisions are
   already made and out of scope. Two or three sentences usually suffice;
   point to a doc (`docs/PRD.md`) rather than paraphrasing a long one.
4. **The specific questions.** Generic "review this" gets generic output.
   Ask what you actually are unsure about, and for the artifact type:
   - Design doc / spec: missing requirements, internal contradictions,
     unstated assumptions, simpler alternatives, failure modes at scale,
     what will be hard to change later.
   - Plan: wrong ordering, hidden dependencies, steps that will be much
     bigger than they look, missing verification.
   - Code / diff: correctness bugs, edge cases, concurrency, security,
     whether the change matches the stated intent, tests that are missing.
5. **Output shape.** Ask for a ranked list of findings, each with severity,
   location (file:line or section heading), the problem, and a concrete
   suggestion. Ask it to state confidence and to separate "this is wrong"
   from "I would do it differently". Cap the count (e.g. top 10) so it
   ranks instead of pads.

Example prompt file:

```
You are an independent reviewer giving a second opinion. Be direct and
specific. Skip praise and summary; only report problems and alternatives.

Artifact: docs/milestones/05-usage/design.md (read it). Context: docs/PRD.md
sections FR-9 and FR-10 state the requirements. Fixed constraints: Go
backend, MongoDB, single container; per-user visibility is enforced in the
API layer, never in the database. Decided and out of scope: the choice to
store usage records outside the deleteAccountData cascade.

Questions:
1. Does the aggregation design bound memory as the collection grows?
2. Are there race conditions between the background job and live writes?
3. What is the simplest design that meets FR-9 and FR-10, if not this one?

Output: up to 8 findings ranked by severity. For each: severity, section,
problem, concrete suggestion, confidence (high/med/low). Mark each as
"defect" or "preference".
```

## Before running

Tell the user you are about to consult codex and what you will ask; a
one-line summary is enough. Do not paste the whole prompt unless they ask.
Runs take one to several minutes and consume their OpenAI quota.

## Reporting back

Do not relay codex's output verbatim. You are the one with the conversation
context, so reconcile:

- **Agree:** findings you think are right, especially ones you missed. Say
  what you would change as a result.
- **Disagree:** findings that are wrong or moot given context codex lacked,
  with the reason. Codex reading cold will often flag decisions the user
  already made deliberately; do not let those masquerade as new problems.
- **Uncertain:** findings you cannot settle, framed as questions for the
  user.

Keep codex's severities and locations so the user can trace each item. If
the user wants the raw output, the script printed it to stdout; save it to
the scratchpad first when the run is long so you can quote it later.

## Failure modes

- Script exits nonzero with stderr shown: usually auth (`codex login`),
  a model name codex does not know, or the timeout. Report the stderr tail;
  do not retry blindly.
- Answer is a summary with no findings: the prompt lacked specific
  questions or the "skip praise" stance. Tighten and rerun once.
- Codex asks a clarifying question instead of answering: there is no one
  to answer it. Fold the answer into the prompt and rerun.
