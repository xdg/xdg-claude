# Plugin evals

An eval runs a prompt against Claude with a plugin loaded and scores the result
with automatic checks. It answers two questions a manual spot check cannot:
does the plugin change behavior at all, and did my last edit break it?

Suites live in `<plugin>/evals/` and run with `claude plugin eval` (Claude Code
2.1.269 or later). Official reference: <https://code.claude.com/docs/en/plugin-evals>.

## Plugins with suites

| Plugin | Cases | Command (from the plugin directory) |
|---|---|---|
| `avoid-ai-tells` | 2 | `claude plugin eval . --no-publish` |
| `decision-log` | 4 | `claude plugin eval . --no-publish --scaffold --allow-tools Write Edit` |

A full run of either costs under $1 and takes under a minute with `-j 8`.

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

| Type | Checks | Cost | Use for |
|---|---|---|---|
| `regex` | Pattern present, absent, or present N times in the reply or a file | Free | Anything you can state as a pattern |
| `file_exists` | A file was (or was not) created during the run | Free | "Must not write" rules |
| `tool_used` | A tool was called between `min` and `max` times | Free | Skill triggering, forbidden tools |
| `llm` | A judge model applies PASS/FAIL lines you write; three votes, majority wins | Paid | Judgments no pattern captures |

Prefer the free types. They give the same answer every time; a judge does not.

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
`avoid-ai-tells` scores about 0.83 per case today, so pass `--threshold 0.6`
if you gate CI on it.

## Debugging a failing grader

A failing score says a check failed, and nothing about why. Read the reply:

```bash
claude plugin eval . --case <name> --runs 1 --ablation none --keep-temp --json out.json
jq -r '.cases[0].arms.with[0].tracePath' out.json   # path to the transcript
```

`report.html` in `evals/results/<timestamp>/` shows the same data in a browser.
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
- Each run loads only the plugin under test. Interactions between plugins need a
  case that lists several under `plugins:` in its frontmatter.
