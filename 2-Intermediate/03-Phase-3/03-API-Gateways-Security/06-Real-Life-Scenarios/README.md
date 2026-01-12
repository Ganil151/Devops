# 06: Real-Life Scenarios

Explore how API Gateway and Security concepts are applied in production environments.

## 🛠️ Scenario 1: Preventing a Targeted DDoS Attack
**Context**: Your public-facing E-commerce API is being hit by 10,000 requests per second from a single subnet in a specific country where you don't even have customers, causing the checkout service to crash.
**Challenge**: Protect the checkout service without affecting legitimate users.
**Solution**:
1. **Analyze**: Use Gateway logs (Kong/CloudWatch) to identify the source IP range.
2. **Action**: Implement a **Geo-blocking** rule at the WAF/Gateway level to block traffic from that country.
3. **Refinement**: Apply a strict **Rate Limit** for all unauthenticated requests (e.g., 5 req/min) while allowing authenticated users more headroom (50 req/min).

---

## 🏗️ Scenario 2: The "Strangler Fig" Migration
**Context**: Your company is migrating a legacy Monolith to Microservices. You want to move the "User Management" part first.
**Challenge**: How do you shift traffic without the users noticing?
**Solution**:
1. **Implementation**: Place an **API Gateway** in front of the Monolith.
2. **Routing**: Initially, route 100% of traffic to the Monolith.
3. **Execution**: Deploy the new "User Service". Update the Gateway to route any path starting with `/api/v1/users` to the new microservice, while leaving everything else (e.g., `/api/v1/billing`) pointed at the Monolith.
4. **Validation**: Gradually move more paths until the Monolith can be decommissioned.

---

## 🔑 Scenario 3: Multi-Tenant JWT Authentication
**Context**: You are building a SaaS platform where each customer (Tenant) has their own database.
**Challenge**: How does the backend know which database to query based on a single API call?
**Solution**:
1. **JWT Custom Claims**: Include a `tenant_id` claim in the JWT payload when the user logs in.
2. **Gateway Validation**: The Gateway validates the JWT.
3. **Header Injection**: The Gateway extracts the `tenant_id` and injects it into a header (e.g., `X-Tenant-ID`) before forwarding the request to the backend.
4. **Backend Logic**: Backend services use this header to select the correct database connection string dynamically.

---

## ⚡ Scenario 4: Handling Service Failures with Circuit Breakers
**Context**: Your "Recommendation Engine" service is intermittently slow (5+ seconds) due to high load, causing the API Gateway to timeout and return 504 errors to all users.
**Challenge**: Prevent a single slow service from bringing down the entire API.
**Solution**:
1. **Gateway Configuration**: Enable the **Circuit Breaker** plugin for the Recommendation Service.
2. **Thresholds**: Set a failure threshold (e.g., if 50% of requests fail or timeout over 30 seconds, open the circuit).
3. **Fallback**: Configure a **Fallback response**. Instead of an error, return a static list of "Popular Items" from the cache.
4. **Recovery**: Once the Recommendation Service stabilizes, the circuit moves to "Half-Open" and eventually "Closed".

---

## 📜 Scenario 5: Secure Machine-to-Machine Communication
**Context**: Your "Inventory Service" needs to talk to the "Shipping Service" to update tracking numbers. These are internal services, but they still need to be secure.
**Challenge**: How do services authenticate with each other without user intervention?
**Solution**:
1. **OAuth2 Flow**: Use the **Client Credentials Flow**.
2. **Identity Provider**: The Inventory Service requests an Access Token from the Authorization Server (e.g., Keycloak) using its `client_id` and `client_secret`.
3. **Internal Auth**: For every request to the Shipping Service, the Inventory Service includes this token in the header.
4. **Gateway Check**: The Gateway (or an internal sidecar) verifies the token and the specific `write:shipping` scope before allowing the call.
