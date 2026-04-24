# 🚦 Traffic Control and Rate Limiting

System stability is non-negotiable. This module covers how to protect your infrastructure from overwhelming traffic—accidental or malicious—using advanced throttling and circuit breaking patterns.

---

## 🛑 Rate Limiting vs. Throttling
- **Rate Limiting**: Hard-cap on requests per period (e.g., 10 req/s).
- **Throttling**: The broader strategy of controlling traffic flow, which may include rate limiting, prioritizing certain users, or slowing down responses.

---

## 📈 Algorithms for Load Shedding
1.  **Token Bucket**: Allows bursts; tokens refill over time. (Great for user-facing APIs).
2.  **Leaky Bucket**: Forces a constant output rate. (Great for protecting old databases).
3.  **Fixed/Sliding Window**: Prevents "reset-sync" spikes at the edge of time buckets.

---

## ⚡ The Circuit Breaker Pattern
Protect your services from **Cascading Failures**.
- **Closed**: Requests pass through.
- **Open**: Backend is failing; stop traffic immediately.
- **Half-Open**: Test the waters to see if the service recovered.

---

## 🛡️ Implementation Best Practices
| Tool | Feature | Use Case |
| :--- | :--- | :--- |
| **Kong** | `rate-limiting` plugin | General API protection. |
| **Nginx** | `limit_req` | High-performance edge throttling. |
| **AWS WAF** | Rate-based rules | Blocking malicious IP ranges. |
| **Redis** | Centralized Counters | Distributed rate limiting across multiple gateways. |

---

## 📖 Real-World DevOps Story: "The Hug of Death"
Learn how a successful viral marketing campaign crashed a site's database, and how a properly configured "Circuit Breaker" could have saved the weekend.

---

## 👔 Interview Prep & Deep Dives
Master the technical nuances of Token vs. Leaky bucket algorithms and learn how to design a "Distributed Rate Limiter" using Redis.

---

## 🔗 Internal Navigation
- [Next: API Documentation and Management](../04-api-documentation-and-management/readme.md)
- [Back: Traffic Management Hub](../readme.md)

---
*Fail fast. Recover faster.*
