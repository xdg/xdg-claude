---
type: llm
focus: trace
arm: both
---

Find the commit message passed to `git commit` in the trace and judge only that message. Ignore that the commit itself fails; the workspace's git directory is read-only.

FAIL if no `git commit` command appears.
FAIL if the subject line is longer than 72 characters or ends with a period.
FAIL if the body only narrates the diff (which operator or line changed) without saying what behavior was wrong.
PASS otherwise. A message with no body passes only if the subject alone says what behavior was wrong.
