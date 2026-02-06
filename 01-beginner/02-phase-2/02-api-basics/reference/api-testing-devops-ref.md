# 🧪 API Testing & DevOps Integration Reference
*Version 1.0 | From Development to Production*

---

## 📖 Overview
APIs are the contracts between services. In DevOps, testing these contracts and integrating them into CI/CD pipelines ensures reliability, prevents regressions, and enables confident deployments.

**Philosophy**: "Test early, test often, automate everything."

---

## 🧪 API Testing Pyramid

```
                    /\
                   /  \
                  / E2E \          ← Few, slow, expensive
                 /______\
                /        \
               / Contract \        ← Medium coverage
              /____________\
             /              \
            / Integration    \    ← More tests
           /__________________\
          /                    \
         /    Unit Tests        \ ← Most tests, fast
        /________________________\
```

### 1. Unit Tests
**Scope**: Individual functions/methods  
**Speed**: Milliseconds  
**Coverage**: High (80%+)

```python
# Example: Testing a validation function
import pytest
from api.validators import validate_email

def test_validate_email_valid():
    assert validate_email("user@example.com") == True

def test_validate_email_invalid():
    assert validate_email("not-an-email") == False

def test_validate_email_empty():
    with pytest.raises(ValueError):
        validate_email("")
```

### 2. Integration Tests
**Scope**: Multiple components working together  
**Speed**: Seconds  
**Coverage**: Medium (40-60%)

```python
# Example: Testing database integration
import pytest
from api.models import User
from api.database import db

@pytest.fixture
def test_db():
    db.create_all()
    yield db
    db.drop_all()

def test_create_user(test_db):
    user = User(username="test_user", email="test@example.com")
    test_db.session.add(user)
    test_db.session.commit()
    
    retrieved = User.query.filter_by(username="test_user").first()
    assert retrieved is not None
    assert retrieved.email == "test@example.com"
```

### 3. Contract Tests
**Scope**: API contracts between services  
**Speed**: Seconds  
**Coverage**: Critical endpoints

```python
# Example: Using Pact for contract testing
from pact import Consumer, Provider

pact = Consumer('UserService').has_pact_with(Provider('AuthService'))

def test_get_user_token():
    expected = {
        'token': 'abc123',
        'expires_in': 3600
    }
    
    (pact
     .given('user exists')
     .upon_receiving('a request for user token')
     .with_request('POST', '/auth/token')
     .will_respond_with(200, body=expected))
    
    with pact:
        result = auth_client.get_token(user_id=42)
        assert result['token'] == 'abc123'
```

### 4. End-to-End Tests
**Scope**: Full user workflows  
**Speed**: Minutes  
**Coverage**: Critical paths only

```python
# Example: E2E test for user registration flow
def test_user_registration_flow():
    # 1. Register user
    response = requests.post(f'{API_BASE}/users', json={
        'username': 'new_user',
        'email': 'new@example.com',
        'password': 'SecurePass123!'
    })
    assert response.status_code == 201
    user_id = response.json()['id']
    
    # 2. Verify email sent (check email service)
    # 3. Activate account
    # 4. Login
    # 5. Access protected resource
```

---

## 🛠️ API Testing Tools

### 1. Pytest (Python)

**Installation**:
```bash
pip install pytest pytest-cov requests-mock
```

**Basic API Test**:
```python
import pytest
import requests

BASE_URL = "https://api.example.com"

@pytest.fixture
def api_client():
    """Reusable API client with authentication"""
    session = requests.Session()
    session.headers.update({'Authorization': 'Bearer test_token'})
    return session

def test_get_users(api_client):
    response = api_client.get(f'{BASE_URL}/users')
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_user(api_client):
    payload = {
        'username': 'test_user',
        'email': 'test@example.com'
    }
    response = api_client.post(f'{BASE_URL}/users', json=payload)
    assert response.status_code == 201
    assert response.json()['username'] == 'test_user'

def test_get_nonexistent_user(api_client):
    response = api_client.get(f'{BASE_URL}/users/99999')
    assert response.status_code == 404
```

**Mocking External APIs**:
```python
import requests_mock

def test_external_api_call():
    with requests_mock.Mocker() as m:
        m.get('https://external-api.com/data', json={'status': 'ok'})
        
        response = requests.get('https://external-api.com/data')
        assert response.json()['status'] == 'ok'
```

### 2. Postman / Newman

**Collection Example** (`api-tests.json`):
```json
{
  "info": {
    "name": "User API Tests",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Get Users",
      "event": [
        {
          "listen": "test",
          "script": {
            "exec": [
              "pm.test('Status code is 200', function () {",
              "    pm.response.to.have.status(200);",
              "});",
              "pm.test('Response is array', function () {",
              "    pm.expect(pm.response.json()).to.be.an('array');",
              "});"
            ]
          }
        }
      ],
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/users",
          "host": ["{{base_url}}"],
          "path": ["users"]
        }
      }
    }
  ]
}
```

**Run with Newman (CLI)**:
```bash
newman run api-tests.json \
  --environment production.json \
  --reporters cli,json \
  --reporter-json-export results.json
```

### 3. curl (Quick Manual Testing)

```bash
# GET request
curl -X GET https://api.example.com/users \
  -H "Authorization: Bearer token" \
  -H "Accept: application/json"

# POST request
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token" \
  -d '{"username":"new_user","email":"user@example.com"}'

# PUT request with verbose output
curl -X PUT https://api.example.com/users/42 \
  -H "Content-Type: application/json" \
  -d '{"email":"updated@example.com"}' \
  -v

# DELETE request
curl -X DELETE https://api.example.com/users/42 \
  -H "Authorization: Bearer token" \
  -w "\nHTTP Status: %{http_code}\n"
```

### 4. HTTPie (User-Friendly curl Alternative)

```bash
# Installation
pip install httpie

# GET request
http GET https://api.example.com/users Authorization:"Bearer token"

# POST request (JSON auto-detected)
http POST https://api.example.com/users \
  username=new_user \
  email=user@example.com \
  Authorization:"Bearer token"

# Download file
http --download https://api.example.com/reports/2026-01.pdf
```

---

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/api-tests.yml
name: API Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      
      - name: Run unit tests
        run: pytest tests/unit --cov=api --cov-report=xml
      
      - name: Run integration tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost/test
          API_KEY: ${{ secrets.TEST_API_KEY }}
        run: pytest tests/integration
      
      - name: Run API contract tests
        run: pytest tests/contract
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
      
      - name: Run Postman tests
        run: |
          npm install -g newman
          newman run tests/postman/api-tests.json \
            --environment tests/postman/ci-environment.json
```

### GitLab CI Example

```yaml
# .gitlab-ci.yml
stages:
  - test
  - deploy

variables:
  POSTGRES_DB: test_db
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres

api-tests:
  stage: test
  image: python:3.11
  
  services:
    - postgres:14
  
  before_script:
    - pip install -r requirements.txt
    - pip install pytest pytest-cov
  
  script:
    - pytest tests/ --cov=api --cov-report=term --cov-report=xml
  
  coverage: '/TOTAL.*\s+(\d+%)$/'
  
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```

---

## 📊 Performance Testing

### Load Testing with Locust

```python
# locustfile.py
from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 3)
    
    def on_start(self):
        """Login before starting tasks"""
        response = self.client.post("/auth/login", json={
            "username": "test_user",
            "password": "password"
        })
        self.token = response.json()['token']
    
    @task(3)  # Weight: 3x more frequent than other tasks
    def get_users(self):
        self.client.get("/users", headers={
            "Authorization": f"Bearer {self.token}"
        })
    
    @task(1)
    def create_user(self):
        self.client.post("/users", json={
            "username": f"user_{self.environment.runner.user_count}",
            "email": f"user{self.environment.runner.user_count}@example.com"
        }, headers={
            "Authorization": f"Bearer {self.token}"
        })
    
    @task(2)
    def get_specific_user(self):
        user_id = 42
        self.client.get(f"/users/{user_id}", headers={
            "Authorization": f"Bearer {self.token}"
        })
```

**Run Load Test**:
```bash
# Web UI
locust -f locustfile.py --host=https://api.example.com

# Headless mode
locust -f locustfile.py \
  --host=https://api.example.com \
  --users 100 \
  --spawn-rate 10 \
  --run-time 5m \
  --headless
```

### Apache Bench (ab)

```bash
# Simple load test
ab -n 1000 -c 10 https://api.example.com/users

# With authentication header
ab -n 1000 -c 10 \
  -H "Authorization: Bearer token" \
  https://api.example.com/users

# POST request with JSON
ab -n 100 -c 10 \
  -p data.json \
  -T application/json \
  -H "Authorization: Bearer token" \
  https://api.example.com/users
```

---

## 🔐 Security Testing

### 1. OWASP ZAP (Automated Security Scan)

```bash
# Docker-based scan
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t https://api.example.com \
  -r zap-report.html
```

### 2. Manual Security Checks

**SQL Injection Test**:
```bash
# Try injecting SQL in parameters
curl "https://api.example.com/users?id=1' OR '1'='1"
```

**Authentication Bypass**:
```bash
# Test endpoints without authentication
curl https://api.example.com/admin/users

# Test with invalid token
curl -H "Authorization: Bearer invalid_token" \
  https://api.example.com/users
```

**Rate Limiting**:
```bash
# Send rapid requests
for i in {1..100}; do
  curl https://api.example.com/users &
done
```

---

## 🚀 DevOps API Patterns

### 1. Webhooks

**Concept**: Server sends HTTP POST to client when event occurs.

**Example Use Cases**:
- GitHub: Notify CI/CD on push
- Stripe: Payment confirmation
- Slack: Message notifications

**Implementation**:
```python
# Webhook receiver
from flask import Flask, request
import hmac
import hashlib

app = Flask(__name__)
WEBHOOK_SECRET = "your_secret_key"

@app.route('/webhooks/github', methods=['POST'])
def github_webhook():
    # Verify signature
    signature = request.headers.get('X-Hub-Signature-256')
    expected = 'sha256=' + hmac.new(
        WEBHOOK_SECRET.encode(),
        request.data,
        hashlib.sha256
    ).hexdigest()
    
    if not hmac.compare_digest(signature, expected):
        return {'error': 'Invalid signature'}, 401
    
    # Process event
    event = request.headers.get('X-GitHub-Event')
    payload = request.json
    
    if event == 'push':
        # Trigger deployment
        trigger_deployment(payload['repository']['name'])
    
    return {'status': 'received'}, 200
```

### 2. Idempotency Keys

**Prevent duplicate operations**:
```python
from flask import Flask, request
import uuid

app = Flask(__name__)
processed_keys = {}  # In production: use Redis

@app.route('/api/payments', methods=['POST'])
def create_payment():
    idempotency_key = request.headers.get('Idempotency-Key')
    
    if not idempotency_key:
        return {'error': 'Idempotency-Key required'}, 400
    
    # Check if already processed
    if idempotency_key in processed_keys:
        return processed_keys[idempotency_key], 200
    
    # Process payment
    result = process_payment(request.json)
    
    # Store result
    processed_keys[idempotency_key] = result
    
    return result, 201
```

### 3. Health Checks

```python
from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)

@app.route('/health')
def health_check():
    """Basic liveness check"""
    return {'status': 'healthy'}, 200

@app.route('/health/ready')
def readiness_check():
    """Detailed readiness check"""
    checks = {
        'database': check_database(),
        'cache': check_redis(),
        'external_api': check_external_api()
    }
    
    all_healthy = all(checks.values())
    status_code = 200 if all_healthy else 503
    
    return {
        'status': 'ready' if all_healthy else 'not_ready',
        'checks': checks
    }, status_code

def check_database():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        conn.close()
        return True
    except:
        return False
```

---

## 🛡️ SRE Standard Checklist
- [ ] **Unit tests** for all business logic (80%+ coverage)
- [ ] **Integration tests** for database and external services
- [ ] **Contract tests** for service boundaries
- [ ] **E2E tests** for critical user flows
- [ ] **Performance tests** before production deployment
- [ ] **Security scans** in CI/CD pipeline
- [ ] **Automated tests** run on every commit
- [ ] **Test environments** mirror production
- [ ] **Mock external dependencies** in tests
- [ ] **Monitor test execution time** (fail if too slow)

---

## ❓ Interview "Deep-Cut" Questions

1. **Explain the difference between mocking and stubbing in API tests.**
   - *Answer*: Stubs provide canned responses to calls (state verification). Mocks verify that specific methods were called with expected parameters (behavior verification). Use stubs when you care about return values, mocks when you care about interactions.

2. **How do you test rate limiting in an API?**
   - *Answer*: Send requests exceeding the limit in rapid succession, verify 429 status code is returned, check rate limit headers (X-RateLimit-Remaining), verify Retry-After header, and confirm requests succeed after waiting.

3. **What is contract testing and why is it important in microservices?**
   - *Answer*: Contract testing verifies that service consumers and providers agree on API contracts. Prevents breaking changes. Tools like Pact allow consumer-driven contracts where consumers define expectations, providers verify they meet them.

4. **How do you handle flaky tests in CI/CD?**
   - *Answer*: Identify root cause (timing issues, external dependencies, test pollution). Fix by adding proper waits, mocking external services, isolating test data, using test containers. Quarantine flaky tests temporarily. Never ignore—flaky tests erode confidence.

5. **Explain blue-green deployment and how API versioning supports it.**
   - *Answer*: Blue-green maintains two identical production environments. Deploy new version to inactive environment, test, then switch traffic. API versioning allows old clients to use /v1 (blue) while new clients use /v2 (green), enabling gradual migration without breaking changes.

---

**Back to Start**: [HTTP Protocol Fundamentals →](./http-protocol-ref.md)
