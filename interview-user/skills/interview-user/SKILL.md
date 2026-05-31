---
name: interview-user
description: When the user asks to be interviewed, grilled, or talked through an under-formed plan, design, or strategy, use this skill to run a structured tree-shaped Q&A persisted to disk. Elicitation only; does not produce the final artifact.
---

# interview-user

Elicit structure from an under-formed idea by asking one question at a time, recording each question and answer in a persistent tree on disk. The tree is the source of truth — not chat history.

This skill produces raw material. It does not produce the final artifact. When the user signals "we're done," hand off; do not slide into drafting the PRD/design doc/memo inline.

## When to use

Trigger on phrases like: "interview me about X," "grill this idea," "help me think through Y," "let's poke holes in this plan," "I want to design X but haven't thought it through."

Do not use for: well-scoped implementation tasks, debugging, code review, or any case where the user already knows what they want and is asking for execution.

## Core discipline

**Write the question down before asking it.** This is the single most important rule. The on-disk tree is updated *first*, then the question is posed to the user. Skipping this step collapses the skill into ordinary chat and forfeits the resumability and branch-coverage value.

**One question at a time.** Always. Multi-question messages overwhelm the user and produce shallow answers.

**Preserve the user's coinages verbatim.** When the user invents a term or lands a load-bearing phrasing -- "constraint-driven development," "one person's fix becomes everybody's fix" -- record those exact words in the **Answer**. Paraphrase only the connective tissue around them. The user's own vocabulary is the highest-value material the interview captures; a paraphrase of a coinage discards the thing worth keeping. This matters most for dictated input, which runs long and self-correcting with the gold buried in one specific clause -- read for the clause, keep it intact.

**Recommend an answer only on convergent questions.** A convergent question picks among known options, ratifies a default, or scopes something concrete; lead with a recommendation so the user can "yes / different / why?" A divergent question is generative -- values, success criteria, "what should X be" -- where a confident guess anchors the user before they've explored. Ask divergent questions raw. If the user stalls or asks "what do you think?", *then* offer a recommendation. See "Recommending answers" below.

**Read the repo to find gaps, not to answer questions for the user.** The interview's goal is to get the user to structure their thinking, not to close nodes efficiently. The repo tells you what *is*; the interview elicits what the user *intends*, *values*, or *believes is true*. Those are different artifacts.

Three cases:

- **Pure factual lookup** (what version, what endpoint, what schema) -- read it, record the answer with a `(file:line)` citation, do not ask the user.
- **Repo says X, user's view of X is the elicitation** -- read the repo so the question is *informed*, then ask the user anyway. Example: the code currently routes auth through middleware A; the question "should auth keep going through A?" still goes to the user, with the current state surfaced as context.
- **Intent / values / strategy** -- the repo cannot answer. Do not look. Ask raw.

The repo's primary job in this skill is gap-finding: where does the user's idea conflict with, duplicate, or ignore what already exists? Turn those gaps into questions for the user, not answers on the user's behalf.

**After each answer: decide, write, then resume.** Every user answer triggers the same three-step loop:

1. **Decide if follow-ups are necessary.** Pick from the taxonomy below. The default is *none* -- close the node and move on. A follow-up earns its place only if its answer could change the parent's answer or change the downstream artifact (MECE pruning rule: if the child cannot move the parent, do not ask it).
2. **Write follow-ups as children to the file before asking anything.** Same externalize-before-asking rule as the rest of the skill. Add each child with full tagging (`necessary`/`exploratory`, `convergent`/`divergent`) and a recommended answer on convergent children. Update **Open threads** and **Touched**.
3. **Resume the one-question-at-a-time loop.** Pose the first new child to the user. The other new children wait their turn alongside any pre-existing open nodes; pick the next question by leverage, not by tree position.

If step 1 produced no follow-ups, mark the parent `answered` and move to the next open node. No silent moves -- every answer either closes its parent or branches.

A substantive answer can also resolve *other* open nodes -- a reframe often dissolves seed questions posed earlier. When that happens, mark each of those nodes `subsumed` with a **Reason:** cross-referencing the resolving node, rather than leaving them open or quietly deleting them.

### Follow-up taxonomy

Pick one per answer (including "none"):

- **Close, no follow-up.** Default. The answer is complete enough.
- **Clarify.** The answer is ambiguous. Cite the interpretations: "I'm reading this two ways: X or Y. Which?"
- **Probe an unstated assumption.** Name the implicit premise and ask: "This assumes `<X>`. Is that right?"
- **Test against constraints.** The answer conflicts with declared scope, an earlier answer, or repo reality. Surface the conflict, ask the user to resolve.
- **Pull an implication.** "If `<answer>`, then what about `<consequence>`?" Use sparingly -- the easiest type to over-generate.
- **Adversarial probe.** "What would have to be true for this to be the wrong call?" Reserve for high-stakes nodes where the user seems too confident.

### Follow-up anti-patterns

- **Paraphrase-as-question** ("so you're saying X?") -- record the answer in your own words; do not make the user ratify your phrasing.
- **"Tell me more"** -- unstructured; signals the agent does not know what gap to probe. If you cannot name what you are trying to learn, close the node.
- **Symmetric follow-up across siblings** -- generating the same follow-up type on every node out of habit. Each follow-up is a fresh judgment.
- **Asking before writing.** Follow-ups go into the file first, then to the user. Same rule as root questions.

## Artifact

Question trees live in `docs/questions/<session-name>.md` relative to the current working directory, unless the user or standing instructions specify otherwise. One tree per session. Create the directory if it does not exist.

Before creating the directory, check whether the cwd looks like a build, content, or output location -- a Hugo/Jekyll page bundle, `content/`, `public/`, `dist/`, `build/`, `site/`, or similar -- where the tree would land inside publishable or generated files. If so, propose a repo-root location instead (e.g. the repository's top-level `docs/questions/`) and confirm before writing.

### Node format

Each node is a nested markdown bullet with this shape:

```markdown
- **Q1.2** [open, necessary, divergent] What's the success metric?
  - **Answer:** (filled in once answered) -- brief, plus any file refs consulted
  - **Touched:** 2026-05-17
  - **Q1.2.1** [open, exploratory, convergent] Does it segment by team?
    - **Recommend:** yes, segment by owning team
```

Field reference:

- **ID** -- stable, dotted (`Q1`, `Q1.2`, `Q1.2.3`). Never renumber; if a node is abandoned its ID stays as a tombstone.
- **Status** -- one of `open`, `answered`, `deferred`, `abandoned`, `subsumed`.
- **Necessity** -- `necessary` (must be answered to close the parent) or `exploratory` (interesting but optional).
- **Shape** -- `convergent` (pick among options, ratify a default, scope something concrete) or `divergent` (generative -- values, criteria, open "what should X be"). Drives whether to lead with a recommendation.
- **Recommend** -- the agent's proposed answer. Present *with* convergent questions; offer on divergent questions only if the user stalls.
- **Answer** -- the user's actual answer. Paraphrase the connective tissue for brevity, but keep coined terms and load-bearing phrasings verbatim (see "Preserve the user's coinages verbatim" above). Include `(file:line)` refs for anything sourced from the repo.
- **Touched** -- ISO date of last modification.

`subsumed` marks a node the user never answered directly because another node's answer resolved it -- a seed question that dissolved when a deeper answer reframed the problem. It is distinct from `answered` (the user posed it) and from `abandoned` (dropped as irrelevant): the question got answered, just elsewhere. Use it instead of silently closing a node you never asked.

`deferred`, `abandoned`, and `subsumed` require a one-line **Reason:** field so the trace is preserved for downstream synthesis. For `subsumed`, the reason is a cross-reference to the resolving node -- e.g. `Reason: answered by Q1.2's reframe`.

### Header

Every session file starts with a header:

```markdown
# Interview: <topic>

- **Scope:** <product | code | strategy | creative | mixed>
- **Started:** 2026-05-17
- **Status:** in-progress | complete | paused
- **Stop signal:** (filled in at end)

## Open threads
- Q2, Q3.1   <-- updated continuously; the "where to resume" list
```

The **Open threads** line is what makes resumption cheap: a future session reads the file and knows immediately what is still live.

## Session lifecycle

### Start

1. From the user's opening message, **propose** a kebab-case session name (e.g. `auth-rewrite-scope`, `onboarding-redesign`). Do not ask -- offer the name and let the user override. Skip proposing only if the user already named the session.
2. Check whether `docs/questions/<name>.md` exists.
   - **Exists:** read it, summarize the state in five lines (topic, scope, open thread count, last touched, top 1–3 open questions), ask which thread to pick up. Do not re-ask answered questions.
   - **New:** confirm the topic and scope inline ("Reading this as a `<scope>` interview about `<topic>` -- correct?"), then **seed the file** before asking anything else.

### Seeding a new session

Before the first user-facing question, populate the tree with root questions that target real gaps. Two sources of gaps to mine:

- **Gaps in the user's explanation.** What did they leave implicit? Goals, users, constraints, success criteria, scope boundaries, non-goals. Anything they referenced without defining.
- **Gaps between the idea and the repository.** Scan relevant code, docs, and recent commits. Where does the proposed idea conflict with, duplicate, or ignore what's already there? Where does the repo answer a question the user didn't ask?

Write 3–6 seed questions covering the highest-leverage gaps. Tag each on both axes (`necessary`/`exploratory`, `convergent`/`divergent`). Include a recommended answer on the convergent ones; leave divergent ones open. The seed set is the agenda; the user can reorder, drop, or add before the first question is posed.

### During

After each exchange:

1. Update the file. Mark the parent `answered` or add children. Update **Open threads**. Bump **Touched** on the node.
2. Tag every new child on two axes at creation time: `necessary` / `exploratory` (controls termination) and `convergent` / `divergent` (controls whether to lead with a recommendation).
3. Before adding a child, apply the **thesis-movement test**: does this question move the overall idea forward, or only add granularity to a subset of the parent's answer? A clarifying chain that keeps advancing the thesis is legitimate however deep it nests; drilling that narrows into one sub-aspect is the failure mode. Depth alone is not the signal -- detail-without-movement is. See "Keeping the tree balanced" below.
4. If a question is adjacent to the declared scope (e.g. a code question during a strategy interview), flag it: "this is cross-domain — pursue or park?" Default to park unless the user pulls it in.
5. Pose the next open question to the user -- with a recommended answer if convergent, raw if divergent. Pick by leverage, not by tree position.

Update the file when a node changes status or a child is added — not after every line of chat.

### Stop

Surface a stop suggestion, never auto-decide, when any of:

- All `necessary` nodes are `answered` or `deferred`.
- All remaining `open` nodes are `exploratory`.
- The last several answers added few or no `necessary` children (diminishing returns).
- The user signals "we're done," "good enough," or equivalent.

At stop:

1. Set the header **Status:** to `complete` or `paused`.
2. Fill in **Stop signal:** with the reason (e.g. "all necessary nodes resolved", "user paused — resume on auth threading").
3. Leave `open` nodes in a real, useful state — not noise.
4. **If the user asks for a consolidation or steelman, write it into the tree file** under a `## Consolidation` heading -- not as the deliverable. This is the one synthesizing move the skill permits: a short reflective pass that draws the answered nodes together into the strongest version of the user's own position, preserving their coinages. It is still raw material handed to the downstream synthesis step, not the PRD/design/memo. Do not produce it unprompted (see "Synthesis creep" under Anti-patterns).
5. Tell the user the file path and note that synthesis into a final artifact (PRD / design doc / ADR / memo) is a separate step.

## Keeping the tree balanced

Aim for a tree that is neither too deep on one branch nor too broad on one node. Two tests and one check-in govern this.

**Depth -- the thesis-movement test.** When deciding whether to add a child, ask: does this question move the overall idea forward, or only add granularity to a subset of the parent's answer?

- **Clarifying chain.** Successive follow-up siblings that each advance the whole thesis -- `Q1 -> Q1.1 -> Q1.2 -> Q1.3` where every step reframes or sharpens the core idea.  This deep spine is often the single most valuable line in the interview; do not interrupt it to chase shallower seed questions or drill into an answer until the answer chain is complete.
- **Drilling.** Follow-ups that narrow into one sub-aspect -- `Q1 -> Q1.1 -> Q1.1.1 -> Q1.1.1.1` -- each adding detail to the previous answer without moving the thesis. Drill in when an answer is multifaceted and multiple child questions are necessary will clarify it.  Don't drill in if capturing the details don't advance the goal of the interview (e.g. "nice to have" answers).

**Breadth -- the 3–5 rule.** A single node should not accumulate more than 3–5 direct children. Past that, the node is doing too much: introduce an intermediate grouping question that pushes some of those children down a level, or recognize the node is really several questions and split it. A flat fan of many siblings is as much a smell as an over-deep spine.

**The check-in.** When a branch has absorbed sustained investment -- several questions deep, or you cannot articulate how the next child moves the thesis -- surface a check-in rather than auto-deciding: "we've gone a few levels into `<branch>`; keep pulling this thread or move on to `<next open thread>`?" Trigger the check-in on the substance signal, not on a fixed depth count. Do not auto-prune; do not auto-continue.

## Tagging guidance

`necessary` means: without an answer, a downstream synthesis skill cannot produce a coherent artifact. `exploratory` means: an answer would enrich the artifact but its absence does not block it.

Default to `exploratory` when uncertain. Over-tagging `necessary` defeats the stop criteria — every branch becomes mandatory and the interview runs forever. Confirm `necessary` tags with the user when the call is close: "tagging this necessary — agree, or is this nice-to-have?"

## Recommending answers

Recommendations help on convergent questions and hurt on divergent ones. Use the question's `convergent`/`divergent` tag to decide.

**Convergent -- lead with the recommendation.** The recommendation is a guess, not a commitment. State it briefly, then ask:

> **Q2.1** [open, necessary, convergent] Who owns the migration script after launch?
> **Recommend:** the platform team, since they own the surrounding infra.
> Is that right, someone else, or unresolved?

Three response shapes the user can give cheaply: confirm, redirect, or "I don't know." All three are useful answers; "I don't know" becomes a `deferred` node with a reason.

**Divergent -- ask raw.** Pose the question without a recommendation so the user generates their own framing first:

> **Q1.2** [open, necessary, divergent] What's the success metric for this rewrite?

If the user produces a substantive answer, record it and move on. If they stall, bounce it back ("not sure", "what would you suggest?"), or explicitly ask for your guess, *then* offer a recommendation as a second turn. Record both the recommendation and the user's reaction to it -- the path matters for downstream synthesis.

**When in doubt, ask raw.** The cost of a missed recommendation is a slightly slower turn. The cost of a premature recommendation is anchoring the user before they think.

## Anti-patterns

- **Asking before writing.** The discipline is *externalize, then ask.* Reverse it and the skill is no better than plain chat.
- **Multi-question messages.** Pose one. If two are coupled, pick the one whose answer constrains the other.
- **Synthesis creep.** Do not start drafting the PRD/design/memo mid-interview, even if the user asks "so what would the doc look like?" Note the request, finish elicitation, then hand off. The one carve-out: a reflective **consolidation/steelman written into the tree file** at the user's request during stop (see Stop, step 4) is allowed -- it is raw material that draws the answered nodes together, not the deliverable. Drafting the actual artifact, in the tree file or anywhere else, is still off-limits.
- **Silent tree updates.** Every status change is reflected in the file before the next question is asked.
- **Over-tagging `necessary`.** If everything is mandatory, nothing is. Use the confirm-on-close-calls rule.
- **Recommending on divergent questions.** Anchors the user before they've thought. The whole point of a divergent question is to elicit *their* framing -- a confident guess undermines it. Lean toward "ask raw" when the shape is unclear.
- **Answering questions from the repo that should go to the user.** Closing a node with a `(file:line)` citation feels productive but skips elicitation. If the question is about intent, judgment, or whether-the-current-state-is-right, the repo cannot answer it -- the user must, even if the repo has a relevant fact to surface as context.
- **Renumbering IDs.** Stable IDs are how resumed sessions stay coherent. Abandon nodes in place; never reshuffle.
- **Re-asking answered questions on resume.** Read the file first. The summary on resume should prove this happened.

## Prior art for vocabulary

- **IBIS** (Issue-Based Information Systems) — issue / position / argument / decision node typing.
- **McKinsey issue trees / MECE** — pruning rule: if a branch's answer cannot change the parent's answer, prune it.
- **5 Whys** — depth-control intuition, though linear; this skill branches.

These are reference points, not methodology lock-in. Do not impose their notation on the user.

## Non-goals

- Synthesizing the tree into a final artifact. Separate skill.
- Multi-user collaboration. Single user only.
- Diagram rendering of the tree.
- Domain-specific methodology (Shape Up, DDD, etc.) — layer those on top in separate skills.
