# 🏛️ REST Architecture Reference
*Version 1.0 | Representational State Transfer Principles*

---

## 📖 Overview
REST (Representational State Transfer) is an architectural style for designing networked applications. It's not a protocol or standard, but a set of constraints that, when followed, create scalable, maintainable, and performant APIs.

**Created by**: Roy Fielding (2000) in his doctoral dissertation  
**Philosophy**: "Resources, not actions. State transfer, not remote procedure calls."

---

## 🏗️ The Six REST Constraints

### 1. Client-Server Architecture
**Principle**: Separation of concerns between UI and data storage.

**Benefits**:
- Independent evolution of client and server
- Improved portability of UI
- Scalability through simplified server components

**Example**:
```
❌ Bad: Monolithic app with tightly coupled frontend/backend
✅ Good: React frontend + Node.js API backend (independent deployments)
```

### 2. Statelessness
**Principle**: Each request contains all information needed to process it. Server stores no client context between requests.

**Benefits**:
- Improved scalability (no session state to manage)
- Simplified server implementation
- Better reliability (no session corruption)

**Example**:
```http
❌ Bad: Server stores user session, expects cookie
GET /api/cart HTTP/1.1
Cookie: session_id=abc123

✅ Good: Every request includes authentication
GET /api/cart HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**DevOps Implication**: Stateless APIs can be load-balanced across any server without session affinity.

### 3. Cacheability
**Principle**: Responses must explicitly define themselves as cacheable or non-cacheable.

**Benefits**:
- Reduced latency
- Decreased server load
- Improved scalability

**Example**:
```http
HTTP/1.1 200 OK
Cache-Control: max-age=3600, public
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Sun, 26 Jan 2026 12:00:00 GMT
```

**Cache-Control Directives**:
- `public`: Can be cached by any cache
- `private`: Only cacheable by client browser
- `no-cache`: Must revalidate with server before using
- `no-store`: Never cache (sensitive data)
- `max-age=3600`: Cache for 1 hour

### 4. Uniform Interface
**Principle**: Standardized way to interact with resources.

**Four Sub-Constraints**:

#### a) Resource Identification
Resources are identified by URIs:
```
https://api.example.com/users/42
https://api.example.com/orders/12345
https://api.example.com/servers/web-prod-01
```

#### b) Resource Manipulation Through Representations
Clients manipulate resources through representations (JSON, XML):
```json
{
  "id": 42,
  "username": "devops_engineer",
  "email": "engineer@example.com"
}
```

#### c) Self-Descriptive Messages
Each message includes enough information to describe how to process it:
```http
POST /api/users HTTP/1.1
Content-Type: application/json
Accept: application/json

{"username": "new_user"}
```

#### d) HATEOAS (Hypermedia As The Engine Of Application State)
Responses include links to related resources:
```json
{
  "id": 42,
  "username": "devops_engineer",
  "links": {
    "self": "/api/users/42",
    "orders": "/api/users/42/orders",
    "profile": "/api/users/42/profile"
  }
}
```

### 5. Layered System
**Principle**: Client cannot tell if connected directly to end server or intermediary.

**Benefits**:
- Security through network firewalls
- Load balancing
- Caching proxies

**Example Architecture**:
```
Client → CDN → Load Balancer → API Gateway → Microservice
```

### 6. Code on Demand (Optional)
**Principle**: Server can extend client functionality by transferring executable code.

**Example**: JavaScript sent to browser, Java applets (rarely used in modern APIs)

---

## 🎯 RESTful Resource Design

### Resource Naming Conventions

**✅ Best Practices**:
```
/users                    # Collection of users
/users/42                 # Specific user
/users/42/orders          # User's orders (nested resource)
/orders?status=pending    # Filtered collection
/servers/web-prod-01/logs # Server logs
```

**❌ Anti-Patterns**:
```
/getUsers                 # Don't use verbs (use HTTP methods)
/user/42                  # Use plural nouns
/users/42/getOrders       # Verbs in URI
/api/v1/users_list        # Underscores (use hyphens)
```

### HTTP Method Mapping

| Operation | HTTP Method | URI | Request Body | Response |
|-----------|-------------|-----|--------------|----------|
| List all users | GET | `/users` | None | `200 OK` + array |
| Get user | GET | `/users/42` | None | `200 OK` + object |
| Create user | POST | `/users` | User data | `201 Created` + object |
| Replace user | PUT | `/users/42` | Full user data | `200 OK` + object |
| Update user | PATCH | `/users/42` | Partial data | `200 OK` + object |
| Delete user | DELETE | `/users/42` | None | `204 No Content` |

---

## 📊 REST Maturity Model (Richardson)

### Level 0: The Swamp of POX (Plain Old XML)
Single URI, single HTTP method (usually POST):
```http
POST /api HTTP/1.1

<request>
  <action>getUser</action>
  <userId>42</userId>
</request>
```

**Example**: SOAP, XML-RPC

### Level 1: Resources
Multiple URIs, single HTTP method:
```http
POST /api/users/42 HTTP/1.1
POST /api/orders/123 HTTP/1.1
```

### Level 2: HTTP Verbs
Multiple URIs, proper HTTP methods:
```http
GET /api/users/42 HTTP/1.1
POST /api/users HTTP/1.1
DELETE /api/users/42 HTTP/1.1
```

**Most modern APIs are here**

### Level 3: Hypermedia Controls (HATEOAS)
Responses include navigation links:
```json
{
  "id": 42,
  "username": "devops_engineer",
  "_links": {
    "self": {"href": "/users/42"},
    "orders": {"href": "/users/42/orders"},
    "delete": {"href": "/users/42", "method": "DELETE"}
  }
}
```

**Rare in practice** (complexity vs. benefit tradeoff)

---

## 🔧 Advanced REST Patterns

### 1. Pagination
Handle large collections efficiently:

**Offset-based**:
```http
GET /api/users?limit=20&offset=40 HTTP/1.1
```

**Cursor-based** (better for real-time data):
```http
GET /api/users?limit=20&cursor=eyJpZCI6NDJ9 HTTP/1.1
```

**Response**:
```json
{
  "data": [...],
  "pagination": {
    "total": 1000,
    "limit": 20,
    "offset": 40,
    "next": "/api/users?limit=20&offset=60"
  }
}
```

### 2. Filtering and Sorting
```http
GET /api/servers?status=running&region=us-east-1&sort=-created_at HTTP/1.1
```

**Query Parameters**:
- `status=running`: Filter by status
- `region=us-east-1`: Filter by region
- `sort=-created_at`: Sort descending by creation date

### 3. Field Selection (Sparse Fieldsets)
Reduce payload size:
```http
GET /api/users/42?fields=id,username,email HTTP/1.1
```

### 4. Versioning Strategies

**URI Versioning** (most common):
```
https://api.example.com/v1/users
https://api.example.com/v2/users
```

**Header Versioning**:
```http
GET /api/users HTTP/1.1
Accept: application/vnd.example.v2+json
```

**Query Parameter**:
```
https://api.example.com/users?version=2
```

### 5. Bulk Operations
```http
POST /api/users/bulk HTTP/1.1
Content-Type: application/json

{
  "operations": [
    {"method": "POST", "path": "/users", "body": {...}},
    {"method": "PATCH", "path": "/users/42", "body": {...}},
    {"method": "DELETE", "path": "/users/43"}
  ]
}
```

---

## 🚀 DevOps REST Best Practices

### 1. Idempotency Keys
Prevent duplicate operations:
```http
POST /api/payments HTTP/1.1
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000

{"amount": 100, "currency": "USD"}
```

Server tracks key and returns same response for duplicate requests.

### 2. Rate Limiting Headers
```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 4999
X-RateLimit-Reset: 1643200000
```

### 3. Error Response Format
Consistent error structure:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      {
        "field": "email",
        "issue": "Must be valid email address"
      }
    ],
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

### 4. Health Check Endpoints
```http
GET /health HTTP/1.1

Response:
{
  "status": "healthy",
  "version": "1.2.3",
  "uptime": 86400,
  "dependencies": {
    "database": "healthy",
    "cache": "healthy"
  }
}
```

---

## 🛡️ SRE Standard Checklist
- [ ] **Use nouns for resources**, not verbs
- [ ] **Plural resource names** (`/users`, not `/user`)
- [ ] **Proper HTTP methods** (GET for read, POST for create, etc.)
- [ ] **Meaningful status codes** (don't return 200 for errors)
- [ ] **Versioning strategy** defined from day one
- [ ] **Pagination** for all collection endpoints
- [ ] **Rate limiting** to prevent abuse
- [ ] **Idempotency** for non-safe operations
- [ ] **HTTPS only** in production
- [ ] **Consistent error format** across all endpoints

---

## ❓ Interview "Deep-Cut" Questions

1. **What is the difference between PUT and POST in REST?**
   - *Answer*: POST creates a new resource (server assigns ID), PUT replaces an existing resource at a known URI. POST to `/users` creates user, PUT to `/users/42` replaces user 42.

2. **Explain why statelessness is critical for horizontal scalability.**
   - *Answer*: Stateless APIs allow any server to handle any request without session affinity. This enables simple load balancing and auto-scaling without session migration complexity.

3. **What is HATEOAS and why is it rarely implemented?**
   - *Answer*: HATEOAS includes hypermedia links in responses for API navigation. Rarely implemented because it adds complexity and payload size, while most clients prefer static API documentation.

4. **How do you handle versioning in a REST API without breaking existing clients?**
   - *Answer*: Use URI versioning (`/v1/`, `/v2/`), maintain old versions during deprecation period, provide clear migration guides, and use sunset headers to signal deprecation timeline.

5. **Explain the difference between `Cache-Control: no-cache` and `Cache-Control: no-store`.**
   - *Answer*: `no-cache` allows caching but requires revalidation with server before use. `no-store` prohibits caching entirely (use for sensitive data like payment info).

---

**Next Step**: [API Authentication & Security →](./API-Authentication-Ref.md)
