---
name: outline-file
description: Outline a source file (functions, types, imports) instead of reading it whole. Use before opening an unfamiliar or large file.
---

# Outline a file

Eval fixture. Before reading a Go file, list its declarations with Grep
(`^func |^type |^import`), then Read only the line ranges you need.
