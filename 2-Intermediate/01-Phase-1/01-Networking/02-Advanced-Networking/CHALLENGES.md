# 🎫 NRE Simulation: The Weekly On-Call

> **"Junior, I don't care if you know the OSI model. I care if you know what to do when PagerDuty screams at 3 AM. This isn't a quiz. This is simulation."**

---

## 📅 Monday: The "Slow" API
**Severity**: Sev-3 (Degraded Performance)

### The Alert
User complaints: "The dashboard is loading, but the user profile images take 5 seconds to appear."

### Your Mission
1.  **Hypothesis**: It's network latency or packet loss.
2.  **Tool**: `mtr` (My Traceroute).
3.  **Task**:
    *   Synthesize a report showing the "Last Mile" latency vs. "Backbone" latency.
    *   Determine if the issue is inside our VPC or at the ISP level.
4.  **CLI Drill**:
    ```bash
    mtr --report --report-cycles 10 api.internal
    # Look at the "% Loss" column on the hops.
    ```

---

## 📅 Wednesday: The "Split-Brain" Peering
**Severity**: Sev-2 (Partial Outage)

### The Alert
"Service A in `vpc-prod` cannot access Service B in `vpc-shared`. Connection Timed Out."

### Your Mission
1.  **Hypothesis**: Route Tables are correct, but the Security Group is one-sided.
2.  **Tool**: `nc` (Netcat) and `grep`.
3.  **Task**:
    *   SSH into Service A. Run `nc -zv service-b 8080`.
    *   Verify if the return traffic is allowed.
4.  **The "Gotcha"**: You find the route table points to a **Deleted Peering ID** (`blackhole` status).
5.  **CLI Drill**:
    ```bash
    aws ec2 describe-route-tables --filters "Name=route.state,Values=blackhole"
    ```

---

## 📅 Friday: The Deployment Freeze (MTU)
**Severity**: Sev-1 (Blocker)

### The Alert
"We migrated to a Direct Connect link. Now, `docker push` works, but `git clone` of large repos hangs indefinitely."

### Your Mission
1.  **Hypothesis**: MTU Mismatch. The new link has a smaller MTU than the default 1500.
2.  **Tool**: `ping` with DF (Don't Fragment) bit.
3.  **Task**: Find the "Safe" MTU size.
4.  **CLI Drill**:
    ```bash
    # Start high and go low
    ping -M do -s 1472 git.internal
    # > Message too long
    ping -M do -s 1300 git.internal
    # > Reply from...
    ```
5.  **Resolution**: Adjust the TCP MSS Clamping on the router.

---

## 📂 Report Template
For each challenge, write a simplistic "Post-Mortem":
1.  **Symptoms**: What did the user see?
2.  **Root Cause**: What was the technical failure? (e.g., "Stateless NACL blocked high ports")
3.  **Restoration**: What one command fixed it?
