# API Mastery with Requests

The internet runs on HTTP. The `requests` library is the gold standard for interacting with REST APIs, handling webhooks, and performing health checks.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `api_client.py` (Retries, Timeouts, Sessions).
- **[CHALLENGES](./CHALLENGES.md)**: Repo Lister, Link Checker.

---

## 🔑 Key Concepts

| Concept | Description | Code |
| :--- | :--- | :--- |
| **GET vs POST** | Read data vs Create data | `requests.get()`, `requests.post()` |
| **Status Codes** | 2xx (OK), 4xx (Client Err), 5xx (Server Err) | `resp.status_code` |
| **Timeout** | Stop hanging requests | `timeout=5` (ALWAYS SET THIS) |
| **Session** | Reuse TCP connections (Performance) | `s = requests.Session()` |

---

## 🏗️ Robust API Patterns

### 1. The "Must-Have" Timeout
By default, python requests hang *forever*.

```python
# BAD
requests.get("https://slow-api.com")

# GOOD
try:
    requests.get("https://slow-api.com", timeout=10)
except requests.exceptions.Timeout:
    print("Too slow!")
```

### 2. Automatic Retries
Don't write `while` loops. Use `HTTPAdapter`.

```python
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

retry = Retry(total=3, backoff_factor=1)
adapter = HTTPAdapter(max_retries=retry)
session = requests.Session()
session.mount('https://', adapter)
```

---

## 📖 Real-World Story: The "API Rate Limit" Block

**Problem**: A dashboard script hit Jira API 1,000 times/minute. Jira blocked it with "429 Too Many Requests".
**Crisis**: Dashboard went blank during a release.
**Solution**: Implemented `HTTPAdapter` with `backoff_factor`.
**Result**: Script now detects 429s, waits exponentially (1s, 2s, 4s...), and succeeds without crashing.

---

## ❓ Interview Questions

1.  **What is the difference between `data=` and `json=` in `requests.post()`?**
    - *Answer*: `data=` sends form-encoded data (HTML forms). `json=` sends JSON and sets the `Content-Type: application/json` header automatically.
2.  **Why use a Session object?**
    - *Answer*: To persist parameters (cookies, headers) and reuse the underlying TCP connection (Keep-Alive), which significantly speeds up multiple requests to the same host.
3.  **How do you handle SSL warnings?**
    - *Answer*: `verify=False` (unsafe, dev only) or provide the path to the cert bundle `verify='/path/to/cert.pem'`.

---

[Next: Cloud Automation (Boto3)](../05-Cloud-Automation-Boto3-Deep-Dive/README.md)