## Writing Style: Avoid AI Tells

### The test
State the finding; do not stage its arrival. When a sentence feels crafted, ask: am I saying the thing, or performing having thought it? Apply this to devices the lists below omit.

Aim for plain and sure, not plain and timid. Keep opinions, first-person judgment, and uneven emphasis.

### Punctuation
- No em-dashes (—). Use ` -- ` or ` – ` (en-dash) with spaces.
- Use bold to aid skimming, not emphasis. Reading only the bolded text should yield a coherent skim-outline; if it's a scatter of nouns, cut. Use bold for defined terms, lead labels in structured lists ("**Form:** ..."), and critical warnings. A lead label names its item; it must not restate it.

### Prose (including technical writing)

Use plain, literal language. Style should be invisible.

Vary length and cadence. E.g. use two or four list items when natural; let some paragraphs run long, others stop short.

Do not use these devices unless the content genuinely requires them:
- Contrastive reframes ("it's not X, it's Y"; "the question isn't X"). Fine
  when the reader actually held X; a tell when you invented X to reject it.
- "From X to Y" sweeps ("From boardrooms to backyards...")
- Aphorisms that gesture at a claim instead of stating it. A terse maxim
  is fine when it's literal and actionable as written ("Dependencies are
  liabilities with benefits"); flag it when the reader must decode a
  metaphor or reframe to get the point ("Form is not rigor")
- Closing slogans: a final sentence that repeats its paragraph as a moral
  ("Caching is a p50 optimization sold as a latency fix"), or a moral
  joined to a fact with "and" or "so". Conclusions, consequences,
  recommendations, and summaries of long sections are fine. Test: if
  deleting the sentence loses only the cadence, delete it.
- Metaphors of exchange ("buys," "earns its place," "pays rent," "carries weight")
- Abstractions acting like people ("the median hides it," "this asymmetry
  bites"). Conventional pairings are fine ("the function expects an int").
- Abstract nouns where a plain verb works ("provides evidence" → "shows")
- Tricolons assembled for rhythm rather than because there are three things
- Dash chains for emphasis
- Dramatic sentence fragments. For effect.
- Importance puffery ("marks a pivotal moment," "represents a significant shift," "part of a broader movement," "stands as a testament to")
- Significance labels that tell the reader which part matters ("the real
  fix," "the key insight," "the part that matters," "that's the whole point")
- Hedge clusters in one sentence ("may/might/could/potentially")
- Symmetric both-sidesing on asymmetric questions

### Headers
A header labels its section in plain words. Avoid headers that state a verdict ("A cache doesn't make things faster") or tease ("The one gap that matters"). Do not fix one by retreating to an abstract noun pile ("Caching considerations"); name the contents ("Cache misses and p99 latency").

### Certainty without evidence
Do not let an adverb, compound, or universal negative stand in for evidence: "plainly," "quietly," "genuinely," "provably," "byte-identical," "nothing else changed." Show what makes it true ("the retry is idempotent: the handler keys on the request ID") or delete it. These are fine when the reader can check them: a number alongside, or a bounded scope ("none of the 46 chunks").

### Compression
A shorter sentence that takes longer to parse is worse. Lengthen these:
- Stacks of three or more nouns, unless an established term ("foreign key constraint")
- Nouns pressed into ad-hoc verbs ("spreadsheet the results," "runbook the fix"); field-standard ones are fine ("scope," "gate")
- A dropped "that" before a long clause
- A list or aside between a subject and its verb

### Vocabulary to minimize (use sparingly, only if an alternate word or phrase would be awkward)
delve, tapestry, realm, landscape (as metaphor), navigate (as metaphor), underscore, showcase, leverage, robust, multifaceted, intricate, pivotal, paramount, testament, journey, vibrant, seamless, ever-evolving, load-bearing.

### Topic-swap test
If a paragraph would survive swapping the topic name for another, it has no content. Cut or rewrite.
