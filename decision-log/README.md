# decision-log

A Claude Code plugin that builds the habit of recording durable engineering
decisions in an append-only log.

## What it does

Ships a single skill that Claude reaches for after a choice with teeth: a
dependency, a version pin, a protocol or deployment topology, a deliberate
omission, or a reversal of an earlier decision. Claude appends a dated entry
naming what was chosen, what lost, and the condition for revisiting it.

The format is deliberately plain — `## YYYY-MM-DD — Title` followed by prose,
newest last:

```markdown
# Decision log (append-only)

Format: date — decision — rationale. Newest last. Do not rewrite
history; supersede with a new entry.

## 2026-07-22 — Pin dex v2.45.1 (alpine variant) by tag + digest

The bare version tag IS the alpine variant; chosen over `-distroless`
because it has a shell + wget for the compose healthcheck. Config
verified against the v2.45.1 source, not docs alone.
```

The skill also covers the bar for what earns an entry (real alternatives,
reasoning not recoverable from the diff), and the supersede protocol for
reversing a decision without rewriting history.

### Consent before it touches a repo

The log lives at a path named in the project's `CLAUDE.md`, or `docs/decisions.md`
by default. If no log exists, Claude asks before starting one — repos you do not
own may want no such file. If a log exists in a different format (ADR-per-file, a
table, numbered records), Claude follows that repo's convention instead of
converting it.

It runs in the main conversation, so you see and can veto each entry as it lands.
Invoke it directly with `/decision-log` when Claude does not offer.

## Installation

```bash
claude plugin install decision-log@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
