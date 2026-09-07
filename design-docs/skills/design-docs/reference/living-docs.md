# Living docs and the doc index

Not a rung. Where content goes when it does not belong in the document
being drafted, and how a project declares that.

## Kinds of content, not files

Each kind below has a distinct job. A project may keep them in separate
files or fold several into one; the file count is a project choice, the
distinction is not. When two kinds share a file, label the parts.

| Kind | Holds | Never holds |
|---|---|---|
| **Domain** | Concepts, identity rules (what makes two things the same), trust levels (self-asserted vs verified, derived vs stored), domain rules with their reasons. Solution-aware, implementation-free. | Fields, storage, components |
| **Architecture** | Components and what each owns, data flow, enforcement points (where each rule is checked), mechanisms with a one-line reason and a citation to the decision that chose them | The losing alternatives (decision log), behavior detail (specs) |
| **DataModel** | The data structures and the persistence layer as built: collections or tables, keys, indexes, invariants | Concept definitions (Domain), why the key is the key (decision log) |
| **CodeMap** | Where things are in the tree, and which package owns which responsibility | Anything a reader could get from the file listing |
| **Decision log** | Append-only: each choice between live alternatives, the alternatives, why they lost, what would reopen it | Current structure (Architecture); the decision restated as a rule (PRD) |
| **Acceptance run log** | Per spec: date, run, result per criterion; what failed and what fixed it | Anything but evidence |

Most projects lack a Domain doc, and domain discovery then silts up the PRD
(identity rules, `null` semantics, schema appendices). When you see that
happening, propose the Domain doc; do not grow the PRD.

## The doc index

The project's CLAUDE.md (or wherever the project lists its docs) carries
one row per document with a tier column, so any skill knows where
displaced detail goes:

| Doc | Tier | Holds |
|---|---|---|
| docs/PRD.md | living | needs |
| docs/Domain.md | living | concepts and rules |
| docs/Architecture.md | living | structure |
| docs/decisions.md | historical | rationale |
| docs/milestones/NN-name/design.md | historical | one milestone's shape |
| docs/milestones/NN-name/inch-NN-spec.md | historical | one increment's behavior |
| TODO.md | ephemeral | the current plan |

Shape and paths are the project's; the tier column is the point. When a
project has no index, propose one as part of whatever rung you are
drafting, populated from the files that exist.

## Routing displaced detail

When content surfaces in the wrong document, route it by kind:

| Content that appeared | Goes to |
|---|---|
| A concept's identity or trust rule | Domain (or PRD core concepts if no Domain doc) |
| A mode, picker, surface, or user-facing shape | The current milestone design |
| A component, boundary, or enforcement point | The milestone design while open; Architecture at closeout |
| Field names, types, keys, indexes | The inchstone spec in general terms; DataModel at closeout |
| An alternative and why it lost | Decision log |
| A rule any future solution must keep | PRD, as the rule and its reason |
| "Eventually" | PRD future possibilities, one line |
| Task order, files, signatures | The plan |

If the destination does not exist yet: a missing milestone design gets a
stub (see `prd.md`, Procedure step 2); any other missing doc is proposed,
not created, and the content waits in the report until the user decides.

## Rules

- Concepts stay separate even when files combine.
- Living docs are revised in place, in their existing voice and length.
- Historical docs are cited, never edited after freeze.
- Propose new living docs; create only the milestone design stub unasked.
