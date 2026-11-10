---
description: A log in the skill's template exists. The skill should append one entry and leave the rest alone.
tags: [core]
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

We settled this today: pin golangci-lint to v1.64.8 instead of moving to v2. The v2 config migration drops our two custom gocritic checkers, and rewriting them would take about a week. Revisit when gocritic ships v2 plugin support. Log that decision.
