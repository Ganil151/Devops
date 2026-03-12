# 🌅 Simulation: The Morning Triage

It's 08:00 AM. You sit down with a coffee and open Slack. Your `#ops-alerts` channel has several new unacknowledged threads.

---

### 💬 Case 1: The Connection Refused (Redis)
**[04:22 AM] AlertManager APP-BOT:** 🚨 CRITICAL: Service `Auth-API` is reporting 85% Error Rate in `Production-US-East-1`.

**[04:25 AM] Senior-Dev-Sarah:** I'm seeing "Connection Refused" in the logs. Restarted the pods but it didn't help.

#### 🪵 Log Snippet (Auth-API)
```text
2026-02-05 04:22:11 [ERROR] [Auth-API] - Failed to initialize session handler.
2026-02-05 04:22:12 [DEBUG] [Auth-API] - Connecting to cluster: redis-prod-001.internal.cache.aws...
2026-02-05 04:22:13 [CRITICAL] [Auth-API] - ConnectionError: [Errno 111] Connection refused
```

**Diagnosis**: **Database/Connectivity Layer**. Restarting the app pods won't fix a broken connection to a separate Redis instance. 

---

### 💬 Case 2: The "Unknown Host" (DNS)
**[05:10 AM] AlertManager MONITOR-BOT:** ⚠️ WARNING: `Payment-Processor` heartbeat failed.

#### 🪵 Log Snippet (Payment-Processor)
```text
2026-02-05 05:10:01 [WARN] [Payment-Processor] - Attempting to reach gateway
2026-02-05 05:10:02 [ERROR] [Payment-Processor] - RequestException: Max retries exceeded with url: /v1/charge
2026-02-05 05:10:02 [ERROR] [Payment-Processor] - Caused by: NewConnectionError: <...>: Failed to establish a new connection: [Errno -2] Name or service not known
```

**Diagnosis**: **DNS/Networking Layer**. "Name or service not known" means the application cannot resolve the hostname. 
*   **Question**: Is it a global DNS outage, or did someone accidentally delete a Route53 record?

---

### 💬 Case 3: The 401 Unauthorized (Auth/Expired Token)
**[06:45 AM] AlertManager SECURITY-BOT:** 🛡️ INFO: High frequency of `401 Unauthorized` on `/api/v2/orders`.

#### 🪵 Log Snippet (API-Gateway)
```text
2026-02-05 06:45:30 [INFO] [Gateway] - INCOMING: GET /api/v2/orders HTTP/1.1
2026-02-05 06:45:30 [DEBUG] [Gateway] - Validating JWT via IAM-Service...
2026-02-05 06:45:31 [WARN] [Gateway] - OUTGOING: 401 Unauthorized. Detail: RSA signature verification failed. Token expired at 2026-02-05 06:00:00.
```

**Diagnosis**: **Application/Auth Logic Layer**. The infrastructure is running fine, but the system's identity tokens are expiring.
*   **Action**: Investigate why the token refresh service (or IAM agent) isn't rotating keys.

---

### 🧠 Triage Methodology: The "Traffic Light" Rule

| Layer | Symptom | Action |
| :--- | :--- | :--- |
| **App** | 500 Internal Error, Stack Traces | Check Code Logs, Env Vars |
| **Net/DNS** | Unknown Host, Timeout, 504 Gateway | Check VPC, Route53, SG |
| **Auth** | 401 Unauthorized, 403 Forbidden | Check IAM, JWT, API Keys |
| **Infra** | Connection Refused, Disk Full | Check Redis, DB, Storage |

---

### 🛠️ Junior's Step-by-Step Response:
1.  **Acknowledge**: Post in Slack: "I am looking into Case 2 (DNS issue) now."
2.  **Verify**: Can *you* resolve the address from your local machine or a bastion host?
3.  **Correlate**: Look at the "Change Log." Did someone merge a Terraform PR involving networking at 05:00 AM?
