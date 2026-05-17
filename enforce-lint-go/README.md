# enforce-lint-go

Enforce `golangci-lint` discipline in Claude Code sessions on Go projects.

## What it does

Three hooks:

- **Stop → `go-lint.sh`.** When Claude finishes a turn, find every changed Go file (staged, unstaged, or untracked), group them by their nearest ancestor `go.mod`, and run `golangci-lint run ./...` once per module directory. On failure, block with the per-module lint output so Claude must fix issues before stopping. Works for root-level Go, single-subdir layouts (e.g. `backend/`), and multi-module monorepos with no configuration.
- **PreToolUse `Bash` → `pre-commit-lint.sh`.** Intercept `git commit*` and run the same lint check. Failures block the commit.
- **PreToolUse `Edit|Write|MultiEdit` → `no-nolint.sh`.** Block two evasions:
  - Edits to `.golangci.yml` / `.golangci.yaml` / `.golangci.toml`.
  - Adding bypass directives in code: `//nolint`, `// #nosec`, `//lint:ignore`, `//revive:disable`, `//exhaustive:ignore`, `//exhaustruct:ignore`, `//nosemgrep`, `//noinspection`, `//nolintlint`.

Both blocks tell Claude to escalate to the human rather than work around the failure.

## Requirements

- `golangci-lint` on `PATH` (the Stop / pre-commit hook silently no-ops if missing).
- `jq` on `PATH`.
- Run inside a git working tree.

## Install

Install per-project, not globally. The hooks fire on every Stop, Bash, and Edit/Write call — running `golangci-lint` and applying Go-specific bypass-directive rules in a Python or JS repo is at best wasted work and at worst confusing failures.

From the project root:

```
claude plugin marketplace add xdg-dev/xdg-claude --scope project
claude plugin install enforce-lint-go@xdg-claude --scope project
```

Both commands write to the repo's `.claude/settings.json`. Commit it so the whole team picks the plugin up automatically.

Equivalent in-session: `/plugin marketplace add xdg-dev/xdg-claude` then `/plugin install enforce-lint-go@xdg-claude` -- but the interactive `/plugin install` defaults to `user` scope (machine-wide), which you do **not** want for a language-specific enforcement plugin. Stick to the CLI with `--scope project`, or edit `.claude/settings.json` directly:

```json
{
  "enabledPlugins": {
    "enforce-lint-go@xdg-claude": true
  }
}
```
