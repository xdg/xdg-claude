---
name: how-to-refactor
description: When the user asks to refactor, restructure, extract, rename, simplify, or clean up code without changing behavior, consult this skill to decide whether to delegate to the refactor subagent and how to craft the prompt.
user-invocable: false
---

# Handling refactoring requests

Delegate to the `refactor` subagent (Agent tool, `subagent_type: refactor`) when the user wants code restructured without behavior change. The subagent executes one atomic refactoring, runs tests to verify behavior preservation, and stops. Doing this work in the main session risks tangling refactor edits with unrelated changes and consumes context on diff-level reasoning.

For broader "what should I refactor?" questions, use `plan-refactor` instead — see `how-to-plan-refactor`.

## When to delegate vs. handle inline

Delegate when:
- The user names a specific refactoring: "extract this function", "rename X to Y everywhere", "remove duplication in module Z", "simplify the conditionals in fn()".
- The user picks an item from a `plan-refactor` report and asks you to carry it out.
- The change is mechanical but spans enough code that tests must verify behavior preservation.

Handle inline (do not delegate) when:
- The user is *deciding whether* to refactor — that is conversation, not execution.
- The refactor is a one-line rename inside code already loaded in conversation. Subagent overhead exceeds the work.
- The request mixes refactoring with feature changes or bug fixes. The subagent refuses combined changes — split first.

## Crafting the delegation prompt

The subagent requires a specific target. Pass exact instructions: what to refactor, what technique to apply (if known), what scope (one site vs. all instances).

Examples:

- User: "extract lines 45-60 of auth.go into a function" → "Extract lines 45-60 of auth.go into a well-named function."
- User: "rename getUserData to fetchUserData" → "Rename `getUserData` to `fetchUserData` across the codebase. Verify tests pass."
- User: "simplify the conditionals in validateUser()" → "Simplify the conditionals in validateUser(). Preserve all observable behavior including error handling."
- User: "dedupe the email validation in user-service.ts" → "Eliminate the duplicate email validation logic in user-service.ts. Extract a shared function."

## Anti-patterns

- Delegating with "refactor this file" or "clean this up". The subagent will ask for clarification — wasted round-trip. Pick a specific refactoring first (or run `plan-refactor` to identify one).
- Bundling multiple refactorings into one delegation. The subagent does one atomic change per invocation. For a list, invoke per item.
- Asking the subagent to commit. It does not commit; the calling agent does that separately.
- Telling the subagent to skip tests. Behavior preservation is its core contract; without tests it warns and asks.
