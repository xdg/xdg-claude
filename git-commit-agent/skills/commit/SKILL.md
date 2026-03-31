---
name: commit
description: "Commit current changes with intelligent diff analysis and best-practice commit messages. Use when the user asks to commit, create a commit, stage and commit changes, or write a commit message. Analyzes git diffs, groups related changes into atomic commits, and generates conventional commit messages with proper subject lines and body formatting."
context: fork
agent: commit
disable-model-invocation: true
---

Analyze the current working directory changes with `git status` and `git diff`, determine optimal commit boundaries for atomic commits, stage changes appropriately, craft a conventional commit message in imperative mood (subject under 50 chars), and execute the commit. Report back with commit SHA and subject line only.

$ARGUMENTS
