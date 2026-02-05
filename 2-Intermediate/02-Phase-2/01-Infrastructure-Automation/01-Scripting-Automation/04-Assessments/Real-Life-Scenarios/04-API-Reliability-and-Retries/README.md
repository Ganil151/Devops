# API Reliability and Retries

The network is unreliable. External APIs will fail. Your automation must handle these failures gracefully using retries, timeouts, and backoff.

## 📚 Module Structure
- **[Boilerplates](README.md)**: `resilient_api.py` (Request sessions with retries).
- **[CHALLENGES](./CHALLENGES.md)**: Handling 429 errors and circuit breakers.

---

## 🏗️ Scenario: The "429 Too Many Requests"
**Problem**: A script fetching weather data was hitting a rate limit.
**Solution**: Use a Session with a built-in retry adapter.

```python
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

retry_strategy = Retry(
    total=3,
    status_forcelist=[429, 500, 502, 503, 504],
    method_whitelist=["GET", "POST"],
    backoff_factor=1 # 1s, 2s, 4s...
)
```

---

## 🏗️ Scenario: The "Hanging Request"
**Problem**: An API was slow to respond, causing the script to hang for 10 minutes.
**Solution**: Always specify a `timeout`.

```python
requests.get("https://api.com", timeout=5) # 5 second limit
```

---

## 📖 Real-World Story: The "Cascading Failure"
A microservice was calling another service without a timeout. When the second service slowed down, the first service's connection pool filled up, causing it to crash too. 
**Result**: A small bug in Service B took down the whole platform. 
**Lesson**: Timeouts and Retries are not optional; they are a safety requirement.

---

## ❓ Interview Questions
1. **What is Exponential Backoff?**
   - *Answer*: An algorithm that uses progressively longer waits between retries (e.g., 1, 2, 4, 8 seconds) to avoid overloading a failing system.
2. **What is 'Idempotency' in the context of POST requests?**
   - *Answer*: Ensuring that if a retry happens, the server doesn't create duplicate resources (usually managed via Idempotency Keys in headers).

---

[⬅️ Back to Automation Index](../README.md)
