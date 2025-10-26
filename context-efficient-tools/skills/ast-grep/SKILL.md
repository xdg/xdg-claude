---
name: ast-grep
description: Use ast-grep for structural code search and refactoring when editing code structure with ambiguity in text matching, handling "old_string not unique" problems, or performing formatting-independent pattern matching across function signatures, method calls, and class structures
---

# ast-grep: Structural Code Search and Editing

Use ast-grep to solve the "old_string not unique" problem by matching code structure instead of exact text. This enables refactoring across formatting variations and structural patterns.

## When to Use ast-grep vs Text Tools

### Use ast-grep when:
- **Structural code changes** - Refactoring function signatures, method calls, class structures
- **Formatting-independent matching** - Need to find code regardless of whitespace/line breaks
- **Pattern variations** - Matching similar structures with different variable names/arguments
- **"old_string not unique" problem** - Edit tool fails because text appears in multiple contexts
- **Complex queries** - Finding nested structures, specific AST patterns

### Use text tools (Edit/Grep) when:
- **Simple, unique string replacement** - The exact text appears once or in consistent format
- **Non-code files** - Markdown, configs, data files
- **Comment/documentation edits** - Content that isn't code structure
- **Very small changes** - Single line, obvious context, no ambiguity

## Key Decision Rule

**If editing code structure and there's any ambiguity in text matching → use ast-grep.**

ast-grep's primary value: **Solves the "old_string not unique" problem by matching structure instead of exact text.**

## Detailed Reference

For comprehensive patterns, syntax, metavariables, common use cases, language-specific tips, and best practices, load [ast-grep guide](./reference/ast-grep-guide.md).

The reference includes:
- Pattern syntax and metavariables (`$VAR`, `$$$ARGS`, `$$STMT`)
- Recommended workflow (search, verify, apply, validate)
- Common use cases with examples (function calls, imports, method renames)
- Language-specific tips (JavaScript/TypeScript, Python, Go, Rust)
- Best practices and pitfalls to avoid
- Integration strategies with Edit tool
