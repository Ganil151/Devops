# 📡 API Mastery: The Engineer's Bridge with Requests

> **"A webpage is for humans. An API is for engineers. In the world of DevOps, if you can't talk to a REST API, you are isolated from the ecosystem."**

Welcome to the **API Mastery** module. In the cloud-native era, every piece of infrastructure—be it a firewall, a Kubernetes cluster, or an AWS region—is managed via a REST API. The `Requests` library is the industry standard for interacting with these services. This module covers the patterns of **Persistence**, **Retry-Ability**, and **Timeout Safety** required for production integration.

**Why This Matters for Junior DevOps Engineers:**
- 🚨 **Reliability**: 99% of "flaky" scripts are due to missing retry logic for transient network errors.
- ⚡ **Performance**: Improper use of connections (no sessions) can make scripts 10x slower.
- 🔒 **Security**: Mishandling API tokens and SSL verification leads to major security breaches.
- 🔧 **Daily Work**: You will write scripts to glue tools together (e.g., "Trigger GitLab pipeline when Jira ticket moves to Done").

---

## 📚 Table of Contents

1. [The API Integration Lifecycle](#-the-api-integration-lifecycle)
2. [Core Concepts: Requests & Responses](#-core-concepts-requests--responses)
3. [The Power of Sessions](#-the-power-of-sessions)
4. [Resilient Patterns (Retries & Timeouts)](#-resilient-patterns-retries--timeouts)
5. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
6. [Security Best Practices](#-security-best-practices)
7. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
8. [Hands-On Exercises](#-hands-on-exercises)
9. [Interview Preparation](#-interview-preparation)
10. [Knowledge Check](#-knowledge-check)

---

## 🏗️ The API Integration Lifecycle

Building robust API tools requires **Defensive Networking**. We move from simple "Fire-and-Forget" calls to **Stateful Sessions** and **Exponential Backoff**.
```mermaid
graph TD
    A[Trigger: Event / Logic] --> B{Session Object}
    B -- Config --> C[Retries & Timeouts]
    C --> D[Request: GET/POST/PUT]
    D -- 2xx OK --> E[JSON Parse & logic]
    D -- 4xx/5xx --> F{Retry Adapter?}
    F -- Yes --> G[Wait & Backoff]
    G --> D
    F -- No --> H[Fail-Fast: raise_for_status]
    
    style B fill:#e0f2fe,stroke:#0369a1
    style D fill:#fef3c7,stroke:#d97706
    style H fill:#fee2e2,stroke:#dc2626
```

### 🔍 Lifecycle Breakdown

**Stage 1: Session Configuration**
- **What**: Creating a reusable connection object.
- **Why**: Performance (TCP Keep-Alive) and Global Settings (Headers/Auth).
- **How**: `s = requests.Session()`.

**Stage 2: Resilience Configuration**
- **What**: Defining how to handle failure.
- **Why**: Networks are unreliable; transient failures (503s) happen.
- **How**: `HTTPAdapter` with `Retry` strategy.

**Stage 3: The Request**
- **What**: Sending data with strict boundaries.
- **Why**: Preventing hangs (Timeouts) and attacks (Injection).
- **How**: `s.get(url, timeout=10)`.

**Stage 4: Validation**
- **What**: Checking the outcome.
- **Why**: Silent failures are dangerous.
- **How**: `response.raise_for_status()`.

---

## 💻 Tech Deep-Dive: The Request Object

### The Old Way (Scripting Style)
```python
# ❌ BAD: No timeout, no error checking, new connection every time
import requests

response = requests.get('https://api.github.com/user')
data = response.json() # May crash if response is HTML error page
print(data['login'])
```
### The Modern Way (Engineering Style)
```python
# ✅ GOOD: Defensive, Persistent, and Safe
import requests
from requests.exceptions import RequestException

def get_user_data():
    try:
        # 1. Timeout allows failing fast
        response = requests.get('https://api.github.com/user', timeout=5)
        
        # 2. explicit check for HTTP errors (404, 500)
        response.raise_for_status()
        
        return response.json()
    except RequestException as e:
        print(f"API Error: {e}")
        return None
```
### 🔑 Authentication Patterns

#### Bearer Token (Common for SaaS)
```python
headers = {"Authorization": "Bearer my-secret-token"}
requests.get("https://api.example.com", headers=headers)
```
#### Basic Auth (Common for Internal Tools)
```python
requests.get("https://jenkins.internal", auth=('user', 'pass'))
```

---
## ⚡ The Power of Sessions
A `Session` object persists parameters across requests. It uses **urllib3** connection pooling, meaning it reuses the underlying TCP connection.

**Performance Impact**:
- **Without Session**: DNS Query -> TCP Handshake -> SSL Handshake -> Request -> Teardown (Repeat 100x)
- **With Session**: DNS Query -> TCP Handshake -> SSL Handshake -> Request 1 -> Request 2 -> ... (Repeat 0x)
```python
# Benchmarking Example
import time
import requests

s = requests.Session()
start = time.time()

for _ in range(50):
    s.get("https://www.google.com")

print(f"Time taken: {time.time() - start}s") 
# Result: ~3x faster than individual requests.get()
```

---

## 🛡️ Resilient Patterns: Retries & Timeouts

### The "Zombie Request" Problem
By default, `requests` has **NO TIMEOUT**. If a server accepts the connection but never sends data (hanging), your script will hang **FOREVER**.

**The Fix**:
```python
# Connect timeout: 3.05s (time to establish connection)
# Read timeout: 27s (time to wait for first byte)
requests.get('https://github.com', timeout=(3.05, 27))
```
### Automatic Retries with Backoff
Don't write `while` loops for retries. Use the built-in `HTTPAdapter`.
```python
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def get_resilient_session():
    # 1. Define Retry Strategy
    retry_strategy = Retry(
        total=3,  # Total retries
        backoff_factor=1,  # Sleep: 1s, 2s, 4s
        status_forcelist=[429, 500, 502, 503, 504], # Retry on these errors
        allowed_methods=["HEAD", "GET", "OPTIONS"] # Don't retry POST (non-idempotent)
    )
    
    # 2. Mount Logic
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session = requests.Session()
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    
    return session
```

---

## 🎭 Real-World DevOps Scenarios

### 🛡️ Scenario 1: The "Zombie Monitoring" Outage

**The Incident:** A monitoring script checked 1,000 internal servers every minute. The code used `requests.get(url)`. 

**The Failure:** A network switch glitch caused packets to drop silently. 500 servers became unreachable. The script incorrectly assumed they were "slow" and waited... forever.

**The Catastrophe:** The monitoring server spawned 1,000 processes (1 per minute), creating a "Process Storm". The monitoring server itself crashed due to Out Of Memory (OOM).

**The Root Cause:**
```python
# ❌ Infinite Hang
requests.get(url) 
```

**The Fix:**
```python
# ✅ Fail Fast after 2 seconds
requests.get(url, timeout=2)
```

**Lesson**: **ALWAYS** set a timeout. No exceptions.

### 🔥 Scenario 2: The Rate Limit Ban

**The Incident:** A junior engineer wrote a script to backup all 5,000 Jira tickets to a local DB.

**The Failure:** The script looped `for ticket in tickets: requests.get()`. Jira API allows 10 requests/second. The script hit 100 req/s.

**The Impact:** The corporate IP was banned by Atlassian for 24 hours. The entire engineering team lost access to Jira.

**The Fix:** Respect `429 Too Many Requests` and use `time.sleep()`.

```python
# ✅ Rate Limit Handling
import time

for ticket_id in ids:
    while True:
        response = session.get(f"https://jira.com/api/{ticket_id}")
        if response.status_code == 429:
            wait = int(response.headers.get('Retry-After', 10))
            print(f"Rate limited! Sleeping {wait}s...")
            time.sleep(wait)
            continue
        break
```

---

## 🔒 Security Best Practices

### 1. SSL Handling
**The Risk**: Disabling SSL verification exposes you to Man-in-the-Middle (MITM) attacks.

**Mitigation**:
```python
# ❌ VULNERABLE
requests.get(url, verify=False) # Never do this in production!

# ✅ SECURE (Default)
requests.get(url) 

# ✅ SELF-SIGNED CERTS
requests.get(url, verify='/path/to/corporate_ca.pem')
```

### 2. Secret Leaks in Logs
**The Risk**: Logging the full request object prints headers, including Authorization tokens.

**Mitigation**:
```python
# ❌ BAD
logging.info(f"Request headers: {response.request.headers}")

# ✅ GOOD (Masking)
safe_headers = response.request.headers.copy()
safe_headers['Authorization'] = 'Bearer *****'
logging.info(f"Request sent with: {safe_headers}")
```

---

## ⚠️ Common Pitfalls & Solutions

### Pitfall 1: Assuming JSON response
```python
# ❌ BAD
data = requests.get(url).json() 
# If server returns "502 Bad Gateway" (HTML), this crashes with decoder error.

# ✅ GOOD
resp = requests.get(url)
resp.raise_for_status() # Check for 200 OK first
data = resp.json()
```

### Pitfall 2: Not closing sessions
Sessions hold open TCP connections. If you create thousands of them, you run out of file descriptors.
```python
# ✅ Context Manager closes automatically
with requests.Session() as s:
    s.get(url)
```
---

## 🎯 Hands-On Exercises

### Exercise 1: GitHub Repos Auditor
**Objective**: Fetch all public repositories for a user and count total stars.

**Requirements**:
- Use a Session with retries.
- Handle pagination (GitHub returns 30 per page).
- Output total stars.

**Starter Code**:
```python
import requests

def count_stars(username):
    url = f"https://api.github.com/users/{username}/repos"
    # TODO: Create session with Retry
    # TODO: Loop through pages (Look for 'Link' header)
    # TODO: Sum stargazers_count
    pass
```

### Exercise 2: Website Health Checker
**Objective**: Check a list of URLs and report their health.

**Requirements**:
- Input: List of URLs
- Logic: GET request with 2s timeout.
- Output: Status (UP/DOWN) and Response Time (ms).

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "What is the difference between `json.loads(response.text)` and `response.json()`?"**
- **Answer**: `response.json()` detects the encoding (UTF-8, etc.) from headers automatically. `response.text` relies on best-guess decoding. Always use `.json()`.

**2. "Why use `requests.Session()`?"**
- **Answer**: Connection Pooling (performance) and Cookie Persistence (state).

**3. "Explain 429 vs 503 errors."**
- **Answer**: 
    - **429 (Client Error)**: You are sending too many requests. Slow down.
    - **503 (Server Error)**: The service is overloaded or down. Retry later.

### Advanced Scenario Questions

**4. "How do you handle pagination when an API returns 10,000 items?"**
- **Answer**: Do NOT fetch all into memory list. Use a **Generator**.
```python
def fetch_all_items():
    page = 1
    while True:
        data = get_page(page)
        if not data: break
        for item in data:
            yield item # Memory efficient
        page += 1
```

---

## 🧠 Knowledge Check

**1. What is the default timeout for Requests?**
- [ ] 30s
- [x] None (Infinite)
- [ ] 60s

**2. Which object reuses TCP connections?**
- [ ] `requests.get()`
- [x] `requests.Session()`
- [ ] `HTTPAdapter`

**3. Which status code indicates a redirect?**
- [ ] 200
- [x] 301/302
- [ ] 404

**4. How do you securely pass a password?**
- [ ] In URL (`http://user:pass@site.com`)
- [x] In Headers (`Authorization`)
- [ ] In Query Params (`?password=123`)

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Create a Session with `Retry` logic
- [ ] Always implement timeouts
- [ ] Handle 4xx/5xx errors using `raise_for_status()`
- [ ] Securely pass Authorization tokens
- [ ] Parse JSON responses safely
- [ ] Explain connection pooling

**Score yourself**: 5+/6 = Ready to advance | <5 = Review exercises

[⬅️ Back to Data Ops](readme.md) | [Next: Cloud Automation](readme.md) ➡️