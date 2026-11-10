---
type: regex
pattern: '^## \d{4}-\d{2}-\d{2} -- \S'
flags: m
match: count:3
target: {source: file, path: docs/decisions.md}
---
