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

**Skills** - User-invoked or model-invoked capabilities (replaces commands as of Claude Code 2.1.3)
- Defined in `skills/skill-name/SKILL.md` files with supporting resources
- Each skill isolated in its own directory
- Lazily loaded only when Claude determines they're needed
- Can route to agents via `context: fork` + `agent` frontmatter
- Use `disable-model-invocation: true` for manual-only skills (slash command only)
- Best for: Domain expertise, complex workflows, agent routing, specialized knowledge

**Commands** (legacy) - Custom slash commands; use skills instead
- Defined in `commands/*.md` files
- As of Claude Code 2.1.3, commands and skills are merged; prefer `skills/`
- Existing commands still work but `skills/` is the recommended path

**Agents (Sub-agents)** - Specialized AI assistants with isolated context
- Defined in `agents/*.md` files
- Have their own system prompt and tool permissions
- Routed to via skill frontmatter (`agent` field) or Task tool (`subagent_type`)
- Best for: Intelligent analysis requiring reasoning and adaptation

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
├── skills/                  # Skills (user-invoked and model-invoked)
│   └── skill-name/         # Each skill in its own directory
│       ├── SKILL.md
│       ├── scripts/        # Executable code
│       ├── reference/      # Documentation loaded as needed
│       └── assets/         # Files used in output
├── agents/                  # Specialized sub-agents
│   └── helper.md
├── commands/                # (legacy) Use skills/ instead
│   └── example.md
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
- `reference/` - Documentation loaded only when needed
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

**SKILL.md frontmatter fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (used in slash commands) |
| `description` | Yes | What skill does and when to use it (third-person) |
| `context` | No | `fork` to run skill body as a task prompt in a subagent |
| `agent` | No | Agent name to route to (requires `context: fork`) |
| `disable-model-invocation` | No | `true` for manual-only skills (slash command only) |

**SKILL.md structure (knowledge skill):**
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

**SKILL.md structure (agent-routing skill):**
```markdown
---
name: skill-name
description: Brief description of what the agent does
context: fork
agent: skill-name
disable-model-invocation: true
---

[Task prompt passed to the agent]

$ARGUMENTS
```

**Resource types:**
- **scripts/** - Code rewritten repeatedly or requiring deterministic reliability
- **reference/** - Documentation Claude should reference while working (schemas, API docs, policies)
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
  "agents": [                        // Optional: Agent paths
    "./agents/helper.md"
  ],
  "hooks": [                         // Optional: Hook paths
    "./hooks/hooks.json"
  ],
  "commands": [                      // Legacy: use skills/ instead
    "./commands/example.md"
  ]
}
```

**Note:** Skills are auto-discovered from the `skills/` directory and do not need manifest entries. The `"commands"` field is legacy; prefer `skills/` for new development.

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

## 3. Add a Skill (optional)

Skills are the primary way to add slash-command-invocable capabilities to plugins.

**Simple knowledge skill** (`skills/security-check/SKILL.md`):
```markdown
---
name: security-check
description: Check code for common security vulnerabilities
---

# Security Check

Scan the specified code for OWASP Top 10 vulnerabilities.

$ARGUMENTS
```

**Agent-routing skill** (`skills/review/SKILL.md`):
```markdown
---
name: review
description: Route to the code review agent
context: fork
agent: review
disable-model-invocation: true
---

Review the code for quality, security, and maintainability.

$ARGUMENTS
```

Skills support:
- `$ARGUMENTS` parameter placeholder for user input
- `context: fork` + `agent` for routing to a named agent
- `disable-model-invocation: true` for manual-only (slash command only)
- Auto-discovery from `skills/` directory (no manifest entry needed)

## 4. Add an Agent (optional)

Create `agents/reviewer.md`:
```markdown
---
name: code-review-agent
description: Perform thorough code review checking for quality, bugs, and best practices
tools: Read, Grep, Glob
color: blue
---

# Role

You are a senior code reviewer specializing in identifying code quality issues, potential bugs, and adherence to best practices. Your reviews are thorough, constructive, and specific.

# Primary Responsibilities

**Code Quality Analysis:**
- Check for readability and maintainability issues
- Identify overly complex code that should be simplified
- Verify consistent code style and formatting
- Flag technical debt and suggest improvements

**Bug Detection:**
- Identify potential runtime errors
- Check for edge cases and error handling
- Verify proper null/undefined handling
- Look for race conditions and concurrency issues

**Best Practices Verification:**
- Ensure proper separation of concerns
- Check for security vulnerabilities
- Verify appropriate use of language features
- Validate test coverage for new code

# Reporting Back

Provide a structured review report:

**Summary:** Brief overview (1-2 sentences) of overall code quality

**Issues Found:** List only specific, actionable items with:
- Severity (critical, major, minor)
- File and line number reference
- Brief explanation of the issue
- Suggested fix when appropriate

Do NOT include full code blocks or diffs in your report unless absolutely necessary. Keep feedback concise and actionable.
```

### Agent Writing Guidelines

**Structure:**
- **Frontmatter**: Required metadata (name, description, tools, optional color)
- **Role**: Establish expertise and purpose using second-person ("You are...")
- **Responsibilities**: Detailed behavioral expectations (mix of second-person framing with imperative instructions)
- **Reporting Back**: Specify return format, emphasizing brevity

**Voice and Tone:**
- Use **second-person** to establish role identity ("You are an expert...")
- Use **second-person** for ongoing responsibilities ("Your job is to...")
- Embed **imperatives** within that frame for specific actions ("Analyze X", "Check Y", "Verify Z")
- This hybrid approach is more effective than pure imperative for establishing agent persona

**Tool Permissions:**

Choose tool access based on the agent's purpose:

*Read-Only Tools (safe for information gathering):*
- **Glob** - File pattern matching
- **Grep** - Code search
- **Read** - Read files (text, images, PDFs, notebooks)
- **WebFetch** - Fetch and analyze web content
- **WebSearch** - Search the web
- **Bash** - Execute commands (run specialized cli tools like ast-grep, rg, jq)

*Write Tools (for agents making changes):*
- **Edit** - Modify existing files
- **Write** - Create/overwrite files
- **NotebookEdit** - Edit Jupyter notebook cells
- **Bash** - Execute commands (can modify filesystem, run builds, etc.)

*Task Management & Communication:*
- **TodoWrite** - Track progress in multi-step tasks
- **AskUserQuestion** - Clarify ambiguous decisions
- **Task** - Launch nested subagents for delegation

*Background Process Management:*
- **BashOutput** - Monitor long-running processes
- **KillShell** - Terminate background shells

*Prompt Expansion:*
- **Skill** - Load specialized skill instructions
- **SlashCommand** - Execute custom command prompts

*Restricted Tools:*
- **ExitPlanMode** - Controls parent conversation flow; should NOT be available to subagents

*Common Tool Patterns:*
- **All agents**: Skill and SlashCommand to enhance capabilities
- **Exploration agents:** Read-only tools + TodoWrite
- **Implementation agents:** Full tool access (read + write + bash)
- **Analysis agents:** Read-only + TodoWrite + AskUserQuestion
- **Specialized agents:** Minimal toolset for focused purpose

**Output Specifications:**
- Default to **brevity** - subagent output pollutes main agent's context
- Return only: outcomes, decisions, actionable findings
- Do NOT return: full content, detailed diffs, file lists (these are in git/filesystem)
- Explicitly state what NOT to include and why
- For multi-item results (e.g., multiple commits), specify format for each

**When to Ask vs. Act:**
- Include explicit section on when to request clarification rather than proceeding
- List specific failure conditions (no data, ambiguous input, detected risks)
- Guide subagent to explain situation and specify what's needed

**Scope Interpretation:**
- Provide clear guidance on how to interpret different types of instructions from main agent
- Handle: specific requests, general requests, edge cases
- Reduce ambiguity in execution

**Naming Conventions:**
- Agent **filenames** should end in `-agent` for clarity (e.g., `code-review-agent.md`)
- Agent frontmatter `name` should match the corresponding skill name (e.g., `name: code-review`)
- Skill→agent routing is handled by skill frontmatter (`context: fork` + `agent`), not by agent descriptions
- Do NOT include `(Use subagent_type: ...)` hints in agent descriptions; this is legacy

## 5. Add a Knowledge Skill (optional)

Create `skills/security-analysis/SKILL.md` for a skill that provides domain knowledge (no agent routing):
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

Optional skill resources (each skill in its own directory):
```bash
mkdir -p skills/security-analysis/{scripts,reference,assets}
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
- Use similar structure pattern as skills (hooks use `references/`, skills use `reference/`)
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

## Agent Development

1. **Minimal tool permissions** - Only grant tools the agent actually needs; avoid Task, WebFetch, WebSearch, TodoWrite unless essential
2. **Brevity in output** - Specify return format that minimizes context pollution; return outcomes and decisions, not full content
3. **Clear failure modes** - Include "When to Ask" section listing conditions that require clarification
4. **Scope interpretation** - Provide guidance on how to interpret different instruction types from main agent
5. **Hybrid voice** - Use second-person for role/responsibilities, embed imperatives for specific actions

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
├── skills/
│   └── review-pr/
│       └── SKILL.md
└── agents/
    └── pr-reviewer-agent.md
```

**plugin.json:**
```json
{
  "name": "pr-review",
  "description": "Automated PR review workflow",
  "version": "1.0.0",
  "agents": ["./agents/pr-reviewer-agent.md"]
}
```

**skills/review-pr/SKILL.md:**
```markdown
---
name: review-pr
description: Review a pull request for quality, bugs, and best practices
context: fork
agent: review-pr
disable-model-invocation: true
---

Review the pull request.

$ARGUMENTS
```

**agents/pr-reviewer-agent.md** (frontmatter `name: review-pr` to match skill):

## Example 2: Security Audit Plugin with Skill

```
security-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── security-audit/
│       ├── SKILL.md
│       ├── reference/
│       │   ├── owasp-top-10.md
│       │   └── crypto-best-practices.md
│       └── scripts/
│           └── scan.py
└── hooks/
    └── hooks.json
```

**skills/security-audit/SKILL.md** (knowledge skill, no agent routing):
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
1. Run automated scan: `python scripts/scan.py` (relative to skill directory)
2. Reference [OWASP Top 10 guidance](./reference/owasp-top-10.md)
3. Check [crypto best practices](./reference/crypto-best-practices.md)
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
