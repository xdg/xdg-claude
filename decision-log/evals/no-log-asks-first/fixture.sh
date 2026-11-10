#!/usr/bin/env bash
# Seeds a workspace with no decision log of any kind.
set -euo pipefail
echo "# widgetd" > README.md
printf 'package main\n\nfunc main() {}\n' > main.go
