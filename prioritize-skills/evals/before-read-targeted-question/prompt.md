---
description: A narrow question about one function in a 239-line Go file. The fixture skill says to outline a file before reading it.
tags: [before-acting]
plugins: ["../..", "outline-fixture"]
runs: 10
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Does the upload handler in server/handler.go check the Content-Type header before it reads the body?
