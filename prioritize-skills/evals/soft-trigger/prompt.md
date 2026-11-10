---
description: The user asks for a one-line change summary without saying "commit". The fixture skill fits loosely; the directive should make Claude consult it.
tags: [core]
plugins: ["../..", "commit-messages-fixture"]
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

I renamed getUser to fetchUser in three files. What would be a good one-line summary of that change?
