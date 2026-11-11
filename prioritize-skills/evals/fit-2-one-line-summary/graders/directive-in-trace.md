---
type: regex
pattern: 'Prioritize Skills'
target: trace
---

Canary. Passes when the SessionStart hook's output appears in the trace, so it
must pass in every run of the case and fail in every run of its control.
