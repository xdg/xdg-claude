# Claude Plugin Development Repository

This repository contains Claude Code plugins (agents, skills, commands, hooks) for extending Claude's capabilities. Use this guide as reference when developing, testing, and distributing plugins.

---

# Claude Code Plugins Reference

## What are Plugins?

Claude Code plugins are custom collections of commands, agents, skills, hooks, and MCP servers packaged in a Git repository. Plugins:

- Install with a single command (`/plugin`)
- Work across terminal and VS Code environments
- Enable sharing reusable workflows across projects and teams
- Automate development tasks and standardize practices
- Extend Claude's capabilities with specialized knowledge

## Plugin Architecture

### Component Types

**Skills** - User-invoked or model-invoked capabilities (replaces commands as of Claude Code 2.1.3)
- Defined in `skills/skill-name/SKILL.md` files with supporting resources
- Each skill isolated in its own directory
- Lazily loaded only when Claude determines they're needed
- Three patterns cover most needs: knowledge skill (Type 1), main-agent task (Type 2), and subagent task (Type 3). Either task type can add a `/<activity>` slash command. See "The three skill patterns" below.
- Best for: Domain expertise, complex workflows, agent routing, specialized knowledge

**Commands** (legacy) - Custom slash commands; use skills instead
- Defined in `commands/*.md` files
- As of Claude Code 2.1.3, commands and skills are merged; prefer `skills/`
- Existing commands still work but `skills/` is the recommended path

**Agents (Sub-agents)** - Specialized AI assistants with isolated context
- Defined in `agents/*.md` files
- Have their own system prompt and tool permissions
- Routed to via skill frontmatter (`agent` field) or the Agent tool (`subagent_type`)
- Best for: Intelligent analysis requiring reasoning and adaptation

**Hooks** - Event handlers that run shell commands at lifecycle points
- Defined in `hooks/hooks.json` files with optional `hooks/references/` for content
- Can validate, block, or enhance tool usage
- SessionStart hooks can inject context from reference files
- Best for: Automation, validation, code formatting, injecting session context

**MCP Servers** - Model Context Protocol integrations
- Defined in `.mcp.json` file
- External tool and service integrations
- Best for: Database access, API integrations, system tools

### Standard Directory Structure

```
plugin-name/
├── .claude-plugin/
│   ├── plugin.json          # Required: plugin manifest
│   └── marketplace.json     # Optional: for distribution
├── skills/                  # Skills (user-invoked and model-invoked)
│   └── skill-name/         # Each skill in its own directory
│       ├── SKILL.md
│       ├── scripts/        # Executable code
│       ├── reference/      # Documentation loaded as needed
│       └── assets/         # Files used in output
├── agents/                  # Specialized sub-agents
│   └── helper.md
├── commands/                # (legacy) Use skills/ instead
│   └── example.md
├── hooks/                   # Hook configurations
│   ├── hooks.json
│   ├── session-start.sh    # Hook scripts
│   └── references/         # Content files for hooks to load
└── .mcp.json               # MCP server definitions
```

**Critical:** All component directories must be at plugin root, NOT inside `.claude-plugin/`.

---

# Deep Dive: Agent Skills

## What Makes Skills Special

Skills transform Claude from general-purpose to specialized agent through **progressive disclosure** - a three-level loading system that minimizes context usage while maximizing capability:

**Level 1: Metadata (always loaded, ~100 words)**
- Name and description in SKILL.md frontmatter
- Pre-loaded into system prompt at startup
- Gives Claude just enough info to know when to use each skill

**Level 2: SKILL.md body (loaded when triggered, <5k words)**
- Procedural instructions and workflow guidance
- Loaded only when Claude determines skill is relevant
- Keeps core instructions lean and focused

**Level 3: Bundled resources (loaded on-demand, unlimited)**
- `scripts/` - Executed without reading into context
- `reference/` - Documentation loaded only when needed
- `assets/` - Files used in output, never pollute context

## Skills vs Traditional Approaches

**Traditional:** All instructions loaded upfront, consuming context regardless of relevance

**Skills approach:**
- **Discoverable** - Claude can browse available capabilities via metadata
- **Lazy-loaded** - Content loaded only when needed
- **Executable** - Scripts run deterministically without token generation
- **Composable** - Multiple skills combine for complex workflows
- **Specialized** - Each skill focuses on specific domain

## Skill Design Principles

### The three skill patterns

Most plugin needs fall into one of three patterns. Two axes decide which: is the value Claude *knowing* something or *doing* something (knowledge vs. task), and — for a task — does it run in the **main agent** or a forked **subagent**. Invocation (model-triggered, `/slash`, or both) is a separate frontmatter choice that applies to whichever pattern you pick. Classify the activity before writing files.

**Type 1 — Knowledge skill.** Reference content Claude reads in the main conversation and applies for the rest of the session: conventions, patterns, style guides, domain knowledge, tool usage notes.
- Structure: a single `skills/<name>/SKILL.md`. No subagent, no `context: fork`. The body becomes standing instructions for the session.
- Use when the value is *Claude knowing something while it works*, not *Claude doing a delimited task*.
- Examples: `api-conventions` (REST naming and error formats this codebase uses), `internal-services` (directory of services and their owners), `using-foo-cli` (how to use an in-house CLI tool).

**Type 2 — Main-agent task.** A workflow Claude carries out *in the main conversation*. The skill body is the workflow; it runs in the main thread, optionally spawning its own subagents for sub-steps.
- Structure: a single `skills/<activity>/SKILL.md` whose body is the workflow. No dedicated subagent, no `context: fork`. A slash command is just frontmatter on this one file (see "Slash commands on task skills").
- Use when the loop must stay in the main thread: it needs ongoing human-in-the-loop interaction, or it orchestrates its own subagents and the orchestration state belongs in the main context. Context isolation is either unwanted or already delivered by the inner subagents it spawns.
- Examples: `adversarial-implementation` (drives a TODO.md, delegating each item to isolated subagents while keeping the loop, human checks, and commits in the main thread); a release-checklist runner that pauses for human confirmation between steps.

**Type 3 — Subagent task.** An activity Claude carries out by delegating to a forked subagent, so its file reads and intermediate reasoning stay out of the main context.
- Structure: a **subagent** (Piece 1) and an **educational skill** (Piece 2), plus an optional **user-entry skill** (Piece 3) when you want a `/<activity>` slash command. The slash wrapper is a variant, not a separate type.
- Use when the activity produces output that would clutter the main context, or when you want the harness to enforce a restricted toolset/permission mode on the work.
- Examples: `dependency-impact` analysis after code changes touch shared modules; `code-review`; `commit`; `refactor`. Add Piece 3 for the ones a user invokes frequently (`/commit`, `/code-review`); omit it for the ones Claude only triggers from conversational signals.

### Slash commands on task skills

Both task types can expose a `/<activity>` command, but the cost differs sharply, and the reason is forking.

**Main-agent task (Type 2) + slash = a frontmatter toggle.** The workflow already lives in one skill body that runs in the main thread. A slash command changes nothing structural: keep the single file, add `argument-hint`, reference `$ARGUMENTS` in the body with a fallback line, and set `disable-model-invocation: true` if it should be user-only. There is **one substrate** (the skill body) and it serves both paths — user `/<activity> args` substitutes `$ARGUMENTS`; a model invocation runs the same body with no args. Nothing to reconcile.
- Do **not** add `context: fork` or `agent:` to a main-agent task. Those fork the body into a subagent, which is exactly what this pattern avoids. The file looks superficially like a Piece 3 wrapper but is the opposite: it holds the whole workflow and runs in place.

**Subagent task (Type 3) + slash = a third file (Piece 3).** Forking splits the work across two substrates (the subagent's system prompt and the skill's first user turn) and two invocation paths that must be wired to the same subagent. That reconciliation problem — and the three-piece structure that solves it — is the subject of the next two subsections. It applies to subagent tasks only.

### Why two entry skills converge on one subagent (subagent tasks)

User invocation and Claude invocation use different substrates:

- **User → Piece 3.** When the user types `/<activity> args`, Claude Code substitutes `$ARGUMENTS` into the skill body and forks into the named agent. The rendered body becomes the subagent's first user turn. This is template substitution; it works because the user supplies the arguments.
- **Claude → Agent tool.** When Claude invokes a skill via the Skill tool, it does not pass arguments — unlike a user typing `/command <args>`, where the harness substitutes those args into `$ARGUMENTS`. So a `context: fork` wrapper invoked by Claude renders with no values to fill in. Claude's natural delegation surface is instead the Agent tool, where it crafts the first-user-turn prompt directly. (The runtime bug under "Known runtime bug" — `$ARGUMENTS` dropped on skill-to-skill fork — is one symptom of this broader mismatch.)

The two paths must converge on the same subagent. Otherwise the task description lives in two places — Piece 2's prose *plus* Piece 3's body, or worse, a skill body that hand-rolls a brief for a generic agent — and the copies drift. Piece 2 teaches Claude how to use the Agent tool path; Piece 3 gives the user the template-substitution path; the subagent is the single source of truth they share.

Other benefits of routing both paths through a named subagent:

1. **Context isolation.** The subagent runs in a forked context. File reads, tool output, and intermediate reasoning stay there instead of consuming main-thread tokens. A skill body that briefs a generic agent inline puts that scaffolding in the main thread instead, where it sits for the rest of the session.
2. **Enforced permissions.** `tools`, `model`, and `permissionMode` set in subagent frontmatter are enforced by the harness. The same restrictions written into a prompt for a generic agent are advisory — the agent can ignore them.
3. **Right substrate for each surface.** The subagent body becomes its system prompt — durable role, workflow, and constraints. The skill body becomes the first user turn — task-specific arguments. Each surface holds the kind of content it is good at.
4. **Discoverable.** Named subagents appear in the Agent tool listing with their descriptions; Claude picks among them naturally. An activity buried in skill prose is invisible until that skill triggers.

### The pieces (subagent tasks)

A subagent task is built from up to three pieces. Pieces 1 and 2 are always required; Piece 3 is added only for a slash command. (A main-agent task has no pieces — it is the single skill file described under "Slash commands on task skills.")

**Piece 1 — the subagent (`agents/<activity>.md`).** Required for every subagent task. Holds all baseline behavior in its body (this becomes the system prompt for both invocation paths).
- `description`: concise statement of when Claude should delegate. The only descriptive surface visible in the Agent tool listing — put trigger phrases first.
- `tools` / `model` / `permissionMode`: set explicitly; do not rely on inheritance.
- `skills:` preloads knowledge skills (Type 1) the activity always needs.
- The body must produce sensible behavior when the first user turn is empty or vague. It is the fallback for empty-args user invocations from Piece 3.

**Piece 2 — the educational skill (`skills/how-to-<activity>/SKILL.md`).** Required for every subagent task. Teaches Claude *when* to spawn the subagent and *what* prompt to craft. Pure documentation; not a command.
- Name pattern: `how-to-<activity>`. The imperative phrasing matches Claude's reader-perspective and reads cleanly across all activity types.
- Required frontmatter: `user-invocable: false`.
- The `description` should front-load the user's likely trigger phrases.
- Body covers only the delta the subagent's own description cannot hold: examples of good delegation prompts, when to delegate vs. handle inline, anti-patterns, argument-crafting guidance. Do not restate the subagent's role.

**Piece 3 — the user-entry skill (`skills/<activity>/SKILL.md`).** Added only when a subagent task exposes a slash command. Thin wrapper that turns `/<activity> args` into a fork into the subagent.
- Required frontmatter: `disable-model-invocation: true`, `context: fork`, `agent: <activity>`.
- Body: `$ARGUMENTS` followed by a one-line default trigger so the forked first turn is never empty. Example:
  ```
  $ARGUMENTS

  If the above is empty, run the default <activity> workflow.
  ```
  An empty first user turn is unreliable — the harness may suppress the fork, and even if it forks the model often asks for clarification despite a system-prompt instruction. The trigger sentence is not baseline behavior; it just guarantees a non-empty turn so the subagent's system prompt takes over.
- Nothing else belongs here. No workflow steps, no scope rules, no message conventions — those belong in Piece 1.

To drop the slash command from a subagent task, omit Piece 3. The other two pieces are unchanged. Adding Piece 3 later is mechanical: its body is `$ARGUMENTS` plus the default-trigger line, its frontmatter is fixed, and it does not affect the existing pieces.

### SKILL.md frontmatter fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (matches the slash command, for Piece 3 or a main-agent task) |
| `description` | Yes | What the skill does and when to use it (third-person) |
| `context` | No | `fork` to run the skill body as a task prompt in a subagent (Piece 3 only — never on a main-agent task) |
| `agent` | No | Agent name to route to (requires `context: fork`) |
| `argument-hint` | No | Placeholder shown after `/<name>` in the slash menu; for any slash-invocable skill |
| `disable-model-invocation` | No | `true` for a user-only slash skill — Piece 3, or a main-agent task the user alone should trigger |
| `user-invocable` | No | `false` for Piece 2 — Claude reads it as guidance; user has no slash command |

The two opt-out fields are not interchangeable:

| Field | Effect | Used on |
|-------|--------|---------|
| `disable-model-invocation: true` | User can type `/<name>`; Claude must not auto-call | Piece 3, or a user-only main-agent task |
| `user-invocable: false` | Claude can read/apply; user has no slash command | Piece 2 (educational skill) |

### Description openers for `how-to-<activity>` skills (Piece 2)

Front-load the user's likely trigger phrases, then state the action the skill enables. The trigger clause tells Claude *when* to load the skill; the action clause tells it *what* the skill is for.

Pattern: `When the user asks to <triggers>, consult this skill to <decide whether to delegate to the <activity> subagent and how to craft the prompt>.`

Examples:

- `how-to-commit`: "When the user asks to commit, check in, or save changes, consult this skill to decide whether to delegate to the commit subagent and how to craft the prompt."
- `how-to-code-review`: "When the user asks for a code review, PR review, or critical look at recent changes, consult this skill to decide whether to delegate to the code-review subagent and how to craft the prompt."
- `how-to-security-review`: "When the user asks for a security audit, vuln check, or wants security issues identified, consult this skill to decide whether to delegate to the security-review subagent and how to craft the prompt."
- `how-to-refactor`: "When the user asks to refactor, restructure, or clean up code without changing behavior, consult this skill to decide whether to delegate to the refactor subagent and how to craft the prompt."
- `how-to-plan`: "When the user asks to plan, design an approach, or think through work before implementing, consult this skill to decide whether to delegate to the plan subagent and how to craft the prompt."
- `how-to-research`: "When the user asks to research, investigate, explore the codebase, or understand how something works, consult this skill to decide whether to delegate to the research subagent and how to craft the prompt."

### Invocation paths

- **Knowledge skill (Type 1).** Claude loads it when the description matches; the body becomes standing context. A user may also type `/<name>` to load it on demand. No arguments, no workflow.
- **Main-agent task (Type 2).**
  - *User →* `/<activity> args`: the harness substitutes `$ARGUMENTS` into the skill body and Claude runs that workflow in the main thread.
  - *Claude →* invokes the skill via the Skill tool (unless `disable-model-invocation: true`); the same body runs with no args, its fallback line taking over.
  - Both paths run one file in the main context — no fork, no convergence.
- **Subagent task (Type 3).**
  - *User →* `/<activity> args`: Piece 3 forks → subagent runs with `args` as the first user turn, baseline from the subagent's system prompt.
  - *Claude →* reads Piece 2, decides to delegate, calls the Agent tool on `<activity>` with crafted instructions. Piece 3 is not on this path.
  - Both paths converge on the same subagent.

**UI rendering differs by path.** Agent-tool invocations render as a colored "Agent: <name>" panel streamed turn-by-turn. Slash-command forks (`context: fork`, Piece 3) render the subagent's final output as `<local-command-stdout>` with no colored panel — the harness packages the whole fork as a single slash-command result. Absence of the colored panel after `/<activity>` does *not* mean the fork failed; check `SubagentStop` if in doubt. A main-agent task's `/<activity>` does not fork, so it streams as ordinary main-thread turns.

### Resource types (any skill)

- **scripts/** — code rewritten repeatedly or requiring deterministic reliability
- **reference/** — documentation Claude should reference while working (schemas, API docs, policies)
- **assets/** — files used in final output, not loaded into context

### Anti-patterns

- **Baseline behavior in Piece 3's body.** Only the user path sees it; the subagent should hold it.
- **Workflow or scope logic in Piece 3.** A one-line "if empty, run defaults" trigger is fine and required — but multi-step instructions, scope rules, or message conventions belong in Piece 1. The trigger guarantees a non-empty first turn; the subagent's system prompt makes it meaningful.
- **Restating the subagent in Piece 2.** Recurring token cost for zero signal.
- **Cramming when-to-delegate guidance into the subagent's `description`.** The listing budget is small. Long guidance belongs in Piece 2.
- **Omitting `disable-model-invocation: true` on Piece 3.** The wrapper assumes user-typed text drives behavior; Claude calling it produces nonsense.
- **Duplicating tool/permission configuration across the wrapper and the subagent.** The subagent's frontmatter governs the forked context.
- **Adding a slash wrapper (Piece 3) by default.** If the user wouldn't naturally type the command, omit it. An unused Piece 3 costs maintenance and clutters the slash menu.
- **Putting `context: fork` on a main-agent task.** That forks the workflow into a subagent and discards the very thing the pattern exists for — a loop that stays in the main thread for human interaction or self-orchestration.
- **Forking work that needs main-thread interaction into a subagent task.** If the activity must pause for human confirmation mid-run or hold orchestration state across many sub-steps, it is a main-agent task. A subagent can't carry on a fluid back-and-forth with the user.
- **Cramming a context-heavy, autonomous workflow into a main-agent task.** If it would dump file reads and intermediate reasoning into the main context and needs no human interaction, isolate it as a subagent task.

### Known runtime bug

Skill-to-skill invocation of a `context: fork` skill silently drops `$ARGUMENTS` substitution (issue #34164). Direct user invocation is unaffected. Do not build meta-skills that programmatically invoke Piece 3 until this is fixed.

### Writing Guidelines

1. **Use imperative/infinitive form** - Write verb-first instructions (NOT second person)
   - ✅ "Run tests before committing"
   - ❌ "You should run tests before committing"

2. **Start with concrete examples** - Understand real usage before building

3. **Avoid duplication** - Information lives in SKILL.md OR references, not both

4. **Keep SKILL.md lean** - Move detailed reference material to separate files (target <5k words)

5. **Metadata quality matters** - Description determines when Claude uses the skill

6. **Think about another Claude** - Write for AI consumer, focus on non-obvious procedural knowledge

7. **Large file handling** - If references >10k words, include grep search patterns in SKILL.md

---

# Plugin Manifest (plugin.json)

**Location:** `.claude-plugin/plugin.json`

**Minimal example:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Clear description of what plugin does"
}
```

**Full schema:**
```json
{
  "name": "my-plugin",              // Required: Plugin identifier
  "version": "1.0.0",                // Required: Semantic version
  "description": "Plugin purpose",   // Required: What it does
  "author": {                        // Optional
    "name": "Your Name",
    "email": "you@example.com"
  },
  "agents": [                        // Optional: Agent paths
    "./agents/helper.md"
  ],
  "hooks": [                         // Optional: Hook paths
    "./hooks/hooks.json"
  ],
  "commands": [                      // Legacy: use skills/ instead
    "./commands/example.md"
  ]
}
```

**Note:** Skills, agents, and hooks placed under their standard directories (`skills/`, `agents/`, `hooks/`) are auto-discovered and do not need manifest entries. The `agents` and `hooks` arrays are only needed when files live outside those directories. The `"commands"` field is legacy; prefer `skills/` for new development.

---

# Creating Plugins Step-by-Step

## 1. Initialize Structure

```bash
mkdir my-plugin
cd my-plugin
mkdir -p .claude-plugin agents skills hooks
```

## 2. Create Manifest

Create `.claude-plugin/plugin.json`:
```json
{
  "name": "my-first-plugin",
  "description": "A simple example plugin",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

## 3. Add a skill (optional)

Pick a skill type from "The three skill patterns" above. Each type has a different file layout. Skills are auto-discovered from `skills/` and need no manifest entry.

### Type 1 — knowledge skill

Single file at `skills/<name>/SKILL.md`:
```markdown
---
name: api-conventions
description: REST naming and error formats this codebase uses
---

# API Conventions

[Standing reference content Claude consults during the session.]
```

### Type 2 — main-agent task

Single file at `skills/<activity>/SKILL.md`. The body is the workflow Claude runs in the main thread. No subagent, no `context: fork`. Add the slash-command frontmatter only if the user should invoke it directly; set `disable-model-invocation: true` to make it user-only:
```markdown
---
name: adversarial-implementation
description: Implement TODO.md items via isolated subagents, then verify correctness.
disable-model-invocation: true
argument-hint: "[task, or empty to take the next TODO.md subsection]"
---

Task: `$ARGUMENTS`
(If empty, read TODO.md and implement the next incomplete subsection.)

## Workflow
[the phased workflow Claude executes in the main thread, spawning its own
subagents for individual steps as needed]
```

The whole workflow lives in this one body — it is not a thin wrapper. Omit `disable-model-invocation` to let Claude trigger it from conversational signals too; drop the slash frontmatter entirely for a Claude-only main-agent task.

### Type 3 — subagent task

Two pieces, plus an optional third for a slash command. The subagent (Piece 1) holds behavior; the educational skill (Piece 2) teaches Claude when to delegate. Write Piece 1 using the agent guidance in the next step. Then add Piece 2:

`skills/how-to-dependency-impact/SKILL.md`:
```markdown
---
name: how-to-dependency-impact
description: When code changes touch shared modules, consult this skill to decide whether to delegate to the dependency-impact subagent and how to craft the prompt.
user-invocable: false
---

# Handling shared-module changes

Delegate to the `dependency-impact` subagent via the Agent tool when [...].

## When to delegate vs. handle inline
[examples of clear-delegate vs. handle-inline cases]

## Crafting the delegation prompt
[concrete prompt examples for common scenarios]

## Anti-patterns
[misuses to avoid]
```

For a `/<activity>` slash command, add Piece 3 (the user-entry wrapper) to the two pieces above. Unlike a main-agent task, this wrapper *does* fork — it carries `context: fork` and `agent:` and holds no workflow of its own:

`skills/<activity>/SKILL.md`:
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

If the above is empty, run the default commit workflow.
```

Body is `$ARGUMENTS` plus a one-line default trigger. The trigger guarantees the forked first turn is non-empty so the fork actually fires; the subagent's system prompt owns the actual workflow.

## 4. Add an Agent (Piece 1, optional)

For a subagent task (Type 3), create the subagent at `agents/<activity>.md`. The subagent body becomes the system prompt for both invocation paths (user `/<activity>` and Claude-initiated Agent calls), so it must hold all baseline behavior and behave sensibly when the first user turn is empty. (A main-agent task has no subagent — its workflow lives in the skill body.)

Example — `agents/code-review.md`:
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

Note: the `name` field matches the corresponding skill name (e.g. `code-review`, not `code-review-agent`). The harness routes by the frontmatter `name`, not the filename.

### Agent Writing Guidelines

**Structure:**
- **Frontmatter**: Required metadata (name, description, tools, optional color)
- **Role**: Establish expertise and purpose using second-person ("You are...")
- **Responsibilities**: Detailed behavioral expectations (mix of second-person framing with imperative instructions)
- **Reporting Back**: Specify return format, emphasizing brevity

**Voice and Tone:**
- Use **second-person** to establish role identity ("You are an expert...")
- Use **second-person** for ongoing responsibilities ("Your job is to...")
- Embed **imperatives** within that frame for specific actions ("Analyze X", "Check Y", "Verify Z")
- This hybrid approach is more effective than pure imperative for establishing agent persona

**Tool Permissions:**

Choose tool access based on the agent's purpose:

*Read-Only Tools (safe for information gathering):*
- **Glob** - File pattern matching
- **Grep** - Code search
- **Read** - Read files (text, images, PDFs, notebooks)
- **WebFetch** - Fetch and analyze web content
- **WebSearch** - Search the web
- **Bash** - Execute commands (run specialized cli tools like ast-grep, rg, jq)

*Write Tools (for agents making changes):*
- **Edit** - Modify existing files
- **Write** - Create/overwrite files
- **NotebookEdit** - Edit Jupyter notebook cells
- **Bash** - Execute commands (can modify filesystem, run builds, etc.)

*Task Management & Communication:*
- **TodoWrite** - Track progress in multi-step tasks
- **AskUserQuestion** - Clarify ambiguous decisions
- **Task** - Launch nested subagents for delegation

*Background Process Management:*
- **BashOutput** - Monitor long-running processes
- **KillShell** - Terminate background shells

*Prompt Expansion:*
- **Skill** - Load specialized skill instructions (preferred for agents)
- **SlashCommand** - Execute custom command prompts (legacy; commands and skills merged in Claude Code 2.1.3, prefer Skill)

*Restricted Tools:*
- **ExitPlanMode** - Controls parent conversation flow; should NOT be available to subagents

*Common Tool Patterns:*
- **All agents**: Skill to enhance capabilities (do not include SlashCommand for new agents)
- **Exploration agents:** Read-only tools + TodoWrite
- **Implementation agents:** Full tool access (read + write + bash)
- **Analysis agents:** Read-only + TodoWrite + AskUserQuestion
- **Specialized agents:** Minimal toolset for focused purpose

**Output Specifications:**
- Default to **brevity** - subagent output pollutes main agent's context
- Return only: outcomes, decisions, actionable findings
- Do NOT return: full content, detailed diffs, file lists (these are in git/filesystem)
- Explicitly state what NOT to include and why
- For multi-item results (e.g., multiple commits), specify format for each

**When to Ask vs. Act:**
- Include explicit section on when to request clarification rather than proceeding
- List specific failure conditions (no data, ambiguous input, detected risks)
- Guide subagent to explain situation and specify what's needed

**Scope Interpretation:**
- Provide clear guidance on how to interpret different types of instructions from main agent
- Handle: specific requests, general requests, edge cases
- Reduce ambiguity in execution

**Naming Conventions:**
- Agent frontmatter `name` is what the harness routes by; it should match the corresponding skill name (e.g., `name: code-review`). The filename is incidental — `agents/code-review.md` is fine.
- Skill→agent routing is handled by skill frontmatter (`context: fork` + `agent`), not by agent descriptions
- Do NOT include `(Use subagent_type: ...)` hints in agent descriptions; this is legacy

## 5. Add Hooks (optional)

Create `hooks/hooks.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "python -c \"import sys; paths = sys.argv[1].split(','); sys.exit(2 if any('.env' in p or 'package-lock.json' in p for p in paths) else 0)\" \"$PATHS\""
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
            "command": "prettier --write \"$PATHS\""
          }
        ]
      }
    ]
  }
}
```

**Hook exit codes:**
- `0` = Success, allow operation
- `2` = Block operation (PreToolUse only, message via stderr)
- Other non-zero = Non-blocking error shown to user

### SessionStart Hooks with References

SessionStart hooks can inject content into Claude's context at the start of every session. Use `hooks/references/` to store content files that the hook script reads and injects.

**Example structure:**
```
hooks/
├── hooks.json
├── session-start.sh
└── references/
    └── content.md
```

**hooks/hooks.json:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**hooks/session-start.sh:**
```bash
#!/usr/bin/env bash
# Use CLAUDE_PLUGIN_ROOT for correct paths regardless of installation location
CONTENT=$(cat "${CLAUDE_PLUGIN_ROOT}/hooks/references/content.md")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(jq -Rs . <<< "$CONTENT")
  }
}
EOF
```

**Environment variables available in hooks:**
- `${CLAUDE_PLUGIN_ROOT}` - Absolute path to your plugin directory (use for all file paths)

This pattern allows you to:
- Keep reference content separate from hook logic
- Use similar structure pattern as skills (hooks use `references/`, skills use `reference/`)
- Inject documentation, style guides, or policies at session start
- Avoid embedding large content in CLAUDE.md files
- Use portable paths via `${CLAUDE_PLUGIN_ROOT}`

---

# Plugin Distribution

## Marketplace Configuration

Create `.claude-plugin/marketplace.json`:
```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "Collection of development plugins",
  "owner": {
    "name": "Team Name",
    "email": "team@example.com"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./my-plugin",
      "description": "Plugin description",
      "version": "1.0.0",
      "category": "development",
      "tags": ["productivity", "automation"],
      "strict": true
    }
  ]
}
```

# Best Practices

## Plugin Design

1. **Single responsibility** - Each plugin solves one problem well
2. **Clear documentation** - Include usage examples and expected behavior
3. **Descriptive names** - Use clear, searchable plugin and command names
4. **Semantic versioning** - Follow semver for version numbers; bump versions in both the per-plugin `.claude-plugin/plugin.json` and the root `.claude-plugin/marketplace.json`
5. **List new plugins in README.md** - When adding a new plugin to this marketplace, add a row to the appropriate table under "List of Plugins" in `README.md` (Essential / CLAUDE.md extensions / Agents / Skills). Pick the category that matches the plugin's primary surface.
6. **Minimal dependencies** - Keep plugins lightweight and focused

## Agent Development

1. **Minimal tool permissions** - Only grant tools the agent actually needs; avoid Task, WebFetch, WebSearch, TodoWrite unless essential
2. **Brevity in output** - Specify return format that minimizes context pollution; return outcomes and decisions, not full content
3. **Clear failure modes** - Include "When to Ask" section listing conditions that require clarification
4. **Scope interpretation** - Provide guidance on how to interpret different instruction types from main agent
5. **Hybrid voice** - Use second-person for role/responsibilities, embed imperatives for specific actions

## Skills Development

1. **Context efficiency** - Use progressive disclosure, keep SKILL.md under 5k words
2. **Scripts as black boxes** - Include `--help` flags, design for execution not reading
3. **Smart references** - Large docs should have grep search patterns in SKILL.md
4. **Clear metadata** - Description determines when Claude invokes skill

## Security

1. **Review plugin source** - Always inspect code before installing
2. **Trust verification** - Only install from trusted marketplaces and authors
3. **Permission awareness** - Understand what tools each agent can use
4. **Sensitive data protection** - Use hooks to prevent committing secrets
5. **Skills from trusted sources** - Skills can direct Claude to invoke tools and execute code

## Development Workflow

1. **Test locally first** - Use local marketplace for rapid iteration
2. **Progressive complexity** - Start simple, add features incrementally
3. **Hook validation** - Test exit codes and error handling thoroughly
4. **Version control** - Track all plugin changes in Git
5. **Performance** - Keep hook commands fast (<1s)

## Team Standardization

1. **Shared marketplaces** - Create team-specific plugin collections
2. **Consistent naming** - Establish plugin naming conventions
3. **Code review** - Review plugin changes like production code
4. **Documentation** - Maintain plugin usage guides
5. **Onboarding** - Include plugin setup in developer onboarding

---

# Complete Examples

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

# Resources

- **Official Docs:** https://docs.claude.com/en/docs/claude-code/plugins
- **Skills**: https://docs.claude.com/en/docs/claude-code/skills
- **Plugin Announcement:** https://www.anthropic.com/news/claude-code-plugins
- **Marketplace Guide:** https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- **Example Plugins:** https://github.com/anthropics/claude-code
