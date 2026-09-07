# Inchstone Specification

Rung: Behavior. Tier: historical once accepted.

**Reads on entry:** the milestone design and its inchstone list, sibling
specs in the same milestone, the decision log, acceptance run logs, and the
code the increment touches. **Feeds on exit:** the milestone design
(resolved open questions, narrowed readings), the decision log, the
acceptance run log it creates, and at closeout the DataModel and CodeMap
docs.

## North Star

**A spec answers two questions: what gets built, and how you will know it is
done.** Everything else (file layout, task order, types, which function calls
which) belongs to the implementation plan that comes afterward.

An inchstone is one tangible, independently acceptable increment toward a
milestone: its acceptance criteria can be checked without waiting on a
sibling inchstone, whether or not its value reaches the end user. Its spec is the contract between the design that motivated the
work and the plan that will build it. It gets read three times: when
planning the work, when accepting the work, and a year later by someone
asking why the thing is shaped this way. Write for all three.

## The detail line

"What, not how" is the rule. Here is where it actually falls.

| Subject | The spec states | The spec omits |
|---|---|---|
| Storage | what a collection or table holds, what is unique in it, why that key is the key, what is deliberately not stored | field names, types, index syntax, migrations |
| API | the contract, the semantics, the failure modes, who may call and with what credential | handler structure, framework, middleware wiring |
| Client / UI | what it does, what it refuses to do, what it reports back | markup, components, build steps |
| Input tolerance | which missing, null, degenerate, or unrecognized inputs must survive | the validation code that survives them |
| Existing code | which existing behavior must change, and why that change is in scope rather than incidental | the diff |

Two author heuristics settle borderline cases. They are not checks; the
only check that runs is the acceptance criteria.

1. **Independent implementers.** Two competent implementers working from
   this spec alone build systems that behave identically and disagree only
   about internals. If they would disagree about *behavior*, the spec is
   thin. If they cannot disagree about anything, it has become a plan.
2. **Absent reviewer.** Someone who was not in any of the conversations can
   tell, by running things and looking, whether the inchstone is done.

**One exception to "no code."** A wire contract that something outside the
codebase must produce or consume (a payload envelope, a URL shape, a
required header) is specification, and showing it beats describing it.
Internal structure never qualifies. Reconciling the spec against existing
code (below) is likewise no license to put implementation into the
document: name the required change in prose and stop.

## Obligations

These must be satisfied *somewhere* in the document. Where is your choice.
The first two are the minimum; a spec with only those still tells an
implementer what to build and an acceptor when it is done. The rest apply
when their condition holds.

1. **A boundary.** What is built, and what is explicitly not built with a
   pointer to where it goes instead. Non-scope earns as much ink as scope;
   it is the thing that holds during implementation when everything looks
   adjacent and cheap.
2. **Acceptance criteria.** Numbered and observable. See below.
3. **The go/no-go discovery**, when the inchstone has one: the risky
   unknown it exists to resolve. Naming it explains why everything around
   it is minimal. When there is no discovery, the framing paragraph says
   what the increment delivers instead and why it is worth its own step.
4. **Continuity**, when a prior or later inchstone exists. What this builds
   on, named by prior inchstone and deliverable, and what later inchstones
   will need from it. This is what stops both re-litigating settled ground
   and building throwaway.
5. **Reconciliation with existing code**, whenever code exists. Read it.
   Every change to existing behavior the inchstone forces is stated as
   in-scope work, with the reason it is forced. Assumptions in the design
   that the code has already invalidated get flagged, not silently
   absorbed.
6. **Standing constraints**, when the design declares any (erasure,
   visibility scoping, backward compatibility). Restated as they bind
   *this* increment; a constraint nobody restates is a constraint somebody
   breaks. None declared, none restated.

## Sections, in the usual order

The table is an order, not a form. Rows marked Always are the rung's
minimum: the least the document can hold and still serve the reader one
rung down. Include any other row when its condition holds; when it does
not, omit the section rather than fill it. Content that fits no row gets a
section named for it.
Never copy a previous spec's headings for their own sake, and cut any
section that would hold only a restatement of the design doc.

| Section | Include when |
|---|---|
| Header block: status, date, author, parent doc + section, references | Always |
| Framing paragraph | Always. One paragraph: this states what is built and its acceptance criteria, it is not an implementation plan, and here is what counts as implementation input |
| Design part | No standalone milestone design exists; see "Combined design and spec" in `milestone-design.md` |
| Scope | Always. Numbered list of what is built, then the explicit not-in-this-inchstone list |
| Prerequisites / changes to existing code | Code exists and the increment forces changes to it |
| Data | The increment adds or changes storage. Open with the line that schemas are stated in general terms and exact names and types are implementation decisions |
| Fixtures / test data | The increment depends on data whose shape you do not control, or acceptance needs inputs the live source will not reliably produce |
| API surface | The increment adds or changes endpoints |
| Client / bookmarklet / UI | There is a user-facing artifact |
| Acceptance criteria | Always. Tiered when environments or actors differ |
| Out-of-scope reminders for reviewers | Reviewers will predictably ask about something deferred, or a nearby concept is easy to confuse with what is in scope |

**State the reason beside the choice.** The durable value of a spec is its
embedded rationale: *why a loader stub rather than a self-contained script*,
*why this is stored verbatim*, *why validation is permissive here and strict
there*. A choice recorded without its reason gets reopened. A choice
recorded with its reason gets respected or deliberately overturned.

## Acceptance criteria

Each criterion is something a person runs and observes, or something test
coverage (unit, integration, or e2e) observes mechanically, numbered so it
can be cited in a review, a plan, or a run log.

**Form.** A short bold name, then the action and the observable result.
"Idempotency: immediately re-running with an overlapping range creates no
new documents; the summary reports updates, and last-uploaded refreshes
while first-uploaded does not." Not "idempotency works correctly."

**Coverage.** Walk these categories and include the ones that apply:

- Happy path, end to end, with the observable result enumerated
- Repeat / idempotency / concurrent actors
- Boundary and limit behavior, including the user cancelling or supplying
  zero
- Degenerate inputs: null, absent, sparse, unrecognized-but-valid
- Auth failure: missing, unknown, superseded, revoked credentials, and that
  nothing is written
- Validation failure: rejected with a useful error, no partial write, no
  abort of unrelated work
- A spot-check of each standing constraint (erasure, scoping) against the
  new storage

**Say which criteria may use synthetic fixtures and which demand live
data.** Without that line, everything gets faked and the go/no-go discovery
is never actually made.

**Tier by environment when something cannot be exercised locally.** Number
continuously across tiers. State which tier is where the work happens, and
what external dependencies the far tier waits on.

## Procedure

1. **Gather inputs.** The design doc and its inchstone list; the PRD; the
   decision log; prior inchstone specs in the same milestone; any
   acceptance run logs. Read the design's open questions; some are
   explicitly assigned to this inchstone.
2. **Infer conventions from siblings.** Path, filename pattern, numbering,
   header block, tiering vocabulary. Match them. If this is the first spec
   in the project, propose the layout and confirm it before drafting.
3. **Reconcile with the code.** When an implementation exists, read the
   parts this inchstone touches. Collect: what must change, what the design
   assumed that is no longer true, what scaffolding this increment retires.
4. **Triage questions.** Batch them, ask once, and ask only the ones that
   change the document's shape (see below). Never ask what the design
   already answers.
5. **Draft.**
6. **Report assumptions and open questions,** numbered, after the draft.
   Anything you decided that the design left open goes here explicitly,
   with the choice you made and why.
7. **Handoffs** (below). Stop here; the plan is a separate step after human
   review.

### Triage questions: what qualifies

Sample questions follow. Ask only if necessary, never for form's sake.

- What is the go/no-go discovery, when the design does not name one?
- Which of the design's open questions must this inchstone settle?
- Does acceptance need tiering because an environment or a second actor is
  unavailable locally?
- Contested scope: something the design implies belongs here that you would
  rather defer, or vice versa.
- A design assumption the code contradicts, where the resolution is a
  judgment call rather than a fact.

Everything else waits for the post-draft list. A draft with five flagged
assumptions beats five questions asked before a word is written.

## Revising an existing spec

Specs get revised after review, after new information, and after the code
teaches you something. Revision is a normal mode, not a failure.

- **Keep the header block's running provenance.** The date line accumulates
  a compressed changelog: what changed, after which review, and when the
  original draft was. It is the cheapest possible history and it survives
  outside git.
- **Update the status** as the inchstone advances: draft, implemented,
  accepted. Accepted is set at closeout and freezes the file; after that,
  corrections go to living docs.
- Rewrite in place rather than appending caveats. The spec must read as one
  coherent statement of the current intent; the decision log is where
  superseded reasoning lives.

## Handoffs

- **Decision log.** When drafting settles a real choice between live
  alternatives, record it (`decision-log` if installed) and cite the entry
  from the spec. The spec states the choice; the log carries the
  alternatives and why they lost.
- **Parent design doc.** When the spec resolves one of the design's open
  questions, changes an inchstone boundary, or supersedes a statement, edit
  the parent in the same pass. Two docs disagreeing about scope is worse
  than either being wrong.
- **Acceptance run log.** Create the companion run-log file the acceptance
  run fills in: a date / run / result table keyed to the criterion numbers,
  plus room for what failed and what fixed it. It is the evidence the
  inchstone is done.
- **Plan.** The implementation plan is the next rung and a separate step:
  `todo-planner` if installed, else plan mode.
- **Closeout.** When the run log shows the criteria met, `closeout.md`
  harvests what the increment taught and freezes this file.

## Anti-patterns

- **Summarizing the design.** If a paragraph would be equally true in the
  parent doc, cut it and reference the parent.
- **Acceptance criteria stated as adjectives.** "Uploads work reliably."
  Nobody can run that.
- **Types, signatures, file lists, task ordering, estimates.** All of it
  belongs to the plan, except when public types or signatures are an
  essential part of an API contract.
- **Silence about existing code the increment breaks.** The most expensive
  omission, because it surfaces mid-implementation as scope nobody
  budgeted.
- **Deciding an open question without saying you did.** Flag every one.
- **Padding to a section template.** An empty section signals the increment
  is incoherent when usually it just means the heading did not apply.

## Rules

- Length follows the number of decisions, not the amount of work. A large
  increment with three decisions is a short spec.
- Prose with reasons, not bullet stubs. Terse fragments lose the rationale,
  and the rationale is the durable part.
- Match the project's existing document voice and conventions over anything
  here.
- Never invent a requirement. If the design and the PRD are both silent and
  the answer matters, it is a triage question or a flagged assumption.
- Do not write the plan. When you find yourself sequencing work, stop; that
  document comes next and is not this one.
