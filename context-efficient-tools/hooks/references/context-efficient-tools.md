---
source: context-efficient-tools plugin
---

## Reach for a context-efficient tool before reading whole files

Before you `Read` an entire file, `Grep` broadly, or fan out to explore an
unfamiliar package, ask whether a targeted tool answers the question for a
fraction of the context:

- **Orienting in a file or package, or listing what it defines** (functions,
  classes, methods, types, imports, exports) -- load `code-structure` and
  outline it first, then Read only the ranges you need. Do this *before*
  opening a large or unfamiliar file, not after.
- **Searching code or text** -- prefer `ripgrep` (rg) over the Grep tool: full
  unredacted output, pipe composition, and flags Grep lacks.
- **Matching or rewriting by code shape**, or when an Edit fails on a
  non-unique string -- use `ast-grep`.
- **Extracting a known field from JSON or YAML** -- use `jq` / `yq` instead of
  reading the whole file.

These skills exist to keep the main context small. The reflex to just open the
file is the thing they replace.
