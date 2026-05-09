---
name: ast-grep
description: Structural code search and refactoring via ast-grep. Reach for this when Edit fails with "old_string not unique", when refactoring across formatting variations, or when matching code shape rather than text.
---

# ast-grep

Default invocation:

```bash
ast-grep -l LANG -p 'PATTERN'                      # search
ast-grep -l LANG -p 'OLD' -r 'NEW'                 # preview rewrite
ast-grep -l LANG -p 'OLD' -r 'NEW' --update-all    # apply
```

`-l` is required -- auto-detect is unreliable. Interactive mode (`-i`) does not work from this harness.

## Metavariables

- `$VAR` -- one AST node (an expression, an identifier, ...)
- `$$$ARGS` -- zero or more items in a list (function args, statement bodies)
- `$$STMT` -- multiple statements

## Canonical patterns

```bash
# Rename a function across all call sites
ast-grep -l typescript -p 'oldFn($$$ARGS)' -r 'newFn($$$ARGS)'

# Rename a method on any receiver
ast-grep -l javascript -p '$OBJ.oldMethod($$$ARGS)' -r '$OBJ.newMethod($$$ARGS)'

# Rewrite imports
ast-grep -l typescript -p 'import $WHAT from "old-pkg"' -r 'import $WHAT from "new-pkg"'
```

Workflow: run without `-r` to see matches, run with `-r` to preview the diff, then add `--update-all`. For surgical per-site control, use ast-grep to find locations and Edit to apply.
