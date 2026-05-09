---
name: code-structure
description: Get an outline (functions/classes/exports) of a file or package without reading it whole. Use when the question is "list/show/what's in" rather than "where is" (search) or "how does it work" (read).
---

# code-structure

When the question is "list the X in Y", do not Read the whole file. Get an outline first; Read selectively after.

## Trigger discrimination

- "list / show / all the methods/classes/exports in ..." -- outline (this skill)
- "where is X defined" / "find calls to X" -- search (rg or ast-grep)
- "how does X work" / "what does X do" -- Read

## Tiered approach

1. **Compiler/parser-aware tool when one fits the language.** These respect exports, cross files, and use real semantic information:
   - Go: `go doc -all ./path/to/pkg`
   - Python: `python -m pydoc some.module.path` (requires the module to be importable -- deps installed, on `PYTHONPATH`)
   - TS/JS third-party: `cat node_modules/<pkg>/dist/index.d.ts` -- the declaration file is a pre-made API outline
   - Java: `javap -p <Class>` (requires compiled `.class` files)

2. **ast-grep with a signature pattern.** Works on any file, no import/build step. See the ast-grep skill for metavariable syntax. Swap the keyword (`function` / `class` / `struct` / `interface` / `type`) to list other constructs:
   - JS/TS: `ast-grep -l typescript -p 'export function $NAME($$$)' file.ts`
   - Python: `ast-grep -l python -p 'def $NAME($$$):' file.py`
   - Go exported: `ast-grep -l go -p 'func $NAME($$$)' file.go | rg -e '^func [A-Z]'`
   - Rust public: `ast-grep -l rust -p 'pub fn $NAME($$$)' file.rs`

3. **ctags fallback** -- universal across languages, canonical for C/C++:
   ```bash
   ctags -f - file | grep -v '^!' | cut -f1,4    # symbol + kind
   ```

Use the outline to decide what to Read, then Read just that section.
