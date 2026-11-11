---
description: Rung 5 of 5 on the fit ladder, which asks how to describe the change in chat, where no skill fits. Measures how often the commit-messages fixture skill is invoked.
tags: [fit]
plugins: ["../..", "commit-messages-fixture"]
runs: 10
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. How should I describe that to a teammate in Slack?
