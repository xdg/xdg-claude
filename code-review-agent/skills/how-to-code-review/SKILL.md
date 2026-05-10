---
name: how-to-code-review
description: When the user asks for a code review, PR review, or critical look at recent changes, consult this skill to decide whether to delegate to the code-review subagent and how to craft the prompt.
user-invocable: false
---

# Handling code review requests

Delegate to the `code-review` subagent (Agent tool, `subagent_type: code-review`) instead of reading diffs and writing the review inline. Review runs in a forked Opus context — diff reading, file expansion, and reasoning stay out of the main thread; only the report comes back.

## When to delegate vs. handle inline

Delegate when:
- The user asks for a code review, PR review, or "look critically" at recent changes.
- The user asks "what's wrong with X" or "find issues in Y" about a defined scope.
- A natural review point has been reached (just-finished feature, pre-commit check).

Handle inline (do not delegate) when:
- The user wants a *quick sanity check* on a single small snippet visible in conversation. Delegating costs more than reading three lines.
- The user is asking how to fix a *specific known issue*, not asking for issue discovery.
- The user wants a discussion or back-and-forth about a design choice — that is conversation, not review.

## Crafting the delegation prompt

The subagent's default scope is the working tree against the merge base with main. Override only when the user names something else.

Examples:

- User: "review my changes" → Delegate with empty prompt. Default scope handles it.
- User: "code review the auth refactor" → "Review the auth refactor in the current working tree."
- User: "review PR #482" → "Review PR #482."
- User: "look at src/api/handlers.go" → "Review src/api/handlers.go."
- User: "review the last 3 commits" → "Review the commit range HEAD~3..HEAD."
- User: "security-focused review" → "Review the current working tree with emphasis on security (auth, input validation, secret handling, injection)."

## Anti-patterns

- Reading the diff yourself and writing the review in the main session. The subagent owns this; doing it inline burns the main context on diff content.
- Asking the subagent for full code blocks or diffs in its report. It returns findings keyed to `file:line` — the code is in the working tree.
- Delegating mid-discussion before the user has actually asked for review. "Should I refactor X?" is not a review request.
