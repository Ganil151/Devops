# 🌐 HTTP Protocol Reference
*Version 1.0 | The Foundation of Web Communication*

---

## 📖 Overview
HTTP (HyperText Transfer Protocol) is the application-layer protocol that powers the web. For DevOps engineers, understanding HTTP is critical for debugging API failures, optimizing performance, and securing service-to-service communication.

---

## 🏗️ HTTP Request Anatomy

### 1. Request Line
The first line of every HTTP request contains three components:
```
METHOD /path/to/resource HTTP/1.1
```

**Example**:
```
GET /api/v1/users/42 HTTP/1.1
```

### 2. HTTP Methods (Verbs)

| Method | Purpose | Idempotent | Safe | Common Use Case |
|--------|---------|------------|------|-----------------|
| **GET** | Retrieve resource | ✅ Yes | ✅ Yes | Fetch user data, list resources |
| **POST** | Create new resource | ❌ No | ❌ No | Create user, submit form |
| **PUT** | Replace entire resource | ✅ Yes | ❌ No | Full update of user profile |
| **PATCH** | Partial update | ⚠️ Maybe | ❌ No | Update single field (email) |
| **DELETE** | Remove resource | ✅ Yes | ❌ No | Delete user account |
| **HEAD** | GET without body | ✅ Yes | ✅ Yes | Check if resource exists |
| **OPTIONS** | Get allowed methods | ✅ Yes | ✅ Yes | CORS preflight requests |

**Key Concepts**:
- **Idempotent**: Multiple identical requests have the same effect as a single request
- **Safe**: Does not modify server state

### 3. Request Headers
Metadata about the request:

```http
GET /api/users HTTP/1.1
Host: api.example.com
User-Agent: DevOps-CLI/1.0
Accept: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
Content-Length: 142
X-Request-ID: 550e8400-e29b-41d4-a716-446655440000
```

**Critical Headers**:
- `Host`: Target server (required in HTTP/1.1)
- `Authorization`: Authentication credentials
- `Content-Type`: Format of request body
- `Accept`: Desired response format
- `User-Agent`: Client identification

### 4. Request Body
Data payload (for POST, PUT, PATCH):

```json
{
  "username": "devops_engineer",
  "email": "engineer@example.com",
  "role": "admin"
}
```

---

## 📥 HTTP Response Anatomy

### 1. Status Line
```
HTTP/1.1 200 OK
```

### 2. Response Headers
```http
HTTP/1.1 200 OK
Date: Sun, 26 Jan 2026 12:45:43 GMT
Server: nginx/1.21.0
Content-Type: application/json; charset=utf-8
Content-Length: 87
Cache-Control: max-age=3600
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
X-RateLimit-Remaining: 4999
```

### 3. Response Body
```json
{
  "id": 42,
  "username": "devops_engineer",
  "created_at": "2026-01-26T12:45:43Z"
}
```

---

## 🔢 Status Code Categories

| Range | Category | Meaning | DevOps Implication |
|-------|----------|---------|-------------------|
| 1xx | Informational | Request received, continuing | Rare in REST APIs |
| 2xx | Success | Request successful | Expected happy path |
| 3xx | Redirection | Further action needed | Handle redirects in automation |
| 4xx | Client Error | Bad request from client | Fix your code/config |
| 5xx | Server Error | Server failed | Retry with backoff |

**Most Common Codes**:
- `200 OK`: Success
- `201 Created`: Resource created successfully
- `204 No Content`: Success with no response body
- `400 Bad Request`: Invalid syntax/validation error
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Authenticated but not authorized
- `404 Not Found`: Resource doesn't exist
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server-side failure
- `502 Bad Gateway`: Upstream server error
- `503 Service Unavailable`: Server overloaded/maintenance
- `504 Gateway Timeout`: Upstream timeout

---

## 🔐 HTTPS vs HTTP

### HTTP (Port 80)
- **Unencrypted**: Data sent in plaintext
- **Vulnerable**: Man-in-the-middle attacks
- **Use Case**: Local development only

### HTTPS (Port 443)
- **Encrypted**: TLS/SSL encryption
- **Secure**: Certificate-based authentication
- **Required**: Production APIs, sensitive data

**TLS Handshake Process**:
1. Client sends supported cipher suites
2. Server responds with certificate
3. Client verifies certificate against CA
4. Symmetric encryption key negotiated
5. Encrypted communication begins

---

## ⚙️ HTTP Versions

### HTTP/1.1 (1997)
- **Persistent Connections**: Keep-alive by default
- **Chunked Transfer**: Stream large responses
- **Host Header**: Virtual hosting support
- **Limitation**: Head-of-line blocking

### HTTP/2 (2015)
- **Multiplexing**: Multiple requests over single connection
- **Server Push**: Proactive resource sending
- **Header Compression**: HPACK algorithm
- **Binary Protocol**: More efficient parsing

### HTTP/3 (2022)
- **QUIC Transport**: UDP-based (not TCP)
- **Faster Handshake**: 0-RTT connection establishment
- **Better Mobile**: Resilient to network changes

---

## 🚀 DevOps Best Practices

### 1. Timeout Configuration
Always set timeouts to prevent hanging requests:
```python
import requests

response = requests.get(
    'https://api.example.com/users',
    timeout=(3.05, 27)  # (connect timeout, read timeout)
)
```

### 2. Retry Logic with Exponential Backoff
```python
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

retry_strategy = Retry(
    total=3,
    status_forcelist=[429, 500, 502, 503, 504],
    backoff_factor=1  # 1s, 2s, 4s
)
adapter = HTTPAdapter(max_retries=retry_strategy)
session = requests.Session()
session.mount("https://", adapter)
```

### 3. Connection Pooling
Reuse connections for better performance:
```python
session = requests.Session()
# Reuse session for multiple requests
session.get('https://api.example.com/endpoint1')
session.get('https://api.example.com/endpoint2')
```

### 4. Request ID Tracking
Include unique IDs for distributed tracing:
```python
import uuid

headers = {
    'X-Request-ID': str(uuid.uuid4())
}
response = requests.get(url, headers=headers)
```

---

## 🛡️ SRE Standard Checklist
- [ ] **Always use HTTPS** in production environments
- [ ] **Set appropriate timeouts** (connect and read)
- [ ] **Implement retry logic** for transient failures (5xx, 429)
- [ ] **Log request/response** for debugging (sanitize sensitive data)
- [ ] **Validate SSL certificates** (don't disable verification)
- [ ] **Use connection pooling** for high-throughput scenarios
- [ ] **Include User-Agent** header for API analytics
- [ ] **Handle redirects** explicitly in automation scripts

---

## ❓ Interview "Deep-Cut" Questions

1. **Explain the difference between `401 Unauthorized` and `403 Forbidden`. When would you use each?**
   - *Answer*: `401` means authentication is required or failed (missing/invalid credentials). `403` means the user is authenticated but lacks permission to access the resource. Use `401` when credentials are missing/wrong, `403` when the user is logged in but not authorized.

2. **What is "Connection Keep-Alive" and why is it important for API performance?**
   - *Answer*: Keep-Alive allows multiple HTTP requests/responses over a single TCP connection, avoiding the overhead of establishing new connections for each request. Critical for reducing latency in high-frequency API calls.

3. **Describe the difference between PUT and PATCH. Why does idempotency matter?**
   - *Answer*: PUT replaces the entire resource (idempotent), while PATCH applies partial modifications (may or may not be idempotent depending on implementation). Idempotency ensures retries don't cause unintended side effects.

4. **What is the purpose of the `OPTIONS` HTTP method?**
   - *Answer*: Used for CORS preflight requests to determine which HTTP methods and headers are allowed for cross-origin requests. Also used to discover API capabilities.

5. **Explain HTTP/2 multiplexing and how it solves HTTP/1.1's head-of-line blocking.**
   - *Answer*: HTTP/2 allows multiple requests/responses to be interleaved over a single TCP connection using streams. This eliminates HTTP/1.1's head-of-line blocking where a slow request blocks subsequent requests on the same connection.

---

**Next Step**: [REST Architecture Principles →](./rest-architecture-ref.md)
