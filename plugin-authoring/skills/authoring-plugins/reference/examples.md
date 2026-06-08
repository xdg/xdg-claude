# Complete worked examples

One example per pattern, plus a standalone hook plugin.

## Example 1: `/commit` plugin (Type 3 subagent task, all three pieces)

```
commit-plugin/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── commit.md                       # Piece 1: subagent
└── skills/
    ├── how-to-commit/
    │   └── SKILL.md                    # Piece 2: educational skill
    └── commit/
        └── SKILL.md                    # Piece 3: user-entry wrapper
```

**`agents/commit.md` (Piece 1):**
```markdown
---
name: commit
description: Stages and commits current working changes with a well-formed message. Use when the user asks to commit, check in, or save changes.
tools: Bash(git:*), Read, Grep
model: sonnet
permissionMode: acceptEdits
---

You stage and commit the user's current changes.

Workflow:
1. Run `git status` and `git diff --staged` (and `git diff` if nothing is staged) to understand the changes.
2. If nothing is staged and there are unstaged changes to tracked files, stage them. Do not add untracked files without an explicit instruction.
3. Compose a commit message: imperative subject under 72 chars; optional body explaining the *why* if non-obvious.
4. Run `git commit`.
5. Report the resulting commit hash and one-line summary.

If the first user turn provides specifics (subject hint, scope, files to include or exclude), follow them. If empty, perform the default workflow above.

Never push. Never amend without an explicit instruction.
```

**`skills/how-to-commit/SKILL.md` (Piece 2):**
```markdown
---
name: how-to-commit
description: When the user asks to commit, check in, or save changes, consult this skill to decide whether to delegate to the commit subagent and how to craft the prompt.
user-invocable: false
---

# Handling commit requests

Delegate to the `commit` subagent via the Agent tool when the user asks to commit work.

## When to delegate vs. handle inline

Delegate when:
- The user asks to commit, check in, or save the current state.
- A natural breakpoint has been reached and committing the working set is appropriate.

Handle inline (do not delegate) when:
- The user is mid-discussion about what should go in the commit and hasn't decided.
- The user explicitly wants a step-by-step walkthrough instead of an autonomous commit.

## Crafting the delegation prompt

Pass any subject hints, scope instructions, or include/exclude rules the user mentioned.

- User: "commit this" → Delegate with empty prompt; subagent's default workflow handles it.
- User: "commit just the auth changes" → Delegate with: "Stage and commit only the changes in the auth module."
- User: "commit with subject 'fix: handle null token'" → Delegate with: "Use subject line: fix: handle null token"

## Anti-patterns

- Do not run `git commit` directly in the main session. The subagent owns this.
- Do not delegate when the user is still exploring whether to commit. Wait for a clear instruction.
```

**`skills/commit/SKILL.md` (Piece 3):**
```markdown
---
name: commit
description: Commit the current working changes.
disable-model-invocation: true
context: fork
agent: commit
argument-hint: "[subject hint or scope]"
---

$ARGUMENTS

If the above is empty, run the default commit workflow over current changes.
```

To drop the slash command (Claude-triggered only, no `/commit`), delete `skills/commit/SKILL.md` (Piece 3). The other two pieces are unchanged.

## Example 2: `/adversarial-implementation` plugin (Type 2 main-agent task)

A workflow that drives a `TODO.md`, delegating each item to isolated subagents while keeping the loop, human-verification pauses, and commits in the main thread. One file — no subagent, no `context: fork`.

```
adversarial-implementation/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── adversarial-implementation/
        └── SKILL.md
```

**`skills/adversarial-implementation/SKILL.md`:**
```markdown
---
name: adversarial-implementation
description: Implement TODO.md items via isolated subagents, then verify correctness.
disable-model-invocation: true
argument-hint: "[task, or empty to take the next TODO.md subsection]"
---

Task: `$ARGUMENTS`
(If empty, read TODO.md and implement the next incomplete subsection.)

## Adversarial Implementation Protocol
[phased workflow: plan the subsection → implement each item via an isolated
subagent → verify with independent lint/test/review subagents → code review →
human verification → commit. The loop, state, and human pauses stay here in the
main thread; the heavy work is isolated in the subagents this body spawns.]
```

Contrast with Example 1: there is no `context: fork`, no `agent:`, and the body is the full workflow rather than a `$ARGUMENTS` wrapper. `disable-model-invocation: true` makes it user-only; drop it to let Claude trigger the workflow too.

## Example 3: Security Audit Plugin (Type 1 knowledge skill)

```
security-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── security-audit/
│       ├── SKILL.md
│       ├── reference/
│       │   ├── owasp-top-10.md
│       │   └── crypto-best-practices.md
│       └── scripts/
│           └── scan.py
└── hooks/
    └── hooks.json
```

**skills/security-audit/SKILL.md** (knowledge skill, no agent routing):
```markdown
---
name: security-audit
description: Comprehensive security analysis following OWASP Top 10 and crypto best practices
---

# Security Audit Skill

Perform security analysis on code and configurations.

## When to Use
- Reviewing code for vulnerabilities
- Auditing authentication/authorization
- Checking cryptographic implementations
- Validating input handling

## Process
1. Run automated scan: `python scripts/scan.py` (relative to skill directory)
2. Reference [OWASP Top 10 guidance](./reference/owasp-top-10.md)
3. Check [crypto best practices](./reference/crypto-best-practices.md)
4. Document findings with severity ratings
```

## Example 4: Code Quality Hook

**hooks/hooks.json:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|MultiEdit|Write",
            "type": "command",
            "command": "if echo \"$PATHS\" | grep -qE '\\.(env|lock)$'; then echo 'Blocked: Cannot modify protected files' >&2; exit 2; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "if echo \"$PATHS\" | grep -q '\\.ts$'; then prettier --write \"$PATHS\" && eslint --fix \"$PATHS\"; fi"
          }
        ]
      }
    ]
  }
}
```
