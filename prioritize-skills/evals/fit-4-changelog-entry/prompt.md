---
description: Rung 4 of 5 on the fit ladder, which asks for a changelog line, which is not a commit message. Measures how often the commit-messages fixture skill is invoked.
tags: [fit]
plugins: ["../..", "commit-messages-fixture"]
runs: 10
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. How should I word the changelog entry?
