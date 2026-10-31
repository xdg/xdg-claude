# comment-review

A Claude Code plugin that adds a `comment-review` subagent and a
`/comment-review` slash command for auditing code comments against *A
Philosophy of Software Design* (Ousterhout) and *The Art of Readable Code*
(Boswell & Foucher).

## What it does

The review judges each comment by one standard: **a comment must describe
something that is not obvious from the code.** Length is never the measure. A
long comment that states a contract the code cannot express stays; a short one
that paraphrases the next line goes.

The review runs in two passes:

- **Content.** Classify each comment (interface, data-structure,
  implementation, cross-module, rationale, marker, disabled code), then check,
  claim by claim: stale claims first, then restatement, repeated names,
  incomplete contracts, padding, duplication, and TODOs with no trigger
  condition. Declarations that need a comment and lack one are findings too.
- **Clarity.** On the survivors, check sentence length, caller obligations
  buried after elaboration, mood-metaphors that cannot be checked against the
  code, and stacked noun clusters. On a file, package, or API surface, a
  terminology census also flags drift between synonyms, and proposes a
  canonical term only where the code shows the words name one operation.

Comments that tools read -- build and compiler directives, lint suppressions,
doctests, license headers -- are left alone, as are generated and vendored
files.

### Report only; the caller applies

The subagent never edits files. It returns a report for its caller, a person
or an orchestrating agent, to act on:

- A header with the target, the commit reviewed, and what was and was not
  covered.
- One finding per comment with a verdict (`FIX`, `DELETE`, `TIGHTEN`,
  `EXPAND`, `ADD`, `CONSOLIDATE`, `DISAMBIGUATE`, `KEEP`) and exact Old/New
  text, which applies as a string replacement and fails cleanly if the file
  changed since the review.
- An **apply-risk** tag on each patch. **Mechanical** findings remove text that
  carried no fact; **judgment** findings add a fact or choose a meaning. An
  unattended workflow can apply the first kind and route the second to a
  person.
- **Needs:** in place of a patch where the missing fact cannot be established
  from code, tests, or docs. The reviewer never invents a contract or a
  rationale.
- A **Design signals** list for comments that are long because the interface
  is hard to explain, and a Verifying section: confirm only comments changed,
  then run lint and tests.

The plugin follows the standard three-piece form:

- **Subagent** (`agents/comment-review.md`): Opus model. Tools: Bash, Glob,
  Grep, Read, Skill -- no edit tools. Reviews uncommitted changes by default,
  or a named file, directory, branch, PR, or commit range.
- **Educational skill** (`skills/how-to-comment-review/SKILL.md`): teaches
  Claude when to delegate, how to craft the prompt, and how to apply the
  report with and without a person present. Not user-invocable.
- **Slash command** (`skills/comment-review/SKILL.md`): `/comment-review
  [target]` forks into the subagent.

## Installation

```bash
claude plugin install comment-review@xdg-claude
```

Requires the `xdg-claude` marketplace to be added first; see the [top-level README](../README.md#installation).
