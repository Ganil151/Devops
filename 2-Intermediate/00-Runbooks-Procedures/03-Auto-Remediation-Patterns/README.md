# 03: Auto-Remediation Patterns

The ultimate goal of a DevOps engineer is to build a **Self-Healing Infrastructure**. Auto-remediation is the practice of having the system detect and fix its own problems based on pre-defined runbooks.

## 🤖 The Remediation Loop

1.  **Observe**: A monitoring tool (Prometheus, CloudWatch) detects an anomaly.
2.  **Evaluate**: An alert rule determines if action is required.
3.  **Execute**: A script or function (Lambda, Bash) runs the fix.
4.  **Verify**: The monitoring tool checks if the system returned to health.
5.  **Notify**: A human is informed that a problem occurred and was resolved.

---

## 🛠️ Common Patterns

### 1. The "Restart" Pattern
- **Trigger**: Service returns 502 Bad Gateway.
- **Action**: Restart the Docker container or systemd service.
- **Risk**: Low (as long as persistent data isn't affected).

### 2. The "Disk Cleanup" Pattern
- **Trigger**: Disk usage exceeds 90%.
- **Action**: Delete temporary logs or rotate archives to S3.
- **Risk**: Minimal.

### 3. The "Auto-Scaling" Pattern
- **Trigger**: CPU > 80% for 5 minutes.
- **Action**: Proactively spin up new instances.
- **Risk**: Moderate (Cost implications).

---

## 🛑 Safety Boundaries

Never automate a fix that could cause catastrophic failure if it triggers incorrectly.
- **Retry Limits**: Only try to auto-reboot a server 3 times. If it's still down, page a human.
- **Throttling**: Don't allow auto-remediation to delete more than 10% of your fleet at once.
- **Circuit Breakers**: If the "fix" leads to more errors, stop the automation immediately.

---

## 🛠️ Implementation Tools
- **AWS Lambda / EventBridge**: Trigger code in response to CloudWatch Alarms.
- **StackStorm**: A powerful open-source event-driven automation platform.
- **Project Flogo**: Ultra-lightweight event-driven framework for edge and cloud.
