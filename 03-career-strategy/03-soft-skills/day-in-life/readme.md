# ✈️ Operation: Day in the Life (Professional Onboarding)

Welcome to the **SRE Bridge**. In this module, we move beyond definitions. You are no longer reading about a role; you are stepping into the "Staff Standard" operational rhythm of a high-tier DevOps team.

---

## 🕒 The Operational Rhythm (The Staff-Standard 24)

### 🌅 08:00 - 09:30 | The Morning Triage
*   **The Goal**: Establish situational awareness.
*   **The Routine**: Check `#alerts-critical`, scan the Grafana dashboard for overnight spikes, and triage the JIRA/ServiceNow board.
*   **The Simulation**: Head to [01-Morning-Triage-Sim](./01-morning-triage-sim/readme.md).

### ⚙️ 10:00 - 12:30 | Infrastructure & Pipelines
*   **The Goal**: Clean the runway.
*   **The Routine**: Reviewing Pull Requests (PRs), fixing broken build dependencies, and executing planned IaC changes.
*   **The Standard**: [02-The-Code-Review-Gate](./02-the-code-review-gate/readme.md).

### 🚨 13:30 - 16:00 | The Afternoon "Incident"
*   **The Goal**: Restore service; avoid finger-pointing.
*   **The Routine**: Handling production outages, participating in war rooms, and executing rollbacks if a change went south.
*   **The Recovery**: [03-Rollback-Procedures](./03-rollback-procedures/readme.md).

### 📚 16:30 - Evening | The Long Game
*   **The Goal**: Sharpen the axe.
*   **The Routine**: Updating documentation, working on long-term automation projects (to reduce toil), and reading CNCF whitepapers or tool release notes.

---

## 🌪️ The "Blast Radius" Decision Tree
When an alert fires, your first task is to determine the scope. A Senior Engineer doesn't treat a "Broken CSS" alert the same as a "Database Connection Timeout."

| Incident Type | Symptoms | Priority | Action |
| :--- | :--- | :--- | :--- |
| **Component Failure** | One microservice is slow; errors in one region. | **Medium** | Triage within the service; check recent commits to that service. |
| **Platform Failure** | DNS issues, K8s cluster errors, Cloud provider outage. | **Critical** | **Immediate Rollback** or Shift traffic to secondary region. |
| **Data Failure** | 500 Errors across all services, DB locked, data corruption. | **Catastrophic** | Kill traffic to the DB; enter Read-Only mode; start DR procedures. |

**The Decision Logic:**
1. Is it affecting **paying customers**?
2. Is it affecting **multiple services**?
3. Can it be **fixed** in 5 minutes, or should we **roll back** in 30 seconds?

---

## 📊 SRE KPI Dashboard (The Staff Standard)
As a candidate, your value isn't just in "fixing things"; it's in the metrics. These are the three numbers that define our team's success:

| Metric | Definition | The Staff Goal |
| :--- | :--- | :--- |
| **MTTR** | **Mean Time To Repair**. How fast we recover from a failure. | Every incident must have a runbook to drive this toward < 5 mins. |
| **MTBF** | **Mean Time Between Failures**. How stable the system is. | High MTBF shows your automation is robust and self-healing. |
| **Def. Freq** | **Deployment Frequency**. How often we push to Prod. | We optimize for small, "boring" deployments to reduce risk. |

---

## 📅 Weekly & Monthly Responsibilities

### 1. The Blameless Post-Mortem
When things break, we don't look for people to blame; we look for systems to fix. Use our [Post-Mortem Template](./templates/post-mortem-template.md) to document every incident.

### 2. The On-Call Rotation (Holding the Pager)
You will eventually join the "Pager Rotation." This means being available 24/7 for a week to respond to high-priority alerts via **PagerDuty** or **OpsGenie**.
*   **Rule 1**: Your laptop is your lifeline.
*   **Rule 2**: Silence is only okay if the dashboard is green.

---

## 🏁 Your Next Steps
1.  Complete the [Morning Triage Simulation](./01-morning-triage-sim/readme.md).
2.  Master the [Prioritization Framework (Eisenhower Matrix)](./prioritization-framework.md).
3.  Review the [Security-First Gate](./02-the-code-review-gate/readme.md).
4.  Master the [Rollback Procedures](./03-rollback-procedures/readme.md).
5.  Print the [Daily Success Checklist](../daily-checklist.md) and keep it on your desk.
