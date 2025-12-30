# Operational Scenarios

When do you actually open a runbook? Identifying the right scenarios prevents documentation bloat.

## 1. Incident Response (The "Firefighter" Runbooks)
- **Trigger**: P0/P1 High-priority alerts.
- **Focus**: Speed to recovery.
- **Example**: `Service 5xx Error Spike`, `Memory Leak in Worker-Node`.

## 2. Service Requests (The "Service Desk" Runbooks)
- **Trigger**: Internal tickets from other teams.
- **Focus**: Accuracy and standardized outcomes.
- **Example**: `Provision a new developer sandbox`, `Rotate SSL certificates`.

## 3. Disaster Recovery (The "Lifeboat" Runbooks)
- **Trigger**: Total region outage, large-scale data loss.
- **Focus**: Massive scale orchestration.
- **Example**: `Failover from US-East-1 to US-West-2`.

## 4. Routine Maintenance (The "Health" Runbooks)
- **Trigger**: Scheduled calendar events.
- **Focus**: Preventing future incidents.
- **Example**: `Monthly patch of Linux kernels`, `Database vacuuming`.

---

## 🏗️ Real-Life Scenario: The Alert Storm
**Problem**: An SRE team receives 50 alerts in 10 minutes. They have 2,000 runbooks.
**The Struggle**: They can't find which runbook corresponds to the specific alert "DiskPressure-NodeA."
**The Fix**: Tag-based mapping. Every Alert in Prometheus now has a link in its description to the exact Runbook URL in GitHub.
**Outcome**: Engineer clicks the alert -> Runbook opens instantly -> Resolution starts in seconds.

---

## ❓ Interview Questions
1.  **How do you decide which tasks deserve a runbook?**
    *   *Answer*: Use the **Frequency vs. Risk** matrix. Tasks that are high-risk (e.g., DB failover) or high-frequency (e.g., Password resets) MUST have runbooks. Low-risk, low-frequency tasks can be documented as general notes.
2.  **What is a 'Gameday' and how does it relate to scenarios?**
    *   *Answer*: A Gameday is a scheduled test where you simulate a disaster (e.g., unplugging a database) and force the team to follow the runbook to fix it. It validates that the runbook works for the intended scenario.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which scenario focuses most on speed?** (Incident Response)
2.  **True/False: You should have a runbook for every single possible action.** (False - avoid 'Documentation Bloat')
3.  **What is a 'Disaster Recovery' runbook used for?** (Large-scale total system failure)
4.  **Can a Service Request be automated?** (Yes, and it should be)
5.  **Which tool links Alerts to Runbooks?** (Monitoring tools like Grafana, Datadog, or PagerDuty)
