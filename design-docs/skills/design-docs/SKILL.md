---
name: design-docs
description: Use when writing or amending a PRD or requirements doc; scoping or designing a milestone, release, or phase from a PRD; drafting or revising an inchstone (increment) specification and its acceptance criteria; closing out an accepted inchstone or a completed milestone; or when detail has landed at the wrong level (a requirement sprouting mechanisms, a design carrying acceptance criteria) and needs a home. Not for implementation plans or TODO.md; those belong to a planning skill or plan mode.
argument-hint: "[prd|design|spec|closeout] <what to draft, amend, or close>"
---

# Design Docs

## The ladder

The ladder has four rungs; each answers one question. Each rung is a level of content that is always
present, even when two rungs share a file.

| | PRD | Milestone design | Inchstone spec | Implementation plan |
|---|---|---|---|---|
| Label | Needs | Shape | Behavior | Steps |
| Question | What must the product do, for whom, and why? | What does this milestone deliver, and how is the system composed to deliver it? | What must this increment observably do, precisely enough to test? | In what order, in which files? |
| Unit | The product | One milestone: a complete slice, either a capability its consumer can use or an experiment that resolves a question | One inchstone: one tangible, independently acceptable increment | One inchstone |
| States | Users, goals, non-goals, vocabulary, numbered requirements with reasons, constraints, open questions, future possibilities | Scope thesis, a plain-terms walkthrough of one case, in/out with destinations, components and ownership, data flow, enforcement points, mechanisms with losing alternatives, inchstone list, exit criteria | Boundary, go/no-go discovery, continuity, forced changes to existing code, data and API in general terms, numbered acceptance criteria | Tasks, files, types, signatures, test names, sequence |
| Omits | Any mechanism, mode, layout, field, or owner of upkeep | Behavior detail (errors, edges, defaults), acceptance criteria, field names, endpoint contracts | Structure (inherited from the design), construction | Re-deciding anything above |
| Reader | Spec author ("required or invented?"); user ("does it do X?") | Spec author ("what is in, what shape?"); anyone ("why not X?") | Implementer, acceptor, reviewer a year on | Implementer, today |

Strategy, then tactics. The PRD says what winning the war means. The design
picks *this* hill, now, and not another, and fixes the shape of the force
that takes it; it constrains every choice below. The spec says what "held"
means: the flag on the summit, the road below cut, no fire from the ridge;
conditions an observer can check without knowing how the assault went. The
plan is the marching orders. Design and spec both answer "how" at different
altitudes: design creates shapes and forecloses options; spec fills in what
must be true for the work to count as done.

Two words are overloaded elsewhere. Gloss "design" as *system design* and
"specification" as *behavioral spec* on first use in any document.

The plan rung belongs to a planning skill (`todo-planner` if installed) or
to plan mode. This skill stops at the spec.

## Boundary rules

- **Information flows down.** Each document cites the one above and never
  restates it. A paragraph equally true one rung up is a citation.
- **Discoveries flow up only when something pushes them.** A
  mid-implementation finding that changes course, or the closeout harvest,
  is the push. A design decision that proves to be a permanent guarantee is
  folded into the PRD as the rule and its reason; the mechanism stays below.
- **A decision belongs at the highest rung where it binds more than one
  thing below.** This is unknowable while drafting, so it is a repair rule
  applied at closeout, not a placement rule applied at draft time.
- **Concepts stay separate; files may combine.** Files are optional below
  the PRD. Small work may hold design and spec in one file with labeled
  parts; each part still obeys its rung.
- **Non-goals are neither required nor prohibited.** Coincidental
  satisfaction is fine; no design, spec, or plan spends effort or shapes a
  decision to achieve one. Anything that must *not* happen is a requirement
  with a reason, never a non-goal.

## The tiers

Three lifetimes, independent of rung. Most placement confusion ("where do
structural decisions live after the milestone closes?") comes from
conflating the two axes: the decision is permanent, the argument is
historical.

- **Living:** PRD, Domain, Architecture, CodeMap, DataModel, and their kin.
  Revised in place as use teaches.
- **Historical:** the decision log; milestone designs, inchstone specs, and
  acceptance run logs once complete. Frozen means frozen: status Complete
  makes the file read-only; corrections go to living docs; at most a
  one-line "superseded by" pointer is added. These answer "how did we get
  here?"
- **Ephemeral:** implementation plans and TODO lists. Deleted when done.

The project's CLAUDE.md doc index should carry a tier column so displaced
detail always has a named destination; `reference/living-docs.md` has the routing table.

## Modes

Decide the mode from the request, read that one reference, and stop after
that rung. Never proceed to the next rung unasked; a human reviews between
rungs.

| Request | Read | Also read on entry |
|---|---|---|
| Write or amend a PRD; a requirement is growing design detail | `reference/prd.md` | Domain doc, decision log, current milestone design |
| Scope or design a milestone; revise a design after a PRD or spec change | `reference/milestone-design.md` | PRD, Architecture, decision log, prior designs |
| Spec an inchstone; revise a spec | `reference/inchstone-spec.md` | Milestone design, sibling specs, the code it touches |
| Small work that skips the milestone design | `reference/milestone-design.md` and `reference/inchstone-spec.md` | As above; one file with labeled parts, concepts kept separate |
| Inchstone accepted; milestone complete; "what did we learn?" | `reference/closeout.md` | Every living doc the work touched |
| Where does this content live? Set up or revise the doc index | `reference/living-docs.md` | CLAUDE.md |

Each rung reference carries its north star, detail line, obligations,
section order, procedure, handoffs, anti-patterns, and rules, plus which
living docs it reads on entry and feeds on exit.

## Explain before you specify

Write for a reader who knows the rung above and has not read the code.

- **Open each decision in plain English:** the problem, the idea, and
  why it beats the obvious alternative, as you would explain it at a
  whiteboard. Title it by what it does for the reader, not by its
  mechanism. Mechanism and code names follow as pointers.
- **Ground abstractions in a case.** Walk one concrete scenario through
  a rule before stating it generally. When a decision plays out
  differently across a few cases, a small table shows it at a glance.
- **Define a term before you lean on it.** Name things by where the
  reader meets them (the album page), not by internal names (the
  masonry).
- **Read back.** Read only each decision's opening paragraph, in order.
  Someone who knows the rung above should be able to retell the design
  from them. Rewrite any opening that needs the body or the code.

Before, told in the code's vocabulary:

> ### D3. One mutation changes the current image and the shape together
>
> Every change of a photo's current image writes its `shape` in the same
> transaction, so the masonry, the slideshow's fit, and the stacks never
> show one image at another's proportions.
>
> - **`AddImage` can make its image current.** An edited image (D4) is
>   added and shown as one operation: one version step, one operation
>   record, one outcome. The flag joins the operation's fingerprint.

After, in plain English:

> ### D3. Changing the shown image updates the photo's shape
>
> A photo stores the width and height of its shown (current) image, its
> **shape**, so the album page, the slideshow, and the album stacks can
> lay it out without opening the image. Every change of the shown image
> writes the new shape in the same step, so no page draws one image in
> another's box.
>
> - **Adding an image always shows it.** `AddImage` makes its image
>   current, with no option to add without showing. Every caller wants
>   this: an editor who uploads a retouched version means it to show,
>   and the older images stay a click away in the image list.

The title states the outcome; "shape" is defined at first use; the reader
meets the album page, not "the masonry"; each bullet leads with behavior
and names the function after.

## Rules for every mode

- **Short docs.** Length follows the number of decisions, not the amount of
  thought. A section that dwarfs its siblings has absorbed the rung below.
- **Sections follow content.** Each rung has a minimum of two to four
  sections; every other section exists only when its condition holds. An
  absent condition means an absent section, never an invented constraint,
  non-goal, or open question. Content that fits no listed section gets its
  own.
- **Reasons beside choices.** The reason is the durable part; a choice
  without one gets reopened.
- **Verify claims about what exists.** Check every statement about
  current code, data, or another document against its source, and cite
  it. Reviewers trust a fluent claim and judge the design built on it.
- **Never invent a requirement.** Silence in the document above is a triage
  question or a flagged assumption, not a guess.
- **Propose, then wait,** for any change outside the document being
  drafted: a fold-back into the PRD, a move into a living doc, a freeze, a
  deletion.
- **A well-formatted draft with fluent rationale can still be wrong.** Be
  suspicious of a draft that raises no questions; offer a
  `review-walkthrough` on any draft above the plan rung.
- **Match the project's voice, numbering, and paths** over anything here.
- **Handoffs:** `decision-log` for a choice between live alternatives;
  `interview-user` when who-and-why is unclear enough that you would be
  guessing. Use them if installed; otherwise ask, and record in place.
