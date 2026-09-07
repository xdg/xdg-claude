# Product Requirements Document

Rung: Needs. Tier: living.

**Reads on entry:** the Domain doc (or wherever concepts live), the decision
log, the current milestone design (to know what is already decided
downstream). **Feeds on exit:** the milestone design (routed detail, new
scope), the decision log (chosen non-goals and rules), the Domain doc
(concept changes).

## North Star

**A PRD states the requirements of a solution, not the solution.** It says
what the product must do, for whom, under what rules, and what it will not
do, and stops there. Every mechanism, layout, mode list, and storage choice
belongs one or two rungs down (milestone design, inchstone spec).

A PRD is read when scoping a milestone, when a spec asks "is this required
or did we invent it", and when a user reports the product misses their need.
Write so that each of those readers can find the requirement, its reason,
and nothing they have to un-learn.

## The detail line

Where "requirement, not solution" actually falls.

| Subject | The PRD states | The PRD omits |
|---|---|---|
| A capability | that users need it, who, and the outcome it serves | the interaction that delivers it (modes, pickers, layouts, defaults) |
| A rule | the rule and why it is a rule (fairness, privacy, reversibility, trust) | where in the code it is enforced |
| Data | the concepts and their identity: what a thing is, what makes two of them the same | fields, types, timestamps vs dates, where it is stored, who edits the table |
| An external system | what it provides and what it cannot be trusted for | the parsing, the tolerance code |
| Precedence | which requirement wins when two collide | the algorithm |
| Deferral | that a need exists and is not in scope now | how it would be built later |

Two author heuristics settle borderline cases.

1. **Solution-swap.** Would the sentence survive a different implementation
   (another UI, another storage engine, another vendor)? If not, it is
   design, not requirement.
2. **Sibling weight.** A requirement should be about as long as its
   siblings. When one FR runs three times the length of the others, it has
   absorbed a design; cut it back to the requirement and move the rest.

**One exception.** A confirmed external interface the product depends on, a
third-party payload or a protocol the product must speak, is a fact about
the world, not a design choice, and belongs in an appendix as reference.
Internal structure never qualifies.

## Obligations

Satisfy these somewhere in the document; placement is yours. The first
three are the minimum; a PRD with only those still tells a spec author what
is required and what is not being built. The rest apply when their
condition holds.

1. **Audience and outcome.** Who the product serves and what changes for
   them. One paragraph that a stranger could restate. This is not the goals
   list; it is the reason the goals exist.
2. **Goals and non-goals**, as parallel lists. Goals: what is being built,
   each one line. Non-goals: what is not, each with its reason. A non-goal
   is not required and not prohibited: if other work satisfies it by
   accident, fine; but no design, spec, or plan spends effort or shapes a
   decision to achieve it. Non-goals earn their ink because they settle
   once something people would otherwise keep proposing; the list is short
   when nothing needs settling, and never padded. Anything that must *not*
   happen is a requirement (a rule with a reason), never a non-goal.
3. **Numbered functional requirements**, each citable (FR-n; FR-n.m for a
   requirement that is a distinct need under a parent, not for the parent's
   detail). A requirement carries its reason beside it.
4. **Core concepts**, when a noun could be read two ways or requirements
   would otherwise drift into synonyms. Each defined once with its identity
   rule and its trust level (self-asserted vs verified, derived vs stored).
   When the project has a Domain doc, this shrinks to the vocabulary and a
   pointer; the identity and trust rules live there.
5. **Constraints** the product inherits (platform, vendor, budget,
   compatibility promises), when there are any. Named, not chosen here, and
   never invented to fill the section.
6. **Open questions** with a default, when anything is undecided, so
   silence does not block work.
7. **Future possibilities**, when the user has said "eventually" about
   something. One line each, at most; this is where speculation goes so it
   stops leaking into requirements.

## Sections, in the usual order

The table is an order, not a form. Rows marked Always are the rung's
minimum: the least the document can hold and still serve the reader one
rung down. Include any other row when its condition holds; when it does
not, omit the section rather than fill it. Content that fits no row gets a
section named for it.

| Section | Include when |
|---|---|
| Header block: status, date with running changelog, author, sources | Always |
| Audience and outcome | Always |
| Goals / non-goals | Always; non-goals list only what needs settling |
| Users and roles | More than one kind of user, or any permission asymmetry |
| Core concepts | A noun could be read two ways, or requirements would drift into synonyms |
| Functional requirements | Always |
| Data model (conceptual) | Identity and ownership rules need a picture, and no Domain doc holds it; never fields |
| Constraints and dependencies | The product inherits any; never invent one |
| Open questions | Anything undecided that a downstream doc must settle |
| Future possibilities | Anything the user has said "eventually" about |
| Appendix: confirmed external interface | The product consumes something it does not control |

**State the reason beside the requirement.** "Win rates always show the
game count" is a rule; "because a 100% rate over two games misleads" is what
keeps it from being cut when someone wants a cleaner table.

## Procedure

1. **Gather inputs.** The requirements interview or notes, prior PRD
   revisions, the decision log, user feedback that prompted the change,
   the Domain doc, and the milestone design if one exists.
2. **Locate the level.** For an amendment: is this a new need (new FR or
   FR-n.m), a change to an existing need (edit in place), or design detail
   arriving early? For the last, record the need in one or two sentences
   and route the rest to a named destination: the current milestone
   design's open questions or scope, or the living doc that owns that kind
   of content (see `living-docs.md`). If no milestone design exists to
   receive it, create a stub (header block, empty scope thesis, the routed
   item under open questions) so the detail is never homeless. The stub is
   the one change outside the PRD that needs no prior approval; say you
   made it.
3. **Triage questions.** Ask only what changes the document's shape: who
   the requirement serves, whether it is required or merely wanted, what it
   must not do. Never ask how it should work; that is not this document's
   question.
4. **Draft or amend.** Match the sibling requirements' length and voice.
5. **Report**, numbered: what was recorded as requirement, what was routed
   downstream and where, and any open question you defaulted.
6. **Handoffs** (below).

## Amending

PRDs get amended when users react, when closeout folds a decision or a
result back, and when a concept changes meaning. Amend in place; keep one
coherent statement of current intent.

- **Header changelog.** The date line accumulates what changed and when.
- **Supersede visibly.** A promoted future possibility is struck with a
  pointer to its FR; a dropped requirement is struck with the decision that
  dropped it. Nothing silently vanishes.
- **Fold-back, not leak.** A design decision that turned out to be a
  requirement (a rule any future solution must keep) is stated in the PRD as
  the rule and its reason, with the mechanism left in the design doc.
- **Experiment results.** When a milestone was an experiment, closeout
  brings its answer here: a requirement confirmed, revised, or dropped, with
  the milestone cited as the reason.
- **Watch the sibling-weight test** on every amendment. Amendments are where
  design detail enters, one reasonable sentence at a time.

## Handoffs

- **Milestone design.** When an amendment routes detail downstream, name the
  target document and add the item to its open questions or scope in the
  same pass (creating the stub if needed, above).
- **Domain doc.** A concept whose identity or trust rule changed is edited
  there, not restated here.
- **Decision log.** A non-goal or a rule chosen between real alternatives
  gets a log entry; the PRD cites it.
- **Requirements interview.** When the need is unclear enough that you are
  guessing at who and why, stop and elicit (`interview-user` if installed)
  rather than draft.

## Anti-patterns

- **Modes and pickers.** "Offers three modes: preset, custom, named" is a
  design. The requirement is "users can scope views to a period that
  matches how they think about the data."
- **Field-level data.** "Start datetime in UTC, end implied by the next
  row" is a schema decision.
- **Ownership of upkeep.** Who edits a table and where it lives is a design
  decision unless it is a constraint imposed from outside.
- **Tech stack in requirements.** Unless it is a genuine external constraint,
  it does not belong.
- **Speculation as requirement.** "Eventually" belongs in future
  possibilities, one line.
- **An FR that dwarfs its siblings.** The reliable sign a design has moved in.
- **Domain discovery parked here.** Identity rules, trust levels, and
  schema-shaped appendices accumulate in the PRD when no living doc holds
  them. Propose the Domain doc instead of growing the PRD.

## Rules

- Length follows the number of distinct needs, not the amount of thought
  behind them.
- Prose with reasons; every requirement can be read alone.
- Match the project's existing voice and numbering over anything here.
- Never invent a requirement. If the user has not said it and it matters,
  it is a question or a flagged default.
- Do not design. When you find yourself choosing between mechanisms, stop;
  that document comes next.
