# interview-user

A skill that conducts a structured, persisted, tree-shaped interview with the user about a plan, design, strategy, or other under-formed idea. Elicitation only -- synthesis into a final artifact (PRD, design doc, ADR, memo) is a separate downstream skill.

## What it does

- Asks one question at a time, with a recommended answer.
- Writes every question to `questions/<session-name>.md` *before* asking it.
- Tags sub-questions `necessary` or `exploratory` so the tree terminates.
- Survives `/clear` and context resets -- the file is the source of truth.
- Surfaces (never auto-decides) stop criteria: all necessary nodes resolved, diminishing returns, or user signal.

## When to use

Trigger phrases: "interview me about X", "grill this idea", "help me think through Y", "poke holes in this plan".

Not for: well-scoped implementation work, debugging, or code review.

## Design notes

See [`../interview-user-design.md`](../interview-user-design.md) for the design rationale, including what this skill buys over naive "ask me questions" prompting.

## Status

Draft (v0.1.0). The core hypothesis under test: the value is mostly in forcing the agent to write each question down before asking it. Everything else (tagging, depth alarms, resumability) is amplification.
