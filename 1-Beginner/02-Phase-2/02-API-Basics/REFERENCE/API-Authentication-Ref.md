# 🔐 API Authentication & Security Reference
*Version 1.0 | Securing Machine-to-Machine Communication*

---

## 📖 Overview
In a zero-trust world, every API request must prove its identity and authorization. This reference covers authentication mechanisms, authorization patterns, and security best practices for production APIs.

**Key Principle**: "Never trust, always verify."

---

## 🔑 Authentication vs Authorization

### Authentication (AuthN)
**Question**: "Who are you?"  
**Purpose**: Verify the identity of the requester  
**Result**: User/service identity established

### Authorization (AuthZ)
**Question**: "What are you allowed to do?"  
**Purpose**: Determine permissions for authenticated identity  
**Result**: Access granted or denied

**Example**:
```
Authentication: User proves they are "alice@example.com" with password
Authorization: System checks if alice@example.com can DELETE /users/42
```

---

## 🛡️ Authentication Mechanisms

### 1. API Keys

**How it works**: Client includes secret key in request header or query parameter.

**Request**:
```http
GET /api/users HTTP/1.1
X-API-Key: sk_live_51H8K2jL4Kz9X3Y7m8N6P5Q4R3S2T1U0
```

**Pros**:
- ✅ Simple to implement
- ✅ Easy to revoke
- ✅ Good for server-to-server communication

**Cons**:
- ❌ No expiration (unless manually rotated)
- ❌ If leaked, valid until revoked
- ❌ No user context (service-level only)

**Best Practices**:
```python
# ✅ Good: Header-based
headers = {'X-API-Key': os.environ['API_KEY']}
requests.get(url, headers=headers)

# ❌ Bad: Query parameter (logged in URLs)
requests.get(f'{url}?api_key={api_key}')
```

**DevOps Use Case**: CI/CD pipelines, monitoring tools, infrastructure automation

---

### 2. HTTP Basic Authentication

**How it works**: Username and password encoded in Base64, sent in `Authorization` header.

**Request**:
```http
GET /api/users HTTP/1.1
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

**Encoding**:
```python
import base64

credentials = "username:password"
encoded = base64.b64encode(credentials.encode()).decode()
# Result: dXNlcm5hbWU6cGFzc3dvcmQ=
```

**Pros**:
- ✅ Simple, widely supported
- ✅ Built into HTTP standard

**Cons**:
- ❌ Credentials sent with every request
- ❌ Base64 is encoding, NOT encryption
- ❌ **REQUIRES HTTPS** (credentials visible otherwise)

**Use Case**: Internal tools, development environments, legacy systems

---

### 3. Bearer Tokens (JWT)

**How it works**: Client obtains token from auth server, includes in subsequent requests.

**Request**:
```http
GET /api/users HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**JWT Structure**:
```
Header.Payload.Signature

Header (Base64):
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload (Base64):
{
  "sub": "1234567890",
  "name": "John Doe",
  "iat": 1516239022,
  "exp": 1516242622,
  "roles": ["admin", "user"]
}

Signature:
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret
)
```

**Pros**:
- ✅ Self-contained (no database lookup needed)
- ✅ Includes user context and permissions
- ✅ Expiration built-in
- ✅ Can be verified without auth server

**Cons**:
- ❌ Cannot be revoked before expiration (without blacklist)
- ❌ Larger than API keys
- ❌ Payload is readable (Base64, not encrypted)

**Python Example**:
```python
import jwt
from datetime import datetime, timedelta

# Create token
payload = {
    'sub': 'user_id_123',
    'name': 'DevOps Engineer',
    'exp': datetime.utcnow() + timedelta(hours=1),
    'iat': datetime.utcnow(),
    'roles': ['admin']
}
token = jwt.encode(payload, 'secret_key', algorithm='HS256')

# Verify token
try:
    decoded = jwt.decode(token, 'secret_key', algorithms=['HS256'])
    print(decoded)
except jwt.ExpiredSignatureError:
    print("Token expired")
except jwt.InvalidTokenError:
    print("Invalid token")
```

**DevOps Use Case**: Microservices authentication, user sessions, mobile apps

---

### 4. OAuth 2.0

**How it works**: Delegated authorization framework allowing third-party access without sharing credentials.

**Flow Types**:

#### a) Authorization Code Flow (Web Apps)
```mermaid
sequenceDiagram
    participant User
    participant Client
    participant AuthServer
    participant ResourceServer

    User->>Client: Click "Login with Google"
    Client->>AuthServer: Redirect to /authorize
    AuthServer->>User: Login page
    User->>AuthServer: Enter credentials
    AuthServer->>Client: Redirect with auth code
    Client->>AuthServer: Exchange code for token
    AuthServer->>Client: Access token + Refresh token
    Client->>ResourceServer: API request with token
    ResourceServer->>Client: Protected resource
```

#### b) Client Credentials Flow (Service-to-Service)
```python
import requests

# Get token
token_response = requests.post(
    'https://auth.example.com/oauth/token',
    data={
        'grant_type': 'client_credentials',
        'client_id': 'your_client_id',
        'client_secret': 'your_client_secret',
        'scope': 'read:users write:users'
    }
)
access_token = token_response.json()['access_token']

# Use token
api_response = requests.get(
    'https://api.example.com/users',
    headers={'Authorization': f'Bearer {access_token}'}
)
```

**OAuth 2.0 Roles**:
- **Resource Owner**: User who owns the data
- **Client**: Application requesting access
- **Authorization Server**: Issues tokens
- **Resource Server**: Hosts protected resources

**Scopes**: Define permission granularity
```
read:users write:users delete:users admin:*
```

**Pros**:
- ✅ Industry standard
- ✅ Delegated authorization
- ✅ Refresh tokens for long-lived access
- ✅ Fine-grained scopes

**Cons**:
- ❌ Complex to implement
- ❌ Multiple flows for different use cases
- ❌ Requires HTTPS

**DevOps Use Case**: GitHub Actions, cloud provider APIs, third-party integrations

---

### 5. Mutual TLS (mTLS)

**How it works**: Both client and server authenticate each other using X.509 certificates.

**Standard TLS**: Server proves identity to client  
**mTLS**: Client also proves identity to server

**Request**:
```python
import requests

response = requests.get(
    'https://api.example.com/users',
    cert=('/path/to/client.crt', '/path/to/client.key'),
    verify='/path/to/ca.crt'
)
```

**Pros**:
- ✅ Strongest authentication (cryptographic)
- ✅ No credentials in application code
- ✅ Certificate-based identity

**Cons**:
- ❌ Complex certificate management
- ❌ Requires PKI infrastructure
- ❌ Difficult to rotate certificates

**DevOps Use Case**: Service mesh (Istio, Linkerd), Kubernetes API, high-security environments

---

## 🎯 Authorization Patterns

### 1. Role-Based Access Control (RBAC)

**Concept**: Users assigned roles, roles have permissions.

**Example**:
```json
{
  "user": "alice@example.com",
  "roles": ["developer", "on-call"],
  "permissions": {
    "developer": ["read:code", "write:code"],
    "on-call": ["read:logs", "restart:services"]
  }
}
```

**Implementation**:
```python
def check_permission(user, required_permission):
    user_permissions = []
    for role in user['roles']:
        user_permissions.extend(ROLE_PERMISSIONS[role])
    return required_permission in user_permissions
```

### 2. Attribute-Based Access Control (ABAC)

**Concept**: Access based on attributes (user, resource, environment).

**Example**:
```python
# Policy: Users can only delete their own resources
if user.id == resource.owner_id:
    allow_delete()

# Policy: Only allow access during business hours
if 9 <= current_hour <= 17:
    allow_access()
```

### 3. Policy-Based (OPA - Open Policy Agent)

**Rego Policy**:
```rego
package api.authz

default allow = false

allow {
    input.method == "GET"
    input.path[0] == "users"
    input.user.roles[_] == "viewer"
}

allow {
    input.method == "DELETE"
    input.path[0] == "users"
    input.user.roles[_] == "admin"
}
```

---

## 🚀 Security Best Practices

### 1. Token Storage

**❌ Never**:
```javascript
// Don't store in localStorage (XSS vulnerable)
localStorage.setItem('token', jwt_token);

// Don't store in cookies without httpOnly flag
document.cookie = `token=${jwt_token}`;
```

**✅ Best**:
```javascript
// Use httpOnly, secure cookies
Set-Cookie: token=xyz; HttpOnly; Secure; SameSite=Strict

// Or use secure session storage for SPAs
sessionStorage.setItem('token', jwt_token);
```

### 2. Token Expiration

**Short-lived access tokens + Refresh tokens**:
```python
{
    "access_token": "eyJ...",  # Expires in 15 minutes
    "refresh_token": "abc...", # Expires in 7 days
    "expires_in": 900
}
```

### 3. Rate Limiting

**Prevent brute force and abuse**:
```python
from flask_limiter import Limiter

limiter = Limiter(
    app,
    key_func=lambda: request.headers.get('X-API-Key'),
    default_limits=["100 per hour"]
)

@app.route('/api/login')
@limiter.limit("5 per minute")
def login():
    # Login logic
    pass
```

### 4. Input Validation

**Never trust client input**:
```python
from marshmallow import Schema, fields, validate

class UserSchema(Schema):
    email = fields.Email(required=True)
    age = fields.Integer(validate=validate.Range(min=0, max=150))
    role = fields.String(validate=validate.OneOf(['user', 'admin']))

# Validate
schema = UserSchema()
errors = schema.validate(request_data)
if errors:
    return {"error": errors}, 400
```

### 5. CORS Configuration

**Restrict cross-origin access**:
```python
from flask_cors import CORS

# ❌ Bad: Allow all origins
CORS(app, origins="*")

# ✅ Good: Whitelist specific origins
CORS(app, origins=[
    "https://app.example.com",
    "https://admin.example.com"
])
```

### 6. Security Headers

**Essential headers**:
```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

---

## 🛡️ SRE Standard Checklist
- [ ] **HTTPS everywhere** (no HTTP in production)
- [ ] **Rotate secrets regularly** (API keys, tokens)
- [ ] **Use short-lived tokens** (15-60 minutes)
- [ ] **Implement refresh token rotation**
- [ ] **Rate limit authentication endpoints** (prevent brute force)
- [ ] **Log authentication failures** (security monitoring)
- [ ] **Validate all inputs** (prevent injection attacks)
- [ ] **Use environment variables** for secrets (never hardcode)
- [ ] **Implement CORS properly** (whitelist origins)
- [ ] **Add security headers** (HSTS, CSP, etc.)

---

## ❓ Interview "Deep-Cut" Questions

1. **Explain the difference between symmetric and asymmetric JWT signing. When would you use each?**
   - *Answer*: Symmetric (HS256) uses same secret for signing and verification (faster, simpler). Asymmetric (RS256) uses private key for signing, public key for verification (better for distributed systems where multiple services verify tokens but shouldn't be able to create them).

2. **What is the purpose of a refresh token, and why not just use long-lived access tokens?**
   - *Answer*: Refresh tokens allow obtaining new access tokens without re-authentication. Short-lived access tokens limit exposure window if compromised. Refresh tokens can be revoked, while JWTs cannot (without blacklist).

3. **Explain the OAuth 2.0 PKCE extension and why it's critical for mobile apps.**
   - *Answer*: PKCE (Proof Key for Code Exchange) prevents authorization code interception attacks. Client generates random code_verifier, sends SHA256 hash (code_challenge) with auth request. When exchanging code for token, sends original code_verifier. Prevents malicious apps from intercepting auth codes.

4. **How do you securely store API keys in a CI/CD pipeline?**
   - *Answer*: Use secret management systems (GitHub Secrets, AWS Secrets Manager, HashiCorp Vault). Never commit to version control. Rotate regularly. Use short-lived credentials when possible. Implement least-privilege access.

5. **What is the difference between CORS and CSRF, and how do you prevent each?**
   - *Answer*: CORS controls which origins can access your API (browser security). CSRF is an attack where malicious site tricks user's browser into making unwanted requests. Prevent CORS issues with proper headers. Prevent CSRF with tokens, SameSite cookies, and checking Origin/Referer headers.

---

**Next Step**: [API Error Handling & Status Codes →](./API-Error-Handling-Ref.md)
