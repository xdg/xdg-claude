---
name: code-review
description: "Review code for bugs, security vulnerabilities, performance bottlenecks, and maintainability issues. Use when the user asks to review code, find bugs, check for vulnerabilities, audit code quality, or get feedback on a file, diff, or pull request. Returns prioritized findings with severity levels and actionable suggestions."
context: fork
agent: code-review
disable-model-invocation: true
---

Review the specified code following this priority order: (1) correctness and bugs, (2) security vulnerabilities, (3) performance bottlenecks, (4) maintainability and readability, (5) style and conventions. Categorize each finding by severity (Critical, High, Medium, Low) with file:line references and concrete fix suggestions. Batch all feedback in a single structured review.

$ARGUMENTS
