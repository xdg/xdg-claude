---
description: Same prompt as fit-4-changelog-entry, in a session with 28 distractor skills and 16 KB of injected rules.
tags: [crowded]
plugins: ["../..", "commit-messages-fixture", "crowd-fixture"]
runs: 10
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. How should I word the changelog entry?
