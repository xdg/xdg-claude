---
name: how-to-plan-refactor
description: When the user asks what to refactor, where to improve code quality, or for analysis of refactoring opportunities, consult this skill to decide whether to delegate to the plan-refactor subagent and how to craft the prompt.
user-invocable: false
---

# Handling refactoring-planning requests

Delegate to the `plan-refactor` subagent (Agent tool, `subagent_type: plan-refactor`) when the user wants *analysis* of refactoring opportunities — not execution. The subagent scans for code smells (duplication, long methods, complex conditionals, poor naming, magic values, dead code, tight coupling, data clumps) and returns a prioritized list under a strict 400-word budget.

For *executing* a specific refactoring, use `refactor` instead — see `how-to-refactor`.

## When to delegate vs. handle inline

Delegate when:
- The user asks "what should I refactor?", "find code smells", "where can this be improved?", "analyze this for refactoring opportunities".
- The user wants prioritized recommendations before deciding what to act on.
- The scope is large enough (a file, directory, or module) that reading inline would burn context.

Handle inline (do not delegate) when:
- The user is asking about a *specific* identified problem ("is this function too long?") — that's a single judgment, not a survey.
- The scope is a short snippet already visible in conversation.
- The user is asking for design feedback or architectural input rather than refactoring opportunities — that is conversation, not scanning.

## Crafting the delegation prompt

State the scope. The subagent's defaults handle priority and reporting format — don't reproduce them.

Examples:

- User: "what should I refactor?" → Delegate with empty prompt if the working set is the implicit scope; otherwise ask the user to narrow scope first.
- User: "find smells in src/api/" → "Analyze src/api/ for refactoring opportunities."
- User: "analyze the auth module" → "Analyze the auth module (src/auth/) for refactoring opportunities."
- User: "review my uncommitted changes for refactor opportunities" → "Analyze the uncommitted changes (staged + unstaged) for refactoring opportunities."

## Anti-patterns

- Delegating without a scope when the working set is unclear. Ask the user to point at something first.
- Asking the subagent to *fix* what it finds. It only recommends; pass items to the `refactor` subagent for execution.
- Expecting an exhaustive list. The subagent caps output at 10 items and 400 words — top opportunities only.
- Delegating for tiny scopes (a single short function). The signal-to-overhead is poor.
