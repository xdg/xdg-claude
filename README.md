# xdg-claude

Community marketplace for Claude Code plugins that enhance development workflows, writing quality, and communication style.

## Installation

Add this marketplace from the command line:

```bash
claude plugin marketplace add xdg/xdg-claude
```

Then install individual plugins:

```bash
claude plugin install coding-best-practices@xdg-claude
```

You can also do both from inside Claude Code with `/plugin marketplace add xdg/xdg-claude` and `/plugin install <name>@xdg-claude`.

## List of Plugins

Plugins fall into three groups:

- **Rule plugins** inject standing instructions into Claude's session or subagent context — parallel to CLAUDE.md, but delivered by the plugin.
- **Hook plugins** run shell commands at lifecycle events to validate, block, or enhance tool usage and enforce project policy.
- **Skill plugins** add new capabilities Claude can use while working. Each is exactly one pattern (see the taxonomy in [CLAUDE.md](CLAUDE.md)):
  - **Knowledge skill** – reference material Claude consults while working (conventions, tool usage, domain knowledge)
  - **Main-agent task** – an activity Claude runs in the main conversation, optionally spawning its own subagents for sub-steps
  - **Subagent task** – an activity Claude delegates to a specialized agent with isolated context, keeping intermediate work out of the main conversation

  A **Slash command** is a `/<name>` shortcut the user types to invoke a task explicitly; either task type can add one (see the plugin's docs for the exact command).

### Essential

Foundational plugins that shape how Claude operates across all other skills and plugins.

| Plugin | Description |
|--------|-------------|
| [**prioritize-skills**](prioritize-skills/README.md) | Directive injected at session and subagent start that requires checking for and invoking applicable skills before responding or acting. Adapted from [obra/superpowers](https://github.com/obra/superpowers) (MIT) |

### Rule plugins

| Plugin | Description |
|--------|-------------|
| [**avoid-ai-tells**](avoid-ai-tells/README.md) | Writing style guidance to avoid common AI patterns: em-dashes, puffery, uniform cadence, banned vocabulary |
| [**coding-best-practices**](coding-best-practices/README.md) | Coding best practices from *Philosophy of Software Design*, *The Art of Readable Code*, and other tips |
| [**elements-of-style**](elements-of-style/README.md) | Writing style guidance from *The Elements of Style* |
| [**pithy-communication**](pithy-communication/README.md) | Pithy communication style guidance for high signal-to-noise ratio output |

### Hook plugins

| Plugin | Description |
|--------|-------------|
| [**enforce-lint-go**](enforce-lint-go/README.md) | Enforce `golangci-lint`: auto-discover Go modules under any layout, run on Stop, block `git commit` on failure, block `//nolint` directives and edits to `.golangci.yml` |

### Skill plugins

| Plugin | Knowledge skill | Main-agent task | Subagent task | Slash command | Description |
|--------|:---------------:|:---------------:|:-------------:|:-------------:|-------------|
| [**adversarial-implementation**](adversarial-implementation/README.md) | | ✓ | | ✓ | Execute a TODO.md plan one checkbox at a time via isolated subagents, with adversarial lint/test/review verification, human-in-the-loop checks, and per-subsection commits |
| [**code-review-agent**](code-review-agent/README.md) | | | ✓ | ✓ | Analyze code quality, security, performance, and maintainability (Opus) |
| [**context-efficient-tools**](context-efficient-tools/README.md) | ✓ | | | | CLI tools that minimize context usage through targeted extraction instead of reading entire files (ripgrep, ast-grep, jq, yq, code-structure) |
| [**git-commit-agent**](git-commit-agent/README.md) | | | ✓ | ✓ | Commit current changes with intelligent analysis and best-practice messages (Sonnet) |
| [**interview-user**](interview-user/README.md) | | ✓ | | | Structured tree-shaped interview to elicit an under-formed plan, design, or strategy, persisted to disk for resumability |
| [**isolated-task-agent**](isolated-task-agent/README.md) | | | ✓ | ✓ | Execute focused work in clean, isolated context without polluting main conversation |
| [**jira-cli**](jira-cli/README.md) | ✓ | | | | Command-line Jira management using jira-cli with efficient querying and issue workflows |
| [**plugin-authoring**](plugin-authoring/README.md) | ✓ | | | | How to author Claude Code plugins: component types, the three skill patterns, frontmatter, agents, hooks, manifests, and worked examples |
| [**refactoring-agent**](refactoring-agent/README.md) | | | ✓ | ✓ | Surgical refactoring and refactor-planning agents for improving code quality without changing behavior (Sonnet/Opus) |
| [**todo-planner**](todo-planner/README.md) | ✓ | | | | Create and maintain structured TODO.md implementation plans with phased tasks, a testing philosophy, and verification checklists |

## License

Apache 2.0 - see [LICENSE](LICENSE) file for details.

## Author

David Golden (xdg@xdg.me)

## Contributing

Contributions welcome! Submit issues or pull requests on GitHub.
