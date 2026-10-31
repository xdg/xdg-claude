---
name: how-to-comment-review
description: When the user asks to review, trim, tighten, or evaluate code comments in a file, diff, or branch -- or asks whether comments are too long, redundant, missing, ambiguous, or inconsistent in their terminology -- consult this skill to decide whether to delegate to the comment-review subagent, how to craft the prompt, and how to apply its report.
user-invocable: false
---

# Handling comment review requests

Delegate to the `comment-review` subagent (Agent tool, `subagent_type: comment-review`) instead of reading comments and judging them inline. The subagent never edits files. It returns a report with exact Old/New replacement text for each finding; applying it is your job.

## When to delegate vs. handle inline

Delegate when:
- The user asks to review, trim, tighten, or audit comments in a file, package, diff, branch, or PR.
- The user asks whether comments are redundant, stale, missing, or inconsistent in terminology.
- A workflow step calls for a comment audit before commit or merge.

Handle inline (do not delegate) when:
- The user asks about one comment already visible in the conversation.
- The user asks you to write a comment for code you just wrote. That is authoring, not review.

## Crafting the delegation prompt

The default target is uncommitted changes (staged, unstaged, and untracked). Name a target only when the user does. Mention clarity or terminology when the user asks about them: the terminology census is skipped on small diffs unless requested.

- "review the comments in my changes" → empty prompt; the default handles it.
- "tighten the comments in session.go" → "Review the comments in session.go."
- "are the comments in pkg/auth consistent?" → "Review the comments in pkg/auth, including the terminology census."
- "check comments on this branch" → "Review comments in the diff from the merge base with main to HEAD."

## Applying the report

The subagent tags each finding **mechanical** or **judgment**, and some findings carry **Needs:** with no patch.

- **With a user present:** show the report and apply only the findings the user picks.
- **Unattended (workflow or orchestrator):** applying mechanical findings is reasonable. Route judgment and Needs findings to a person, or skip them; each one adds a fact or picks a meaning that nobody has confirmed.

Apply each finding as an exact replacement of **Old** with **New** (Edit tool). If Old is not found, the file changed after the review: skip that finding and say so; do not improvise a new patch. Then do what the report's Verifying section says: confirm only comments changed, confirm directives and other protected text are untouched, and run the linter and tests.

## Anti-patterns

- Reading and judging the comments yourself in the main session. The subagent owns the review; doing it inline fills the main context with file contents.
- Asking the subagent to apply its own findings. It has no edit tools by design.
- Applying judgment findings unattended on the grounds that they are "only comments." A wrong contract in a doc comment misleads every caller who reads it.
