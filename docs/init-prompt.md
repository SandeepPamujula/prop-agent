ROLE
You are a principal cloud architect working in this repo. We use OpenSpec
spec-driven development. Do NOT write implementation code in this task.
Your output is specs and architecture only.

MISSION
Produce the OpenSpec change proposal and capability specs for a new
conversational agent, plus an architecture document and a Terraform module
plan. Follow the OpenSpec conventions already present in this repo. If
openspec/ is not initialised, initialise it first and tell me.

PRODUCT
A single-tenant chat agent for a property management operator. One unified
agent serves two user classes:
  - Residents (authenticated, scoped to a property/unit)
  - Prospects (anonymous)

User stories:
  1. As a user, I can ask about HVAC, smart locks, and HOA violations and
     get a grounded troubleshooting answer or the information I need.
  2. As a user, I can create a ticket/incident when the issue is not
     resolved by the answer.
  3. As a user, I can search for a house in natural language.

LOCKED DECISIONS — treat as given, do not re-litigate
  - Standalone system. No reuse of any existing platform VPC, IdP, or
    Salesforce CDC pipeline.
  - Single tenant. Not multi-tenant SaaS.
  - Region: ap-south-1.
  - Channel: web chat widget only. No mobile, SMS, or voice.
  - Model layer: AWS Bedrock. Anthropic Claude 3.x (Haiku/Sonnet/Opus)
    for LLM inference, Titan Embeddings v2 for vector embeddings.
    Single API surface, single credential path (IAM).
  - Streaming transport: SSE (Server-Sent Events) for server-to-widget
    token streaming. User messages sent via POST. Not WebSocket.
  - Identity: Okta OIDC for resident authentication. We validate
    Okta-issued JWTs; we do not manage user accounts. Prospects are
    anonymous (no auth required).
  - Salesforce: Enterprise edition. REST API (Case object) for ticket
    CRUD. No CDC/Platform Events.
  - Compute: EKS Fargate for long-lived services, AWS Lambda for
    short/bursty tool handlers.
  - IaC: Terraform for all infrastructure. No console provisioning.
  - MongoDB Atlas is an EXTERNAL managed dependency. A connection URL is
    supplied. Do not write Terraform to provision the cluster. MongoDB
    serves dual purpose: session/conversation state AND property listing
    data. Connection pool sizing (min/max, idle timeout) must be
    specified per service.
  - Knowledge corpus: ~100,000 incident documents. Parent-child chunking
    strategy (incident doc = parent, derived chunks indexed as vectors
    for RAG retrieval, parent context returned for grounding). Estimated
    500k–1M vector chunks.

CAPABILITIES — spec each independently, do not merge
  - knowledge-troubleshooting : grounded answers with citations, and an
    explicit refusal path when the corpus cannot answer.
  - incident-management       : create and read back tickets in Salesforce.
                                Requires authenticated, property-scoped
                                identity.
  - property-search           : natural language to structured listing
                                results. Available to anonymous users.
  - conversation-orchestration: intent routing, tool selection, session
                                state, response streaming, human escalation.

ARCHITECTURAL INVARIANTS — every spec must hold these
  1. Domain capabilities are exposed to the orchestrator ONLY as MCP tools.
     The orchestrator never calls the LLM provider, Salesforce, or MongoDB
     directly.
  2. Every MCP tool declares its authorization requirement in its schema.
     Enforcement is in the tool router, never in prompt instructions.
     create_ticket requires resident identity. search_houses does not.
  3. Phase 1 mocks and Phase 2 live integrations satisfy the SAME tool
     schemas. The mock is a fixture implementation, not a parallel code path.
  4. Conversation and session state is externalised. Never held in pod memory.
  5. A model gateway service owns all LLM provider interaction: API key
     custody, retries, rate-limit handling, cost attribution, PII redaction
     before egress, and failover between providers behind one internal
     interface.

PHASES — deployment stages of ONE design, not three architectures
  Phase 1 : Mock MCP responses. No backend integrations. All users treated as
            anonymous (no auth). Goal is to validate tool contracts, intent
            routing, and SSE streaming end to end.
  Phase 2 : ~1,000 DAU. Live RAG, MongoDB, mock Salesforce. Okta OIDC
            integrated — validate the auth gate (anonymous ticket creation
            blocked). Goal is to establish real p50/p95/p99 per tool. Do not
            pre-optimise before this data exists.
  Phase 3 : ~100,000 DAU. Scale-out, caching, and per-tool compute placement
            decided FROM Phase 2 telemetry, not upfront.

OUT OF SCOPE — state this explicitly in the specs
  Payments, lease execution, smart-lock actuation (diagnose only, never
  unlock), voice channel, multi-tenancy.

DECISIONS YOU MUST MAKE AND JUSTIFY
For each, compare at least two options with trade-offs, then recommend one:
  - Vector store for RAG (note MongoDB Atlas is already a dependency)
  - Session/conversation state store and its TTL policy
  - Ingestion pipeline for the knowledge corpus (~100k incident docs)
  - Bedrock model invocation pattern and its failure modes
  - Compute placement per MCP tool at Phase 3

DECISIONS ALREADY RESOLVED (do not re-litigate)
  - Streaming transport: SSE (over WebSocket — simpler infra, proxy-
    friendly, natural fit for token streaming pattern).
  - Identity model: Okta OIDC for residents, anonymous for prospects.
  - LLM + Embeddings: Bedrock (Gemini Flash 3.1 + Titan Embeddings v2).
  - Resident Context: Fetch tenant details from MongoDB using Okta Subject ID.
  - Salesforce Auth: OAuth 2.0 Client Credentials for the Case REST API.
  - Human Escalation: Asynchronous ticket in Salesforce for an agent to review later (no live chat handoff).
  - Knowledge Ingestion: Mock data incidents in MongoDB for Phases 1 & 2. Create a CDC to update MongoDB vector DB from Salesforce in Phase 3.
  - Model Gateway: Architect and build this service from scratch.
  - Property Listing Data: Mock data for Phase 0/1. Treat MongoDB collections as read-only for search.

NON-FUNCTIONALS — specify measurable targets per phase
  First-token latency, per-tool p99 budget, RAG groundedness and refusal
  behaviour, PII handling in conversation logs and in LLM egress payloads,
  ticket-creation idempotency, availability target, cost ceiling.

DELIVERABLES
  1. OpenSpec change proposal (why, what changes, impact).
  2. One capability spec per capability above, with requirements and
     scenarios in the repo's OpenSpec format.
  3. MCP tool contract: for troubleshoot_lookup, create_ticket, and
     search_houses — request schema, response schema, error taxonomy,
     idempotency behaviour, and declared auth requirement.
  4. architecture.md: component view, request flow for each user story,
     data flow, trust boundaries, and the phase-to-phase delta.
  5. A decisions section recording every choice from the list above with
     its trade-off rationale.
  6. Terraform module plan: module boundaries, state layout, and
     environment strategy. Plan only, no HCL yet.

METHOD
  - Before writing, list every assumption you are forced to make. If an
    assumption would materially change the architecture, STOP and ask me
    instead of guessing.
  - Design for the Phase 3 shape, but sequence delivery so Phase 1 is
    genuinely thin.
  - Flag anything that is a compliance or legal decision rather than an
    engineering one. Do not decide those yourself.
  - No implementation code. No HCL. Specs, contracts, and diagrams only.

CLARIFICATIONS RESOLVED
  - OpenSpec format: Defined from scratch (YAML frontmatter + Markdown).
  - MCP protocol: Standard MCP (JSON-RPC 2.0 over stdio).
  - Widget: Embedded via <script> tag into existing portal. Frontend in
    scope. Same origin.
  - Salesforce: Case object only (status/comments). Mock through Phase 2,
    live in Phase 3. No API rate-limit constraints.
  - MongoDB: Schema designed from scratch. Atlas Vector Search for RAG.
    Standard mongodb+srv:// URI.
  - Knowledge corpus: Originates from Salesforce. MongoDB is the derived
    search-optimised copy. Structured incidents (JSON fields).
  - Escalation: Same create_ticket tool (category: escalation). Agent
    notifies user with reference number.
  - Non-functionals: Proposed reasonable defaults.
  - Compliance: CCPA. ap-south-1 for Phase 1-2, add us-east-2 in Phase 3.
    DPDP Act flagged for legal review.