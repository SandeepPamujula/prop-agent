# M2: Contract Validation (Phase 1)

**M2.1 As a prospect, I want a multi-turn conversation with tool execution, so that I can get answers and perform actions.**
- Given I am chatting via the SSE widget
- When I send a message
- Then the Orchestrator receives the message, LLM determines intent via tool_use, executes the tool, and streams tokens back
- Size: L
- Type: Feature

**M2.2 As a compliance officer, I want PII redacted via regex, so that user privacy is protected before reaching Bedrock.**
- Given a user sends a message containing an SSN or credit card
- When the Model Gateway processes the egress payload
- Then the sensitive string is replaced with a `[PII:*]` token
- And the redaction manifest is logged securely
- Size: M
- Type: Feature

**M2.3 As a prospect, I want to query knowledge troubleshooting (Happy Path), so that I can resolve my issues.**
- Given I ask an HVAC question
- When the LLM calls `troubleshoot_lookup`
- Then it fetches fixture data and streams a grounded response with citations
- Size: M
- Type: Feature

**M2.4 As a prospect, I want property search (Happy Path), so that I can find a home.**
- Given I ask for a 3-bedroom house under $2000
- When the LLM calls `search_houses`
- Then it correctly extracts the structured filters (bedrooms=3, max_price=2000) and displays the fixture results
- Size: M
- Type: Feature

**M2.5 As an authenticated resident, I want to create a ticket (Mock), so that I can report an unresolved issue.**
- Given I ask to create a ticket in Phase 1
- When the LLM calls `create_ticket`
- Then the MCP server returns a mock case ID without enforcing the auth gate
- Size: S
- Type: Feature

**M2.6 As an on-call engineer, I want circuit breaker failover for Bedrock, so that the chat remains available during provider outages.**
- Given Bedrock returns 3 consecutive 5xx errors
- When the next request is made
- Then the circuit breaker opens and fails over from Sonnet to Haiku
- Size: M
- Type: CI/CD

**M2.7 As a developer on this team, I want mock data fixtures for all MCP tools, so that the orchestrator can be tested end-to-end.**
- Given the MCP tool server is deployed in Phase 1
- When `troubleshoot_lookup`, `create_ticket`, or `search_houses` are invoked
- Then they return static JSON fixtures matching their schema contract
- Size: S
- Type: Enabler
