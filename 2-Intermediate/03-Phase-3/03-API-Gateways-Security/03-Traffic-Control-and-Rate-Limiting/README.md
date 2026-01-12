# 03: Traffic Control and Rate Limiting

Rate limiting and Throttling are essential for protecting backend services from being overwhelmed by too many requests—whether accidental or malicious (DDoS).

## 🛑 Rate Limiting vs. Throttling

- **Rate Limiting**: Restricts the number of requests a client can make within a specific timeframe (e.g., 100 req/min).
- **Throttling**: Gradually slows down the response rate when a limit is exceeded, rather than hard-blocking immediately.

---

## 📈 Common Algorithms

### 1. Token Bucket
- The bucket has a fixed capacity.
- Tokens are added at a constant rate.
- Each request consumes a token.
- If the bucket is empty, the request is rejected.
- **Benefit**: Allows for small bursts of traffic.

### 2. Leaky Bucket
- Requests are added to a "bucket" (a queue).
- They are processed at a constant rate.
- If the bucket is full, new requests are dropped.
- **Benefit**: Smooths out traffic spikes.

### 3. Fixed Window Counter
- Divides time into fixed windows (e.g., 1-minute blocks).
- Counts requests per window.
- **Drawback**: Traffic spikes at the window boundaries can double the allowed limit.

---

## ⚡ Circuit Breaker Pattern

Used to prevent a failure in one service from cascading to others.
- **Closed**: Requests flow normally.
- **Open**: Service is failing; requests are rejected immediately with an error (Failing fast).
- **Half-Open**: Periodically allows a few requests through to see if the service has recovered.

---

## 🏗️ Implementation in DevOps

- **Kong Plugins**: Use the `rate-limiting` or `proxy-cache` plugins.
- **Nginx**: Use `limit_req_zone` and `limit_conn_zone`.
- **AWS WAF**: Use rate-based rules to block malicious IPs.
- **Redis**: Often used as the backend for distributed rate limiting to track counts across multiple gateway instances.
