#!/usr/bin/env bash
# Seeds a workspace whose decision log already follows the skill's template.
set -euo pipefail
mkdir -p docs
echo "# widgetd" > README.md
cat > docs/decisions.md <<'LOG'
# Decision log (append-only)

Format: date -- decision -- rationale. Newest last. Do not rewrite
history; supersede with a new entry.

## 2026-03-02 -- Use pgx over database/sql

We talk to Postgres through pgx v5 directly rather than through database/sql.
database/sql hides LISTEN/NOTIFY and COPY, and the job queue needs both. The
cost is that the storage package cannot be pointed at another database without
a rewrite. Revisit if a second database backend becomes a requirement.

## 2026-05-19 -- Vendor the protobuf definitions

The .proto files are copied into api/proto at a pinned commit instead of pulled
as a git submodule. Submodules broke CI checkouts twice in April, and the
definitions change about once a quarter. Updating them now takes a manual copy
and a commit. Revisit if they start changing monthly.
LOG
