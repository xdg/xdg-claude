---
type: llm
weight: 2
---

Judge only the style of the reply, not whether its argument is right.

FAIL if any sentence rejects a position nobody stated in order to assert another ("it's not X, it's Y"; "you don't have X, you have Y"; "the question isn't X").
FAIL if any sentence tells the reader which part matters instead of saying it ("the key word is", "the real fix", "the point is").
FAIL if a paragraph ends on a sentence that only restates that paragraph as a slogan or moral.
PASS otherwise.
