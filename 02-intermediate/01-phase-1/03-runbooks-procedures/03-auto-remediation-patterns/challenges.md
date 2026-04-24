# Auto-Remediation Patterns Challenges 🤖

Master the "Self-Healing" workflows that allow systems to fix themselves while you sleep.

---

## 🏆 Challenge 01: The Periodic Healer (Cron-based)
**Objective**: Automate simple cleanup tasks to prevent disk exhaustion.

1.  **Requirement**: Design a script that monitors `/var/log`.
2.  **Task**: If the directory exceeds 5GB, delete any `.log.gz` files older than 30 days.
3.  **Action**: Schedule this using a standard `crontab` entry or a Systemd Timer.
4.  **Verification**: Write a mock log generator to test the cleanup logic.

---

## 🏆 Challenge 02: Event-Driven Remediation (AWS Lambda)
**Objective**: React to real-time infrastructure alerts.

1.  **Scenario**: An EC2 instance enters a `stopped` state unexpectedly.
2.  **Logic**: 
    *   **Trigger**: CloudWatch Event (EC2 State Change).
    *   **Function**: A Python helper that checks if the instance has a tag `auto-restart: true`.
    *   **Action**: If yes, restart the instance and send a Slack notification.
3.  **Goal**: Explain the flow: Event -> Trigger -> Logic -> Action.

---

## 🏆 Challenge 03: The Circuit Breaker
**Objective**: Stop a system before a failure cascades.

1.  **Scenario**: A database is timing out. Scaling it up takes 10 minutes.
2.  **Task**: Design an auto-remediation rule that "Disconnects" non-essential services (like a batch processor) until DB latency drops below 200ms.
3.  **Discovery**: Research tools like **StackStorm** or **AWS Systems Manager (SSM) Automation**.
4.  **Analysis**: What is the risk of "Auto-Remediation loops"? (e.g., system restarts every 30 seconds forever).

---

## 📁 Solutions
Remediation scripts and Lambda logic templates are in the `Boilerplates/` directory.
