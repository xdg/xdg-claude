#!/usr/bin/env bash
# Prints, for each grader of each case, its pass rate with prioritize-skills,
# its pass rate in the <case>-control twin, and the difference.
# Usage: pair-deltas.sh <result.json from `claude plugin eval --json`>
set -euo pipefail

jq -r '
  def rate($grader):
    [.arms.with[].graders[] | select(.name == $grader) | .passed] as $runs
    | {passed: ($runs | map(select(.)) | length), total: ($runs | length)};
  def fraction: if .total == 0 then null else .passed / .total end;

  (.cases | map({key: .name, value: .}) | from_entries) as $by_name
  | ["CASE", "GRADER", "WITH", "CONTROL", "DELTA"],
    ( .cases[]
      | select(.name | endswith("-control") | not)
      | . as $case
      | $by_name[$case.name + "-control"] as $control
      | ([$case.arms.with[].graders[].name] | unique)[] as $grader
      | ($case | rate($grader)) as $with
      | (if $control then $control | rate($grader) else {passed: 0, total: 0} end) as $ctrl
      | [ $case.name, $grader,
          "\($with.passed)/\($with.total)",
          "\($ctrl.passed)/\($ctrl.total)",
          ( if ($with | fraction) == null or ($ctrl | fraction) == null then "n/a"
            else (($with | fraction) - ($ctrl | fraction)) * 100 | round / 100
                 | if . > 0 then "+\(.)" else tostring end
            end ) ]
    )
  | @tsv
' "$1" | column -t -s $'\t'
