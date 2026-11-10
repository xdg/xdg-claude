---
type: llm
focus: {source: file, path: docs/decisions.md}
---

Judge only the last entry in the file, the one about golangci-lint.

FAIL if its body uses bullet points or a table instead of prose paragraphs.
FAIL if it does not say what was rejected (golangci-lint v2) and why (the custom gocritic checkers).
FAIL if it does not say when to revisit the decision.
PASS otherwise.
