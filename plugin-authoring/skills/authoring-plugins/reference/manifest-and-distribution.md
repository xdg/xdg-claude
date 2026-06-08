# Manifest and distribution

## Plugin manifest (`.claude-plugin/plugin.json`)

**Minimal:**
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
  "name": "my-plugin",              // Required: plugin identifier
  "version": "1.0.0",                // Required: semantic version
  "description": "Plugin purpose",   // Required: what it does
  "author": {                        // Optional
    "name": "Your Name",
    "email": "you@example.com"
  },
  "agents": [ "./agents/helper.md" ],  // Optional: agent paths
  "hooks":  [ "./hooks/hooks.json" ],  // Optional: hook paths
  "commands": [ "./commands/example.md" ] // Legacy: prefer skills/
}
```

Skills, agents, and hooks placed under their standard directories (`skills/`, `agents/`, `hooks/`) are auto-discovered and need no manifest entry. The `agents` and `hooks` arrays are only needed when files live outside those directories. The `commands` field is legacy; prefer `skills/` for new development.

## Scaffolding a plugin

```bash
mkdir my-plugin && cd my-plugin
mkdir -p .claude-plugin agents skills hooks
```

Then write `.claude-plugin/plugin.json` (above) and add components per their reference files.

## Marketplace configuration (`.claude-plugin/marketplace.json`)

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

When you add a plugin to a marketplace, register it here AND add a row to the README plugin table. Bump versions in both the per-plugin `plugin.json` and the marketplace entry (semver).

## Best-practice checklists

**Plugin design.** Single responsibility (one problem well); clear docs with usage examples; descriptive, searchable names; semantic versioning bumped in both manifest and marketplace entry; list new plugins in the README; minimal dependencies.

**Agent development.** Minimal tool permissions; brevity in output (outcomes and decisions, not full content); clear failure modes ("When to ask"); scope-interpretation guidance; hybrid voice (second person for role, imperatives for actions).

**Skills development.** Context efficiency via progressive disclosure (SKILL.md under 5k words); scripts as black boxes (`--help` flags, designed for execution not reading); smart references (grep patterns in SKILL.md for large docs); clear metadata (the description drives invocation).

**Security.** Review plugin source before installing; only install from trusted marketplaces/authors; understand each agent's tool access; use hooks to prevent committing secrets; remember skills can direct Claude to invoke tools and execute code.

**Development workflow.** Test locally first (local marketplace for rapid iteration); progressive complexity (start simple); validate hooks (exit codes, error handling); version-control all changes; keep hook commands fast (<1s).

**Team standardization.** Shared marketplaces for team collections; consistent naming conventions; review plugin changes like production code; maintain usage docs; include plugin setup in onboarding.
