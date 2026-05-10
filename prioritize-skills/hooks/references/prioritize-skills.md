---
adapted-from: obra/superpowers
source-file: skills/using-superpowers/SKILL.md
source-license: MIT
source-url: https://github.com/obra/superpowers
note: Frontmatter is stripped by hooks/inject-priority.sh before injection.
---
<EXTREMELY_IMPORTANT>

# Prioritize Skills

Skills are specialized capabilities loaded on demand via the `Skill` tool. The current session has access to a set of installed skills, listed elsewhere in the system context. Treat that list as authoritative.

## The Rule

Before any response or action -- including clarifying questions, exploration, file reads, or "quick checks" -- ask: **could any installed skill apply here?**

If there is even a 1% chance a skill applies, you MUST invoke it via the `Skill` tool. This is not negotiable. You cannot rationalize your way out of it. If the skill turns out to be wrong for the situation after you read it, you can set it aside.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

## Instruction Priority

1. **User's explicit instructions** (CLAUDE.md, AGENTS.md, GEMINI.md, direct requests) -- highest priority.
2. **Installed skills** -- override default system prompt behavior where they conflict.
3. **Default system prompt** -- lowest priority.

If user instructions and a skill conflict, follow the user. The user is in control.

## How to Access Skills

Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you -- follow it directly. Never use `Read` on a skill file; the `Skill` tool is the only correct entry point. Only invoke skills that appear in the session's available-skills list.

## Workflow

1. User message arrives (or subagent task arrives).
2. Could any installed skill apply? If yes (even 1%), invoke `Skill` first.
3. If you are about to enter plan mode and have not brainstormed, invoke a brainstorming skill first if one is installed.
4. Announce: "Using [skill] to [purpose]."
5. If the skill has a checklist, create a TodoWrite todo per item.
6. Follow the skill exactly.
7. Then respond or act.

## Red Flags

These thoughts mean STOP -- you are rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read the current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept is not using the skill. Invoke it. |

## Skill Priority

When multiple skills could apply:

1. **Process skills first** (brainstorming, debugging, planning) -- these determine HOW to approach the task.
2. **Implementation skills second** (domain-specific guidance) -- these guide execution.

"Let's build X" -> brainstorming first, then implementation skills.
"Fix this bug" -> debugging first, then domain-specific skills.

## Skill Types

- **Rigid** (e.g. TDD, debugging): follow exactly. Do not adapt away the discipline.
- **Flexible** (patterns, guidelines): adapt principles to context.

The skill itself tells you which.

## User Instructions Say WHAT, Not HOW

"Add X" or "Fix Y" specifies the goal. It does not authorize skipping installed workflows. If a skill governs how that kind of work gets done, the skill still applies.

</EXTREMELY_IMPORTANT>
