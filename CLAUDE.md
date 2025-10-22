# Claude Plugin Development Repository

This repository contains Claude Code plugins (agents, skills, commands, hooks) for extending Claude's capabilities. Use this guide as reference when developing, testing, and distributing plugins.

---

# Claude Code Plugins Reference

## What are Plugins?

Claude Code plugins are custom collections of commands, agents, skills, hooks, and MCP servers packaged in a Git repository. Plugins:

- Install with a single command (`/plugin`)
- Work across terminal and VS Code environments
- Enable sharing reusable workflows across projects and teams
- Automate development tasks and standardize practices
- Extend Claude's capabilities with specialized knowledge

## Plugin Architecture

### Component Types

**Commands** - Custom slash commands for quick, deterministic actions
- Defined in `commands/*.md` files
- Use natural language instructions with parameter placeholders
- Best for: Quick, repeatable tasks with predictable flow

**Agents (Sub-agents)** - Specialized AI assistants with isolated context
- Defined in `agents/*.md` files
- Have their own system prompt and tool permissions
- Best for: Intelligent analysis requiring reasoning and adaptation

**Skills** - Model-invoked expertise that Claude autonomously uses when relevant
- Defined in `skills/SKILL.md` files with supporting resources
- Lazily loaded only when Claude determines they're needed
- Best for: Domain expertise, complex workflows, specialized knowledge

**Hooks** - Event handlers that run shell commands at lifecycle points
- Defined in `hooks/hooks.json` files with optional `hooks/references/` for content
- Can validate, block, or enhance tool usage
- SessionStart hooks can inject context from reference files
- Best for: Automation, validation, code formatting, injecting session context

**MCP Servers** - Model Context Protocol integrations
- Defined in `.mcp.json` file
- External tool and service integrations
- Best for: Database access, API integrations, system tools

### Standard Directory Structure

```
plugin-name/
├── .claude-plugin/
│   ├── plugin.json          # Required: plugin manifest
│   └── marketplace.json     # Optional: for distribution
├── commands/                # Custom slash commands
│   └── example.md
├── agents/                  # Specialized sub-agents
│   └── helper.md
├── skills/                  # Model-invoked expertise
│   ├── SKILL.md
│   ├── scripts/            # Executable code
│   ├── references/         # Documentation loaded as needed
│   └── assets/             # Files used in output
├── hooks/                   # Hook configurations
│   ├── hooks.json
│   ├── session-start.sh    # Hook scripts
│   └── references/         # Content files for hooks to load
└── .mcp.json               # MCP server definitions
```

**Critical:** All component directories must be at plugin root, NOT inside `.claude-plugin/`.

---

# Deep Dive: Agent Skills

## What Makes Skills Special

Skills transform Claude from general-purpose to specialized agent through **progressive disclosure** - a three-level loading system that minimizes context usage while maximizing capability:

**Level 1: Metadata (always loaded, ~100 words)**
- Name and description in SKILL.md frontmatter
- Pre-loaded into system prompt at startup
- Gives Claude just enough info to know when to use each skill

**Level 2: SKILL.md body (loaded when triggered, <5k words)**
- Procedural instructions and workflow guidance
- Loaded only when Claude determines skill is relevant
- Keeps core instructions lean and focused

**Level 3: Bundled resources (loaded on-demand, unlimited)**
- `scripts/` - Executed without reading into context
- `references/` - Documentation loaded only when needed
- `assets/` - Files used in output, never pollute context

## Skills vs Traditional Approaches

**Traditional:** All instructions loaded upfront, consuming context regardless of relevance

**Skills approach:**
- **Discoverable** - Claude can browse available capabilities via metadata
- **Lazy-loaded** - Content loaded only when needed
- **Executable** - Scripts run deterministically without token generation
- **Composable** - Multiple skills combine for complex workflows
- **Specialized** - Each skill focuses on specific domain

## Skill Design Principles

### Content Organization

**SKILL.md structure:**
```markdown
---
name: skill-name
description: Complete description of what skill does and when to use it (third-person)
---

# Skill Name

[Purpose in a few sentences]

## When to Use
[Specific triggers and use cases]

## How to Use
[Procedural instructions referencing bundled resources]
```

**Resource types:**
- **scripts/** - Code rewritten repeatedly or requiring deterministic reliability
- **references/** - Documentation Claude should reference while working (schemas, API docs, policies)
- **assets/** - Files used in final output, not loaded into context

### Writing Guidelines

1. **Use imperative/infinitive form** - Write verb-first instructions (NOT second person)
   - ✅ "Run tests before committing"
   - ❌ "You should run tests before committing"

2. **Start with concrete examples** - Understand real usage before building

3. **Avoid duplication** - Information lives in SKILL.md OR references, not both

4. **Keep SKILL.md lean** - Move detailed reference material to separate files (target <5k words)

5. **Metadata quality matters** - Description determines when Claude uses the skill

6. **Think about another Claude** - Write for AI consumer, focus on non-obvious procedural knowledge

7. **Large file handling** - If references >10k words, include grep search patterns in SKILL.md

---

# Plugin Manifest (plugin.json)

**Location:** `.claude-plugin/plugin.json`

**Minimal example:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Clear description of what plugin does"
}
```

**Full schema:**
```json
{
  "name": "my-plugin",              // Required: Plugin identifier
  "version": "1.0.0",                // Required: Semantic version
  "description": "Plugin purpose",   // Required: What it does
  "author": {                        // Optional
    "name": "Your Name",
    "email": "you@example.com"
  },
  "commands": [                      // Optional: Command paths
    "./commands/example.md"
  ],
  "agents": [                        // Optional: Agent paths
    "./agents/helper.md"
  ],
  "hooks": [                         // Optional: Hook paths
    "./hooks/hooks.json"
  ]
}
```

---

# Creating Plugins Step-by-Step

## 1. Initialize Structure

```bash
mkdir my-plugin
cd my-plugin
mkdir -p .claude-plugin commands agents skills hooks
```

## 2. Create Manifest

Create `.claude-plugin/plugin.json`:
```json
{
  "name": "my-first-plugin",
  "description": "A simple example plugin",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

## 3. Add a Command (optional)

Create `commands/hello.md`:
```markdown
# Hello Command

Say hello to the user with their name.

Usage: /hello $NAME

Example: /hello Alice
```

Commands support:
- Natural language instructions
- `$ARGUMENTS` or `$NAME` style parameters
- Clear usage examples

## 4. Add an Agent (optional)

Create `agents/reviewer.md`:
```markdown
# Code Review Agent

You are a senior code reviewer. Your job is to:

1. Check for code quality issues
2. Identify potential bugs
3. Suggest improvements
4. Verify best practices

Always be constructive and specific in your feedback.
```

Agents define:
- Role and personality
- Specific responsibilities
- Behavioral guidelines

## 5. Add a Skill (optional)

Create `skills/SKILL.md`:
```markdown
---
name: security-analysis
description: Analyze code for security vulnerabilities following OWASP guidelines
---

# Security Analysis Skill

Use when analyzing code for security vulnerabilities.

## Common Vulnerabilities to Check
- SQL injection
- XSS attacks
- CSRF vulnerabilities
- Insecure authentication
- Sensitive data exposure

## Analysis Process
1. Identify input validation points
2. Check authentication/authorization
3. Review data handling
4. Verify cryptographic practices
```

Optional skill resources:
```bash
mkdir -p skills/scripts skills/references skills/assets
```

## 6. Add Hooks (optional)

Create `hooks/hooks.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "python -c \"import sys; paths = sys.argv[1].split(','); sys.exit(2 if any('.env' in p or 'package-lock.json' in p for p in paths) else 0)\" \"$PATHS\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "prettier --write \"$PATHS\""
          }
        ]
      }
    ]
  }
}
```

**Hook exit codes:**
- `0` = Success, allow operation
- `2` = Block operation (PreToolUse only, message via stderr)
- Other non-zero = Non-blocking error shown to user

### SessionStart Hooks with References

SessionStart hooks can inject content into Claude's context at the start of every session. Use `hooks/references/` to store content files that the hook script reads and injects.

**Example structure:**
```
hooks/
├── hooks.json
├── session-start.sh
└── references/
    └── content.md
```

**hooks/hooks.json:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**hooks/session-start.sh:**
```bash
#!/usr/bin/env bash
# Use CLAUDE_PLUGIN_ROOT for correct paths regardless of installation location
CONTENT=$(cat "${CLAUDE_PLUGIN_ROOT}/hooks/references/content.md")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(jq -Rs . <<< "$CONTENT")
  }
}
EOF
```

**Environment variables available in hooks:**
- `${CLAUDE_PLUGIN_ROOT}` - Absolute path to your plugin directory (use for all file paths)

This pattern allows you to:
- Keep reference content separate from hook logic
- Share common structure with skills (both use `references/`)
- Inject documentation, style guides, or policies at session start
- Avoid embedding large content in CLAUDE.md files
- Use portable paths via `${CLAUDE_PLUGIN_ROOT}`

---

# Plugin Distribution

## Marketplace Configuration

Create `.claude-plugin/marketplace.json`:
```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "Collection of development plugins",
  "owner": {
    "name": "Team Name",
    "email": "team@example.com"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./my-plugin",
      "description": "Plugin description",
      "version": "1.0.0",
      "category": "development",
      "tags": ["productivity", "automation"],
      "strict": true
    }
  ]
}
```

# Best Practices

## Plugin Design

1. **Single responsibility** - Each plugin solves one problem well
2. **Clear documentation** - Include usage examples and expected behavior
3. **Descriptive names** - Use clear, searchable plugin and command names
4. **Semantic versioning** - Follow semver for version numbers
5. **Minimal dependencies** - Keep plugins lightweight and focused

## Skills Development

1. **Context efficiency** - Use progressive disclosure, keep SKILL.md under 5k words
2. **Scripts as black boxes** - Include `--help` flags, design for execution not reading
3. **Smart references** - Large docs should have grep search patterns in SKILL.md
4. **Clear metadata** - Description determines when Claude invokes skill
5. **Evaluation-driven** - Start with evals, identify gaps, build incrementally

## Security

1. **Review plugin source** - Always inspect code before installing
2. **Trust verification** - Only install from trusted marketplaces and authors
3. **Permission awareness** - Understand what tools each agent can use
4. **Sensitive data protection** - Use hooks to prevent committing secrets
5. **Skills from trusted sources** - Skills can direct Claude to invoke tools and execute code

## Development Workflow

1. **Test locally first** - Use local marketplace for rapid iteration
2. **Progressive complexity** - Start simple, add features incrementally
3. **Hook validation** - Test exit codes and error handling thoroughly
4. **Version control** - Track all plugin changes in Git
5. **Performance** - Keep hook commands fast (<1s)

## Team Standardization

1. **Shared marketplaces** - Create team-specific plugin collections
2. **Consistent naming** - Establish plugin naming conventions
3. **Code review** - Review plugin changes like production code
4. **Documentation** - Maintain plugin usage guides
5. **Onboarding** - Include plugin setup in developer onboarding

---

# Complete Examples

## Example 1: PR Review Plugin

```
pr-review-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── review-pr.md
└── agents/
    └── pr-reviewer.md
```

**plugin.json:**
```json
{
  "name": "pr-review",
  "description": "Automated PR review workflow",
  "version": "1.0.0",
  "commands": ["./commands/review-pr.md"],
  "agents": ["./agents/pr-reviewer.md"]
}
```

## Example 2: Security Audit Plugin with Skill

```
security-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── SKILL.md
│   ├── references/
│   │   ├── owasp-top-10.md
│   │   └── crypto-best-practices.md
│   └── scripts/
│       └── scan.py
└── hooks/
    └── hooks.json
```

**skills/SKILL.md:**
```markdown
---
name: security-audit
description: Comprehensive security analysis following OWASP Top 10 and crypto best practices
---

# Security Audit Skill

Perform security analysis on code and configurations.

## When to Use
- Reviewing code for vulnerabilities
- Auditing authentication/authorization
- Checking cryptographic implementations
- Validating input handling

## Process
1. Run automated scan: `python skills/scripts/scan.py`
2. Reference [OWASP Top 10 guidance](./references/owasp-top-10.md)
3. Check [crypto best practices](./references/crypto-best-practices.md)
4. Document findings with severity ratings
```

## Example 3: Code Quality Hook

**hooks/hooks.json:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|MultiEdit|Write",
            "type": "command",
            "command": "if echo \"$PATHS\" | grep -qE '\\.(env|lock)$'; then echo 'Blocked: Cannot modify protected files' >&2; exit 2; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "matcher": "Edit|Write",
            "type": "command",
            "command": "if echo \"$PATHS\" | grep -q '\\.ts$'; then prettier --write \"$PATHS\" && eslint --fix \"$PATHS\"; fi"
          }
        ]
      }
    ]
  }
}
```

# Resources

- **Official Docs:** https://docs.claude.com/en/docs/claude-code/plugins
- **Skills**: https://docs.claude.com/en/docs/claude-code/skills
- **Plugin Announcement:** https://www.anthropic.com/news/claude-code-plugins
- **Marketplace Guide:** https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- **Example Plugins:** https://github.com/anthropics/claude-code
