Refactor code following the protocol below. Look for additional instructions on
what to refactor after the protocol. If none are given, ask what to refactor.

REFACTORING PROTOCOL:

PREREQUISITES:
- Understand code purpose and context
- Ensure all tests pass
- Identify specific code smell (duplication, long method, unclear naming, complex conditional)

EXECUTE:
1. Make ONE atomic change:
   - Extract duplicate code into well-named functions
   - Simplify complex logic into smaller methods
   - Replace magic values with named constants
   - Introduce interfaces to reduce coupling

2. Preserve ALL observable behavior:
   - Same outputs for same inputs
   - Same error handling
   - Same or better performance
   - Same side effects

3. Run all tests - must pass without modification to test logic

4. Offer to commit the change:
    - If the refactor began from fully commited code, use the message: "Refactor: [specific change]"
    - If the refactor modified newly changed, uncommitted code, use a normal commit message without "Refactor"

CONSTRAINTS:
- Never combine refactoring with feature changes
- If tests need updates beyond mechanical changes (e.g., method names), reconsider the refactoring
- If unclear about behavior preservation, stop and seek clarification

COMMON PATTERNS:
- Extract Method: Replace code block with descriptive function call
- DRY: Replace 2+ similar code blocks with parameterized function
- Replace Conditional: Use polymorphism for type-based switches
- Introduce Parameter Object: Group related parameters

TIPS:
- When searching for duplication in frontend code, look for similar HTML structures or repeated CSS classes.
