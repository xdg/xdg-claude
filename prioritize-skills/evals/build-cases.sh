#!/usr/bin/env bash
# Generates the parts of the suite that git does not hold. Run before
# `claude plugin eval prioritize-skills`; `make eval-prioritize-skills` does.
#
# 1. Fixture copies. A fixture plugin must sit inside the case that lists it in
#    `plugins:`, and neither a shared directory nor a symlink is accepted. The
#    sources live in fixtures/ and are copied into each case.
# 2. Control twins. Every case gets a <case>-control that differs only in not
#    loading prioritize-skills. The plugin's effect on a case is its pass rate
#    minus its control's.
set -euo pipefail

evals_dir=$(dirname "$0")

find "$evals_dir" -mindepth 1 -maxdepth 1 -type d -name '*-control' -exec rm -rf {} +

for prompt in "$evals_dir"/*/prompt.md; do
  case_dir=$(dirname "$prompt")

  fixtures=$(grep '^plugins:' "$prompt" | grep -o '"[a-z-]*-fixture"' | tr -d '"')
  for fixture in $fixtures; do
    rm -rf "${case_dir:?}/$fixture"
    cp -R "$evals_dir/fixtures/$fixture" "$case_dir/$fixture"
  done

  control_dir="$case_dir-control"
  cp -R "$case_dir" "$control_dir"
  # -i.bak: the one in-place form both GNU and BSD sed accept
  sed -i.bak 's|"\.\./\.\.", *||' "$control_dir/prompt.md"
  rm "$control_dir/prompt.md.bak"
  if [[ -f "$control_dir/case.yaml" ]]; then
    sed -i.bak 's|^name: \(.*\)$|name: \1-control|' "$control_dir/case.yaml"
    rm "$control_dir/case.yaml.bak"
  fi
done
