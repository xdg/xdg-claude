---
name: decision-log
description: Record a durable engineering decision in the repo's append-only decision log (docs/decisions.md by default). Use after choosing between real alternatives — a dependency, a version pin, an architecture or protocol choice, a deliberate non-implementation, or a reversal of an earlier decision. Also use when the user says "log that decision", "write this down", or asks what was decided and why.
---

# Decision log

An append-only log of choices with teeth: what was decided, when, and why the
alternatives lost. It exists so a future reader — the user, a contributor, or a
later session — does not relitigate a settled question or silently undo it.

## What earns an entry

Log a decision when **all** of these hold:

- Real alternatives existed and one was chosen.
- The choice constrains future work, or a future reader would otherwise be
  tempted to change it back.
- The reasoning is not recoverable from the diff alone.

Typical: dependency and version pins, protocol/interface choices, deployment
topology, deliberate omissions ("no X, because the pinned version cannot"),
security trade-offs, and reversals of earlier entries.

Not log-worthy: refactors, renames, formatting, bug fixes, anything the code
plus a commit message already explains. A log padded with trivia stops being
read.

## Where the log lives

1. If the project's `CLAUDE.md` (or `AGENTS.md`) names a decision-log path, use it.
2. Otherwise `docs/decisions.md`.
3. If that is absent, check for `DECISIONS.md`, `doc/decisions.md`, or an
   `adr/` / `docs/adr/` directory before concluding there is none.

## Before writing, verify the ground

**Never create a decision log, and never restructure an existing one, without
asking the user first.** Many repos -- especially ones the user does not own --
have their own conventions or want none of this.

- **Log exists and follows the template below** — append. No need to ask.
- **Log exists but uses a different format** (ADR-per-file, a table, numbered
  records) — follow *that* repo's format. Match its headings, numbering, and
  field names. Do not convert it to this template.
- **Log exists and is formatted ambiguously** — show the user one existing entry
  and ask whether to match it or use this skill's template.
- **No log anywhere** — stop and ask: "This repo has no decision log. Start one
  at `<path>`?" Take no action on a refusal, and do not re-ask in that session.

## Entry template

```markdown
## YYYY-MM-DD — Short imperative title

One to two paragraphs of prose: what was chosen, what it was chosen over, and
the reason the alternative lost. Name concrete versions, flags, file paths, and
issue numbers. Record the consequence the reader will feel, and the condition
under which the decision should be revisited.
```

Rules:

- **Newest last.** Append at the end of the file.
- **One `##` heading per decision.** Date first, em-dash separator, then a title
  short enough to scan in a `rg '^## '` listing.
- **Prose, not bullets.** The rationale is an argument; bullets shred it.
- **Get the date from the environment,** not from memory.
- **Cite specifics.** `v2.45.1`, `dex issue #4212`, `oauth2.pkce.enforce` — a
  vague entry cannot be verified later.

New file header:

```markdown
# Decision log (append-only)

Format: date — decision — rationale. Newest last. Do not rewrite
history; supersede with a new entry.
```

## Reversing a decision

History is append-only. To change a settled decision:

1. Add a new entry whose title ends with `(supersedes above)` or
   `(supersedes "<old title>")`.
2. Add one bold line to the *old* entry pointing forward:
   `**Superseded** — see "<new title>".` Use `**Partly superseded**` when only
   part of it fell.

Never delete or silently edit a past entry. Fixing a typo is fine; changing what
it claims is not.

## Procedure

1. Locate the log (above) and read its last few entries for format and voice.
2. Confirm the decision meets the bar in "What earns an entry". If it does not,
   say so and skip -- writing a weak entry is worse than writing none.
3. Draft the entry. If the decision reverses an earlier one, prepare the
   supersede marker too.
4. Append it, and mention the entry title in your reply so the user can object.

Batch related choices made in one sitting into one entry when they share a
rationale. Split them when a future reader would search for them separately.
