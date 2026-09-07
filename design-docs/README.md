# design-docs

A Claude Code plugin for the document ladder of software work: PRD, milestone
system design, inchstone behavioral spec, and the closeout that feeds what the
work taught back into the living docs.

## What it does

Ships a single Type 2 (main-agent task) skill, `design-docs`, that is modal:
the request picks the rung, the skill reads one reference for that rung, drafts
or amends that one document, and stops. A human reviews between rungs; the
skill never proceeds to the next one unasked.

The core (`SKILL.md`) states what every mode shares:

- **The ladder**: four rungs (Needs / Shape / Behavior / Steps), each with the
  question it answers, what it states, what it omits, and who reads it.
- **Boundary rules**: information flows down and is cited, never restated;
  discoveries flow up at closeout; a decision belongs at the highest rung where
  it binds more than one thing below.
- **The tiers**: living, historical (frozen on completion), ephemeral (deleted
  when done), independent of rung.

The references, loaded one per invocation:

| Reference | Mode |
|---|---|
| `reference/prd.md` | Write or amend a PRD; route design detail that leaked into a requirement |
| `reference/milestone-design.md` | Scope and design a milestone as a complete slice (a capability or an experiment); also the combined design+spec form for small work |
| `reference/inchstone-spec.md` | Spec one increment: boundary, go/no-go discovery, continuity, numbered acceptance criteria |
| `reference/closeout.md` | At inchstone acceptance or milestone close: harvest structure, rationale, and needs into living docs; freeze; delete the plan. Propose-then-wait |
| `reference/living-docs.md` | Kinds of living content (Domain, Architecture, DataModel, CodeMap), the CLAUDE.md doc index with a tier column, and the routing table for displaced detail |

The plan rung is deliberately absent. The skill hands off to
[todo-planner](../todo-planner/README.md) if installed, else plan mode. It also
hands off to [decision-log](../decision-log/README.md),
[interview-user](../interview-user/README.md), and
[review-walkthrough](../review-walkthrough/README.md) when those are installed.

## Usage

Model-invoked from requests like "amend the PRD for X", "design the next
milestone", "spec inchstone 3", or "close out inchstone 2". Or explicitly:

```
/design-docs spec inchstone 3
/design-docs closeout milestone 01
```

## Installation

```bash
claude plugin install design-docs@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
