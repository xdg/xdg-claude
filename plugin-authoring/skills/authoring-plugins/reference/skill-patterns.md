# The three skill patterns (in depth)

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

## Slash commands on task skills

Both task types can expose a `/<activity>` command, but the cost differs sharply, and the reason is forking.

**Main-agent task (Type 2) + slash = a frontmatter toggle.** The workflow already lives in one skill body that runs in the main thread. A slash command changes nothing structural: keep the single file, add `argument-hint`, reference `$ARGUMENTS` in the body with a fallback line, and set `disable-model-invocation: true` if it should be user-only. There is **one substrate** (the skill body) and it serves both paths — user `/<activity> args` substitutes `$ARGUMENTS`; a model invocation runs the same body with no args. Nothing to reconcile.
- Do **not** add `context: fork` or `agent:` to a main-agent task. Those fork the body into a subagent, which is exactly what this pattern avoids. The file looks superficially like a Piece 3 wrapper but is the opposite: it holds the whole workflow and runs in place.

**Subagent task (Type 3) + slash = a third file (Piece 3).** Forking splits the work across two substrates (the subagent's system prompt and the skill's first user turn) and two invocation paths that must be wired to the same subagent. That reconciliation problem — and the three-piece structure that solves it — is the subject of the next two sections. It applies to subagent tasks only.

## Why two entry skills converge on one subagent (subagent tasks)

User invocation and Claude invocation use different substrates:

- **User → Piece 3.** When the user types `/<activity> args`, Claude Code substitutes `$ARGUMENTS` into the skill body and forks into the named agent. The rendered body becomes the subagent's first user turn. This is template substitution; it works because the user supplies the arguments.
- **Claude → Agent tool.** When Claude invokes a skill via the Skill tool, it does not pass arguments — unlike a user typing `/command <args>`, where the harness substitutes those args into `$ARGUMENTS`. So a `context: fork` wrapper invoked by Claude renders with no values to fill in. Claude's natural delegation surface is instead the Agent tool, where it crafts the first-user-turn prompt directly. (The runtime bug under "Known runtime bug" — `$ARGUMENTS` dropped on skill-to-skill fork — is one symptom of this broader mismatch.)

The two paths must converge on the same subagent. Otherwise the task description lives in two places — Piece 2's prose *plus* Piece 3's body, or worse, a skill body that hand-rolls a brief for a generic agent — and the copies drift. Piece 2 teaches Claude how to use the Agent tool path; Piece 3 gives the user the template-substitution path; the subagent is the single source of truth they share.

Other benefits of routing both paths through a named subagent:

1. **Context isolation.** The subagent runs in a forked context. File reads, tool output, and intermediate reasoning stay there instead of consuming main-thread tokens. A skill body that briefs a generic agent inline puts that scaffolding in the main thread instead, where it sits for the rest of the session.
2. **Enforced permissions.** `tools`, `model`, and `permissionMode` set in subagent frontmatter are enforced by the harness. The same restrictions written into a prompt for a generic agent are advisory — the agent can ignore them.
3. **Right substrate for each surface.** The subagent body becomes its system prompt — durable role, workflow, and constraints. The skill body becomes the first user turn — task-specific arguments. Each surface holds the kind of content it is good at.
4. **Discoverable.** Named subagents appear in the Agent tool listing with their descriptions; Claude picks among them naturally. An activity buried in skill prose is invisible until that skill triggers.

## The pieces (subagent tasks)

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

## Description openers for `how-to-<activity>` skills (Piece 2)

Front-load the user's likely trigger phrases, then state the action the skill enables. The trigger clause tells Claude *when* to load the skill; the action clause tells it *what* the skill is for.

Pattern: `When the user asks to <triggers>, consult this skill to <decide whether to delegate to the <activity> subagent and how to craft the prompt>.`

Examples:

- `how-to-commit`: "When the user asks to commit, check in, or save changes, consult this skill to decide whether to delegate to the commit subagent and how to craft the prompt."
- `how-to-code-review`: "When the user asks for a code review, PR review, or critical look at recent changes, consult this skill to decide whether to delegate to the code-review subagent and how to craft the prompt."
- `how-to-security-review`: "When the user asks for a security audit, vuln check, or wants security issues identified, consult this skill to decide whether to delegate to the security-review subagent and how to craft the prompt."
- `how-to-refactor`: "When the user asks to refactor, restructure, or clean up code without changing behavior, consult this skill to decide whether to delegate to the refactor subagent and how to craft the prompt."
- `how-to-plan`: "When the user asks to plan, design an approach, or think through work before implementing, consult this skill to decide whether to delegate to the plan subagent and how to craft the prompt."
- `how-to-research`: "When the user asks to research, investigate, explore the codebase, or understand how something works, consult this skill to decide whether to delegate to the research subagent and how to craft the prompt."

## Invocation paths

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

## Resource types (any skill)

- **scripts/** — code rewritten repeatedly or requiring deterministic reliability
- **reference/** — documentation Claude should reference while working (schemas, API docs, policies)
- **assets/** — files used in final output, not loaded into context

## Anti-patterns

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

## Known runtime bug

Skill-to-skill invocation of a `context: fork` skill silently drops `$ARGUMENTS` substitution (issue #34164). Direct user invocation is unaffected. Do not build meta-skills that programmatically invoke Piece 3 until this is fixed.

## Writing guidelines

1. **Use imperative/infinitive form** — write verb-first instructions (NOT second person).
   - ✅ "Run tests before committing"
   - ❌ "You should run tests before committing"
2. **Start with concrete examples** — understand real usage before building.
3. **Avoid duplication** — information lives in SKILL.md OR references, not both.
4. **Keep SKILL.md lean** — move detailed reference material to separate files (target <5k words).
5. **Metadata quality matters** — the description determines when Claude uses the skill.
6. **Think about another Claude** — write for an AI consumer; focus on non-obvious procedural knowledge.
7. **Large file handling** — if references exceed ~10k words, include grep search patterns in SKILL.md.
