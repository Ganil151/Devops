# Log Management Foundations

Logs are a chronological record of events happening within a system. They are the first place a DevOps engineer looks when a monitoring alert is triggered.

---

## 🏗️ 1. The Standard Output (stdout)
In the world of microservices and containers (Docker/Kubernetes), applications should *not* write logs to files on disk. Instead:
- They should write all logs to **stdout** and **stderr**.
- The container runtime captures these streams.
- A log driver (like Fluentd or Promtail) ships them to a central location.

---

## 🚥 2. Log Levels
Using the correct log level is critical for filtering and alerting:

| Level | Purpose |
| :--- | :--- |
| **DEBUG** | Extremely detailed info for developers. Disabled in production. |
| **INFO** | General system events (e.g., "User logged in", "Service started"). |
| **WARN** | Something unexpected happened, but the system is still working. |
| **ERROR** | A functionality failed, but the app is still running. |
| **FATAL/CRITICAL** | The system is dying. Requires immediate human intervention. |

---

## 📦 3. Structured Logging (JSON)
Plain text logs are hard for machines to read. **Structured logging** (usually in JSON format) allows you to search and filter logs based on fields like `user_id`, `request_id`, or `status_code` without complex regex.

**Example**:
```json
{
  "timestamp": "2023-10-27T10:00:00Z",
  "level": "ERROR",
  "msg": "Database connection failed",
  "service": "billing-api",
  "request_id": "abc-123"
}
```

---

## 🕵️ 4. Log Aggregation
The process of collecting logs from hundreds of servers and storing them in a central, searchable database (e.g., ELK Stack, Loki, or Splunk).
- **Goal**: Single pane of glass for all application audits.
