---
name: review-walkthrough
description: When the user asks to be walked through a file or a diff, wants a guided review, asks to go through code function by function or change by change, or says "review walkthrough", use this skill to run an interactive one-unit-per-exchange walkthrough driven by a persisted checklist. NOT for automated code review — do not use for "review this PR", "review my changes", or "code review" requests; those belong to code-review skills/agents.
argument-hint: "<file or diff spec to walk through>"
---

# review-walkthrough

An interactive, one-unit-at-a-time walkthrough of a file or a diff, paced by the user. Claude presents each function, annotates it, and flags findings; the user reads along and interrogates. Progress lives in a checklist file in the repo, so the walkthrough survives `/clear` and spans sessions.

This is a teaching/interrogation protocol, not an automated review. The human is in the loop on every unit. Never batch units, never run ahead, never summarize the file wholesale.

## When to use

Trigger on: "walk me through this file", "walk me through this diff/branch/these changes", "guided review of X", "explain this file function by function", "let's go through auth.go together", "review walkthrough".

Do not use for: "review this PR", "code review", "review my changes", or any request for an automated verdict on a diff. Those go to code-review tooling. If ambiguous, ask.

## Unit and target

The target is either a **file** (or a small, tightly-coupled set of files) or a **diff** (a branch range, staged changes, a commit, a PR).

- **File target:** the default unit is the function, walked in file order. When the file's natural structure differs, pick a better unit: sections of a config file, endpoints of an API spec, classes or methods, top-level blocks of a script. A file set gets one checklist, grouped by file.
- **Diff target:** the unit is the **change group** — a set of related hunks forming one coherent modification. See "Diff targets" below. Never use raw hunks as units.

Language-agnostic: nothing in the protocol depends on the language.

## Setup (first invocation for a target)

1. **Pick the checklist path.** Default `REVIEW.md` at the repo root. If that name is taken or the repo has a docs convention, propose an alternative (e.g. `docs/review-<file>.md`) and confirm. If a checklist for this target already exists, resume instead (see below).
2. **Identify the units.** File target: outline the file (prefer a structure-outlining tool over reading the whole file) and list its units in file order. Diff target: build change groups per "Diff targets" below and pin the diff spec.
3. **Identify related files for coupling checks.** File target: callers, config, sibling packages, external dependencies the file leans on. Diff target: the blast radius — callers of changed symbols, tests covering changed code. List them in the checklist.
4. **Write the checklist file** using the template below. It must contain the protocol itself, so a fresh session can resume from the file alone without this skill loaded.
5. **Confirm the agenda** with the user (unit choice, order, related files — and for a diff, the grouping itself), then start the first unit.

### Checklist template

The template below is the file-target variant. For a diff target, adapt it: the header names the pinned diff spec (with SHAs) instead of a target file, the protocol steps incorporate the "Diff targets" rules (grouping, size cap, presentation choice, completeness verdict, re-diff on resume), and checklist items are named change groups, with sub-items where the size cap forced a split.

```markdown
# <target file> Review Walkthrough Checklist

## Walkthrough protocol (for the Claude session driving this)

Target file: `<path>`. Work through the checklist below one <unit> per
exchange, in order unless the user redirects. For each:

1. **Show the code.** Quote the <unit> verbatim, split into stanzas at
   natural seams (guard clauses, lock sections, network calls). Short
   <unit>s can be one stanza. Do not elide lines.
2. **Comment per stanza:** what it does, why it's written this way, and any
   subtlety or coupling to code outside this <unit> (callers, config,
   other packages, deployment assumptions). Name the coupled file/symbol
   so the user can chase it. Read the coupled code when a claim depends
   on it; do not speculate.
3. **Don't paraphrase the file's own comments.** Add value by verifying
   their claims against the code, or by stating what they omit. If a
   comment and the code disagree, that is a finding.
4. **End with a verdict:** either "no findings" or concrete flags —
   bugs, questionable trade-offs, missing tests, or design choices worth
   challenging. Give the user something to dispute, not just a summary.
   Do not pad with generic observations.
5. Wait for the user's questions; make edits only if they direct. When
   they're done with the <unit>, check it off in this file with a
   one-line parenthetical note of what was found or changed, then
   proceed.

One <unit> per exchange, always. If the user asks about a later item,
answer, but return to checklist order unless they redirect. Never batch
items, "briefly cover the rest," or produce a bulk findings report —
findings surface item by item and live in the checklist notes.

Related files for coupling checks: <list>.

## Checklist

- [ ] `<unit 1>`
- [ ] `<unit 2>`
...
```

## Diff targets

When the target is a diff, the protocol is unchanged except as noted here. The checklist protocol section written at setup must be the diff variant, including these rules.

**Pin the diff spec.** Record the exact spec in the checklist header (e.g. `main...feature` with the base and tip SHAs at setup time, or a commit SHA, or "staged as of <SHA>"). On resume, re-diff and compare: if the diff changed, reconcile the group list first and tell the user.

**Build change groups.** Raw hunks are byte-window artifacts — one hunk can straddle two functions, one function can be split across hunks. Cluster in two passes:

1. *Mechanical:* attribute each hunk to its enclosing function/section.
2. *Semantic:* merge hunks — across files — that form one logical change: a signature change plus its call-site updates, a renamed symbol plus its uses, a new helper plus its first caller. Split a hunk that contains two unrelated edits into two groups and note it.

Name each group by its meaning, not its location: `validateToken signature change (auth.go, handlers.go ×3 call sites)`, not a hunk header.

**Size cap: about a screenful.** A group whose quoted presentation would run well past ~50 lines is too big for one exchange. Split it into sub-items under a parent heading in the checklist (e.g. the anchor change as one item, its fallout as another), each independently checkable.

**Confirm the grouping.** The proposed group list is part of the setup agenda; present it and let the user merge, split, reorder, or drop groups before the first exchange. Bad clustering poisons the whole walkthrough — do not skip this.

**Ordering.** File order is arbitrary for a diff. Default to dependency order: core/anchor changes first, mechanical fallout after. Propose the order with the agenda.

**Presentation per group.** Pick per item:

- *Diff-quoted:* hunks verbatim with context, stanza'd. Best for small self-contained edits.
- *New-code-quoted:* for a rewritten function, quote the new version in stanzas and describe what changed from the old. The user reviews the destination, not the delta encoding.
- *Anchor + satellites:* for a cross-file group, quote the anchor change fully, then show call-site hunks compactly.

**Verdict adds a completeness dimension.** Beyond "is this code right?", ask "is this change complete and consistent?" — missed call sites, callers whose assumptions the change breaks, tests not updated, comments/docs now stale.

## The per-unit exchange

The checklist file's protocol section is the single source of truth for the exchange loop — follow it as written there (it is the template above, adapted to the target). After setup, the walkthrough is driven from the file, not from this skill. Check-off notes are one-line parentheticals, e.g. `(CSRF check assumes proxy sets Origin; flagged missing test)`.

## Resuming

When invoked and a checklist for the target exists (or the user points at one): read it, report progress in a line or two (N of M done, last note), and present the first unchecked unit. The file's own protocol section governs; do not re-explain the process to the user. Do not redo checked items unless asked.

If the target changed since the checklist was written (units added, removed, renamed; for a diff, re-diff against the pinned spec), reconcile the checklist first — add/remove items in place, note the change — and tell the user.

## Setup anti-patterns

Run-time discipline (pacing, quoting, verdicts, check-offs) lives in the checklist's protocol section; these are mistakes made while *creating* it:

- **Raw hunks as checklist items.** Hunk boundaries are diff-encoding artifacts; units are semantic change groups, confirmed by the user.
- **Unconfirmed grouping.** Starting the first diff exchange before the user has ratified the group list.
- **Writing a checklist without the protocol section.** The file must stand alone for a fresh session; a bare item list forfeits resumability.
- **Weakening the protocol while adapting the template.** The diff variant adds rules (presentation choice, completeness verdict, re-diff on resume); it never drops the verbatim-quoting, one-unit pacing, or verdict requirements.
