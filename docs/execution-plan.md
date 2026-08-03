## Step 1 — Extract

### Capabilities/Components
- Chat Widget
- Orchestrator Service
- Model Gateway Service
- MCP Tool Server (stdio)
- Troubleshoot MCP Server (HTTP)
- Knowledge Troubleshooting (Capability)
- Incident Management (Capability)
- Property Search (Capability)
- Conversation Orchestration (Capability)

### Phase Boundaries
- Phase 1: Mock MCP Responses, No Backend Integrations, All Users Anonymous, ~10 Concurrent Users. EKS Fargate minimal (ap-south-1).
- Phase 2: Live Integration (1k DAU), Okta OIDC Integration, Auth Gate Testing, Live Atlas Vector Search, Live MongoDB, Mock Salesforce.
- Phase 3: Scale (100k DAU), Live Salesforce REST API, Salesforce CDC, ap-south-1 + us-east-2, Lambda for Burst Tools, Caching Layer.

### External Dependencies
- AWS Bedrock (Claude 3.x, Titan Embeddings v2)
- MongoDB Atlas (Document store, sessions, vector search, listings)
- Okta (OIDC, JWKS caching)
- Salesforce (REST API case CRUD, CDC)

### NFRs
- Latency: First-token p50 <2s (P1) -> <1.5s (P2) -> <1s (P3); End-to-end p95 <6s (P1) -> <5s (P2) -> <3.5s (P3).
- Availability: 95% (P1) -> 99.5% (P2) -> 99.9% (P3).
- Cost ceiling: $500 (P1) -> $3000 (P2) -> $15000 (P3).
- Quality: RAG groundedness >=85% (P2) -> >=90% (P3); Intent classification accuracy >=90% (P2) -> >=95% (P3); Ticket idempotency window 1 hour.
- Security: PII redaction before egress (regex + Comprehend), WAF, TLS 1.2+, CCPA/DPDP compliance, 30-min session TTL.

### Capability Deltas
- Knowledge Troubleshooting (ADDED): RAG-grounded answers with citations, category filtering, explicit refusal on low scores, anonymous access, multi-turn follow-ups.
- Incident Management (ADDED): Authenticated ticket creation with resident context scoping, idempotency, auth gate rejection for anonymous, human escalation, ticket read-back.
- Property Search (ADDED): NL-to-structured filter extraction, pagination, empty result handling, conversational follow-up refinement.
- Conversation Orchestration (ADDED): Claude `tool_use` intent routing, tool availability by user type, multi-tool turns, PII redaction, Bedrock fallbacks, externalized MongoDB session state, SSE streaming.

## Step 2 — Milestones

| Milestone | Goal | Exit Criteria | Depends On |
|---|---|---|---|
| M1: Foundation & Pipeline | Base AWS networking, CI/CD, and infra scaffolding deployed. | TF state in S3. Networking, cluster, and basic pipelines exist. (Local/mock dependencies) | None |
| M2: Contract Validation (Phase 1) | End-to-end SSE chat with anonymous mock tool execution. | All services running on dev EKS. LLM correctly routes intents to JSON fixture responses. | M1 |
| M3: Identity & Live Data (Phase 2) | Live MongoDB, Vector Search, and Okta Auth integration. | Real Vector Search answers questions. Auth gate blocks anonymous tickets. MongoDB stores sessions/tickets. | M2 |
| M4: Prod Readiness & Observability | Security, monitoring, WAF, and CDN deployed for 1k DAU. | Amazon Comprehend PII redaction live. X-Ray, CloudWatch alarms active. | M3 |
| M5: Scale & CRM Sync (Phase 3) | 100k DAU with Salesforce sync and multi-region HA. | Live ticket CRUD via Salesforce API. CDC Lambda syncs to Vector Store. Multi-region routing active. | M4 |

*Note: M1 and M2 run on local/mocked dependencies without real live integrations. M3 is the first milestone requiring production-like identity (Okta) and database (MongoDB) infrastructure.*

## Step 3 — User Stories

Detailed user stories have been extracted into individual milestone documents:
- [M1: Foundation & Pipeline](milestone-1.md)
- [M2: Contract Validation (Phase 1)](milestone-2.md)
- [M3: Identity & Live Data (Phase 2)](milestone-3.md)
- [M4: Prod Readiness & Observability](milestone-4.md)
- [M5: Scale & CRM Sync (Phase 3)](milestone-5.md)

## Open Questions
- **DPDP Act 2023 Compliance**: Architecture flags Indian data protection laws as a legal review requirement. Need confirmation from Legal on consent flows and data localization requirements before Phase 2.
- **Compute Placement for Burst Tools**: ADR-005 defers the decision to use Lambda vs EKS for MCP tools based on Phase 2 telemetry. What specific metric thresholds will trigger a move to Lambda in Phase 3?
- **Geospatial Extraction**: Property search supports a `2dsphere` index, but NL-to-geo filters (e.g., "near downtown") are deferred to Phase 3. Should this be explicitly designed into the OpenSpec now or left as a fast-follow?

## Explicitly Out of Scope
- Payments (no payment processing or billing integration).
- Lease execution (no document signing or lease management).
- Smart-lock actuation (diagnose only, no lock/unlock commands).
- Voice channel (web chat widget only; no telephony, IVR, or speech-to-text).
- Multi-tenancy (single-tenant deployment; no tenant isolation).
- SMS / Mobile app (web chat widget embedded in portal only).
- Live chat handoff (escalation is asynchronous via Salesforce ticket).
- Data pipeline for property listings (source-of-truth and ingestion for listings is out of scope).
