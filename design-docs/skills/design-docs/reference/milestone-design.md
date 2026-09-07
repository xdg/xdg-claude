# Milestone System Design

Rung: Shape. Tier: historical once complete.

**Reads on entry:** the PRD, the Architecture and DataModel docs (current
structure, so the design states only what changes), the decision log, prior
milestone designs, the code. **Feeds on exit:** the PRD (fold-backs), the
decision log (each structural choice), the inchstone specs (the list and the
assigned open questions), and at closeout the Architecture, DataModel, and
CodeMap docs.

## North Star

**A milestone is a complete slice of capability: something its consumer can
use end to end, or an experiment that resolves a question.** The consumer is
usually an end user, but may be an operator, an integrating system, or a
downstream team. Its design
decides what the slice delivers, what it deliberately does not, and how the
system is composed to deliver it. The design picks this hill and not
another, and it fixes the shape of the force: components, what each owns,
how data moves between them, where each rule is enforced, and which
mechanism was chosen where the choice is expensive to reverse. It
constrains every choice below and stops before behavior detail and
construction.

It is read when writing each inchstone spec, when someone asks "why is X not
in this release", and when the next milestone asks what it can build on.
Write for the second reader most: the durable value of the design is its
recorded refusals and the reasons behind them.

## The detail line

| Subject | The design states | The design omits |
|---|---|---|
| Scope | which PRD requirements ship fully or partially, and which wait | acceptance criteria for any of them |
| Structural decisions | the mechanism, when it binds more than one inchstone or is expensive to reverse: unit of storage, where visibility is enforced, read-time vs write-time derivation, how an aggregate is computed, where reference data lives; each with its reason and the losing alternative | field names, types, endpoint contracts, error and edge behavior |
| Components | what exists, what each owns, how data flows between them, which existing pieces change | internal structure of a component, code layout |
| Data model stance | the collections or entities, their keys, and the invariants that keep later milestones additive | types, timestamps, validation |
| User-facing shape | the modes or surfaces a requirement takes in this milestone | layouts, controls, copy |
| Reference data | that it exists, where it lives, and who keeps it | its format and contents |
| Inchstones | the ordered list, one line of what each delivers and why it comes where it does | tasks, files, estimates |
| Exit | observable conditions under which the milestone is done | test names |

Three author heuristics.

1. **Same shape.** Two competent implementers working from this design and
   the PRD build systems with the same components and boundaries and
   disagree only inside a component. If they would build different shapes,
   the design is thin; if they could not disagree about behavior, it has
   become a spec.
2. **Spec-writer sufficiency.** An inchstone spec author needs no further
   conversation to know what is in, what is out, and which structure the
   increment must fit into.
3. **Refusal test.** Every "not in this milestone" line names where the item
   goes instead (a later milestone, a future possibility, never). A deferral
   without a destination gets rebuilt into scope.

A mechanism that only one inchstone cares about, and that could go either
way without changing the shape, is left to that inchstone's spec.

## Obligations

The first three are the minimum; a design with only those still tells a
spec author what is in, what is out, and what comes first. The rest apply
when their condition holds.

1. **Scope thesis.** One paragraph: who this milestone serves, whether it is
   a capability or an experiment, who can use what at the end or what
   question gets answered, and why this slice first. Early dogfooding beats
   completeness.
2. **In and out of scope, per requirement.** In: citing the PRD section,
   with this milestone's reading of it and the structural decisions it
   forces. Out: each with its destination and its reason. Out is empty only
   when the milestone ships the whole PRD.
3. **Inchstones.** Tangible, incremental, independently acceptable,
   testable steps, ordered so early ones de-risk later ones. Independently
   acceptable means the increment's criteria can be checked without waiting
   on a sibling; its consumer may be an end user, an API client, an
   operator, or a later inchstone. Reaching the end user is not required. A
   slice defined by labor rather than by behavior is what this rules out. A
   standing constraint that every inchstone must honor is stated once here,
   not as a numbered step.
4. **Structural decisions with rationale**, when a choice is expensive to
   reverse or binds more than one inchstone. Argued in place, with the
   losing alternative. When an Architecture doc exists, cite the current
   structure and state only what this milestone changes. A milestone with
   no such choice says nothing here.
5. **Constraints carried forward**, when the PRD has any that bind this
   milestone, or the milestone adds one (proof methods, no one-way doors).
   Restated as they bind this milestone; never manufactured.
6. **Exit criteria**, when done means more than every inchstone accepted:
   an integrative proof across inchstones, or an experiment's reading (what
   outcome confirms, revises, or kills the requirement it tests).
   Observable, few, with the proof method for each that cannot be observed
   live.

## Sections, in the usual order

The table is an order, not a form. Rows marked Always are the rung's
minimum: the least the document can hold and still serve the reader one
rung down. Include any other row when its condition holds; when it does
not, omit the section rather than fill it. Content that fits no row gets a
section named for it.

| Section | Include when |
|---|---|
| Header block: status, date with running changelog, author, source PRD | Always |
| Scope thesis | Always |
| In scope, by requirement | Always |
| Out of scope | The PRD holds requirements this milestone does not fully ship |
| Structural decisions | A choice is expensive to reverse or binds more than one inchstone; may live inside In scope when few |
| Data model stance | Storage exists or is introduced |
| Privacy / erasure / visibility stance | The PRD has such rules |
| Constraints carried forward | The PRD has any that bind this milestone, or this milestone adds one |
| Open questions assigned to inchstones | Anything a spec must settle |
| Inchstones | Always |
| Exit criteria | Done means more than every inchstone accepted, or the milestone is an experiment |

## Procedure

1. **Gather inputs.** The PRD, the decision log, prior milestone designs,
   the living structure docs, the state of the code, and any user feedback
   that triggered a revision.
2. **Reconcile with the code** when it exists: what is built, what the
   previous milestone left as scaffolding, what a new requirement forces to
   change. Name forced changes as scope.
3. **Triage questions.** Only those that change scope or order: the
   dogfood slice, contested inclusions, an unresolved PRD open question
   whose answer changes structure.
4. **Draft.** Argue each structural decision in place, with the losing
   alternative named.
5. **Report**, numbered: assumptions, PRD open questions you settled, PRD
   folds you recommend.
6. **Handoffs** (below). Stop here; the inchstone specs are a separate
   step after human review.

### Combined design and spec

Small work sometimes skips a standalone design and goes straight to a spec.
The design rung still exists; it just shares a file. Give the spec a
labeled design part carrying the scope thesis, in/out with destinations,
and any structural decision with its losing alternative, then the
behavioral part per `inchstone-spec.md`. Keep the parts distinct: the
design part forecloses options, the spec part states what must be true.

## Revising

A design is revised as inchstone specs settle its open questions, as
requirements change, and as code teaches. Revise in place; the header
changelog carries the history.

- **Specs write back.** When a spec resolves an open question or narrows a
  reading, the design is edited in the same pass and cites the spec.
- **Requirement changes land here first as scope**, then as a new or
  reordered inchstone. Never let a PRD amendment carry its own design.
- **Status advances**: draft, in progress, complete. Complete is set at
  closeout (`closeout.md`), with the exit criteria read against what
  shipped, and freezes the file.

## Handoffs

- **PRD.** A structural decision that is really a rule for all time (a
  reversibility guarantee, a privacy boundary) is folded back into the PRD
  as the rule and its reason; the design keeps the mechanism. Design detail
  that leaked into the PRD is pulled down here.
- **Decision log.** Every structural decision chosen between live
  alternatives gets an entry; the design cites it.
- **Inchstone specs.** `inchstone-spec.md` takes the inchstone list and open
  questions from here; assign each open question to the inchstone that must
  settle it.
- **Closeout.** When the last inchstone is accepted, `closeout.md` harvests
  structure into the living docs and freezes this file.

## Anti-patterns

- **Acceptance criteria in the design.** They belong to the inchstone spec.
- **Behavior detail.** Error cases, edge inputs, exact defaults: a spec
  makes those testable; a design that carries them has drifted down a rung.
- **Schemas.** "Collection keyed by (gameid, uploader)" is a structural
  decision; a field list is a spec's implementation input.
- **Structure without a reason.** A mechanism recorded without its losing
  alternative gets reopened by the first spec that finds it inconvenient.
- **Deferral without destination.**
- **Inchstones that are tasks.** "Add the endpoint" is a task; "Capture:
  upload API and bookmarklet end to end against live data" is an inchstone.
- **Re-arguing the PRD.** If a paragraph would be equally true in the PRD,
  cite it.
- **Restating the architecture.** If the Architecture doc already says it,
  cite it; state only what changes.
- **Sequencing by convenience.** Order by what de-risks and what becomes
  usable, and say so.
- **A milestone that is not a slice.** One inchstone dressed as a milestone,
  or a grab-bag of tasks with no consumer or question at the end.

## Rules

- Length follows the number of structural decisions and refusals.
- Prose with reasons; the reasons are the durable part.
- Match the project's existing voice and conventions over anything here.
- Never invent a requirement; cite the PRD or flag the assumption.
- Do not spec and do not plan. Behavior detail goes to the inchstone
  spec; construction to the plan.
