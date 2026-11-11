---
type: llm
focus: trace
arm: both
---

Find the commit message passed to a `git commit` command in the trace and judge only that message. The git binary may be invoked by full path (`/opt/homebrew/bin/git commit`) or through a shell variable (`$G commit`); treat those as `git commit`. Ignore whether the commit succeeded.

FAIL if no `git commit` command appears.
FAIL if the subject line is longer than 72 characters or ends with a period.
FAIL if the body only narrates the diff (which operator or line changed) without saying what behavior was wrong.
PASS otherwise. A message with no body passes only if the subject alone says what behavior was wrong.
