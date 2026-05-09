---
name: ripgrep
description: Search code and text files via ripgrep (rg) in Bash. Prefer rg over the Grep tool: rg gives full unredacted output, supports pipe composition, and exposes flags Grep does not (-F, -w, -L, -v).
---

# ripgrep

Default invocation:

```bash
rg -n -C 2 -t TYPE -e 'pattern'
```

- `-n` line numbers
- `-C 2` two lines of context before/after
- `-t TYPE` file-type filter (`-t js`, `-t py`, `-t go`, ...; `rg --type-list` for the full set)
- `-e 'pattern'` single-quoted to keep the shell out

## Tool selection

Default to `Bash(rg)` for code/text search. Grep is the Claude Code built-in (also rg under the hood) but truncates output, cannot pipe, and exposes only a subset of rg flags. Use Grep only when the search is trivial *and* structured output is desired.

Glob handles filename-only matching.

## Non-default flags worth knowing

- `-F` literal pattern, no regex -- use when the pattern contains `.` `(` `*` etc.; avoids escape hell
- `-w` whole-word match -- `-w -e 'test'` won't hit `testing` or `latest`
- `-l` / `-L` list files containing / not containing the pattern
- `-g 'glob'` glob filter when `-t` doesn't fit (`-g '*.test.js'`, `-g '!vendor/**'`)
- `-e 'a' -e 'b'` multiple patterns, OR semantics
