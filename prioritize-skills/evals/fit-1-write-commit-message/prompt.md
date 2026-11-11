---
description: Rung 1 of 5 on the fit ladder, which asks for a commit message outright. Measures how often the commit-messages fixture skill is invoked.
tags: [fit]
plugins: ["../..", "commit-messages-fixture"]
runs: 10
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. Write the commit message.
