# review-walkthrough

A skill that runs a guided, interactive walkthrough of a file or a diff one unit at a time, driven by a checklist document (`REVIEW.md` by default) that Claude creates and maintains in the repo. The user reads along and interrogates each unit; Claude quotes the code verbatim in stanzas, annotates each stanza (what/why/coupling), verifies the file's own comments instead of paraphrasing them, and ends every unit with a disputable verdict. Progress is checked off with one-line notes, so the walkthrough spans sessions.

Deliberately distinct from automated code review: it is a teaching/interrogation protocol with the human in the loop on every function, not a bulk findings report. It will not trigger on "review this PR" or "code review" requests.

## What it does

- Sets up a checklist file containing the walkthrough protocol itself, a related-files list for coupling checks, and the units in file order — a fresh session can resume from the file alone.
- One unit per exchange: quote verbatim in stanzas, comment per stanza, verify comments' claims, end with "no findings" or concrete flags.
- Waits for the user's questions before checking the item off (with a parenthetical note) and moving on.
- Flexible in unit (functions by default; sections, endpoints, classes work) and target (one file, sometimes a small set). Language-agnostic.
- Diff targets (branch range, commit, staged changes): units are semantic *change groups* — related hunks clustered into one coherent modification, user-confirmed at setup, capped at roughly a screenful with oversized groups split into sub-items. The diff spec is pinned by SHA so resume detects drift; verdicts add a completeness check (missed call sites, broken caller assumptions, stale tests/docs).

## When to use

Trigger phrases: "walk me through this file", "walk me through this diff/branch/these changes", "guided review of X", "explain this file function by function", "review walkthrough". Also available as `/review-walkthrough <file or diff spec>`.

Not for: "review this PR", "review my changes", automated code review.

## Installation

```bash
claude plugin install review-walkthrough@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
