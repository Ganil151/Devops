# 🏆 API Best Practices Reference
*Version 1.0 | Production-Grade API Design and Implementation*

---

## 📖 Overview
Building APIs is easy. Building **good** APIs that scale, remain maintainable, and delight developers is an art. This reference distills industry best practices from companies like Stripe, GitHub, AWS, and Google into actionable guidelines.

**Philosophy**: "Design for developers, optimize for operations, secure by default."

---

## 🎯 API Design Principles

### 1. Developer Experience First

**Principle**: Your API is a product. Treat API consumers as customers.

**Best Practices**:
```
✅ Intuitive naming (users, not usr or u)
✅ Consistent patterns across all endpoints
✅ Comprehensive documentation with examples
✅ Interactive API explorer (Swagger/OpenAPI)
✅ Clear error messages with actionable guidance
✅ SDKs in popular languages
```

**Example - Good vs Bad**:
```http
❌ Bad: Inconsistent naming
GET /api/getUsers
POST /api/user/create
DELETE /api/remove_user/42

✅ Good: RESTful consistency
GET /api/users
POST /api/users
DELETE /api/users/42
```

---

### 2. API Versioning Strategy

**Principle**: Never break existing clients. Versioning is mandatory.

**Versioning Approaches**:

#### a) URI Versioning (Recommended)
```
https://api.example.com/v1/users
https://api.example.com/v2/users
```

**Pros**: 
- ✅ Explicit and visible
- ✅ Easy to route and cache
- ✅ Simple for clients

**Cons**:
- ❌ Pollutes URI space

#### b) Header Versioning
```http
GET /api/users HTTP/1.1
Accept: application/vnd.example.v2+json
```

**Pros**:
- ✅ Clean URIs
- ✅ Content negotiation

**Cons**:
- ❌ Less visible
- ❌ Harder to test in browser

#### c) Query Parameter (Not Recommended)
```
https://api.example.com/users?version=2
```

**Cons**:
- ❌ Caching issues
- ❌ Easy to forget

**Versioning Best Practices**:
```python
# Semantic versioning for APIs
v1.0.0 → v1.1.0  # Backward compatible (new features)
v1.1.0 → v2.0.0  # Breaking changes

# Deprecation timeline
1. Announce deprecation (6 months notice)
2. Add deprecation headers
3. Provide migration guide
4. Sunset old version
```

**Deprecation Header**:
```http
HTTP/1.1 200 OK
Deprecation: Sun, 26 Jul 2026 12:00:00 GMT
Sunset: Sun, 26 Jan 2027 12:00:00 GMT
Link: <https://docs.example.com/migration/v1-to-v2>; rel="deprecation"
```

---

### 3. Pagination Strategy

**Principle**: Never return unbounded collections.

#### Offset-Based Pagination
```http
GET /api/users?limit=20&offset=40 HTTP/1.1

Response:
{
  "data": [...],
  "pagination": {
    "limit": 20,
    "offset": 40,
    "total": 1000,
    "has_more": true,
    "next": "/api/users?limit=20&offset=60",
    "prev": "/api/users?limit=20&offset=20"
  }
}
```

**Pros**: Simple, allows jumping to specific pages  
**Cons**: Inconsistent with real-time data (items added/removed)

#### Cursor-Based Pagination (Recommended for Real-Time)
```http
GET /api/users?limit=20&cursor=eyJpZCI6NDJ9 HTTP/1.1

Response:
{
  "data": [...],
  "pagination": {
    "limit": 20,
    "next_cursor": "eyJpZCI6NjJ9",
    "has_more": true
  }
}
```

**Pros**: Consistent results, efficient for large datasets  
**Cons**: Can't jump to arbitrary page

**Implementation Example**:
```python
from flask import Flask, request, jsonify
import base64
import json

app = Flask(__name__)

@app.route('/api/users')
def get_users():
    limit = int(request.args.get('limit', 20))
    cursor = request.args.get('cursor')
    
    # Decode cursor
    if cursor:
        decoded = json.loads(base64.b64decode(cursor))
        last_id = decoded['id']
        users = User.query.filter(User.id > last_id).limit(limit + 1).all()
    else:
        users = User.query.limit(limit + 1).all()
    
    # Check if more results
    has_more = len(users) > limit
    if has_more:
        users = users[:limit]
    
    # Create next cursor
    next_cursor = None
    if has_more:
        next_cursor = base64.b64encode(
            json.dumps({'id': users[-1].id}).encode()
        ).decode()
    
    return jsonify({
        'data': [u.to_dict() for u in users],
        'pagination': {
            'limit': limit,
            'next_cursor': next_cursor,
            'has_more': has_more
        }
    })
```

---

### 4. Filtering, Sorting, and Field Selection

**Filtering**:
```http
GET /api/servers?status=running&region=us-east-1&type=web HTTP/1.1
```

**Sorting**:
```http
# Single field
GET /api/users?sort=created_at HTTP/1.1

# Descending (prefix with -)
GET /api/users?sort=-created_at HTTP/1.1

# Multiple fields
GET /api/users?sort=role,-created_at HTTP/1.1
```

**Field Selection (Sparse Fieldsets)**:
```http
GET /api/users/42?fields=id,username,email HTTP/1.1

Response:
{
  "id": 42,
  "username": "devops_engineer",
  "email": "engineer@example.com"
  // Other fields omitted
}
```

**Implementation**:
```python
@app.route('/api/users')
def get_users():
    query = User.query
    
    # Filtering
    if status := request.args.get('status'):
        query = query.filter(User.status == status)
    if region := request.args.get('region'):
        query = query.filter(User.region == region)
    
    # Sorting
    if sort := request.args.get('sort'):
        for field in sort.split(','):
            if field.startswith('-'):
                query = query.order_by(getattr(User, field[1:]).desc())
            else:
                query = query.order_by(getattr(User, field))
    
    users = query.all()
    
    # Field selection
    if fields := request.args.get('fields'):
        field_list = fields.split(',')
        return jsonify([
            {k: v for k, v in u.to_dict().items() if k in field_list}
            for u in users
        ])
    
    return jsonify([u.to_dict() for u in users])
```

---

## 🔐 Security Best Practices

### 1. Authentication & Authorization

**Always Use HTTPS**:
```python
# Force HTTPS in production
from flask import Flask, redirect, request

app = Flask(__name__)

@app.before_request
def force_https():
    if not request.is_secure and app.env == 'production':
        url = request.url.replace('http://', 'https://', 1)
        return redirect(url, code=301)
```

**Implement Rate Limiting**:
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="redis://localhost:6379"
)

@app.route('/api/login')
@limiter.limit("5 per minute")
def login():
    # Login logic
    pass

@app.route('/api/users')
@limiter.limit("100 per minute")
def get_users():
    # Users logic
    pass
```

**Rate Limit Headers**:
```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1643200000
```

### 2. Input Validation

**Never Trust Client Input**:
```python
from marshmallow import Schema, fields, validate, ValidationError

class UserCreateSchema(Schema):
    username = fields.Str(
        required=True,
        validate=[
            validate.Length(min=3, max=50),
            validate.Regexp(r'^[a-zA-Z0-9_]+$', error='Only alphanumeric and underscore')
        ]
    )
    email = fields.Email(required=True)
    age = fields.Int(validate=validate.Range(min=0, max=150))
    role = fields.Str(validate=validate.OneOf(['user', 'admin', 'moderator']))

@app.route('/api/users', methods=['POST'])
def create_user():
    schema = UserCreateSchema()
    
    try:
        data = schema.load(request.json)
    except ValidationError as err:
        return jsonify({
            'error': {
                'code': 'VALIDATION_ERROR',
                'message': 'Request validation failed',
                'details': err.messages
            }
        }), 422
    
    # Create user with validated data
    user = User(**data)
    db.session.add(user)
    db.session.commit()
    
    return jsonify(user.to_dict()), 201
```

### 3. SQL Injection Prevention

**Always Use Parameterized Queries**:
```python
# ❌ NEVER DO THIS (SQL Injection vulnerable)
user_id = request.args.get('id')
query = f"SELECT * FROM users WHERE id = {user_id}"
db.execute(query)

# ✅ Use parameterized queries
user_id = request.args.get('id')
query = "SELECT * FROM users WHERE id = :id"
db.execute(query, {'id': user_id})

# ✅ Or use ORM
user = User.query.filter_by(id=user_id).first()
```

### 4. CORS Configuration

**Restrict Origins**:
```python
from flask_cors import CORS

# ❌ Bad: Allow all origins
CORS(app, origins="*")

# ✅ Good: Whitelist specific origins
CORS(app, resources={
    r"/api/*": {
        "origins": [
            "https://app.example.com",
            "https://admin.example.com"
        ],
        "methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Content-Type", "Authorization"],
        "expose_headers": ["X-Request-ID"],
        "max_age": 3600
    }
})
```

### 5. Security Headers

**Essential Headers**:
```python
@app.after_request
def set_security_headers(response):
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    return response
```

---

## 📊 Performance Best Practices

### 1. Caching Strategy

**HTTP Caching**:
```python
from flask import make_response
from datetime import datetime, timedelta

@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    
    response = make_response(jsonify(user.to_dict()))
    
    # Cache for 1 hour
    response.headers['Cache-Control'] = 'public, max-age=3600'
    
    # ETag for conditional requests
    etag = hashlib.md5(json.dumps(user.to_dict()).encode()).hexdigest()
    response.headers['ETag'] = f'"{etag}"'
    
    # Last-Modified
    response.headers['Last-Modified'] = user.updated_at.strftime('%a, %d %b %Y %H:%M:%S GMT')
    
    return response
```

**Conditional Requests**:
```python
@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    
    # Check If-None-Match (ETag)
    etag = hashlib.md5(json.dumps(user.to_dict()).encode()).hexdigest()
    if request.headers.get('If-None-Match') == f'"{etag}"':
        return '', 304
    
    # Check If-Modified-Since
    if if_modified := request.headers.get('If-Modified-Since'):
        if_modified_dt = datetime.strptime(if_modified, '%a, %d %b %Y %H:%M:%S GMT')
        if user.updated_at <= if_modified_dt:
            return '', 304
    
    response = make_response(jsonify(user.to_dict()))
    response.headers['ETag'] = f'"{etag}"'
    response.headers['Last-Modified'] = user.updated_at.strftime('%a, %d %b %Y %H:%M:%S GMT')
    
    return response
```

### 2. Database Query Optimization

**N+1 Query Problem**:
```python
# ❌ Bad: N+1 queries
users = User.query.all()
for user in users:
    print(user.orders)  # Separate query for each user

# ✅ Good: Eager loading
users = User.query.options(joinedload(User.orders)).all()
for user in users:
    print(user.orders)  # No additional queries
```

**Pagination at Database Level**:
```python
# ✅ Limit results in database, not in Python
users = User.query.limit(20).offset(40).all()

# ❌ Don't do this
all_users = User.query.all()
users = all_users[40:60]
```

### 3. Compression

**Enable Gzip Compression**:
```python
from flask_compress import Compress

app = Flask(__name__)
Compress(app)

# Configure compression
app.config['COMPRESS_MIMETYPES'] = [
    'text/html',
    'text/css',
    'text/javascript',
    'application/json',
    'application/javascript'
]
app.config['COMPRESS_LEVEL'] = 6
app.config['COMPRESS_MIN_SIZE'] = 500
```

### 4. Async Operations for Long-Running Tasks

**Use Background Jobs**:
```python
from celery import Celery

celery = Celery('tasks', broker='redis://localhost:6379')

@celery.task
def process_large_file(file_id):
    # Long-running task
    file = File.query.get(file_id)
    # Process file...
    file.status = 'completed'
    db.session.commit()

@app.route('/api/files', methods=['POST'])
def upload_file():
    # Save file
    file = File(status='pending')
    db.session.add(file)
    db.session.commit()
    
    # Queue background task
    task = process_large_file.delay(file.id)
    
    return jsonify({
        'id': file.id,
        'status': 'pending',
        'task_id': task.id,
        'status_url': f'/api/files/{file.id}/status'
    }), 202
```

---

## 🎯 Idempotency Best Practices

**Implement Idempotency Keys**:
```python
import redis

redis_client = redis.Redis(host='localhost', port=6379, db=0)

@app.route('/api/payments', methods=['POST'])
def create_payment():
    idempotency_key = request.headers.get('Idempotency-Key')
    
    if not idempotency_key:
        return jsonify({
            'error': {
                'code': 'MISSING_IDEMPOTENCY_KEY',
                'message': 'Idempotency-Key header required for payment operations'
            }
        }), 400
    
    # Check if already processed
    cached_response = redis_client.get(f'idempotency:{idempotency_key}')
    if cached_response:
        return jsonify(json.loads(cached_response)), 200
    
    # Process payment
    payment = process_payment(request.json)
    
    # Cache result for 24 hours
    redis_client.setex(
        f'idempotency:{idempotency_key}',
        86400,
        json.dumps(payment.to_dict())
    )
    
    return jsonify(payment.to_dict()), 201
```

---

## 📝 Documentation Best Practices

### 1. OpenAPI/Swagger Specification

```yaml
openapi: 3.0.0
info:
  title: User Management API
  version: 1.0.0
  description: API for managing users in the system

servers:
  - url: https://api.example.com/v1
    description: Production server
  - url: https://staging-api.example.com/v1
    description: Staging server

paths:
  /users:
    get:
      summary: List all users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            minimum: 1
            maximum: 100
        - name: offset
          in: query
          schema:
            type: integer
            default: 0
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
          example: 42
        username:
          type: string
          example: devops_engineer
        email:
          type: string
          format: email
          example: engineer@example.com
        created_at:
          type: string
          format: date-time
```

### 2. Code Examples in Documentation

**Provide examples in multiple languages**:
```markdown
## Create User

### Request
```http
POST /api/users HTTP/1.1
Content-Type: application/json
Authorization: Bearer token

{
  "username": "new_user",
  "email": "user@example.com"
}
```

### Python
```python
import requests

response = requests.post(
    'https://api.example.com/users',
    json={'username': 'new_user', 'email': 'user@example.com'},
    headers={'Authorization': 'Bearer token'}
)
```

### curl
```bash
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token" \
  -d '{"username":"new_user","email":"user@example.com"}'
```
```

---

## 🛡️ SRE Standard Checklist

### Design
- [ ] **RESTful naming** (plural nouns, no verbs in URIs)
- [ ] **Versioning strategy** implemented from day one
- [ ] **Pagination** on all collection endpoints
- [ ] **Filtering and sorting** support
- [ ] **Field selection** for large resources

### Security
- [ ] **HTTPS only** in production
- [ ] **Authentication** on all protected endpoints
- [ ] **Rate limiting** to prevent abuse
- [ ] **Input validation** on all user inputs
- [ ] **CORS** properly configured
- [ ] **Security headers** set

### Performance
- [ ] **Database query optimization** (no N+1 queries)
- [ ] **HTTP caching** with ETags and Cache-Control
- [ ] **Compression** enabled (gzip)
- [ ] **Async operations** for long-running tasks
- [ ] **Connection pooling** for databases

### Reliability
- [ ] **Idempotency** for non-safe operations
- [ ] **Retry logic** with exponential backoff
- [ ] **Circuit breakers** for external dependencies
- [ ] **Health check** endpoints
- [ ] **Graceful degradation** on partial failures

### Observability
- [ ] **Request ID** in all requests/responses
- [ ] **Structured logging** with context
- [ ] **Metrics** (latency, error rate, throughput)
- [ ] **Distributed tracing** (OpenTelemetry)
- [ ] **Error tracking** (Sentry, Rollbar)

### Documentation
- [ ] **OpenAPI/Swagger** specification
- [ ] **Code examples** in multiple languages
- [ ] **Error codes** documented
- [ ] **Changelog** maintained
- [ ] **Migration guides** for breaking changes

---

## ❓ Interview "Deep-Cut" Questions

1. **How do you handle API versioning without breaking existing clients?**
   - *Answer*: Use URI versioning (/v1/, /v2/), maintain old versions during deprecation period, provide migration guides, use deprecation headers (Deprecation, Sunset), give 6-12 months notice, and ensure backward compatibility within major versions.

2. **Explain the difference between offset-based and cursor-based pagination. When would you use each?**
   - *Answer*: Offset-based allows jumping to specific pages but can be inconsistent with real-time data. Cursor-based provides consistent results and is efficient for large datasets but doesn't allow arbitrary page jumps. Use offset for static data with page numbers, cursor for real-time feeds and infinite scroll.

3. **What is the N+1 query problem and how do you prevent it?**
   - *Answer*: N+1 occurs when fetching a collection requires 1 query for the collection plus N queries for related data. Prevent with eager loading (joinedload in SQLAlchemy), select_related/prefetch_related in Django, or GraphQL DataLoader pattern.

4. **How do you implement idempotency for payment operations?**
   - *Answer*: Require Idempotency-Key header (UUID), store operation result in cache (Redis) with key as identifier, check cache before processing, return cached result for duplicate requests, set TTL (24-48 hours), and handle concurrent requests with locks.

5. **Explain how ETags improve API performance.**
   - *Answer*: ETags are resource version identifiers. Client sends If-None-Match header with ETag on subsequent requests. Server returns 304 Not Modified if unchanged, saving bandwidth and processing. Reduces latency and server load for frequently accessed, rarely changed resources.

---

**Next Step**: [HTTP Protocol Fundamentals →](./HTTP-Protocol-Ref.md)
