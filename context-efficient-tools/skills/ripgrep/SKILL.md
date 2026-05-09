---
name: ripgrep
description: Search file contents efficiently with ripgrep (rg) -- one-shot pattern searches that return files, line numbers, and context in a single call.
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

| Need | Tool |
|---|---|
| Simple pattern, structured output | Grep (Claude Code tool, built on rg) |
| `-F`, `-w`, `-v`, `-L`, pipe composition | Bash(rg) |
| File name only, not contents | Glob |

Default to Grep unless something on the right column applies.

## Non-default flags worth knowing

- `-F` literal pattern, no regex -- use when the pattern contains `.` `(` `*` etc.; avoids escape hell
- `-w` whole-word match -- `-w -e 'test'` won't hit `testing` or `latest`
- `-l` / `-L` list files containing / not containing the pattern
- `-g 'glob'` glob filter when `-t` doesn't fit (`-g '*.test.js'`, `-g '!vendor/**'`)
- `-e 'a' -e 'b'` multiple patterns, OR semantics
