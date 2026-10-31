---
name: comment-review
description: Audit code comments for information content and clarity
context: fork
agent: comment-review
disable-model-invocation: true
argument-hint: "[target: file, directory, PR, branch, or commit range]"
---

$ARGUMENTS

If the above is empty, review the comments in the uncommitted changes.
