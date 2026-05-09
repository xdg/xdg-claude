---
name: yq
description: Extract a known field from a YAML file by running yq instead of reading the whole file.
---

# yq

When you need a specific field from a YAML file, reach for `yq` rather than Read. Syntax mirrors jq.

```bash
yq '.field' file.yml
```

Assumes `mikefarah/yq` (Go-based). The Python `kislyuk/yq` fork has different syntax; if jq-style queries don't work, check which `yq` is on `PATH`.

Three things easy to forget:
- `-r` -- raw string output (no surrounding quotes)
- `select(document_index == N)` -- pick the Nth doc in a multi-document file (`---` separators)
- `yq -o json file.yml | jq '...'` -- escape hatch when yq syntax gets ugly

For anything else, `yq --help`.
