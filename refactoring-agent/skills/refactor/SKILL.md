---
name: refactor
description: "Execute one specific, surgical code refactoring while preserving all observable behavior. Use when the user asks to extract a function, remove duplication, simplify conditionals, rename symbols, reduce nesting, or perform any targeted code quality improvement. Runs tests before and after to verify behavior preservation. For planning what to refactor, use plan-refactor instead."
context: fork
agent: refactor
disable-model-invocation: true
---

Execute the following refactoring as a single atomic change. Verify all tests pass before and after. Preserve all observable behavior — same outputs, same error handling, same side effects. If tests fail after 5 attempts, revert and report the blocker. Do not combine with feature changes or bug fixes.

$ARGUMENTS
