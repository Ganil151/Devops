# Event-Driven Triggers

Modern auto-remediation relies on **event-driven architecture** where alerts automatically trigger remediation workflows.

## Event Sources

### 1. Metrics-Based (Time-Series)
Triggered when a metric crosses a threshold.
- **Example**: "CPU > 90% for 5 minutes."
- **Tools**: Prometheus Alertmanager, CloudWatch Alarms, Datadog Monitors.

### 2. Log-Based (Pattern Matching)
Triggered when a specific error appears in logs.
- **Example**: "ERROR: OutOfMemoryException" appears 10 times in 1 minute.
- **Tools**: ELK Stack, Splunk, CloudWatch Logs Insights.

### 3. Trace-Based (Distributed Tracing)
Triggered by anomalies in request flows.
- **Example**: "Latency spike in payment service."
- **Tools**: Jaeger, Zipkin, AWS X-Ray.

### 4. Synthetic Monitoring
Triggered when a synthetic test fails.
- **Example**: "Health check endpoint returns 500."
- **Tools**: Pingdom, Datadog Synthetics, AWS Route 53 Health Checks.

---

## Event Routing Platforms

### AWS EventBridge
```json
{
  "source": ["aws.cloudwatch"],
  "detail-type": ["CloudWatch Alarm State Change"],
  "detail": {
    "alarmName": ["DiskSpaceHigh"],
    "state": {"value": ["ALARM"]}
  }
}
```
**Target**: Lambda function that runs cleanup script.

### Kubernetes Event-Driven Autoscaling (KEDA)
Scales pods based on external metrics (queue depth, HTTP requests).

### StackStorm
Open-source automation platform with built-in event routing.

---

## 🏗️ Real-Life Scenario: The "Missed" Alert
**Problem**: A critical alert fires, but it's sent to an email inbox that no one monitors.
**Outcome**: The database fills up and crashes. The alert was sent 2 hours earlier.
**Fix**: Implement **Event-Driven Automation**. The alert triggers a Lambda function that runs the cleanup script immediately, and *also* sends a Slack notification.
**Result**: MTTR drops from 2 hours to 30 seconds.

---

## ❓ Interview Questions
1.  **What is the advantage of event-driven remediation over scheduled jobs?**
    *   *Answer*: Event-driven is reactive and immediate (fixes issues as they occur), while scheduled jobs are periodic and may miss time-sensitive issues or waste resources running when not needed.
2.  **How do you prevent 'Alert Storms' from triggering too many remediation actions?**
    *   *Answer*: Use alert aggregation, deduplication windows, and circuit breakers. For example, "Only trigger remediation once per 15 minutes for the same alert."

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which event source uses thresholds?** (Metrics-Based)
2.  **True/False: Log-based triggers require pattern matching.** (True)
3.  **What is KEDA used for?** (Event-driven autoscaling in Kubernetes)
4.  **Which AWS service routes events to Lambda?** (EventBridge)
5.  **What is 'Synthetic Monitoring'?** (Automated tests that simulate user behavior)
