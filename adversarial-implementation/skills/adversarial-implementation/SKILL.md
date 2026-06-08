---
name: adversarial-implementation
description: Implement TODO.md items via isolated subagents, then adversarially verify correctness. Drives a phased loop that implements one checkbox at a time, runs independent lint/test/review subagents, handles human verification, and commits per subsection.
disable-model-invocation: true
argument-hint: "[task, or empty to take the next TODO.md subsection]"
---

Task: `$ARGUMENTS`
(If no task is provided, read TODO.md, if it exists. Implement the next incomplete
subsection. If there is no TODO.md file, prompt the user for instructions.)

## Adversarial Implementation Protocol

When implementing from TODO.md:
- **Implementation unit**: Individual checkboxes (keeps subagent sessions manageable)
- **Completion unit** (aka "subsection"): The immediate parent heading of a group of
  checkboxes—i.e., the most specific heading that directly contains them, not any ancestor.

Example TODO structure:
```
### 3.1 OAuth Setup
#### 3.1.1 Configure provider
- [ ] Add client ID
- [ ] Add client secret
#### 3.1.2 Implement callback
- [ ] Handle redirect
```
Here, `3.1.1` and `3.1.2` are completion units (each is a subsection directly containing checkboxes).
`3.1 OAuth Setup` is NOT a completion unit—it's a parent grouping.

A completion unit is complete only when ALL its checkboxes are checked—including any
that require human verification.

### Phase 1: Plan the Subsection

For the next incomplete Phase subsection:

1. Read ALL checkboxes within the subsection
2. Categorize each checkbox:
   - **Automatable**: Code changes, automated tests
   - **Human-required**: Browser interactions, visual verification, manual testing
3. Process automatable items one at a time (or in small logical batches) through
   Phases 2-4 before moving to the next item
4. Track which items are complete within the subsection
5. If subsection has NO automatable items, skip directly to Phase 6

### Phase 2: Implement Single Item via Subagent

For each automatable checkbox:

1. Spawn an isolated task subagent (if one exists, or a general subagent
   otherwise) with this prompt structure:
```
   Task: [specific checkbox item]
   Context files: TODO.md, any other relevant specs or instructions (OMIT code
   files; the subagent can find these on its own)
   Constraints: [project rules, style guide refs]
   Acceptance criteria: [the specific checkbox, explicitly stated]
   Output: Implement and report a concise summary of what you changed.
```
2. Do NOT provide the full codebase—give minimal necessary context so you
   minimize use of the main context. Include: TODO.md, relevant specs, file paths
   to modify. Exclude: file contents the subagent can read itself, unrelated modules.

### Phase 3: Verify Single Item

After the implementation subagent from Phase 2 completes, do steps 1 and 2 below in parallel:

1. Have a fresh subagent run linter/formatter checks according to CLAUDE.md or
   other instructions and report on failures
2. Have a fresh subagent run tests according to CLAUDE.md or other instructions
   and report on failures

For linting, formatting, and testing, remind subagents of any particular rules
for how to do such actions (e.g., Makefile or other build system targets).

After 1 and 2 complete, do steps 3 and 4 below in parallel:

3. Have a fresh subagent review the diff against acceptance criteria.
4. Have a fresh subagent review the diff for code smells, such as:
   - Unintended side effects (files changed that shouldn't be)
   - Rule violations (check CLAUDE.md for rules)
   - Incomplete implementation (partial work presented as done)
   - Faked tests (hardcoded to pass)
   - Hardcoded function return values
   - New TODO comments left behind
   - Any other notable code smells (ignoring small style nits)

### Phase 4: Iterate or Continue

If verification fails:
1. Document specific failures
2. Spawn NEW subagent (don't reuse) with:
   - Original task
   - What was attempted
   - Specific failures to fix
   - Stricter constraints based on what went wrong
3. Repeat Phase 3 to re-verify

NOTE: Max 3 iterations per item, then escalate to human.

If iteration was required, after verification succeeds, reflect on why the
initial attempt failed. Decide whether amending guidelines (in the TODO.md file
or CLAUDE.md file) might have prevented the failure. If so, propose the changes
to the user.

After item passes verification:
1. Mark that checkbox complete in TODO.md
2. If more automatable items remain in the subsection, return to Phase 2
3. If all automatable items are done, proceed to Phase 5

IMPORTANT: Do NOT commit yet—defer until Phase 7.

### Phase 5: Code Review

1. Run the code review subagent (or a general subagent if unavailable) to review
   new files and the changed files diff.
2. If the review does not report any significant or major issues, proceed to Phase 6.
3. Spawn an isolated subagent to fix the issues.
4. After fixes are complete, spawn another isolated subagent to ensure that tests still pass.
5. If tests do not pass, return to Step 3 of this phase to fix them.

Do NOT proceed to Phase 6 unless all tests pass.

### Phase 6: Human Verification

After ALL automatable items in the subsection pass verification:

1. Scan the subsection for ANY unchecked checkboxes
2. If unchecked items remain, they require human action. Prompt the user with:
   - What needs manual verification (list each unchecked item)
   - Setup instructions (e.g., "run `make dev`, open http://localhost:5175")
   - Expected behavior to confirm for each item
   - Ask user to confirm pass/fail for each item
3. Wait for user response before proceeding
4. If user reports any failure:
   - Return to Phase 2 to fix the issue (spawning new subagent with user feedback)
   - After fix, re-run Phases 3-5 verification
   - Then return to Phase 6 for user to re-verify
5. After user confirms all items pass, mark those checkboxes complete

Do NOT proceed to Phase 7 while ANY unchecked items remain in the subsection.

### Phase 7: Commit Subsection

If and only if ALL checkboxes in the subsection are now checked:

1. Use a git commit agent (if one exists) to commit the work (the agent can
   generate a commit message); if no such agent exists, use a general subagent
   instead. The commit includes all implementation work plus TODO.md updates.
2. Unless the human user indicated otherwise during a prior phase, or if the
   context window is more than 75% full, return to
   Phase 1 and proceed with the next incomplete subsection.

Ensure that commits happen only after ALL verification (automated AND manual)
succeeds and only after ALL corresponding checkboxes are checked.

### Escalation Triggers

Stop and ask the human when any of these occur. Present your findings, what
you've tried, and await guidance before proceeding:

- Test failures you can't diagnose
- Conflicting requirements discovered
- Changes needed outside declared scope
- 3 failed iterations on same item
- Unclear which checkboxes are automatable vs. human-required
