# Closeout

Not a rung. The step that runs at two moments: when an inchstone's
acceptance criteria are met, and when a milestone's last inchstone is
accepted. Its job is to make insight flow up the ladder, which otherwise
happens only by accident.

**Reads on entry:** the spec or design being closed, its run log, the plan,
the decision log, and every living doc the work touched. **Feeds on exit:**
the living docs, the decision log, the PRD.

## North Star

**Closeout asks one question: what did this work teach that is not yet
written where it will be found?** Structure that now exists in code, a
choice made mid-implementation, a need the user discovered, a rule that
turned out to be permanent. Each has a living home; closeout moves it
there and then freezes the historical record.

The value is the prompt, not the prose. Harvest is nobody's job until it is
a step; this step exists so the author is reminded to look. A closeout
that finds nothing to move is a legitimate result.

## Procedure

Every step is a proposal. Draft the full set of moves as a numbered list,
present it, and wait. Apply only what is approved.

1. **Read the run log against the criteria.** Confirm each criterion has a
   passing run. Anything unmet is not closed; stop and say so.
2. **Harvest structure.** Components, boundaries, keys, invariants, and
   enforcement points that the work settled go to Architecture, DataModel,
   or CodeMap (whichever the project's doc index names). Move, do not
   copy: the historical doc keeps the argument, the living doc keeps the
   fact, and a citation joins them.
3. **Harvest rationale.** A choice made during implementation that was
   between live alternatives, and is not yet in the decision log, gets an
   entry (`decision-log` if installed).
4. **Apply the repair rule.** For each decision the work made, ask whether
   it binds more than one thing below its current rung. If it does, propose
   moving it up: a spec-level choice that every later inchstone must honor
   belongs in the design; a design mechanism that any future solution must
   keep belongs in the PRD as the rule and its reason.
5. **Harvest needs.** Discovered requirements, and rule-level guarantees the
   user now relies on, go to the PRD as amendments (`prd.md`, Amending).
6. **At milestone close, read the scope thesis.** For a feature: state how
   the user experience changed, in one paragraph, and whether the PRD's
   reading of the requirements still holds. For an experiment: state the
   result and which requirement it confirms, revises, or kills. Either may
   produce no PRD change; say so explicitly rather than skipping.
7. **Freeze.** Set status Accepted (spec) or Complete (design), note the
   date in the header changelog, and mark the file read-only in whatever
   way the project uses (a header line, a directory move, file mode).
   Corrections after this point go to living docs; the frozen file gets at
   most a one-line "superseded by" pointer.
8. **Delete the plan.** TODO.md and any per-inchstone plan are ephemeral.
   Anything in them worth keeping was harvested above.
9. **Report** what moved where, what was frozen, and what was deleted.

## Anti-patterns

- **Copying instead of moving.** Two statements of one fact drift apart.
- **Editing a frozen doc.** The correction belongs in a living doc; the
  frozen doc gets a pointer at most.
- **"Complete" as a build status.** Exit criteria prove the build. Step 6
  proves the slice did what it was for.
- **Harvest as a wall of new prose.** A living doc gains the facts the work
  settled, in the doc's existing voice and length. If the harvest doubles
  the Architecture doc, it is carrying the argument, which belongs in the
  frozen design.
- **Skipping the repair rule** because placement felt right at draft time.
  It could not have been known then.
- **Closing with unmet criteria** because the remainder "is small."

## Rules

- Propose, then wait. No move, freeze, or deletion without approval.
- Move, do not copy; cite the frozen doc from the living one.
- Match the project's freeze convention; propose one if none exists.
- A closeout that changes nothing is reported, not silently skipped.
