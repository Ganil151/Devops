# Detection and Alerting

The faster you detect an incident, the faster you can respond. **Mean Time To Detect (MTTD)** is as important as MTTR.

## Detection Sources

### 1. Automated Monitoring
**Best**: Proactive, catches issues before users notice.
- **Metrics**: CPU, memory, disk, error rates, latency.
- **Logs**: Error patterns, exceptions, security events.
- **Synthetic Monitoring**: Automated tests simulating user behavior.
- **Tools**: Prometheus, Datadog, New Relic, CloudWatch.

### 2. User Reports
**Reality**: Sometimes users notice before monitoring does.
- **Channels**: Support tickets, social media, direct emails.
- **Problem**: High MTTD (users may wait before reporting).

### 3. Internal Discovery
**Worst**: Engineer stumbles upon issue while working.
- **Problem**: Indicates monitoring gaps.

---

## Alert Quality Metrics

### 1. Signal-to-Noise Ratio
What percentage of alerts are actionable?
- **Target**: > 95% of alerts should require action.
- **Problem**: Too many false positives cause alert fatigue.

### 2. Alert Actionability
Does the alert tell you what to do?
- **Bad**: "High CPU on server-123"
- **Good**: "High CPU on server-123. Runbook: https://wiki/cpu-spike"

### 3. Alert Grouping
Are related alerts aggregated?
- **Bad**: 100 alerts for "Pod Crash" (one per pod).
- **Good**: 1 alert "Multiple pods crashing in api-deployment"

---

## The Perfect Alert

```yaml
Alert: DatabaseConnectionPoolExhausted
Severity: P1
Description: |
  The connection pool for the primary database has reached 95% capacity.
  This will cause new requests to fail within 2-3 minutes.
Impact: Payment processing will fail
Runbook: https://wiki.company.com/runbooks/db-connections
Dashboard: https://grafana.company.com/d/database
Escalation: If not resolved in 15 min, page DBA team
```

---

## 🏗️ Real-Life Scenario: The "Crying Wolf" Alert
**Problem**: An alert fires 50 times per day for "Disk > 80%". Engineers ignore it.
**Crisis**: One day, disk actually fills to 100%. The alert fires. No one responds because they assume it's another false positive.
**Outcome**: 2-hour outage.
**Fix**: Adjust threshold to 90% and add auto-remediation for 80-90% range.
**Result**: Alert fires only for real emergencies. Engineers trust it again.

---

## ❓ Interview Questions
1.  **What is MTTD and why does it matter?**
    *   *Answer*: Mean Time To Detect - the average time between when an incident starts and when it's detected. It matters because you can't fix what you don't know is broken. Lower MTTD means faster response.
2.  **How do you prevent alert fatigue?**
    *   *Answer*: By ensuring alerts are actionable (high signal-to-noise ratio), properly grouped, have clear runbooks, and use appropriate thresholds. Also implement auto-remediation for routine issues.

---

## 🧠 Quiz Snippet (5/50+)
1.  **What does MTTD stand for?** (Mean Time To Detect)
2.  **True/False: User reports are the best detection method.** (False - automated monitoring is better)
3.  **What is 'Alert Fatigue'?** (Desensitization from too many low-quality alerts)
4.  **Should an alert include a runbook link?** (Yes)
5.  **What is a good signal-to-noise ratio for alerts?** (> 95% actionable)
