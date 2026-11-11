# prioritize-skills

A Claude Code plugin that injects a directive at session start (and on subagent dispatch) requiring Claude to check for and invoke applicable skills before responding or acting.

## What it does

On `SessionStart` and `SubagentStart`, the plugin's hook reads `hooks/references/prioritize-skills.md` and injects it as `additionalContext`. The directive establishes:

- A "1% rule": if any installed skill might apply, invoke it via the `Skill` tool first.
- An instruction-priority ladder (user instructions > skills > default system prompt).
- A workflow: check skills, announce, follow the skill, then respond.
- A red-flag table of common rationalizations for skipping skill invocation.
- A process-skills-before-implementation-skills ordering.

The plugin ships no skills of its own. It is the prioritization layer; install whatever skills you actually want alongside it.

## Evals

`evals/` holds a `claude plugin eval` suite. The plugin only matters when other
skills are installed, so every case loads a fixture plugin, and every case has a
control twin that loads the same fixtures without this plugin. The plugin's
effect on a case is its pass rate minus its control's.

```bash
make eval-prioritize-skills   # from the repo root
```

The target runs three steps:

1. `evals/build-cases.sh` copies the fixture plugins from `evals/fixtures/` into
   each case that lists them in `plugins:` and generates a `<case>-control` twin
   of every case. Both are gitignored. A fixture must sit inside its case
   directory, so the copies cannot be avoided.
2. `claude plugin eval ./prioritize-skills --ablation none --scaffold --threshold 0`.
   `--ablation none` turns off the built-in no-plugin arm, which would also
   remove the fixture skills. Controls fail the canary grader by design, so the
   suite measures an effect and does not gate on a threshold.
3. `evals/pair-deltas.sh` prints each grader's pass rate with the plugin, in the
   control, and the difference.

### Cases

| Cases | Fixtures | Question |
|---|---|---|
| `fit-1` to `fit-5` | `commit-messages` skill | How often is the skill invoked as the prompt moves from "write the commit message" to "describe that in Slack"? |
| `crowded-fit-1` to `crowded-fit-5` | The same skill, 28 distractor skills, and 16 KB of rules injected at session start | The same ladder in a session that resembles a real one |
| `before-read-explain-file`, `before-read-targeted-question` | `outline-file` skill and a seeded Go repo | Is the skill consulted before the first `Read`? Graded with `tool_order`. |
| `no-skill-applies` | `commit-messages` skill | Does the directive cause a spurious skill call on `17 * 23`? |

`fit-2-one-line-summary` also carries two canary graders. `directive-in-trace`
passes when the hook's output appears in the trace; it must score 10/10 with the
plugin and 0/10 in the control, or the hook is not firing and no other number
means anything. `announces-skill` checks for the "Using [skill] to [purpose]"
line the directive asks for.

### Results for 0.1.3 on claude-opus-5-5

| Case | With | Control | Δ |
|---|---|---|---|
| `fit-1`, `fit-2` (both sessions) | 10/10 | 10/10 | 0 |
| `fit-3-pr-title` | 50/50 | 43/50 | +0.14 |
| `crowded-fit-3-pr-title` | 49/50 | 9/50 | +0.80 |
| `fit-4`, `fit-5` (both sessions) | 0/10 | 0/10 | 0 |
| `before-read-targeted-question` | 10/10 | 0/10 | +1.00 |
| `before-read-explain-file` | 10/10 | 9/10 | +0.10 |
| `no-skill-applies` | 10/10 clean | 10/10 clean | 0 |

The directive has no effect where the skill plainly fits or plainly does not.
It has a large effect on a borderline prompt in a crowded session, where the
baseline drops from 86% to 18%, and on a narrow question about a file, where
the baseline never consults the skill and reads the file directly.
`announces-skill` scored 0/10: the model invokes the skill without announcing it.

Not covered: the SubagentStart path, false positives on prompts that share a
skill's vocabulary, and any model other than the default.

See [docs/evals.md](../docs/evals.md) for how to read the results and add cases.


## Installation

```bash
claude plugin install prioritize-skills@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).

`SubagentStart` is Claude Code-specific; on platforms that lack the event the hook is harmless and only the session-level injection fires.

## Credits

The directive in `hooks/references/prioritize-skills.md` is adapted from [obra/superpowers](https://github.com/obra/superpowers), specifically `skills/using-superpowers/SKILL.md`. Superpowers is MIT-licensed. Modifications: removed superpowers-specific branding, dropped the `<SUBAGENT-STOP>` clause (this plugin intentionally primes subagents too), and adjusted phrasing to be platform-neutral.
