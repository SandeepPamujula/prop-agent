---
name: troubleshoot_lookup
version: 0.1.0
status: draft
type: mcp-tool-contract
protocol: JSON-RPC 2.0 over stdio
auth: none
idempotent: true (safe, read-only)
capability: knowledge-troubleshooting
phase: [1, 2, 3]
---

# MCP Tool Contract: `troubleshoot_lookup`

## Overview

Retrieves relevant knowledge chunks from the incident corpus using vector similarity search. Used by the [Knowledge Troubleshooting](../capabilities/knowledge-troubleshooting.md) capability to ground LLM responses with citations.

| Property | Value |
|----------|-------|
| **Auth** | `none` — available to all users |
| **Idempotent** | Safe (read-only, no side effects) |
| **Phase 1 Backend** | Fixture JSON file |
| **Phase 2+ Backend** | Atlas Vector Search (MongoDB) |

## MCP Tool Declaration

This is the `tools/list` response entry for this tool:

```json
{
  "name": "troubleshoot_lookup",
  "description": "Search the knowledge base for troubleshooting information about HVAC systems, smart locks, and HOA violations. Returns relevant knowledge chunks with similarity scores and resolution steps. Use this tool when the user asks about maintenance issues, how things work, or needs troubleshooting help.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "The user's troubleshooting question or search query in natural language.",
        "minLength": 3,
        "maxLength": 500
      },
      "category_filter": {
        "type": "string",
        "enum": ["hvac", "smart_lock", "hoa_violation"],
        "description": "Optional category to narrow the search. Omit to search all categories."
      },
      "max_results": {
        "type": "integer",
        "description": "Maximum number of results to return. Defaults to 5.",
        "minimum": 1,
        "maximum": 20,
        "default": 5
      }
    },
    "required": ["query"],
    "additionalProperties": false
  }
}
```

## Request Schema

### `tools/call` Request

```json
{
  "jsonrpc": "2.0",
  "id": "req-001",
  "method": "tools/call",
  "params": {
    "name": "troubleshoot_lookup",
    "arguments": {
      "query": "AC blowing warm air",
      "category_filter": "hvac",
      "max_results": 5
    }
  }
}
```

### Parameter Details

| Parameter | Type | Required | Default | Description |
|-----------|------|:--------:|---------|-------------|
| `query` | string | ✅ | — | Natural language query. Min 3, max 500 characters. |
| `category_filter` | string (enum) | ❌ | — | One of: `hvac`, `smart_lock`, `hoa_violation`. Narrows vector search space. |
| `max_results` | integer | ❌ | 5 | Number of results. Range: 1–20. |

## Response Schema

### Success Response

```json
{
  "jsonrpc": "2.0",
  "id": "req-001",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"results\":[{\"chunk_id\":\"CHK-001\",\"content\":\"If your AC is blowing warm air, first check the thermostat settings...\",\"score\":0.87,\"category\":\"hvac\",\"resolution_steps\":\"1. Check thermostat is set to COOL mode\\n2. Verify temperature setting is below room temperature\\n3. Check air filter...\",\"parent_incident\":{\"incident_id\":\"INC-042\",\"title\":\"AC Blowing Warm Air\",\"category\":\"hvac\"}}],\"total_results\":3,\"query_embedding_model\":\"amazon.titan-embed-text-v2:0\"}"
      }
    ]
  }
}
```

### Parsed Response Object

```json
{
  "results": [
    {
      "chunk_id": "CHK-001",
      "content": "If your AC is blowing warm air, first check the thermostat settings...",
      "score": 0.87,
      "category": "hvac",
      "resolution_steps": "1. Check thermostat is set to COOL mode\n2. Verify temperature setting is below room temperature\n3. Check air filter...",
      "parent_incident": {
        "incident_id": "INC-042",
        "title": "AC Blowing Warm Air",
        "category": "hvac"
      }
    }
  ],
  "total_results": 3,
  "query_embedding_model": "amazon.titan-embed-text-v2:0"
}
```

### Response Field Details

| Field | Type | Description |
|-------|------|-------------|
| `results` | array | Ordered by descending `score`. Empty array if no results. |
| `results[].chunk_id` | string | Unique identifier for the knowledge chunk |
| `results[].content` | string | Chunk text (500–1000 tokens) |
| `results[].score` | float | Cosine similarity score (0.0–1.0). Scores < 0.3 indicate low confidence. |
| `results[].category` | string | Category inherited from parent incident |
| `results[].resolution_steps` | string | Step-by-step resolution from parent incident |
| `results[].parent_incident` | object | Parent incident context (retrieved via `$lookup`) |
| `results[].parent_incident.incident_id` | string | Parent incident unique ID |
| `results[].parent_incident.title` | string | Parent incident title |
| `results[].parent_incident.category` | string | Parent incident category |
| `total_results` | integer | Total matching chunks (before `max_results` limit) |
| `query_embedding_model` | string | Embedding model used for the query vector |

## Error Taxonomy

All errors follow the shared error envelope:

```json
{
  "jsonrpc": "2.0",
  "id": "req-001",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"error\":{\"code\":\"VECTOR_STORE_UNAVAILABLE\",\"message\":\"Atlas Vector Search is temporarily unavailable\",\"retryable\":true,\"details\":{}}}"
      }
    ],
    "isError": true
  }
}
```

| Error Code | Description | Retryable | When |
|-----------|-------------|:---------:|------|
| `VALIDATION_ERROR` | Invalid input (query too short/long, invalid category) | No | Bad request |
| `VECTOR_STORE_UNAVAILABLE` | Atlas Vector Search index or MongoDB cluster unreachable | Yes | Infrastructure issue |
| `DATABASE_UNAVAILABLE` | MongoDB connection failure | Yes | Infrastructure issue |
| `QUERY_TOO_BROAD` | Query matches too many chunks to be useful (> threshold) | No | Ambiguous query |
| `NO_RESULTS` | No chunks matched above minimum score threshold | No | Corpus gap or off-topic query |
| `RATE_LIMITED` | Internal rate limiting triggered | Yes | High traffic |

## Idempotency

This tool is **safe** (read-only). Identical requests produce identical results (modulo index updates). No idempotency key is needed.

## Phase-Specific Backend

| Phase | Backend | Query Path |
|-------|---------|------------|
| Phase 1 | Fixture JSON file | Return pre-defined fixture results matching query patterns |
| Phase 2 | Atlas Vector Search | Embed query via Titan v2 → HNSW cosine search on `incident_chunks` → `$lookup` to `incidents` for parent context |
| Phase 3 | Atlas Vector Search + response caching | Same as Phase 2, with caching for frequent queries based on Phase 2 hotspot data |

## Query Pipeline (Phase 2+)

```
1. Receive query string
2. Generate embedding via Bedrock Titan Embeddings v2 (1024 dimensions)
3. Execute Atlas Vector Search:
   - Index: incident_vector_index
   - Similarity: cosine
   - Pre-filter by category (if category_filter provided)
   - Return top-K chunks
4. $lookup to incidents collection via parent_incident_id
5. Enrich chunks with parent context (title, description, resolution_steps)
6. Return sorted by score (descending)
```
