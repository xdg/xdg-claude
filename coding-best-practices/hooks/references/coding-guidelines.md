# Coding guidelines

## Philosophy of Software Design (Ousterhout)

### Core Principle
**Complexity is the enemy.** Good design minimizes cognitive load.

### Deep vs Shallow Modules

"Modules should be deep, interfaces should be simple, and special cases should be eliminated."

- **Deep modules:** Simple interface, powerful implementation. High benefit/cost ratio.
- **Shallow modules:** Complex interface, trivial implementation. No abstraction value.

### Key Practices

**Strategic over tactical:** Invest 10-20% extra on good design upfront; quick fixes accumulate complexity.

**Information hiding:** Bury complexity behind simple interfaces. Users shouldn't know implementation details.

**Pull complexity downward:** Make module implementers work harder so users work less. The opposite is disaster.

**Different layer, different abstraction:** Pass-through methods/variables are red flags. Each layer should add value.

**Avoid leaky abstractions:** No exceptions for normal control flow; no getters/setters that expose internal structure.

**Design it twice:** Always consider multiple approaches. First idea is rarely best.

**General-purpose > special-case:** Fewer, more flexible methods > many specialized ones.

**Define errors out of existence:** Design APIs so errors can't happen vs detecting/handling them.

## The Art of Readable Code (Boswell & Foucher)

### Core Principle
**Code should minimize the time for someone else to understand it.** Readability > cleverness.

### Naming
- **Be specific:** `retval` → `seconds_since_request`
- **Encode units/types:** `delay_secs`, `unsafe_html`, `num_errors`
- **Use concrete names:** `ServerCanStart()` > `CanListenOnPort()`
- **Attach important details:** `max_threads` > `threads`, `plaintext_password` > `password`
- **Longer names for larger scopes.** Loop iterator `i` is fine; class member needs context.

### Comments
- **Don't describe what code does.** Describe why and non-obvious consequences.
- **Record your thought process:** "Tried X, didn't work because Y"
- **Document flaws:** `TODO`, `FIXME`, `HACK`, `XXX`
- **Comment constants:** Why this number? Why not another?
- **"Big picture" comments:** High-level intent before implementation details.

### Aesthetics & Structure
- **Consistent style > "correct" style.** Pick one, stick to it.
- **Align similar code:** Makes differences obvious.
- **Use line breaks to create paragraphs.** Group related statements.
- **Order matters:** Most important → least important, or logical flow.

### Control Flow
- **Prefer positive conditionals:** `if (is_valid)` > `if (!is_invalid)`
- **Put changing values on left:** `if (length >= 10)` > `if (10 <= length)`
- **Minimize nesting:** Early returns > deep if-else trees. >3 levels deep is a smell.
- **Return early:** Guard clauses > nested success paths.

### Variables
- **Eliminate intermediate variables** that don't add clarity.
- **Shrink variable scope:** Define close to use, narrow lifetime.
- **Prefer immutable:** Write-once variables are easier to reason about.

### Breaking Down Problems
1. **Extract functions** for logical chunks, even if called once.
2. **One task per function.** If you use "and" describing it, split it. >50 LOC usually means more than one task.
3. **Unrelated subproblems** should be separate functions.
4. **Interface should be obvious.** If usage is unclear, redesign.

## Surgical Changes

### Core Principle
**Every changed line must trace to the request.** Scope discipline beats opportunistic improvement.

### Key Practices

**Change only what the task requires.** No improving adjacent code, refactoring what isn't broken, or restyling code that works.

**Match the surrounding style,** even where you'd write it differently. Consistency beats personal preference.

**Preserve what you don't fully understand.** Code and comments may matter in ways not visible locally; don't alter them as a side effect.

**Flag off-task problems, don't fix them.** Dead code, a bug, a smell outside the task? Note it for the user; keep it out of this diff.

**Separate refactors from behavior changes,** and treat removal as its own task. A refactor and a behavior change are distinct steps, never one tangled diff. Deleting dead code earns real verification (search callers, check serialization/reflection/interface use, run tests), not a drive-by edit.

## Dependency Philosophy

### Core Principle
**Choose dependencies that reduce system complexity and risk, not just code volume.** Dependencies are liabilities with benefits.

### Quality Checklist
**Green:** Active maintenance (<6mo old), high downloads + age >2yr, small dep tree (<3 levels), semantic versioning, permissive license
**Red:** Abandoned (>1yr), frequent breaking changes, deep dep tree, single maintainer on critical path, requires native compilation

### Decision Framework
1. Security, crypto, complex protocol, or battle-tested algorithm (compression, parser, image)? → Use dependency
2. Within an established framework's ecosystem? → Use the ecosystem; fighting it costs more than bloat
3. <100 LOC straightforward code, or performance-critical hot path? → Write it
4. Well-known, actively maintained library? → Evaluate transitive deps
5. Requirements stable or shifting? → Stable = dep, shifting = DIY
6. Transitive dep count >10? → Smell

## Test Isolation

### Core Principle
**Tests must be hermetic.** Independent of siblings; independent of the host.

Use dynamic/random identifiers (ports, namespaces, instance IDs) rather than fixed values so parallel runs don't collide. Mock home directories and clear environment variables so user config can't affect tests; never let tests modify the user's configuration.
