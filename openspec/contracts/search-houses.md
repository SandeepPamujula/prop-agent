---
name: search_houses
version: 0.1.0
status: draft
type: mcp-tool-contract
protocol: JSON-RPC 2.0 over stdio
auth: none
idempotent: true (safe, read-only)
capability: property-search
phase: [1, 2, 3]
---

# MCP Tool Contract: `search_houses`

## Overview

Searches available property listings using natural language queries with structured filters. Used by the [Property Search](../capabilities/property-search.md) capability.

| Property | Value |
|----------|-------|
| **Auth** | `none` — available to all users |
| **Idempotent** | Safe (read-only, no side effects) |
| **Phase 1 Backend** | Fixture JSON file |
| **Phase 2+ Backend** | Atlas Search (MongoDB) |

## MCP Tool Declaration

This is the `tools/list` response entry for this tool:

```json
{
  "name": "search_houses",
  "description": "Search for available property listings based on the user's criteria. Supports filtering by price range, number of bedrooms/bathrooms, city, and amenities. Use this tool when the user is looking for a place to rent or wants to browse available properties.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "The user's search query in natural language. Used for full-text search and semantic matching.",
        "minLength": 2,
        "maxLength": 500
      },
      "filters": {
        "type": "object",
        "description": "Structured filters extracted from the user's query.",
        "properties": {
          "min_price": {
            "type": "number",
            "description": "Minimum monthly rent in USD.",
            "minimum": 0
          },
          "max_price": {
            "type": "number",
            "description": "Maximum monthly rent in USD.",
            "minimum": 0
          },
          "min_bedrooms": {
            "type": "integer",
            "description": "Minimum number of bedrooms.",
            "minimum": 0
          },
          "max_bedrooms": {
            "type": "integer",
            "description": "Maximum number of bedrooms.",
            "minimum": 0
          },
          "min_bathrooms": {
            "type": "integer",
            "description": "Minimum number of bathrooms.",
            "minimum": 0
          },
          "city": {
            "type": "string",
            "description": "City name to filter by."
          },
          "state": {
            "type": "string",
            "description": "State abbreviation to filter by (e.g., 'TX', 'CA').",
            "minLength": 2,
            "maxLength": 2
          },
          "amenities": {
            "type": "array",
            "items": {
              "type": "string"
            },
            "description": "List of desired amenities (e.g., 'pool', 'garage', 'pet_friendly', 'gym', 'laundry')."
          }
        },
        "additionalProperties": false
      },
      "limit": {
        "type": "integer",
        "description": "Maximum number of listings to return. Defaults to 5.",
        "minimum": 1,
        "maximum": 20,
        "default": 5
      },
      "offset": {
        "type": "integer",
        "description": "Offset for pagination. Defaults to 0.",
        "minimum": 0,
        "default": 0
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
  "id": "req-003",
  "method": "tools/call",
  "params": {
    "name": "search_houses",
    "arguments": {
      "query": "3 bedroom house near downtown",
      "filters": {
        "max_price": 2000,
        "min_bedrooms": 3
      },
      "limit": 5,
      "offset": 0
    }
  }
}
```

### Parameter Details

| Parameter | Type | Required | Default | Description |
|-----------|------|:--------:|---------|-------------|
| `query` | string | ✅ | — | Natural language query. Min 2, max 500 characters. |
| `filters` | object | ❌ | — | Structured filters (see sub-fields below) |
| `filters.min_price` | number | ❌ | — | Minimum monthly rent (USD) |
| `filters.max_price` | number | ❌ | — | Maximum monthly rent (USD) |
| `filters.min_bedrooms` | integer | ❌ | — | Minimum bedrooms |
| `filters.max_bedrooms` | integer | ❌ | — | Maximum bedrooms |
| `filters.min_bathrooms` | integer | ❌ | — | Minimum bathrooms |
| `filters.city` | string | ❌ | — | City name |
| `filters.state` | string | ❌ | — | State abbreviation (2 chars) |
| `filters.amenities` | string[] | ❌ | — | Desired amenities |
| `limit` | integer | ❌ | 5 | Results per page. Range: 1–20. |
| `offset` | integer | ❌ | 0 | Pagination offset |

## Response Schema

### Success Response

```json
{
  "jsonrpc": "2.0",
  "id": "req-003",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"listings\":[{\"listing_id\":\"LST-001\",\"address\":\"123 Main St\",\"city\":\"Austin\",\"state\":\"TX\",\"zip\":\"78701\",\"price\":1800,\"bedrooms\":3,\"bathrooms\":2,\"sqft\":1450,\"amenities\":[\"pool\",\"garage\"],\"description\":\"Spacious 3BR home near downtown with pool and attached garage.\",\"image_urls\":[\"https://cdn.example.com/lst-001-1.jpg\"],\"active\":true,\"listed_at\":\"2026-07-15T00:00:00Z\"}],\"pagination\":{\"total\":12,\"limit\":5,\"offset\":0,\"has_more\":true}}"
      }
    ]
  }
}
```

### Parsed Response Object

```json
{
  "listings": [
    {
      "listing_id": "LST-001",
      "address": "123 Main St",
      "city": "Austin",
      "state": "TX",
      "zip": "78701",
      "price": 1800,
      "bedrooms": 3,
      "bathrooms": 2,
      "sqft": 1450,
      "amenities": ["pool", "garage"],
      "description": "Spacious 3BR home near downtown with pool and attached garage.",
      "image_urls": ["https://cdn.example.com/lst-001-1.jpg"],
      "active": true,
      "listed_at": "2026-07-15T00:00:00Z"
    }
  ],
  "pagination": {
    "total": 12,
    "limit": 5,
    "offset": 0,
    "has_more": true
  }
}
```

### Response Field Details

| Field | Type | Description |
|-------|------|-------------|
| `listings` | array | Matching property listings. Empty array if no results. |
| `listings[].listing_id` | string | Unique listing identifier |
| `listings[].address` | string | Street address |
| `listings[].city` | string | City |
| `listings[].state` | string | State abbreviation |
| `listings[].zip` | string | ZIP code |
| `listings[].price` | number | Monthly rent in USD |
| `listings[].bedrooms` | integer | Number of bedrooms |
| `listings[].bathrooms` | integer | Number of bathrooms |
| `listings[].sqft` | integer | Square footage |
| `listings[].amenities` | string[] | Available amenities |
| `listings[].description` | string | Property description |
| `listings[].image_urls` | string[] | Property image URLs |
| `listings[].active` | boolean | Whether the listing is currently active |
| `listings[].listed_at` | string (ISO 8601) | When the property was listed |
| `pagination.total` | integer | Total matching listings |
| `pagination.limit` | integer | Results per page (echoed from request) |
| `pagination.offset` | integer | Current offset (echoed from request) |
| `pagination.has_more` | boolean | Whether more results are available |

## Error Taxonomy

| Error Code | Description | Retryable | When |
|-----------|-------------|:---------:|------|
| `VALIDATION_ERROR` | Invalid input (query too short, invalid filter values) | No | Bad request |
| `QUERY_PARSE_ERROR` | Unable to extract meaningful search intent from query | No | Overly vague query (e.g., just "houses") |
| `NO_RESULTS` | No listings match the query and filters | No | No matching data |
| `DATABASE_UNAVAILABLE` | MongoDB / Atlas Search unavailable | Yes | Infrastructure issue |
| `RATE_LIMITED` | Internal rate limiting triggered | Yes | High traffic |

## Idempotency

This tool is **safe** (read-only). Identical requests produce identical results (modulo listing updates). No idempotency key is needed.

## Phase-Specific Backend

| Phase | Backend | Details |
|-------|---------|---------|
| Phase 1 | Fixture JSON file | Return pre-defined fixture listings matching filter patterns |
| Phase 2 | Atlas Search (MongoDB) | Full-text search on `property_listings` collection with faceted filters |
| Phase 3 | Atlas Search + result caching | Same as Phase 2, with caching for frequent queries based on Phase 2 hotspot data |

## Query Pipeline (Phase 2+)

```
1. Receive query string + structured filters
2. Build Atlas Search query:
   - Full-text: $search on description, address, city fields
   - Filters: compound query with filter clauses for price range,
     bedrooms, bathrooms, amenities, city, state
   - Active only: { active: true }
3. Apply pagination (limit + offset)
4. Return sorted by relevance score (default) or price (if implied by query)
```
