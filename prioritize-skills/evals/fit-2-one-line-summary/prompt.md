---
description: Rung 2 of 5 on the fit ladder, which asks for a one-line change summary without saying "commit". Measures how often the commit-messages fixture skill is invoked.
tags: [fit]
plugins: ["../..", "commit-messages-fixture"]
runs: 10
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. What would be a good one-line summary of that change?
