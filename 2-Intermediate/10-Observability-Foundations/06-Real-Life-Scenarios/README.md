# Observability Real-Life Scenarios

See how monitoring and logging expertise can prevent outages and solve performance puzzles.

---

## 🛠️ Scenario 1: The "Invisible" Outage (Black-box Failure)
**Problem:** Your internal monitoring says CPU is low, memory is fine, and there are 0 errors in the logs. However, customers are complaining on Twitter that they cannot log in.

**The Investigation:**
1. You run a manual test and realize the "Login" button is broken because an external CDN is down. Your "White-box" monitoring (internal) didn't see it because the app itself was "healthy."
2. **The Solution**: Implement **Black-box/Synthetic Monitoring**. Create a script that simulates a user login every 2 minutes. If it fails, trigger a high-priority alert.
**Goal**: Monitor the user experience, not just the server statistics.

---

## 🏗️ Scenario 2: Hunting the Memory Leak (Saturation)
**Problem:** A specific microservice is crashing every 6 hours with an `OOMKilled` error.

**The Investigation:**
1. You look at the **Saturation** metrics (Memory Usage). You see a "sawtooth" pattern: memory slowly climbs until it hits the limit, crashes, and starts over.
2. You correlate the memory climb with a spike in **Traffic**.
3. **The Fix**: You use an **APM tool** to find that a specific function is not closing database connections, causing a memory leak.
**Goal**: Use saturation trends to identify software bugs.

---

## 🌩️ Scenario 3: Investigating Slow Page Loads (Tracing)
**Problem:** Users are reporting that the "Checkout" page takes 15 seconds to load.

**The Investigation:**
1. You look at **Distributed Tracing** for the `/checkout` endpoint.
2. The trace shows that the `order-service` is fast (100ms), but the `shipping-calculator-service` is taking 14 seconds because it's waiting for a response from a 3rd-party carrier API.
3. **The Fix**: Add a timeout and a fallback (default shipping cost) for the carrier API so the user isn't blocked.
**Goal**: Identify the "bottleneck service" in a microservices chain.

---

## 🔄 Scenario 4: Log Drowning
**Problem:** Your production logs are moving so fast that you can't manually find the "Critical" errors during an incident.

**The Investigation:**
1. You realize the developers left `DEBUG` logs enabled in production.
2. **The Fix**:
   - Immediately switch the **Log Level** to `INFO` or `WARN` via an environment variable.
   - Use a **Log Aggregator** (Elasticsearch) to filter for `level: "ERROR"` to isolate the real issues.
**Goal**: Manage log volume to maintain "Signal-to-Noise" ratio.

---

## 🛡️ Scenario 5: Cascading Readiness Failure
**Problem:** Your database goes down for planned maintenance. Suddenly, all your web servers are killed and restarted by Kubernetes, even though they should have just waited for the DB.

**The Investigation:**
1. You find that the **Liveness Probe** was checking the database connection. When the DB failed, the Liveness probe failed, and K8s killed the healthy web containers.
2. **The Solution**: Move the database check to the **Readiness Probe**. If the DB is down, the web server stays alive but stops receiving traffic.
**Goal**: Avoid "Self-Inflicted" outages through proper probe design.

---

## 💡 Key Takeaway
Observability is about **Predictability**. By watching the right signals (Golden Signals, Probes, Traces), you turn "mystery outages" into "documented incidents" that can be resolved quickly or even automatically.
