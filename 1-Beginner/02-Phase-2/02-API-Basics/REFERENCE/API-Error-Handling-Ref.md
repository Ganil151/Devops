# ⚠️ API Error Handling & Status Codes Reference
*Version 1.0 | Graceful Failure in Distributed Systems*

---

## 📖 Overview
In production systems, errors are not exceptions—they are expected events. Proper error handling and meaningful status codes are the difference between a debuggable system and a black box.

**Philosophy**: "Fail fast, fail loudly, fail informatively."

---

## 🔢 HTTP Status Code Deep Dive

### 1xx: Informational (Rarely Used in REST)

| Code | Name | Meaning | Use Case |
|------|------|---------|----------|
| **100** | Continue | Server received headers, client should send body | Large file uploads |
| **101** | Switching Protocols | Server switching to protocol requested by client | WebSocket upgrade |
| **102** | Processing | Server processing request (won't timeout) | Long-running operations |

**DevOps Note**: You'll rarely encounter these in REST APIs.

---

### 2xx: Success

| Code | Name | When to Use | Response Body |
|------|------|-------------|---------------|
| **200** | OK | Successful GET, PUT, PATCH | Resource representation |
| **201** | Created | Successful POST (resource created) | Created resource + Location header |
| **202** | Accepted | Request accepted, processing async | Status URL or job ID |
| **204** | No Content | Successful DELETE or PUT with no response | Empty body |
| **206** | Partial Content | Range request successful | Partial resource |

**Examples**:

```http
# 200 OK - Successful retrieval
GET /api/users/42 HTTP/1.1

HTTP/1.1 200 OK
Content-Type: application/json

{"id": 42, "username": "devops_engineer"}
```

```http
# 201 Created - Resource created
POST /api/users HTTP/1.1
Content-Type: application/json

{"username": "new_user", "email": "user@example.com"}

HTTP/1.1 201 Created
Location: /api/users/123
Content-Type: application/json

{"id": 123, "username": "new_user", "created_at": "2026-01-26T12:45:43Z"}
```

```http
# 202 Accepted - Async processing
POST /api/deployments HTTP/1.1

HTTP/1.1 202 Accepted
Content-Type: application/json

{
  "job_id": "deploy-550e8400",
  "status": "pending",
  "status_url": "/api/deployments/deploy-550e8400"
}
```

```http
# 204 No Content - Successful deletion
DELETE /api/users/42 HTTP/1.1

HTTP/1.1 204 No Content
```

---

### 3xx: Redirection

| Code | Name | Meaning | DevOps Implication |
|------|------|---------|-------------------|
| **301** | Moved Permanently | Resource permanently moved | Update bookmarks/configs |
| **302** | Found | Temporary redirect | Follow redirect |
| **303** | See Other | Redirect to GET after POST | POST-Redirect-GET pattern |
| **304** | Not Modified | Cached version still valid | Use cached response |
| **307** | Temporary Redirect | Temporary redirect (preserve method) | Retry with same method |
| **308** | Permanent Redirect | Permanent redirect (preserve method) | Update configs |

**Caching Example**:
```http
# Initial request
GET /api/users/42 HTTP/1.1

HTTP/1.1 200 OK
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Sun, 26 Jan 2026 12:00:00 GMT

{"id": 42, "username": "devops_engineer"}

# Subsequent request with ETag
GET /api/users/42 HTTP/1.1
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"

HTTP/1.1 304 Not Modified
```

---

### 4xx: Client Errors

| Code | Name | When to Use | Client Action |
|------|------|-------------|---------------|
| **400** | Bad Request | Malformed syntax, invalid JSON | Fix request format |
| **401** | Unauthorized | Missing or invalid authentication | Provide credentials |
| **403** | Forbidden | Authenticated but not authorized | Request access |
| **404** | Not Found | Resource doesn't exist | Check URI |
| **405** | Method Not Allowed | HTTP method not supported | Use allowed method |
| **406** | Not Acceptable | Can't produce requested format | Change Accept header |
| **409** | Conflict | Request conflicts with current state | Resolve conflict |
| **410** | Gone | Resource permanently deleted | Stop requesting |
| **415** | Unsupported Media Type | Content-Type not supported | Change Content-Type |
| **422** | Unprocessable Entity | Validation failed | Fix validation errors |
| **429** | Too Many Requests | Rate limit exceeded | Implement backoff |

**Detailed Examples**:

#### 400 Bad Request
```http
POST /api/users HTTP/1.1
Content-Type: application/json

{"username": "test", "email": "invalid-email"}

HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "issue": "Invalid email format",
        "provided": "invalid-email"
      }
    ],
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

#### 401 Unauthorized
```http
GET /api/users HTTP/1.1

HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="api"
Content-Type: application/json

{
  "error": {
    "code": "AUTHENTICATION_REQUIRED",
    "message": "Missing or invalid authentication token",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

#### 403 Forbidden
```http
DELETE /api/users/42 HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "User lacks permission to delete resources",
    "required_role": "admin",
    "user_roles": ["viewer"],
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

#### 404 Not Found
```http
GET /api/users/99999 HTTP/1.1

HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User with ID 99999 not found",
    "resource_type": "user",
    "resource_id": "99999",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

#### 409 Conflict
```http
POST /api/users HTTP/1.1
Content-Type: application/json

{"username": "existing_user", "email": "user@example.com"}

HTTP/1.1 409 Conflict
Content-Type: application/json

{
  "error": {
    "code": "RESOURCE_CONFLICT",
    "message": "User with username 'existing_user' already exists",
    "conflicting_field": "username",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

#### 422 Unprocessable Entity
```http
POST /api/users HTTP/1.1
Content-Type: application/json

{"username": "ab", "email": "user@example.com", "age": -5}

HTTP/1.1 422 Unprocessable Entity
Content-Type: application/json

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "username",
        "issue": "Must be at least 3 characters",
        "provided": "ab"
      },
      {
        "field": "age",
        "issue": "Must be non-negative",
        "provided": -5
      }
    ],
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

#### 429 Too Many Requests
```http
GET /api/users HTTP/1.1
X-API-Key: sk_live_abc123

HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1643200000
Retry-After: 60
Content-Type: application/json

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "API rate limit exceeded",
    "limit": 100,
    "window": "1 hour",
    "retry_after": 60,
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

---

### 5xx: Server Errors

| Code | Name | Meaning | Client Action |
|------|------|---------|---------------|
| **500** | Internal Server Error | Unhandled server exception | Retry with backoff |
| **501** | Not Implemented | Feature not implemented | Don't retry |
| **502** | Bad Gateway | Invalid response from upstream | Retry with backoff |
| **503** | Service Unavailable | Server overloaded or maintenance | Retry after delay |
| **504** | Gateway Timeout | Upstream server timeout | Retry with backoff |

**Examples**:

#### 500 Internal Server Error
```http
GET /api/users/42 HTTP/1.1

HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred",
    "request_id": "550e8400-e29b-41d4-a716-446655440000",
    "support_url": "https://support.example.com"
  }
}
```

**Note**: Never expose stack traces or internal details in production!

#### 503 Service Unavailable
```http
GET /api/users HTTP/1.1

HTTP/1.1 503 Service Unavailable
Retry-After: 120
Content-Type: application/json

{
  "error": {
    "code": "SERVICE_UNAVAILABLE",
    "message": "Service temporarily unavailable due to maintenance",
    "retry_after": 120,
    "maintenance_window": "2026-01-26T14:00:00Z to 2026-01-26T16:00:00Z",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

---

## 🎯 Error Response Design

### Standard Error Format

**Consistent structure across all errors**:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [...],
    "request_id": "unique-request-identifier",
    "timestamp": "2026-01-26T12:45:43Z",
    "documentation_url": "https://docs.example.com/errors/ERROR_CODE"
  }
}
```

### Error Code Taxonomy

**Use hierarchical error codes**:
```
AUTH_001: Invalid credentials
AUTH_002: Token expired
AUTH_003: Insufficient permissions

VALIDATION_001: Missing required field
VALIDATION_002: Invalid format
VALIDATION_003: Value out of range

RESOURCE_001: Not found
RESOURCE_002: Already exists
RESOURCE_003: Conflict
```

### Validation Error Details

**Provide actionable feedback**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "location": "body",
        "issue": "Invalid email format",
        "provided": "not-an-email",
        "expected": "Valid email address (e.g., user@example.com)"
      },
      {
        "field": "age",
        "location": "body",
        "issue": "Value out of range",
        "provided": 200,
        "expected": "Integer between 0 and 150"
      }
    ],
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

---

## 🚀 Client-Side Error Handling

### Python Example with Retry Logic

```python
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import time

def create_session_with_retries():
    """Create session with automatic retry logic"""
    session = requests.Session()
    
    retry_strategy = Retry(
        total=3,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["HEAD", "GET", "OPTIONS", "PUT", "DELETE"],
        backoff_factor=1  # 1s, 2s, 4s
    )
    
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    
    return session

def handle_api_error(response):
    """Handle different error scenarios"""
    if response.status_code == 400:
        error_data = response.json()
        print(f"Validation error: {error_data['error']['message']}")
        for detail in error_data['error'].get('details', []):
            print(f"  - {detail['field']}: {detail['issue']}")
        return None
    
    elif response.status_code == 401:
        print("Authentication required. Please provide valid credentials.")
        # Trigger re-authentication flow
        return None
    
    elif response.status_code == 403:
        print("Access forbidden. Insufficient permissions.")
        return None
    
    elif response.status_code == 404:
        print("Resource not found.")
        return None
    
    elif response.status_code == 429:
        retry_after = int(response.headers.get('Retry-After', 60))
        print(f"Rate limit exceeded. Retrying after {retry_after} seconds...")
        time.sleep(retry_after)
        return "retry"
    
    elif response.status_code >= 500:
        print(f"Server error: {response.status_code}. Will retry with backoff.")
        return "retry"
    
    else:
        print(f"Unexpected error: {response.status_code}")
        return None

# Usage
session = create_session_with_retries()

try:
    response = session.get(
        'https://api.example.com/users/42',
        headers={'Authorization': 'Bearer token'},
        timeout=(3, 10)
    )
    response.raise_for_status()
    data = response.json()
    print(data)

except requests.exceptions.HTTPError as e:
    handle_api_error(e.response)

except requests.exceptions.Timeout:
    print("Request timed out. Check network connectivity.")

except requests.exceptions.ConnectionError:
    print("Connection error. Check API endpoint.")

except requests.exceptions.RequestException as e:
    print(f"Unexpected error: {e}")
```

### Exponential Backoff Implementation

```python
import time
import random

def exponential_backoff_retry(func, max_retries=5, base_delay=1):
    """Retry function with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            
            # Calculate delay with jitter
            delay = base_delay * (2 ** attempt) + random.uniform(0, 1)
            print(f"Attempt {attempt + 1} failed: {e}. Retrying in {delay:.2f}s...")
            time.sleep(delay)

# Usage
def risky_api_call():
    response = requests.get('https://api.example.com/unstable-endpoint')
    response.raise_for_status()
    return response.json()

data = exponential_backoff_retry(risky_api_call)
```

---

## 🛡️ Server-Side Error Handling Best Practices

### 1. Never Expose Internal Details

**❌ Bad**:
```json
{
  "error": "Traceback (most recent call last):\n  File '/app/api.py', line 42\n    db.query(User).filter(User.id == user_id).first()\nSQLAlchemyError: (psycopg2.OperationalError) FATAL: password authentication failed"
}
```

**✅ Good**:
```json
{
  "error": {
    "code": "DATABASE_ERROR",
    "message": "Unable to process request due to internal error",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

### 2. Log Errors with Context

```python
import logging
import uuid

logger = logging.getLogger(__name__)

@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    request_id = str(uuid.uuid4())
    
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            logger.warning(f"[{request_id}] User {user_id} not found")
            return {"error": {"code": "NOT_FOUND", "request_id": request_id}}, 404
        
        return {"data": user.to_dict()}, 200
    
    except Exception as e:
        logger.error(f"[{request_id}] Error fetching user {user_id}: {e}", exc_info=True)
        return {
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred",
                "request_id": request_id
            }
        }, 500
```

### 3. Use Circuit Breakers for Upstream Services

```python
from pybreaker import CircuitBreaker

# Circuit breaker for external API
external_api_breaker = CircuitBreaker(
    fail_max=5,
    timeout_duration=60
)

@external_api_breaker
def call_external_api():
    response = requests.get('https://external-api.com/data', timeout=5)
    response.raise_for_status()
    return response.json()

try:
    data = call_external_api()
except CircuitBreakerError:
    # Circuit is open, return cached data or error
    return {"error": {"code": "SERVICE_UNAVAILABLE"}}, 503
```

---

## 🛡️ SRE Standard Checklist
- [ ] **Use appropriate status codes** (don't return 200 for errors)
- [ ] **Consistent error format** across all endpoints
- [ ] **Include request IDs** for traceability
- [ ] **Never expose stack traces** in production
- [ ] **Implement retry logic** for transient failures (5xx, 429)
- [ ] **Use exponential backoff** with jitter
- [ ] **Respect Retry-After** headers
- [ ] **Log all errors** with context (request ID, user, timestamp)
- [ ] **Monitor error rates** (alert on spikes)
- [ ] **Provide documentation** for error codes

---

## ❓ Interview "Deep-Cut" Questions

1. **When should you use 422 Unprocessable Entity vs 400 Bad Request?**
   - *Answer*: Use 400 for malformed requests (invalid JSON, wrong Content-Type). Use 422 for syntactically correct requests that fail business logic validation (email already exists, invalid date range).

2. **Explain the difference between 502 Bad Gateway and 504 Gateway Timeout.**
   - *Answer*: 502 means the gateway received an invalid response from upstream server (e.g., upstream returned HTML instead of JSON). 504 means the gateway didn't receive any response from upstream within timeout period.

3. **Why is exponential backoff with jitter better than simple exponential backoff?**
   - *Answer*: Jitter adds randomness to retry delays, preventing "thundering herd" problem where many clients retry simultaneously after the same delay, potentially overwhelming the recovering server.

4. **What is a circuit breaker pattern and when should you use it?**
   - *Answer*: Circuit breaker prevents cascading failures by stopping requests to failing services. After threshold failures, circuit "opens" (rejects requests immediately), then "half-opens" (tests with single request), and "closes" (resumes normal operation) if successful. Use for external dependencies.

5. **How do you handle partial failures in a microservices architecture?**
   - *Answer*: Use fallback mechanisms (cached data, default values), implement timeouts, use circuit breakers, return partial responses with status indicators, and design for graceful degradation rather than complete failure.

---

**Next Step**: [API Testing & DevOps Integration →](./API-Testing-DevOps-Ref.md)
