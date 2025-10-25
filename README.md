# xdg-claude

Community marketplace for Claude Code plugins that enhance development workflows, writing quality, and communication style.

## Installation

Configure this marketplace in Claude Code by adding the GitHub repository URL to your marketplace settings directly within `claude`.

```bash
/marketplace add https://github.com/xdg/xdg-claude
```

Once added, you can browse and install individual plugins:

```bash
/plugin
/plugin install coding-best-practices@xdg-claude
```

## List of Plugins

### CLAUDE.md extensions

Inject instructions at session start as if they were in your CLAUDE.md.

| Plugin | Description |
|--------|-------------|
| **coding-best-practices** | Injects coding best practices from *Philosophy of Software Design*, *The Art of Readable Code*, and other tips |
| **elements-of-style** | Injects writing style guidance from *The Elements of Style* |
| **pithy-communication** | Injects pithy communication style guidance for high signal-to-noise ratio output |

### Agents

Specialized sub-agents for focused tasks.

| Plugin | Description |
|--------|-------------|
| **code-review** | Code review agent for analyzing code quality, security, performance, and maintainability |

### Skills

Give Claude new [skills](https://docs.claude.com/en/docs/claude-code/skills).

| Plugin | Description |
|--------|-------------|
| **context-efficient-tools** | CLI tools that minimize context usage through targeted extraction instead of reading entire files (ripgrep, ast-grep, jq, yq) |
| **jira-cli** | Command-line Jira management skill using jira-cli with efficient querying and issue workflows |

## License

Apache 2.0 - see [LICENSE](LICENSE) file for details.

## Author

David Golden (xdg@xdg.me)

## Contributing

Contributions welcome! Submit issues or pull requests on GitHub.
