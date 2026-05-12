# Superpowers vs xdg-claude: Comparison Analysis

**Date:** 2026-05-11
**Repos:** `/Users/xdg/git/xdg-claude/` and `/Users/xdg/git/clones/superpowers/`

---

## 1. Inventory: All Superpowers Skills by Theme

### Design / Planning
| Skill | Description |
|-------|-------------|
| `brainstorming` | Socratic design refinement before any implementation; hard gate prevents coding without approved spec |
| `writing-plans` | Writes zero-ambiguity implementation plans (TDD-first, exact file paths, complete code) |

### Execution / Orchestration
| Skill | Description |
|-------|-------------|
| `subagent-driven-development` | Dispatches a fresh subagent per plan task + two-stage review; no human checkpoints |
| `executing-plans` | Inline batch execution with human checkpoints; fallback when no subagent support |
| `dispatching-parallel-agents` | Concurrent subagent dispatch for independent problem domains |

### Code Quality / Review
| Skill | Description |
|-------|-------------|
| `requesting-code-review` | Dispatches a reviewer subagent after each task; pre-review checklist |
| `receiving-code-review` | Technical evaluation protocol for incoming review feedback; anti-performative-agreement rules |
| `test-driven-development` | RED-GREEN-REFACTOR cycle; iron law: no production code without a failing test first |
| `verification-before-completion` | Evidence gate before any completion claim; blocks "should work" assertions |

### Debugging
| Skill | Description |
|-------|-------------|
| `systematic-debugging` | 4-phase root cause process: read errors, reproduce, pattern analysis, hypothesis/test; halts at 3 failed fixes |

### Git / Branch Workflow
| Skill | Description |
|-------|-------------|
| `using-git-worktrees` | Isolated workspace setup; detects existing isolation, native tool preferred, git fallback |
| `finishing-a-development-branch` | Structured 4-option completion: merge / PR / keep / discard; test gate, worktree cleanup |

### Meta / Self-Improvement
| Skill | Description |
|-------|-------------|
| `writing-skills` | TDD applied to skill authoring; RED-GREEN-REFACTOR for process documentation |
| `using-superpowers` | Session-start skill-check enforcer; mandates skill invocation |

---

## 2. Recommendations Per Skill / Cluster

### `systematic-debugging` → **New standalone plugin: `debugging-agent`**

**Pros:**
- Clearest standalone value. Discipline, not a workflow; no dependency on other superpowers skills.
- xdg-claude has nothing for debugging. Real gap.
- 4-phase process (read errors / reproduce / pattern analysis / hypothesis) maps cleanly to a Type 1 knowledge skill + Type 2 subagent pattern already used in xdg-claude.
- Supporting files (`root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md`) match xdg-claude's context-efficient-tools philosophy.

**Cons:**
- Full SKILL.md is long. A port should trim the "real-world impact" metrics section, which reads as sales copy.

**Verdict:** Port it. Type 2 subagent plugin matching `refactoring-agent`'s shape. Subagent runs the 4-phase process; routing skill triggers on bug/test-failure signals.

---

### `verification-before-completion` → **Merge into `coding-best-practices`**

**Pros:**
- Aligned with xdg-claude's coding-best-practices.
- Short enough to live as a hook section rather than a standalone plugin.
- Core rule (no completion claims without running the command) reinforces existing discipline.

**Cons:**
- "Iron law" framing is heavier than xdg-claude's guidance-oriented style.
- Hook injection is lower friction than a skill invocation.

**Verdict:** Extract the `BEFORE claiming status` checklist into coding-best-practices hooks. Drop the "24 failure memories" framing.

---

### `test-driven-development` → **New standalone plugin: `tdd-discipline`**

**Pros:**
- xdg-claude has nothing on testing. Clean gap.
- Claude frequently skips TDD; a mandatory-invocation skill changes that.
- Supporting `testing-anti-patterns.md` is high-value reference.
- Type 1 knowledge skill shape.

**Cons:**
- "Iron law" / "delete code written before tests" framing is stricter than some projects need.
- RED-GREEN-REFACTOR Graphviz dot syntax doesn't render in Claude Code (still readable as text).

**Verdict:** Port as `tdd-discipline`, Type 1 knowledge skill. Add an escape hatch for codebases without test infrastructure (fall back to verification-before-completion).

---

### `brainstorming` → **Skip (philosophical mismatch)**

- Hard gate ("do NOT write any code until design is approved") is disruptive installed standalone. Users expect a collaborative aid, not a mandatory block.
- Couples tightly to `writing-plans` as its terminal state. Handoff goes nowhere without the rest of the pipeline.
- xdg-claude's `isolated-task-agent` already provides "think in isolation before acting."
- Visual companion feature references superpowers-specific tooling.

**Partial reuse:** Extract "propose 2-3 approaches before settling" and "one question at a time" as additions to coding-best-practices or pithy-communication.

---

### `writing-plans` → **Skip (pipeline dependency)**

- Only useful as part of brainstorming → writing-plans → subagent-driven-development.
- Standalone, writes plan files to `docs/superpowers/plans/` with hardcoded references to other superpowers skills.
- Plan format is high-quality but too prescriptive for general use.

**Partial reuse:** The plan format (exact paths, complete code per step, interleaved TDD) is worth documenting in a future xdg-claude planning plugin with the branding stripped.

---

### `subagent-driven-development` + `executing-plans` + `dispatching-parallel-agents` → **Skip (orchestration layer)**

- Three skills form superpowers' orchestration layer; deeply interdependent.
- xdg-claude's `isolated-task-agent` covers single delegated tasks. Different scope (pipeline orchestration) but the conceptual overlap would confuse users.
- `dispatching-parallel-agents` is the most reusable, but it's essentially what `isolated-task-agent` already does with better doctrine ("one agent per independent problem domain").

**Possible merge:** Add `dispatching-parallel-agents`'s context-isolation principle ("construct exactly what the subagent needs, never let it inherit your session's context") to `isolated-task-agent`.

---

### `requesting-code-review` → **Merge into `code-review-agent`**

**Pros:**
- Overlaps directly with `code-review-agent`. Superpowers adds "mandatory after each task" framing and "fresh context for reviewer" principle.
- Mandatory trigger list (after each task, major feature, before merge) is a useful addition.

**Cons:**
- xdg-claude's code-review is already well-structured. Additive change, not a port.

**Verdict:** Add the mandatory trigger list and "never let reviewer inherit session history" principle to `code-review-agent/skills/how-to-code-review/SKILL.md`.

---

### `receiving-code-review` → **New standalone plugin: `code-review-reception`**

**Pros:**
- xdg-claude has a code-review dispatcher but nothing for receiving feedback. Genuine gap.
- Self-contained; not pipeline-dependent.
- "Forbidden responses" list (no "You're absolutely right!", no performative agreement) aligns with `avoid-ai-tells`.
- YAGNI check for reviewer suggestions is genuinely useful.
- "Verify before implementing, push back with technical reasoning" is distinct from anything in xdg-claude.

**Cons:**
- "Strange things are afoot at the Circle K" safety phrase is project-specific. Strip it.
- `gh api` GitHub thread reply guidance is implementation-specific.

**Verdict:** Port as standalone plugin. Pairs naturally with `code-review-agent` but serves a distinct purpose, so keep separate per xdg-claude's small-focused-plugin philosophy.

---

### `using-git-worktrees` + `finishing-a-development-branch` → **New plugin: `git-workflow`**

**Pros:**
- xdg-claude's `git-commit-agent` handles committing; nothing handles branch lifecycle.
- Two skills are naturally paired (worktree setup on entry, branch finishing on exit).
- `finishing-a-development-branch` (4-option menu, test gate, worktree cleanup) works well as a Type 2 subagent or Type 3 with `/finish-branch` slash command.
- Worktree detection logic (GIT_DIR vs GIT_COMMON, submodule guard) is genuinely tricky and worth documenting.

**Cons:**
- `using-git-worktrees` references superpowers' `EnterWorktree` native tool. A port needs to rely on xdg-claude's equivalent tools or git fallback.
- Step 6 cleanup logic (provenance check via `.worktrees/` path) is brittle. Port the concept, simplify the implementation.

**Verdict:** Bundle as `git-workflow`: `git-worktree-setup` (Type 1) + `finish-branch` (Type 3 with `/finish-branch`, subagent-backed).

---

### `writing-skills` → **Skip**

- Superpowers' internal meta-skill. xdg-claude has CLAUDE.md and its own conventions.
- TDD-for-documentation approach is interesting but xdg-claude uses git-based human-reviewed PRs rather than agent-tested skills.
- Most value is in "when to create a skill" -- extract as a paragraph in CLAUDE.md if useful.

---

### `using-superpowers` → **Already ported**

xdg-claude's `prioritize-skills` is explicitly adapted from this. No action needed.

---

## 3. Grouping Proposals

### Bundle A: `debugging-agent` (new plugin)
- `systematic-debugging` as primary skill (Type 1 knowledge + Type 2 subagent)
- Reference files: root-cause-tracing, defense-in-depth, condition-based-waiting
- Slash command: `/debug`
- Model: Opus (same as `code-review-agent`)

### Bundle B: `tdd-discipline` (new plugin)
- `test-driven-development` as Type 1 knowledge skill
- `testing-anti-patterns.md` as reference
- No subagent; this is behavioral guidance
- Pairs with: `verification-before-completion` rules added to `coding-best-practices`

### Bundle C: `git-workflow` (new plugin)
- `git-worktree-setup`: Type 1 knowledge skill
- `finish-branch`: Type 3 slash command with subagent presenting 4-option menu

### Merges into existing plugins:
- `requesting-code-review` triggers → `code-review-agent/skills/how-to-code-review/SKILL.md`
- `dispatching-parallel-agents` isolation principle → `isolated-task-agent/skills/how-to-isolated/SKILL.md`
- `verification-before-completion` checklist → `coding-best-practices/hooks/`

### Standalone (separate plugin):
- `code-review-reception` → receives and evaluates code review feedback

---

## 4. Creative Variations

### 4a. `debugging-agent` as a Type 2 subagent

`systematic-debugging` is written as behavioral guidance for Claude itself. xdg-claude's pattern for complex analytical work is delegation (see `refactoring-agent`, `code-review-agent`). A `debugging-agent` subagent would:
- Receive: error message, failing test output, recent git diff
- Run: 4-phase process in isolation, no main-conversation pollution
- Return: structured report (root cause, hypothesis, proposed fix, confidence)

Strictly more useful than inline debugging guidance because deep file exploration stays out of the main context.

### 4b. `tdd-discipline` + verification as tiny rule plugins

Neither is a workflow; both are standing behavioral constraints. Closer to `coding-best-practices` than to skill plugins. Option: add a `tdd` and `verify-before-claiming` section to coding-best-practices hooks (low plugin count, no individual opt-out). Cleaner: two separate tiny rule plugins, each hooking `PreToolUse` or session start. Easy individual opt-out.

### 4c. Documented pairing in README

`code-review-reception` and `code-review-agent` are nearly always wanted together. xdg-claude's README could document a "code review pair" without merging them. Two install commands; README makes the pairing obvious.

### 4d. "Inspired by brainstorming": lightweight `design-first` rule plugin

Rather than porting the full brainstorming skill, ship a rule plugin injecting one standing instruction: "Before writing code for any new feature or component, spend one message exploring 2-3 approaches and your recommendation." No hard gate, no mandatory spec document, no handoff. Just a nudge toward deliberate design in xdg-claude's light-touch style.

### 4e. Gap analysis: what superpowers exposes about xdg-claude

| Area | superpowers | xdg-claude | Gap |
|------|-------------|------------|-----|
| Debugging | systematic-debugging | nothing | Yes -- debugging-agent |
| Testing | test-driven-development | nothing | Yes -- tdd-discipline |
| Design/planning | brainstorming + writing-plans | nothing | Partial -- lightweight design-first |
| Branch lifecycle | using-git-worktrees + finishing-a-development-branch | git-commit-agent (commit only) | Yes -- git-workflow |
| Review reception | receiving-code-review | nothing | Yes -- code-review-reception |
| Review requesting | requesting-code-review | code-review-agent | Mostly covered |
| Parallel execution | dispatching-parallel-agents | isolated-task-agent | Close enough |
| Communication style | nothing | avoid-ai-tells, pithy-communication, elements-of-style | xdg-claude leads |
| Writing guidance | nothing | coding-best-practices | xdg-claude leads |

Four clear gaps: debugging, testing discipline, branch lifecycle, code review reception.

---

## 5. Duplication and Philosophical Conflicts

### Direct duplication
- `using-superpowers` ≈ `prioritize-skills`. Already noted in xdg-claude's README.
- `requesting-code-review` overlaps with `how-to-code-review`. Superpowers adds mandatory-after-each-task framing; xdg-claude uses softer signal-matching.

### Philosophical conflicts

**Mandatory vs. contextual triggers.** Superpowers uses hard gates and "MUST use before ANY X" enforcement. xdg-claude's prioritize-skills uses softer signal-matching. Real tension. Porting as-is imports the mandatory-invocation style. For debugging and TDD this is fine (sticky habits desirable). For brainstorming it would disrupt.

**Pipeline vs. mix-and-match.** Superpowers is integrated methodology (brainstorming → writing-plans → subagent-driven-development). xdg-claude is explicit mix-and-match. Pipeline-step skills (writing-plans, executing-plans, brainstorming) don't translate; standalone disciplines (systematic-debugging, TDD, code-review-reception) translate cleanly.

**Docs persisted vs. ephemeral.** Superpowers routinely writes to `docs/superpowers/specs/` and `docs/superpowers/plans/`. xdg-claude plugins don't persist artifacts. Porting writing-plans or brainstorming requires adopting this convention or dropping the doc-writing steps.

**Context isolation framing.** Both care about subagent context isolation with different emphasis. Superpowers: "construct exactly what the subagent needs, never inherit session context." xdg-claude: "avoid polluting main conversation." Same principle, different angle. Merging the framing when extending isolated-task-agent would add clarity.

---

## Recommended Action Order

1. **Port `systematic-debugging` as `debugging-agent`** -- highest standalone value, no pipeline dependency, clear gap.
2. **Add `receiving-code-review` as `code-review-reception`** -- self-contained, pairs with existing plugin, distinct purpose.
3. **Port `test-driven-development` as `tdd-discipline`** -- knowledge skill, no subagent needed, fills clear gap.
4. **Add branch lifecycle as `git-workflow`** -- moderate effort, extends `git-commit-agent`'s commit-only coverage.
5. **Merge small additions** -- requesting-code-review trigger list into how-to-code-review; dispatching principle into how-to-isolated; verification checklist into coding-best-practices.
6. **Consider `design-first` rule plugin** -- lightweight brainstorming inspiration, low friction, no pipeline dependency.
