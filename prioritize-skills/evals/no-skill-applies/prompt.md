---
description: No installed skill fits. The directive must not cause a spurious skill call.
tags: [guardrail]
plugins: ["../..", "commit-messages-fixture"]
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

What is 17 * 23?
