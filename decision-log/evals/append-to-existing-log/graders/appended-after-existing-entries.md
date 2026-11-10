---
type: regex
pattern: '## 2026-03-02 -- Use pgx over database/sql[\s\S]*Revisit if a second database backend[\s\S]*## 2026-05-19 -- Vendor the protobuf definitions[\s\S]*Revisit if they start changing monthly\.[\s\S]*^## \d{4}-\d{2}-\d{2} -- .*golangci-lint'
flags: im
target: {source: file, path: docs/decisions.md}
---
