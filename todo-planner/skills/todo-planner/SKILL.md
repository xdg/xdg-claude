---
name: todo-planner
description: Create and maintain structured TODO.md implementation plans with phased tasks, testing philosophy, and verification checklists. This skill should be used when the user asks to create a TODO file, implementation plan, project roadmap, or phased development plan. Also use when asked to update or extend an existing TODO.md in this style.
---

# TODO Planner

## Overview

Create structured TODO.md files for tracking multi-phase implementation projects. The format emphasizes testability, verification, and phase dependencies to maintain context and ensure thorough execution.

## Document Structure

A TODO.md file consists of these sections in order:

```
# Project Implementation Plan
[1-2 sentence description]

## Testing Philosophy
[Testing approach preamble - re-injected for context retention]

## Verification Checklist
[Pre-commit checklist - re-injected for context retention]

## Dependencies Between Phases
[ASCII diagram showing phase relationships]

---

## Phase N: Title
[Phase description]

### N.1 Sub-phase title
- [x] Completed task
- [ ] Pending task
- [ ] **Test**: Explicit test task

---

## Future Phases (Deferred)
[Items explicitly out of scope for now]
```

### Nesting subphases

Subphases may be nested, if the complexity of a phase is high.  Number them
hierarchically: x.y or x.y.z or x.y.z.a, a necessary.  The scope of a subphase
should be work that can be completed in a single agent session and would
logically make sense as an atomic commit -- a single, logical unit of change.

## Testing Philosophy Preamble

Include a Testing Philosophy section near the top. This section is **critical for context retention** - when working on later phases, this preamble reminds the agent of testing expectations.

Template:
```markdown
## Testing Philosophy

- **Automated tests for business logic**: [specific areas like store operations, API handlers]
- **Manual tests for UI interactions**: [specific areas like drag-drop, visual behavior]
- **Factor code for testability**: Interfaces for backends, dependency injection
- **[Language] tests**: [framework specifics, e.g., "Use `testing` with `httptest` for handlers"]
- **[Frontend] tests**: [framework specifics, e.g., "Vitest for component logic"]
```

## Verification Checklist Preamble

Include a Verification Checklist that specifies what to do before marking a phase complete. This is also **re-injected for context retention**.

Template:
```markdown
## Verification Checklist

Before marking a phase complete and committing it:

1. `make test-backend` passes (backend)
2. `make test-frontend` passes (frontend algorithms/state)
3. Manual browser testing by user for UI interactions only
4. No console errors in browser
5. Code reviewed for obvious issues

Use Makefile targets for linting, formatting, and testing, if available.

When verification of a phase or subphase is complete, commit all
relevent newly-created and modified files.
```

Customize the verification section to match the project's actual test commands.

## Dependencies Between Phases

Include an ASCII diagram showing how phases depend on each other. This helps identify parallelizable work and critical paths.

Example:
```markdown
## Dependencies Between Phases

​```
Phase 1-3 (Foundation)
       │
       ▼
Phase 4 (Core Features)
       │
       ├─► Phase 5 (Enhancement A)
       │         │
       │         ▼
       │   Phase 6 (Depends on 5)
       │
       └─► Phase 7 (Enhancement B, parallel to 5-6)
               │
               ▼
         Phase 8 (Production)
​```
```

## Phase Structure

Each phase follows this pattern:

```markdown
---

## Phase N: Descriptive Title

[1-2 sentence description of what this phase accomplishes]

### N.1 Sub-phase title
- [x] Specific completed task
- [ ] Specific pending task
- [ ] **Test**: Unit test for [specific thing]

### N.2 Another sub-phase
- [ ] Task with clear deliverable
- [ ] **Test**: Integration test - [specific scenario]
```

Guidelines:
- Use `---` horizontal rules between phases for visual separation
- Number phases sequentially (Phase 1, Phase 2, etc.)
- Number sub-phases hierarchically (1.1, 1.2, 5.6.3, etc.)
- Use `[x]` for completed tasks, `[ ]` for pending
- Prefix test tasks with `**Test**:` in bold for visibility
- Be specific: "Implement `GET /api/albums`" not "Add API endpoint"

## Test Task Patterns

Explicit test tasks ensure coverage. Common patterns:

```markdown
- [ ] **Test**: Unit test for JSON marshal/unmarshal round-trip
- [ ] **Test**: Handler test with mock store
- [ ] **Test**: Integration test - upload photo, thumbnail created
- [ ] **Test**: Manual - OAuth flow completes, user info in header
```

The `**Test**:` prefix makes test tasks scannable and ensures they're not overlooked.

## Future Phases Section

End with a deferred items section to capture scope creep without cluttering active phases:

```markdown
---

## Future Phases (Deferred)

### Feature Category
- Deferred feature description
- Another deferred feature

### Another Category
- More deferred items
```

## Creating a New TODO.md

When creating a new TODO.md:

1. Gather project context: tech stack, testing frameworks, build commands
2. Write the Testing Philosophy section tailored to the project
3. Write the Verification Checklist with actual project commands
4. Sketch the phase dependency diagram
5. Define phases and subphases (if needed) with specific, actionable tasks
6. Include explicit **Test** tasks for each sub-phase
7. Add a Future Phases section for out-of-scope items

## Updating an Existing TODO.md

When updating:

1. Mark completed tasks with `[x]`
3. Add new tasks discovered during implementation
4. Update the dependency diagram if phases shift
5. Move completed phases above the current work (or leave in place with all tasks checked)
6. Preserve the Testing Philosophy and Verification Checklist preambles - do not remove them
