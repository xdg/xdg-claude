# context-efficient-tools

A Claude Code plugin that bundles knowledge skills for CLI tools that minimize context usage by extracting only what's needed instead of reading whole files.

## What it does

Ships five Type 1 (knowledge) skills. Each teaches Claude when and how to use a specific CLI tool in place of broader file reads or the built-in Grep tool.

| Skill | Purpose |
|-------|---------|
| **ripgrep** | Search code and text via `rg`. Preferred over the Grep tool: full unredacted output, pipe composition, and flags like `-F`, `-w`, `-L`, `-v`. |
| **ast-grep** | Structural code search and refactoring. Use when Edit fails on uniqueness, when refactoring across formatting variations, or when matching code shape rather than text. |
| **code-structure** | Get an outline (functions/classes/exports) of a file or package without reading it whole. For "list/show/what's in" questions. |
| **jq** | Extract a known field from a JSON file by running `jq` instead of reading the whole file. |
| **yq** | Extract a known field from a YAML file by running `yq` instead of reading the whole file. |

Skills load lazily: only the metadata is in context until Claude decides one applies, at which point the full SKILL.md content is loaded.

## Installation

```bash
claude plugin install context-efficient-tools@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
