---
description: A rename is below the skill's bar for a log entry. The skill should say so and leave the log alone.
tags: [guardrail]
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

I renamed getUser to fetchUser across the api package so it matches the other fetch* helpers. Log that decision.
