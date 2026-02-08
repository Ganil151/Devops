# ✅ Junior DevOps Daily Success Checklist (SRE Standard)

Use this checklist during your first 90 days to ensure you are maintaining "Situational Awareness" and proactive ownership of the infrastructure.

### 🌅 The Pulse Check (First 30 Minutes)

- [ ] **Grafana/Prometheus**: Scan the Master Dashboard. Check the "Golden Signals": **Latency**, **Traffic**, **Errors**, and **Saturation**.
- [ ] **Slack/Teams #Alerts**: Triage unacknowledged critical alerts. Check the thread history to see if a Senior already touched them.
- [ ] **CI/CD Pipelines**: Review the "Nightly Integration" runs. If a test failed, was it a "Flaky Test" or a legitimate infrastructure regressions?
- [ ] **Cost Watch**: Check the AWS/Azure Billing dashboard (or Kubecost). Are we trending towards a budget blowout for the month?

### ⚙️ The Engineering Block (Mid-Day)

- [ ] **PR Review Queue**: Review at least 2 IaC Pull Requests. Focus on **Security** (SG rules) and **Consistency** (Tagging).
- [ ] **Drift Detection**: Run a `terraform plan` on a core set of infrastructure. Did a manual change (toil) bypass our version control?
- [ ] **Secret Hygiene**: Run a quick scan of the repos you worked on today (e.g., `gitleaks protect --staged`).

### 🚨 Operational Readiness

- [ ] **Incident Rehearsal**: Do you know the exact command to roll back the current production version of the primary service? (Check the [Rollback Guide](./02-day-in-the-life-operations/03-rollback-procedures/readme.md)).
- [ ] **On-Call Handover**: If you are entering the rotation, verify your PagerDuty schedule and ensure your notification settings are loud enough.

### 🌇 The Legacy Check (End of Day)

- [ ] **Documentation Debt**: If you implemented a workaround today, did you document it in the Wiki or local README?
- [ ] **Toil Audit**: Identify one manual task you did today that took more than 15 minutes. Add it to your "Automation Backlog" for tomorrow.
- [ ] **Handover Note**: Leave a short summary in `#ops-log` or `#devops-handoff` if a task is still in progress.

---
*"Junior DevOps Engineers fix bugs. Senior DevOps Engineers fix the processes that allowed the bugs to happen."*
