# Plugin evals

An eval runs a prompt against Claude with a plugin loaded and scores the result
with automatic checks. It answers two questions a manual spot check cannot:
does the plugin change behavior at all, and did my last edit break it?

Suites live in `<plugin>/evals/` and run with `claude plugin eval` (Claude Code
2.1.269 or later). Official reference: <https://code.claude.com/docs/en/plugin-evals>.

## Plugins with suites

| Plugin | Cases | Command (from the repo root) |
|---|---|---|
| `avoid-ai-tells` | 2 | `make eval-avoid-ai-tells` |
| `decision-log` | 4 | `make eval-decision-log` |
| `git-commit-agent` | 3 | `make eval-git-commit-agent` |
| `prioritize-skills` | 13, each with a generated control | `make eval-prioritize-skills` |

`make evals` runs all of them. The per-plugin flags (`--scaffold`,
`--allow-tools`, `--ablation`) live in the root `Makefile`; pass extra flags
with `ARGS='...'`. A suite takes under a minute.

## When to run

Run a plugin's suite when you bump its version, before committing the bump. Do
not run suites on other edits. Run cost is not a concern: the account is on a
flat plan, so do not trim runs, cases, or `llm` graders to save money, and do
not ask before running a suite at a version bump.

When a plugin with a suite gains a new eval case or flag, update its target in
the `Makefile`. When a plugin gains its first suite, add a target and a row here.

Granting Bash (`git-commit-agent`) requires a sandbox backend. On Linux, install
`bubblewrap` and `socat`; without them every run is refused.

## Vocabulary

- **Case**: one directory under `evals/`. It holds `prompt.md` (the user message,
  plus settings in frontmatter) and `graders/*.md` (the checks).
- **Grader**: one pass/fail check on a run. A run's score is the fraction of
  graders that pass, by weight.
- **Run**: one execution of a case. Model output varies, so each case runs three
  times by default and the case score is the mean.
- **Arm**: each case runs twice over, once **with** the plugin and once
  **without** it. The difference between the two scores (Δ) is the plugin's
  measured effect.
- **Fixture**: a `fixture.sh` that seeds the empty workspace with files before
  the run. It is named in `case.yaml` and runs only with `--scaffold`. It must
  sit inside its case directory.

## Grader types used here

| Type | Checks | Deterministic | Use for |
|---|---|---|---|
| `regex` | Pattern present, absent, or present N times in the reply or a file | Yes | Anything you can state as a pattern |
| `file_exists` | A file was (or was not) created during the run | Yes | "Must not write" rules |
| `tool_used` | A tool was called between `min` and `max` times | Yes | Skill triggering, forbidden tools |
| `tool_order` | The first call to one tool precedes the first call to another; fails if either is never called | Yes | "Check the skill before reading" rules |
| `llm` | A judge model applies PASS/FAIL lines you write; three votes, majority wins | No | Judgments no pattern captures |

Prefer the deterministic types when a pattern can state the check: they give the
same answer every time, and a judge does not.

## Reading a result

```
CASE                       WITH  W/OUT  Δ
no-log-asks-first          1.00  0.17   +0.83
append-to-existing-log     1.00  1.00   0.00
```

- **High WITH, low W/OUT**: the plugin causes the behavior. This is the result
  that justifies the plugin.
- **Both high**: Claude does this unprompted. The case is still useful as a
  regression guard if it covers the plugin's main path; otherwise delete it.
- **Both low**: the plugin fails, or the grader is wrong. Read the replies
  before deciding which.
- **WITH between 0 and 1**: the behavior is inconsistent. Raise `--runs` before
  drawing conclusions from three samples.

The process exits 1 if any case scores below `--threshold` (default 1.0).
`avoid-ai-tells` scores about 0.83 per case today, so its `make` target passes
`--threshold 0.6`. Use `make -k evals` to run every suite past a failure.

## Debugging a failing grader

A failing score says a check failed, and nothing about why. Read the reply:

```bash
make eval-<plugin> ARGS='--case <name> --runs 1 --ablation none --keep-temp --json out.json'
jq -r '.cases[0].arms.with[0].tracePath' out.json   # path to the transcript
```

`report.html` in `<plugin>/evals/results/<timestamp>/` shows the same data in a
browser.
`evals/results/` is gitignored. `--keep-temp` leaves directories in `/tmp`; the
command prints their paths so you can delete them.

When an `llm` grader's votes split (`FAIL PASS FAIL`), suspect the rubric first.
A split vote usually means one rubric line is ambiguous.

## Adding a case

1. Pick one behavior the plugin promises. Quote the sentence in the skill or
   hook text that promises it.
2. Write a prompt that a user would plausibly type and that gives the model a
   chance to get it wrong.
3. Write the graders. Give each one a file name that reads as a claim
   (`no-file-created.md`), so a failure names what broke.
4. Run that case once with `--case <name> --runs 1` and read the reply. Confirm
   that each grader passes or fails for the reason you intended.
5. Run it at the default three runs. Keep the case if Δ is positive or if it
   guards the plugin's main path.

For skills, include one case that must **not** trigger the skill, using a prompt
that shares its vocabulary. `decision-log/evals/unrelated-question-does-not-trigger`
is the model to copy.

## Limits

- Three runs per arm is a small sample. Treat a Δ under about 0.3 as noise until
  more runs confirm it.
- The baseline arm changes with the model. A case that separates the arms today
  can stop doing so after a model upgrade; that means the plugin's guidance has
  become redundant for that behavior, which is worth knowing.
- Whether a commit lands depends on the platform: on Linux (bubblewrap) the
  workspace's git directory was observed read-only, and on macOS (Seatbelt)
  commits succeed. Grade the command the agent issues with `tool_used` and
  `input_match` rather than the resulting history, as `git-commit-agent/evals`
  does. Match any way of invoking git (`git`, `/opt/homebrew/bin/git`, `$G`,
  `git -C dir`); agents use all of them.
- On macOS the agent's Bash sees a minimal `PATH`, and `/usr/bin/git` (the Xcode
  shim) fails in the sandbox because `xcrun` cannot write its cache. Runs succeed
  only because the agent finds `/opt/homebrew/bin/git` on its own, which costs a
  few turns. Without Homebrew git, cases that need git cannot pass on macOS. A
  case can set only `EVAL_*` environment variables, so `PATH` cannot be fixed
  from the suite.
- A `tool_used` grader sees subagent tool calls as well as the main agent's, and
  cannot tell them apart.

## Plugins that only matter alongside other plugins

Each run loads only the plugin under test, and the built-in baseline arm removes
every plugin. A plugin like `prioritize-skills`, whose effect is on other
plugins' skills, needs a different comparison:

1. Put a small fixture plugin in its own subdirectory of the case. A `plugins:`
   entry must sit inside its case directory: a directory shared between cases
   and a symlink to one are both rejected.
2. Write the case twice: one lists `plugins: ["../..", "<fixture>"]`, the
   control lists `plugins: ["<fixture>"]`.
3. Run with `--ablation none` and subtract the control's pass rate.

`prioritize-skills/evals` automates steps 1 and 2. Fixture sources live once in
`evals/fixtures/`, and each case names the ones it wants in `plugins:`.
`build-cases.sh` copies them into every case and generates a `<case>-control`
twin with the plugin under test removed, so a pair cannot drift apart. The
copies and the twins are gitignored. `pair-deltas.sh` reads the `--json` result
and prints each grader's pass rate with the plugin, in the control, and the
difference. The `make` target runs all three steps.

Control cases score low by design, so a suite built this way measures an effect
and cannot gate on `--threshold`.
