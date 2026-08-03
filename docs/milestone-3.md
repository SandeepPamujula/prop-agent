# M3: Identity & Live Data (Phase 2)

**M3.1 As an authenticated resident, I want ticket creation to enforce an auth gate, so that only residents can create tickets.**
- Given I am an anonymous prospect
- When I ask to create a ticket
- Then the MCP server returns `AUTH_REQUIRED` and the LLM asks me to sign in
- Size: M
- Type: Feature

**M3.2 As an authenticated resident, I want duplicate ticket requests to be detected, so that I don't create multiple identical tickets.**
- Given I have already created a ticket in the current turn
- When a retry with the same idempotency key is received within 1 hour
- Then the tool returns `DUPLICATE_DETECTED` with the original ticket details
- Size: M
- Type: Feature

**M3.3 As an authenticated resident, I want to escalate to a human, so that complex issues are handled by support staff.**
- Given I explicitly ask to speak to a human
- When the LLM calls `create_ticket`
- Then it creates a ticket with `category: "escalation"` asynchronously
- Size: M
- Type: Feature

**M3.4 As a prospect, I want empty property search results to be handled gracefully, so that I know to broaden my search.**
- Given I search for overly specific criteria (e.g., 5 bedrooms under $500 in Manhattan)
- When `search_houses` returns `NO_RESULTS` from Atlas Search
- Then the LLM acknowledges no results and suggests broadening criteria
- Size: S
- Type: Feature

**M3.5 As a prospect, I want explicit refusal for out-of-domain knowledge queries, so that I am not given hallucinated answers.**
- Given I ask a question outside the corpus
- When `troubleshoot_lookup` returns all similarity scores < 0.3
- Then the LLM explicitly refuses to answer and offers to create a ticket
- Size: M
- Type: Feature

**M3.6 As a user, I want follow-up refinement on property search and troubleshooting, so that I can iteratively narrow my needs.**
- Given I received a set of search results or troubleshooting steps
- When I ask a follow-up question (e.g., "Any with a garage?" or "What about the filter?")
- Then the LLM calls the appropriate tool with refined context based on conversation history
- Size: M
- Type: Feature

**M3.7 As a user, I want session expiry handling, so that my chat sessions don't leak resources.**
- Given my session has been idle for 30 minutes
- When the MongoDB TTL index fires
- Then the session document is deleted, and my next message starts a new session
- Size: S
- Type: Feature
