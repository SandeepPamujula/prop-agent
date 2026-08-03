# M5: Scale & CRM Sync (Phase 3)

**M5.1 As a platform engineer, I want multi-region networking configured, so that we achieve 99.9% availability.**
- Given the `us-east-2.tf` and `route53.tf` modules are applied
- When a user in a different geography connects
- Then Route53 latency-based routing sends them to the fastest active region
- Size: L
- Type: Infrastructure
- Status: tbd

**M5.2 As a platform engineer, I want a CDC ingestion Lambda, so that Salesforce cases sync to the vector store.**
- Given the `compute-lambda` Terraform module is applied
- When Salesforce cases are updated
- Then the Lambda polls `getUpdated` every 15 minutes, chunks the text, embeds via Titan v2, and upserts to Atlas Vector Search
- Size: M
- Type: Infrastructure
- Status: tbd

**M5.3 As an authenticated resident, I want my tickets created in live Salesforce, so that agents can actually resolve them.**
- Given I ask to create a ticket in Phase 3
- When the MCP server executes `create_ticket`
- Then it performs a POST to the Salesforce REST API (via OAuth 2.0) and returns the real case number
- Size: L
- Type: Feature
- Status: tbd
