---
name: how-to-isolated
description: When a task would pollute the main context with intermediate results, file reads, or speculative exploration, consult this skill to decide whether to delegate to the isolated subagent and how to craft the prompt.
user-invocable: false
---

# Handling context-heavy tasks

Delegate to the `isolated` subagent (Agent tool, `subagent_type: isolated`) when a task's working material is large but the answer is small. The fork absorbs the reading, searching, and reasoning; only the structured writeup comes back.

This is the right tool when no topic-specific subagent applies (commit, code-review, refactor, plan-refactor each have their own — prefer those when they fit). The `isolated` subagent is the general-purpose fallback with a tighter return-contract than the built-in `general-purpose` agent.

## When to delegate vs. handle inline

Delegate when:
- The task requires reading many files but the conclusion fits in a paragraph (e.g. "where is feature X implemented?", "which callers depend on Y?", "summarize this 2000-line config").
- An exploration might hit dead ends or produce false leads that would clutter the main thread.
- The work is *parallelizable* with the main task — fire and continue.
- The user explicitly wants something investigated without disturbing the current line of work.

Handle inline (do not delegate) when:
- The task is a single-file read or a one-shot grep. Delegation overhead exceeds the context cost.
- The work is iterative back-and-forth with the user — the subagent runs once and returns.
- A topic-specific subagent fits (commit, code-review, refactor, plan-refactor). Use the specific one.
- The user wants to *see* the intermediate steps (e.g. they are learning the codebase). Isolation hides the work.

## Crafting the delegation prompt

Hand the subagent a clear deliverable, not a process. State the question; let it choose the path. Include any starting points (file paths, symbol names, ticket IDs) the user mentioned, since the fork starts with no conversation context.

Examples:

- User: "find out how rate limiting works in this codebase" → "Investigate how rate limiting is implemented in this codebase. Identify the responsible module(s), the algorithm, and where limits are configured. Report file:line references."
- User: "is feature X still wired up?" → "Determine whether feature X is still reachable from the entry points (HTTP routes, CLI commands, scheduled jobs). Report yes/no with file:line evidence; flag any dead branches you find."
- User: "skim this 5000-line log for what failed" → "Examine the log at <path>. Identify the failure, the immediate cause, and any earlier warnings that look related. Report under 200 words; quote the exact failure lines."

## Anti-patterns

- Passing a vague directive ("look at the codebase") with no deliverable. The subagent will return a vague writeup.
- Using `isolated` when a topic-specific subagent fits. Specific agents have richer defaults and tighter contracts.
- Asking the subagent to make permanent changes. Its contract is *investigation and reporting*; if a change is needed, take its findings and act in the main thread (or delegate to an implementation agent).
- Forwarding ongoing conversation context. The fork starts clean; everything the subagent needs must be in the prompt.
