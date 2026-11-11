---
description: Rung 3 of 5 on the fit ladder, which asks for a pull request title, a neighbor of a commit subject. Measures how often the commit-messages fixture skill is invoked.
tags: [fit]
plugins: ["../..", "commit-messages-fixture"]
runs: 50
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. What should the pull request title be?
