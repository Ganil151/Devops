# 🧪 Automation Challenges: Building the Guardrails

Automation is where FinOps becomes a scalable engineering practice.

---

## 🏗️ Challenge 1: The "Shift-Left" Architect
**Scenario**: A developer opens a PR that upgrades an RDS instance from `db.t3.medium` to `db.r5.4xlarge`.
**Task**: 
1.  Study the `src/infracost_ci.yml` workflow.
2.  Explain how this tool helps catch the "NAT Gateway Mistake" from the root README before it's deployed.
3.  **Governance Question**: Should you *lock* the PR from being merged if the cost increase is >$1,000, or just notify the manager? Defend your choice.

---

## 💤 Challenge 2: The Sleepy Cluster
**Scenario**: You have 50 dev environments that are only used from 9 AM to 6 PM EST.
**Task**:
1.  Review the logic in `shutdown_scheduler.py` (found in `src/`).
2.  How would you modify the script to *exclude* instances that have a `Critical: "true"` tag?
3.  Calculate the savings: If 50 instances cost $1/hr and you shut them down for 12 hours a day + all weekend.

---

## 🚨 Challenge 3: Anomaly Response
**Scenario**: Your Cost Anomaly Detection alerts you to a $500/hr spike in S3 `PutObject` calls.
**Task**:
1.  What is the first "Automated Action" you would take? (e.g., Alerting Slack, Killing the IAM user, etc.)
2.  How do you distinguish between a valid Black Friday traffic spike and a runaway log-loop bug?

---

## 📂 Challenge 4: Multi-Cloud Tooling
**Scenario**: Your company now uses both AWS and Azure.
**Task**:
1.  Pick one "Third-Party" tool from the README (e.g., CloudHealth, Vantage, or Kubecost).
2.  Research its pricing and "Value Add" over native tools.
3.  Why is a third-party tool often better for a Multi-Cloud environment than using AWS Cost Explorer + Azure Cost Management separately?

---
### 🏁 Finished?
You've built the robots to manage the money. Proceed to **[06: Interview Mastery](../06-interview-questions-and-quizzes/readme.md)** to seal your career path.
