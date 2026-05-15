---
name: commit
description: Commit current changes with intelligent analysis and best-practice messages
context: fork
agent: git-commit-agent:commit
disable-model-invocation: true
argument-hint: "[subject hint or scope]"
---

$ARGUMENTS

If the above is empty, run the default commit workflow over current changes.
