# Writing agents (Piece 1 of a subagent task)

Create the subagent at `agents/<activity>.md`. The body becomes the system prompt for both invocation paths (user `/<activity>` and Claude-initiated Agent calls), so it must hold all baseline behavior and behave sensibly when the first user turn is empty.

## Worked example — `agents/code-review.md`

```markdown
---
name: code-review
description: Reviews code for quality, bugs, and best practices. Use when the user asks for a code review, PR review, or critical look at recent changes.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
skills:
  - context-efficient-tools:ripgrep
  - context-efficient-tools:ast-grep
  - context-efficient-tools:code-structure
---

You review the user's code changes and report issues.

Workflow:
1. If the first user turn names a scope (a PR, a commit range, a path), review that. Otherwise review the working tree against the merge base with the main branch.
2. Read the changed files and surrounding context as needed.
3. Identify quality issues, likely bugs, and security concerns. Skip stylistic nits the formatter would catch.
4. Return a structured report (see "Reporting" below).

# Responsibilities

- Quality: readability, maintainability, unnecessary complexity.
- Correctness: edge cases, error handling, null/undefined, concurrency.
- Security: input validation, secret handling, common vulnerability patterns.

# Reporting

Return:
- **Summary:** 1–2 sentences on overall quality.
- **Issues:** Each entry has severity (critical / major / minor), `file:line`, and a one-sentence explanation. Suggest a fix when it fits in a line.

Do not return full code blocks, diffs, or file listings — those are in the working tree. Keep the report scannable.
```

The `name` field matches the corresponding skill name (e.g. `code-review`, not `code-review-agent`). The harness routes by the frontmatter `name`, not the filename.

## Structure

- **Frontmatter** — required metadata (name, description, tools, optional color).
- **Role** — establish expertise and purpose in second person ("You are...").
- **Responsibilities** — detailed behavioral expectations (second-person framing with embedded imperatives).
- **Reporting back** — specify return format, emphasizing brevity.

## Voice and tone

- Use **second-person** to establish role identity ("You are an expert...").
- Use **second-person** for ongoing responsibilities ("Your job is to...").
- Embed **imperatives** within that frame for specific actions ("Analyze X", "Check Y", "Verify Z").
- This hybrid approach beats pure imperative for establishing an agent persona.

## Tool permissions

Choose tool access by the agent's purpose.

*Read-only (information gathering):* **Glob** (file patterns), **Grep** (code search), **Read** (text/images/PDFs/notebooks), **WebFetch** (fetch web content), **WebSearch** (search the web), **Bash** (run CLI tools like ast-grep, rg, jq).

*Write (making changes):* **Edit** (modify files), **Write** (create/overwrite), **NotebookEdit** (edit notebook cells), **Bash** (modify filesystem, run builds).

*Task management & communication:* **TodoWrite** (track multi-step progress), **AskUserQuestion** (clarify decisions), **Task** (launch nested subagents).

*Background process management:* **BashOutput** (monitor long-running processes), **KillShell** (terminate background shells).

*Prompt expansion:* **Skill** (load skill instructions — preferred for agents), **SlashCommand** (legacy; commands and skills merged in 2.1.3, prefer Skill).

*Restricted:* **ExitPlanMode** controls parent conversation flow; should NOT be available to subagents.

*Common patterns:*
- **All agents:** Skill to enhance capabilities (do not include SlashCommand for new agents).
- **Exploration agents:** read-only tools + TodoWrite.
- **Implementation agents:** full access (read + write + bash).
- **Analysis agents:** read-only + TodoWrite + AskUserQuestion.
- **Specialized agents:** minimal toolset for a focused purpose.

Grant only the tools the agent needs; avoid Task, WebFetch, WebSearch, TodoWrite unless essential.

## Output specifications

- Default to **brevity** — subagent output pollutes the main agent's context.
- Return only outcomes, decisions, actionable findings.
- Do NOT return full content, detailed diffs, or file lists — those are in git/filesystem.
- State explicitly what NOT to include and why.
- For multi-item results (e.g. multiple commits), specify the format for each.

## When to ask vs. act

- Include an explicit section on when to request clarification rather than proceeding.
- List specific failure conditions (no data, ambiguous input, detected risks).
- Guide the subagent to explain the situation and specify what's needed.

## Scope interpretation

- Guide how to interpret different instruction types from the main agent (specific request, general request, edge cases).
- Reduce ambiguity in execution.

## Naming conventions

- The frontmatter `name` is what the harness routes by; it should match the corresponding skill name (e.g. `name: code-review`). The filename is incidental — `agents/code-review.md` is fine.
- Skill→agent routing is handled by skill frontmatter (`context: fork` + `agent`), not by agent descriptions.
- Do NOT include `(Use subagent_type: ...)` hints in agent descriptions; this is legacy.
