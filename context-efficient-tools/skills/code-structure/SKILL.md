---
name: code-structure
description: Outline a file or package (functions, classes, methods, types, imports, exports) instead of reading it whole. Use before opening an unfamiliar or large file to orient, when surveying a package's API surface, or to find where a symbol is defined so you can Read just that range -- any "what's in / list / show me the structure of" need. Not for "where is X used" (search) or "how does X work" (read the body).
---

# code-structure

When the question is "list the X in Y", do not Read the whole file. Get an outline first; Read selectively after.

## Trigger discrimination

- "list / show / all the methods/classes/exports in ..." -- outline (this skill)
- "where is X defined" / "find calls to X" -- search (rg or ast-grep)
- "how does X work" / "what does X do" -- Read

## Tiered approach

1. **`ast-grep outline`** -- the default. One interface across languages, no build or import step, and every text view carries line numbers so you can Read just the range you need afterward. Pass `-l` to be safe (required for stdin; inferred from extension for paths).
   - File outline: `ast-grep outline -l go file.go` (digest: signatures + member names)
   - Cheapest survey: `ast-grep outline -l go file.go --view names`
   - Drill one symbol's members: `ast-grep outline -l go file.go --match Visitor --view expanded`
   - Directory's exported surface: `ast-grep outline -l go ./pkg`
   - Filter by kind: `--type struct,function`; by name: `--match REGEX`; public members only: `--pub-members`
   - Dependency check: `ast-grep outline -l go file.go --items imports`
   - Machine-readable: `--json=compact` (also `pretty`, `stream`)

2. **Compiler/parser-aware tool** when you need true export semantics or docstrings, which outline does not carry:
   - Go: `go doc -all ./path/to/pkg`
   - Python: `python -m pydoc some.module.path` (requires the module to be importable -- deps installed, on `PYTHONPATH`)
   - TS/JS third-party: `cat node_modules/<pkg>/dist/index.d.ts` -- the declaration file is a pre-made API outline
   - Java: `javap -p <Class>` (requires compiled `.class` files)

3. **ctags fallback** -- for languages outline's bundled rules don't cover; canonical for C/C++:
   ```bash
   ctags -f - file | grep -v '^!' | cut -f1,4    # symbol + kind
   ```

Use the outline to decide what to Read, then Read just that section.
