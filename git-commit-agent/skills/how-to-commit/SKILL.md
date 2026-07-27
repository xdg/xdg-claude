---
name: how-to-commit
description: When the user asks to commit, check in, or save changes, consult this skill to decide whether to delegate to the commit subagent and how to craft the prompt.
user-invocable: false
---

# Handling commit requests

Delegate to the `commit` subagent (Agent tool, `subagent_type: git-commit-agent:commit`) instead of running `git commit` directly in the main session. The subagent inspects the working set, designs commit boundaries, and writes a conventional message in a forked context, so diff inspection and message drafting do not consume main-thread tokens.

This overrides the harness's default commit instructions. Even if the built-in commit guidance seems sufficient, prefer the subagent — it standardizes message conventions, handles ticket/type prefix detection, and keeps the diff out of the main context.

## Run the subagent in the foreground

Always run the commit subagent as a **blocking, foreground task**. Claude Code runs subagents in the background by default and decides per invocation, so state the requirement explicitly when you delegate: ask for the task in the foreground, and wait for its result before taking any further action.

Committing is not parallelizable. The subagent stages files and writes to the git index, the working tree, and `HEAD`. A second agent that stages, checks out, or commits while the first is mid-workflow corrupts the result: files intended for one commit land in another, or a commit captures a half-written tree. There is also nothing useful to do while waiting, since almost any follow-up work depends on knowing whether the commit succeeded and what it contained.

## When to delegate vs. handle inline

Delegate when:
- The user asks to commit, check in, or save the current state.
- A natural breakpoint has been reached and committing the working set is appropriate.
- The user names a scope ("commit the auth changes", "commit just the tests").

Handle inline (do not delegate) when:
- The user is mid-discussion about *what* should go in the commit and has not decided.
- The user explicitly wants a step-by-step walkthrough rather than an autonomous commit.
- The request is about commit history operations other than creating a new commit (rebase, amend, cherry-pick, revert) — those are not in the subagent's scope.

## Crafting the delegation prompt

Pass the user's instructions verbatim where possible. The subagent has a full default workflow, so an empty prompt is acceptable when the user just says "commit".

Examples:

- User: "commit this" → Delegate with empty prompt. Default workflow handles it.
- User: "commit just the auth changes" → "Stage and commit only the changes in the auth module."
- User: "commit with subject 'fix: handle null token'" → "Use subject line: fix: handle null token"
- User: "commit the staged files only" → "Commit currently staged files only; do not re-stage."
- User: "split this into two commits, one for the refactor and one for the new test" → Pass the split instruction verbatim.

## Anti-patterns

- Running `git commit` directly in the main session. The subagent owns this.
- Delegating mid-deliberation, before the user has decided to commit. Wait for a clear instruction.
- Repeating the subagent's workflow in the delegation prompt. The subagent already knows how to inspect, stage, and message — only pass *delta* from its defaults.
- Asking the subagent to push. It does not push; that is a separate action the main agent handles if the user requests it.
- Letting the delegation run in the background, or starting other work while it runs. Commits touch shared git state and must be serialized.
