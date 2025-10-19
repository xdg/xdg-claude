# Coding guidelines

## Philosophy of Software Design (Ousterhout)

### Core Principle
**Complexity is the enemy.** Good design minimizes cognitive load.

### Deep vs Shallow Modules
- **Deep modules:** Simple interface, powerful implementation. High benefit/cost ratio.
- **Shallow modules:** Complex interface, trivial implementation. No abstraction value.
- Goal: Maximum functionality behind minimal interface.

### Strategic vs Tactical Programming
- **Tactical:** Quick fixes, "just make it work." Accumulates complexity.
- **Strategic:** Invest 10-20% extra time in good design upfront. Pays dividends.
- Working code isn't enough. Well-designed code is the goal.

### Key Practices

**Information hiding:** Bury complexity behind simple interfaces. Users shouldn't know implementation details.

**Pull complexity downward:** Make module implementers work harder so users work less. The opposite is disaster.

**Different layer, different abstraction:** Pass-through methods/variables are red flags. Each layer should add value.

**Design it twice:** Always consider multiple approaches. First idea is rarely best.

**General-purpose > special-case:** Fewer, more flexible methods > many specialized ones.

**Define errors out of existence:** Design APIs so errors can't happen vs detecting/handling them.

### Red Flags
- Pass-through methods/variables (shallow layers)
- Special cases multiplying (configuration complexity)
- Exceptions for normal control flow
- Comments describing what code does (should describe why/non-obvious)
- Getters/setters exposing internal structure

### Design Mantra
"Modules should be deep, interfaces should be simple, and special cases should be eliminated."

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
- **Minimize nesting:** Early returns > deep if-else trees.
- **Return early:** Guard clauses > nested success paths.

### Variables
- **Eliminate intermediate variables** that don't add clarity.
- **Shrink variable scope:** Define close to use, narrow lifetime.
- **Prefer immutable:** Write-once variables are easier to reason about.

### Breaking Down Problems
1. **Extract functions** for logical chunks, even if called once.
2. **One task per function.** If you use "and" describing it, split it.
3. **Unrelated subproblems** should be separate functions.
4. **Interface should be obvious.** If usage is unclear, redesign.

### Red Flags
- Nested ifs >3 deep
- Functions >50 LOC (usually)
- Variables with large scope
- Clever/terse code that requires decoding
- Inconsistent naming/formatting

### Key Insight
**The reader matters more than the writer.** Code is read 10x more than written.

## Dependency Philosophy

**Default: Skeptical.** Dependencies are liabilities with benefits.

### Use Dependencies For
- Security/crypto (never roll your own)
- Complex protocols (HTTP/2, OAuth2, WebSockets)
- Battle-tested algorithms (compression, parsers, image processing)
- Framework ecosystems (fighting them is worse than bloat)
- Complex text format parsing (URIs, email addresses)

### Write It Yourself For
- <100 LOC of straightforward code
- Project-specific logic
- Frequently changing requirements
- Performance-critical paths

### Quality Checklist
**Green:** Active maintenance (<6mo old), high downloads + age >2yr, small dep tree (<3 levels), semantic versioning, permissive license
**Red:** Abandoned (>1yr), frequent breaking changes, deep dep tree, single maintainer on critical path, requires native compilation

### Decision Framework
1. Security/crypto/complex protocol? → Use dependency
2. <100 LOC straightforward code? → Write it
3. Well-known, actively maintained library exists? → Evaluate transitive deps
4. Requirements stable or shifting? → Stable = dep, shifting = DIY
5. Transitive dep count >10? → Smell

### Examples
**Use:** bcrypt, axios/fetch, lodash (tree-shake), express
**Avoid:** is-odd, left-pad, unmaintained plugins, framework wrappers

### Meta-Principle
Choose dependencies that reduce total system complexity, not just code volume.

## Working Directory Management

### Important Guidelines
1. **Always check current directory** if unknown
2. **Use absolute paths** when possible to avoid confusion
3. **Return to project root** after completing tasks in subdirectories
4. **Prefer running git commands from project root** to avoid path issues

### Command Location Reference
- **Git commands**: Always run from project root
- **Docker commands**: Run from project root unless othewise instructed

## Bash Tool Best Practices
- When changing directories for a specific task, prefer using subshells to preserve exit codes:
  ```bash
  # Best: Use subshell (preserves exit code)
  (cd backend && go build)

  # Alternative: Explicit directory management
  cd backend
  go build
  cd ..

  # Avoid: Chaining with && (hides exit codes)
  cd backend && go build && cd ..  # Bad: if go build fails, cd .. won't run
  ```
- **Always verify command success** by checking output and exit codes
