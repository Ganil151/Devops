# 🤖 05: FinOps-as-Code & Automation

**[⬅️ Back to Module Index](../readme.md)** | **[Next: Interview Mastery ➡️](../06-interview-questions-and-quizzes/readme.md)**

---

# ⚙️ Shift-Left FinOps

Manual cost optimization doesn't scale. To manage an enterprise cloud with thousands of resources, you must build **Cost Guardrails** directly into your engineering workflows. This module covers automation from CI/CD to runtime governance.

## 🏗️ The Automation Layers

1.  **Pre-Deployment**: Predicting costs before the code is merged (Infracost).
2.  **Runtime Scheduling**: Shutting down dev/test environments during nights/weekends.
3.  **Self-Healing Cleanup**: Automatically deleting orphaned EBS volumes or idle Elastic IPs.
4.  **Anomaly Detection**: Real-time alerts when a service spikes unexpectedly.

---

## 🏎️ Shift-Left: Infracost

Infracost allows you to see the financial impact of a Terraform change directly in your Pull Request.
*   **Junior Way**: Merging code and waiting 30 days for the bill.
*   **Architect Way**: Blocking a PR because it increases the monthly spend by $5,000 without justification.

> See the example in `src/infracost_ci.yml`.

---

## 💤 The Weekend Shutdown: Scheduler

Most dev environments are idle 70% of the time (nights and weekends).
*   **Strategy**: Use Lambda and EventBridge to "Stop" instances at 8 PM and "Start" them at 8 AM.
*   **Tagging**: Only resources with `AutoShutdown: "true"` are affected, allowing production and critical dev tools to stay up.

---

## 🚨 Anomaly Detection: The "Anti-Spike" Guard

When an infinite loop in a script starts thousands of tasks, you need to know **In Seconds**, not days.
*   **AWS Cost Anomaly Detection**: Uses machine learning to find spikes that deviate from your normal usage patterns.
*   **Action**: Send a Slack alert or trigger a Lambda to "Kill" the suspicious process.

---

## 📂 Project Structure

Check out the `src/` directory for automation blueprints:
- `infracost_ci.yml`: A GitHub Action template to integrate cost estimates into your PRs.
- `shutdown_scheduler.py`: A Python Lambda function to manage dev-environment uptime.
- `slack_alerts.json`: A standard payload for cost anomaly notifications.

---

## 🧪 Experience the Challenges
Ready to automate your savings? Try the **[Automation Challenges](./challenges.md)**.
