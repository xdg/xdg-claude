---
description: No installed skill fits. The directive must not cause a spurious skill call.
tags: [guardrail]
plugins: ["../..", "commit-messages-fixture"]
runs: 10
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

What is 17 * 23?
