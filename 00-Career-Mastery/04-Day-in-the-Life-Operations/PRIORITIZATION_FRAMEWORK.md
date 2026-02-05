# 🚦 Prioritization: The Eisenhower Matrix & Customer Impact

In DevOps and SRE (Site Reliability Engineering), everything often feels "Urgent." Learning how to triage effectively is the difference between a Junior who burns out and a Senior who stabilizes the system.

---

## 🏛️ 1. The Eisenhower Matrix (SRE Edition)

This framework helps you categorize tasks based on **Urgency** and **Importance**. It is the primary tool for managing "Toil" vs. "Project Work."

| | **Important** | **Not Important** |
| :--- | :--- | :--- |
| **Urgent** | **Q1: Crisis Management (DO)**<br>• Production Outages<br>• Security Breaches<br>• Database Corruption<br>*Action: Urgent response required.* | **Q3: Interruptions (FILTER/DELEGATE)**<br>• Non-actionable Slack pings<br>• "Urgent" non-impact feature requests<br>• Low-value meetings<br>*Action: Minimize or automate these.* |
| **Not Urgent** | **Q2: The Staff Standard (PLAN)**<br>• Automation (Reducing Toil)<br>• Disaster Recovery Planning<br>• Infrastructure Refactoring<br>*Action: This is where you build the future.* | **Q4: The Distractions (ELIMINATE)**<br>• Over-engineering one-off tasks<br>• Redundant manual reports<br>• Deep-diving into "Interesting" but irrelevant tech<br>*Action: Stop doing these.* |

### 💡 The Mindset: Expand Quadrant 2
A Junior lives in **Quadrant 1** (Firefighting). A Senior Engineer lives in **Quadrant 2** (Prevention). Your goal is to automate Q1 tasks so they move to Q2 or disappear entirely.

---

## 🎯 2. The "Customer Impact" Framework

When multiple tasks are in Q1, use the **Customer Impact** lens to decide what to fix first. This aligns technical effort with business value.

### 🔴 P0: High Impact (Immediate Action)
- **Revenue Blocked**: Users cannot complete transactions/checkout.
- **Data Integrity**: The system is losing or corrupting user data.
- **Global Outage**: The primary service is down for all regions.

### 🟡 P1: Medium Impact (Triage)
- **Degraded Performance**: The site is extremely slow (Latencies > 3s).
- **Tooling Failure**: Developers cannot deploy code (CI/CD down).
- **Feature Partial Failure**: A sub-feature (e.g., "Reset Password") is broken.

### 🔵 P2: Low Impact (Backlog)
- **Cosmetic Bugs**: Typos, styling issues, or broken links in help docs.
- **Noisy Alerts**: Monitoring alerts that don't represent a service failure.
- **Refactoring**: Improving code that is currently working and performing well.

---

## 🛠️ The Operational Rule: "Customer First, System Second"

1.  **Stop the Bleeding**: Restore service immediately using a rollback or a "dirty fix" to lower **MTTR** (Mean Time To Recovery).
2.  **Verify**: Ensure the customer is back online.
3.  **Root Cause Analysis (RCA)**: Perform a deep dive to ensure the issue never happens again.

---

### 🚀 Practical Application
Apply these frameworks in the **[Morning Triage Simulation](./01-Morning-Triage-Sim/README.md)** to decide which alert to investigate first.
