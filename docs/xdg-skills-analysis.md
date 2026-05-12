# Personal Skills Analysis: `todo-planner` and `adversarial-implementation`

**Date:** 2026-05-11
**Sources:**
- `~/.claude/skills/todo-planner/SKILL.md`
- `~/.claude/commands/adversarial-implementation.md`

Companion to `superpowers-analysis.md`. Looks at the two personal skills currently in `~/.claude/` and asks: how do they relate to xdg-claude's plugin collection and to superpowers' methodology? Should they be promoted to plugins, kept private, or reshaped?

---

## 1. What These Two Skills Actually Are

### `todo-planner` (informational skill)
Defines a TODO.md document format. Sections in fixed order: project description, **Testing Philosophy** preamble, **Verification Checklist** preamble, phase dependency ASCII diagram, numbered phases with hierarchical subphases, explicit `**Test**:` tasks, "Future Phases (Deferred)" sink. The preambles are intentionally re-injected so a subagent reading a single phase still sees the testing/verification rules.

**Shape:** Type 1 informational. No subagent, no slash command. Pure format spec.

**Distinguishing feature:** the Testing Philosophy + Verification Checklist preambles. These are not in any superpowers planning artifact. They exist specifically to survive context fragmentation when a subagent reads one phase out of context.

### `adversarial-implementation` (slash command)
A 7-phase protocol for executing a TODO.md subsection. Each automatable checkbox runs through: implement (subagent) → verify (parallel lint+test subagents, then parallel acceptance+smell-review subagents) → iterate on failure (fresh subagent, max 3) → after subsection done, code review pass → human verification for non-automatable items → commit.

**Shape:** currently a slash command in `~/.claude/commands/`. In xdg-claude's idiom this is a candidate Type 3 (user-entry skill + how-to skill + orchestrator subagent), though the orchestration shape is unusual.

**Distinguishing feature:** parallel verification fan-out (lint+test in one wave, acceptance+smell-review in the next). Superpowers' subagent-driven-development uses sequential review stages. The xdg version is more aggressive about exploiting parallelism.

---

## 2. Relationship to xdg-claude

### Gaps these skills fill that xdg-claude doesn't cover

| Gap | Filled by | Notes |
|-----|-----------|-------|
| Writing structured plans | `todo-planner` | Nothing in xdg-claude does this. Closest neighbor is the `superpowers-analysis.md` recommendation to add a `design-first` rule plugin (lighter-weight). |
| Executing a plan with isolation per task | `adversarial-implementation` | xdg-claude has `isolated-task-agent` (single delegation) but nothing for a multi-task pipeline. |
| Adversarial review (smell-check that's a separate agent from acceptance-check) | `adversarial-implementation` Phase 3 step 4 | `code-review-agent` reviews finished changes; doesn't run mid-iteration smell checks per task. |

### Overlaps with existing xdg-claude plugins

| xdg-claude plugin | Overlap | Tension? |
|-------------------|---------|----------|
| `isolated-task-agent` | adversarial Phase 2 dispatches a subagent per checkbox. That's exactly isolated-task-agent's job. | Not really -- adversarial *uses* isolated-task-agent. The protocol layer sits above. |
| `code-review-agent` | adversarial Phase 5 calls "the code review subagent (or a general subagent if unavailable)". | Clean integration. adversarial defers to whichever code review plugin is installed. |
| `git-commit-agent` | adversarial Phase 7 calls "a git commit agent". | Clean integration, same pattern. |
| `coding-best-practices` | Testing Philosophy and Verification Checklist preambles overlap with project-level coding rules. | The preambles are *per-project*, coding-best-practices is *general*. Different scope. |

`adversarial-implementation` is best understood as an **orchestrator** that calls the existing single-purpose agents in sequence. It depends on the rest of the xdg-claude collection rather than competing with it.

---

## 3. Relationship to Superpowers

### Direct mappings

| xdg personal skill | Superpowers analog | Comparison |
|-------------------|--------------------|------------|
| `todo-planner` | `writing-plans` | Different emphasis. See below. |
| `adversarial-implementation` | `subagent-driven-development` | Same shape, different review topology. See below. |

### `todo-planner` vs `writing-plans`

| Dimension | todo-planner | writing-plans |
|-----------|--------------|---------------|
| Output | TODO.md (per-project root) | `docs/superpowers/plans/<name>.md` |
| Testability framing | Testing Philosophy preamble (per-project tailored) | TDD steps interleaved with implementation (RED before GREEN) |
| File path discipline | Tasks like "Implement `GET /api/albums`" -- specific but not always file-pathed | Mandatory exact file paths and complete code blocks in every step |
| Phase structure | Numbered phases + hierarchical subphases + Future Phases sink | Numbered tasks, fewer hierarchical levels |
| Context retention strategy | Re-injected preambles (Testing Philosophy + Verification Checklist) | Each task contains everything needed to execute it |
| Implicit verifier | "the human or next agent reads the preamble" | "the spec is so complete you can't get it wrong" |
| Trade-off | More flexible, less precise | More precise, more verbose, more brittle when requirements shift |

These are two different theories of plan-as-spec. Superpowers bets on **completeness** (no ambiguity to misinterpret). todo-planner bets on **context-retention** (preambles travel with each phase so the agent doesn't drift).

The context-retention bet is interesting and not present in superpowers. It's specifically a hedge against the failure mode where a subagent reading one phase forgets the testing/verification rules. Superpowers solves the same problem by making each task standalone-complete; todo-planner solves it by making preambles re-visible.

### `adversarial-implementation` vs `subagent-driven-development`

| Dimension | adversarial-implementation | subagent-driven-development |
|-----------|----------------------------|------------------------------|
| Dispatch granularity | One subagent per checkbox | One subagent per task |
| Verification topology | Parallel: lint+test → parallel: acceptance+smell-review | Sequential: spec review → quality review |
| Iteration cap | Max 3 per item | Implicit (debugging skill caps at 3 failed fixes) |
| Smell-check specifics | Explicit list (faked tests, hardcoded returns, side effects, new TODOs, partial work claimed as done) | Implicit in code-review delegation |
| Human checkpoints | After each subsection's automatable items pass, prompts user for manual verification before commit | No human checkpoints; full autonomous |
| Commit cadence | One commit per subsection (after all checkboxes including human-verified ones are checked) | One commit per task |
| Escalation triggers | Explicit list (test failures undiagnosable, conflicting requirements, scope creep, 3 failed iterations, unclear automatable/human split) | "Halts at 3 failed fixes" via debugging skill |
| Reflection on failure | After successful iteration, asks "would amending TODO.md or CLAUDE.md have prevented this?" and proposes changes | Not present |

Three things distinguish the xdg version:

1. **Parallel verification waves.** Lint+test together (fast feedback), then acceptance+smell-review together (independent perspectives on the same diff). This roughly halves wall time per task vs. fully sequential review.

2. **Explicit smell list.** "Faked tests hardcoded to pass" and "partial work presented as done" are named failure modes. This is signal-of-experience; these are real things Claude does. Superpowers gestures at code review but doesn't enumerate.

3. **Reflection loop.** After a recovery, asks "what should we have written into TODO.md or CLAUDE.md to prevent this?" That's a meta-improvement step superpowers doesn't have, and it's how you incrementally harden a long-running plan.

---

## 4. The Combined Pipeline

`todo-planner` + `adversarial-implementation` is structurally close to superpowers' `brainstorming` → `writing-plans` → `subagent-driven-development` chain, minus the brainstorming front-end.

```
xdg pipeline:          (gap)          → todo-planner → adversarial-implementation
superpowers pipeline:  brainstorming  → writing-plans → subagent-driven-development
```

The missing front-end (deliberate design exploration before writing the plan) is also the gap flagged in `superpowers-analysis.md` section 4d. A `design-first` rule plugin would slot in.

**Implication:** there's a natural three-plugin family forming.
- `design-first` (proposed in superpowers-analysis): standing rule, explore 2-3 approaches before coding
- `todo-planner` (existing personal skill): the format
- `adversarial-implementation` (existing personal skill): the executor

Each is independently useful. Together they make a methodology. This matches xdg-claude's mix-and-match philosophy better than superpowers' integrated pipeline because each piece stands alone.

---

## 5. Recommendations

### Promote `todo-planner` to a public plugin

**Verdict:** Yes. Standalone plugin, Type 1 informational skill.

**Pros:**
- Clean, no dependencies, valuable on its own.
- The preambles-for-context-retention idea is genuinely novel and worth sharing.
- Pairs naturally with `adversarial-implementation` but doesn't require it.
- Pairs naturally with `code-review-agent` (verification checklist mentions code review).

**Cons:**
- Some sections are project-specific in their current templating (e.g., `make test-backend`). The plugin port should make these placeholders explicit.

**Suggested name:** `todo-planner` (keep). Plugin layout:
```
todo-planner/
├── .claude-plugin/plugin.json
└── skills/todo-planner/SKILL.md
```

**Small edits for the port:**
- Strip `make`-specific examples to placeholders; mention them as one option among several.
- Add a one-paragraph note on the preambles-as-context-retention design choice. That's the differentiator and worth flagging.
- Cross-reference `adversarial-implementation` plugin as the natural executor.

---

### Ship `adversarial-implementation` *together with* `todo-planner` as one plugin

**Verdict:** The two are tightly coupled through the TODO.md format. todo-planner writes it; adversarial-implementation reads it (subsection structure, `**Test**:` prefix, checkbox semantics, preambles). Ship them in one plugin.

That coupling mirrors the way superpowers' core methodology hangs together (brainstorming → writing-plans → subagent-driven-development). Different content, same pattern: the planning artifact's format is the contract the executor depends on.

This doesn't preclude other implementation loops. Someone could install the bundled plugin for the format and write their own `/build` command that reads TODO.md differently. Or skip the executor entirely and drive TODO.md by hand. The plugin ships the *pair*; consumers pick how much to use.

**Suggested plugin name:** `plan-and-build` or `phased-implementation`. Layout:
```
plan-and-build/
├── .claude-plugin/plugin.json
├── agents/adversarial-implementation.md
└── skills/
    ├── todo-planner/SKILL.md
    ├── how-to-adversarial-implementation/SKILL.md
    └── adversarial-implementation/SKILL.md
```

**Open question on granularity.** We're still figuring out the right size for planning+implementing units. todo-planner's "a subphase = one agent session = one atomic commit" is one bet. Superpowers' "each task is self-complete with exact code" is another. Per-checkbox dispatch (adversarial's choice) vs. per-task dispatch (superpowers' choice) is a third dimension. None of these are settled. The plugin should present its choices as choices, not as the truth — leave room in the docs for users to disagree and adapt.

### Reshape `adversarial-implementation` into Type 3 (subagent + how-to + user-entry)

**Pros:**
- Real working executor that exercises xdg-claude's existing agent collection (`isolated-task-agent`, `code-review-agent`, `git-commit-agent`).
- Distinguishing features (parallel verification waves, explicit smell list, reflection loop) are genuinely novel vs. superpowers.
- A clear `/adversarial-implementation` (or shorter `/build`) command is natural.

**Cons:**
- Currently a single command file. Needs to be split into the three-piece pattern xdg-claude uses.
- "If a code review agent exists, use it; otherwise general subagent" branching is fragile. In the plugin world, document that `code-review-agent` is a soft dependency and the plugin works better with it installed.

**Suggested shape (Type 3):**
```
adversarial-implementation/
├── .claude-plugin/plugin.json
├── agents/adversarial-implementation.md          # Piece 1: orchestrator subagent
└── skills/
    ├── how-to-adversarial-implementation/SKILL.md  # Piece 2: when to delegate
    └── adversarial-implementation/SKILL.md        # Piece 3: /adversarial-implementation
```

Open question: should the orchestrator be a *subagent*, or should the protocol body live in the user-entry skill itself and run in the main thread? The orchestrator dispatches further subagents for each task, so context isolation matters less than for a single-purpose subagent. A counter-argument: keeping the orchestrator's bookkeeping (which checkbox, which iteration count, which subsection) out of the main thread is valuable for long runs.

**Recommendation:** orchestrator as subagent. Main thread sees only progress summaries and completion reports; subsection-level state stays in the orchestrator's context.

**Shorter command alias:** consider `/build` or `/implement` as the slash command. `/adversarial-implementation` is descriptive but long.

---

### Can the adversarial orchestrator (a subagent) dispatch further subagents?

Yes, with caveats.

**Mechanically.** Subagents can invoke the Agent (Task) tool if it's listed in their `tools` frontmatter. Nested delegation works. The orchestrator subagent can dispatch implementation subagents, lint/test subagents, acceptance/smell-review subagents, and finally hand off to the commit subagent.

**Practical considerations:**

1. **Tool allowlist must include `Task`/`Agent` explicitly.** Don't rely on inheritance. Set it in the orchestrator's frontmatter.
2. **Named subagent routing works from nested context.** The orchestrator can call `subagent_type: isolated-task-agent`, `subagent_type: code-review`, `subagent_type: commit` the same as the main thread can.
3. **Observability degrades with depth.** The user sees the orchestrator's "Agent: adversarial-implementation" panel. Calls to *its* subagents render nested inside that panel and are harder to follow. For a 20-checkbox subsection with parallel verification fan-out, the user sees a lot of activity in one collapsed view.
4. **Cost compounds.** Orchestrator + implementation + lint + test + acceptance + smell = 6 contexts per checkbox. Multiply by checkboxes in the subsection. This was already true when adversarial ran from the main thread, but worth flagging.
5. **Error propagation.** If a nested subagent fails or returns garbage, the orchestrator interprets and decides whether to retry. The main thread no longer sees the raw failure -- only what the orchestrator chose to report. Specify in the orchestrator's system prompt what to surface on failure.
6. **Permission mode is per-subagent, not inherited.** Each named subagent's frontmatter governs its own permissions. You can't blanket-loosen permissions for a whole orchestration run; each agent in the chain controls its own scope. This is usually what you want.

**Counter-option: main-thread orchestrator.** Keep adversarial as a Type 3 user-entry skill where the protocol body runs in the main thread (no orchestrator subagent wrapper). Trade-off:
- *Pro:* user sees every dispatched subagent as a top-level panel; full observability.
- *Pro:* bookkeeping uses main context, fine if the run finishes in one session.
- *Con:* main context fills with per-checkbox state (which iteration, which subagent returned what). For long runs this matters.

**Recommendation:** start with the subagent orchestrator. Specify in its system prompt: "Report to the main thread only: subsection progress, escalation requests, and final commit summary. Do not stream per-checkbox details." That keeps the main thread clean while preserving observability at decision points.

### Suggested order of operations

1. Bundle `todo-planner` + `adversarial-implementation` into one `plan-and-build` plugin. Port todo-planner as-is; reshape adversarial into Type 3.
2. (Future) Add the `design-first` rule plugin proposed in superpowers-analysis.md section 4d as the front-end.
3. (Future) Consider a `debugging-agent` plugin (also proposed in superpowers-analysis.md). adversarial's "3 failed iterations" escalation would benefit from delegating to debugging-agent before escalating to the human.

---

## 6. Creative Variations

### 6a. Hybrid with the proposed `debugging-agent`

Adversarial-implementation's Phase 4 says: max 3 iterations, then escalate to human. A better escalation path: max 3 implementation iterations, then delegate to `debugging-agent` (if installed) for a root-cause pass, *then* escalate to human if that also fails. Two-step escalation captures the case where the right answer isn't "try again with stricter constraints" but "stop trying and diagnose."

### 6b. todo-planner's preambles as a general pattern

The preambles-re-injection idea is more general than TODO.md. Any document that gets read in fragments by subagents could benefit from the same pattern: a header section that travels with every subsection. This could become an xdg-claude meta-pattern documented in the marketplace README, not just in the todo-planner skill.

### 6c. Adversarial verification as a standalone

The verification phase of adversarial-implementation (parallel lint+test, then parallel acceptance+smell-review) is reusable outside the TODO.md pipeline. Any single change could go through it. Extract as `/verify` or `verify-change` plugin? Probably overkill -- the natural integration is for `code-review-agent` to absorb the explicit smell list. Worth adding the named smell-list to `code-review-agent`'s subagent body:

> Check for: faked tests hardcoded to pass, hardcoded function return values, partial work presented as complete, new TODO comments left behind, file changes outside the declared scope.

That's concrete failure-mode language that improves the existing plugin.

### 6d. Reflection loop as a standalone discipline

The "after recovery, propose amendments to TODO.md or CLAUDE.md" reflection step is a discipline that generalizes beyond adversarial-implementation. It's basically: *after fixing a bug, ask whether a guideline change would have prevented it*. This could be a tiny rule plugin (`reflect-on-fix`) that triggers after any iteration cycle. The reflect skill at `~/.claude/skills/reflect/` may already cover this -- worth checking and either consolidating or differentiating.

### 6e. Subsection size discipline

todo-planner says "a subphase should be work that can be completed in a single agent session and would logically make sense as an atomic commit." Adversarial-implementation commits per subsection. That's a nice invariant: the planning unit equals the commit unit. Worth elevating to a stated principle in the todo-planner skill, not just buried in the nesting-subphases section.

---

## 7. Conclusions

Both personal skills are publication-ready, bundled as one plugin:

- `todo-planner` → port as-is; genuine novel idea (preambles for context retention).
- `adversarial-implementation` → reshape into Type 3 (orchestrator subagent + how-to + user-entry). Novel parallel verification topology and explicit smell-list deserve wider use.
- **Ship them together.** The TODO.md format is the contract between them; they're tightly coupled in the same way superpowers' core methodology is. Granularity for planning+implementing units (per-checkbox vs. per-task, atomic-commit boundary, subphase nesting depth) is unsettled. The plugin should present its choices as choices.

Together they bring a planning + executing methodology to xdg-claude that's currently missing. Compared to superpowers' equivalent (brainstorming + writing-plans + subagent-driven-development), the xdg pair is:

- Less rigid (no hard TDD gates, no mandatory exact-code-in-plan)
- More parallel (verification fan-out)
- More integrated with existing single-purpose agents (delegates to code-review, git-commit, isolated-task)
- Missing a front-end (no brainstorming equivalent)

That last gap is the natural follow-on: a lightweight `design-first` rule plugin would complete the trio without importing superpowers' philosophical baggage.
