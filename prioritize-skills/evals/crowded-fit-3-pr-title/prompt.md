---
description: Same prompt as fit-3-pr-title, in a session with 28 distractor skills and 16 KB of injected rules.
tags: [crowded]
plugins: ["../..", "commit-messages-fixture", "crowd-fixture"]
runs: 50
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. What should the pull request title be?
