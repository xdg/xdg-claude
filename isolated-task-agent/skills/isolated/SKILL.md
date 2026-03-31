---
name: isolated
description: "Execute a focused subtask in a clean, isolated context that keeps the main conversation history unpolluted. Use when running exploratory analysis, parallel investigations, context-heavy research, experimental operations, one-off calculations, or any self-contained work that should not clutter the primary conversation."
context: fork
agent: isolated
disable-model-invocation: true
---

Execute the following task in isolated context. Work independently, use all available tools, and return only a concise summary of findings and outcomes — do not include working process or intermediate steps.

$ARGUMENTS
