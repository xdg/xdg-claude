---
name: plan-refactor
description: "Analyze code and recommend prioritized refactoring opportunities without making changes. Use when the user asks what to refactor, where to improve code quality, how to find code smells, or needs analysis of technical debt, duplication, or complexity. Returns a ranked list of recommendations with value/risk assessment — does not modify code."
context: fork
agent: plan-refactor
disable-model-invocation: true
---

Analyze the specified code for refactoring opportunities. Scan for duplication, long methods, complex conditionals, poor naming, dead code, tight coupling, and magic values. Return a prioritized list (max 10) in the format `[PRIORITY] file:line - Action | Rationale | Benefit`, ranked by high-value/low-risk first. Do not make code changes — recommendations only.

$ARGUMENTS
