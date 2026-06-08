# xdg-claude — plugin marketplace repository

This repository is a Claude Code plugin marketplace. Each top-level directory
(e.g. `coding-best-practices/`, `git-commit-agent/`, `plugin-authoring/`) is a
self-contained plugin. The marketplace manifest lives at
`.claude-plugin/marketplace.json`.

## Authoring or revising a plugin

The full authoring manual — component types, the three skill patterns, SKILL.md
/ agent / hook / manifest reference, and worked examples — lives in the
`authoring-plugins` skill, not here. It loads on demand instead of consuming
context every session.

- If the `plugin-authoring` plugin is installed, invoke the `authoring-plugins`
  skill (or just start the task; its description triggers it).
- If it is not installed, read the skill directly:
  `plugin-authoring/skills/authoring-plugins/SKILL.md` and its `reference/` files.

## Repository conventions (apply to every change here)

These rules govern work in this repo regardless of which plugin you touch:

1. **Version bumps are paired.** When you change a plugin, bump its semver in
   BOTH `<plugin>/.claude-plugin/plugin.json` and the matching entry in
   `.claude-plugin/marketplace.json`. The two must never disagree.

2. **New plugins get registered in two places.** Add an entry to
   `.claude-plugin/marketplace.json` AND a row to the appropriate table under
   "List of Plugins" in `README.md` (Essential / Rule / Hook / Skill). Pick the
   category matching the plugin's primary surface.

3. **Each plugin needs its own `README.md`** following the style of the existing
   ones (what it does, installation, marketplace prerequisite).

4. **One plugin, one responsibility.** Skill plugins are each exactly one
   pattern from the taxonomy in the `authoring-plugins` skill.
