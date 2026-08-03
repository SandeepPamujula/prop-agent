---
name: property-management-agent
version: 0.1.0
status: draft
date: 2026-08-03
type: change-proposal
author: Architecture Team
---

# Change Proposal — Property Management Conversational Agent

## Summary

Introduce a **single-tenant, web-based conversational agent** for a property management operator. The agent serves two user classes (residents and prospects) across three domain capabilities via a unified chat widget embedded in the existing property management portal.

## Motivation

The property management operator needs automated, 24/7 support for:
- **Troubleshooting**: Residents and prospects asking about HVAC, smart locks, and HOA violations
- **Incident management**: Residents creating and tracking support tickets when troubleshooting doesn't resolve their issue
- **Property search**: Prospects (and residents) searching for available properties in natural language

Currently these interactions require human staff. The agent reduces support load while maintaining a human escalation path for complex issues.

## What Changes

### New System

A conversational agent deployed on AWS (`ap-south-1`) consisting of:

| Component | Purpose | Tech Stack |
|-----------|---------|------------|
| **Chat Widget** | Embedded `<script>` in existing portal, SSE streaming | React (TS) + Tailwind |
| **Orchestrator Service** | Conversation lifecycle, intent routing, MCP client | Node.js (TS) |
| **Model Gateway Service** | All Bedrock API interaction, PII redaction, retries | Node.js (TS) |
| **MCP Tool Server** | Hosts domain tools behind MCP protocol | Node.js (TS) |

### Capabilities

| Capability | Spec | MCP Tool | Auth Required |
|------------|------|----------|:------------:|
| [Knowledge Troubleshooting](capabilities/knowledge-troubleshooting.md) | RAG-grounded answers with citations | [`troubleshoot_lookup`](contracts/troubleshoot-lookup.md) | No |
| [Incident Management](capabilities/incident-management.md) | Create/read tickets | [`create_ticket`](contracts/create-ticket.md) | Yes (Phase 2+) |
| [Property Search](capabilities/property-search.md) | NL-to-structured listing search | [`search_houses`](contracts/search-houses.md) | No |
| [Conversation Orchestration](capabilities/conversation-orchestration.md) | Intent routing, session state, streaming | N/A (orchestrator-level) | — |

### External Dependencies

| Dependency | Purpose |
|------------|---------|
| AWS Bedrock (Claude 3.x + Titan Embeddings v2) | LLM inference and vector embeddings |
| MongoDB Atlas | Session state, property listings, vector search, mock incidents |
| Okta | OIDC identity provider for resident authentication (Phase 2+) |
| Salesforce (Enterprise) | Case CRUD via REST API (Phase 3) |

## Impact

- **Infrastructure**: New AWS resources in `ap-south-1` — EKS Fargate cluster, ALB, VPC, CloudWatch, Secrets Manager. Terraform-managed.
- **External services**: New integrations with MongoDB Atlas (provided), Okta (provided), Salesforce (Phase 3).
- **Cost**: $500/mo (Phase 1) → $3,000/mo (Phase 2) → $15,000/mo (Phase 3).
- **Users**: Dev team (Phase 1) → ~1,000 DAU (Phase 2) → ~100,000 DAU (Phase 3).

## Phased Delivery

The architecture is **one design** with progressive backend integration:

| Phase | Focus | Auth | Backends |
|-------|-------|------|----------|
| **Phase 1** | Contract validation | All users anonymous (no auth) | Mock MCP responses (fixture JSON) |
| **Phase 2** | Live integration (1k DAU) | Okta OIDC integrated, auth gate enforced | Live Atlas Vector Search, MongoDB, mock Salesforce |
| **Phase 3** | Scale (100k DAU) | Same | Live Salesforce, multi-region, caching |

## Out of Scope

Payments, lease execution, smart-lock actuation (diagnose only), voice channel, multi-tenancy, SMS/mobile app, live chat handoff, property listing data ingestion pipeline (populated by an external system).

## Related Documents

- [Architecture](../docs/architecture.md) — System-level design, data model, security, NFRs, ADRs, Terraform plan
- [Capability Specs](capabilities/) — Per-capability requirements and scenarios
- [Tool Contracts](contracts/) — MCP tool schemas, error taxonomy, idempotency
