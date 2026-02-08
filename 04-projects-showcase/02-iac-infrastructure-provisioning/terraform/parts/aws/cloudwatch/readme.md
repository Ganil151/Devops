# AWS CloudWatch Architectural Patterns

This directory contains 20 common CloudWatch patterns for monitoring, logging, and alerting using Terraform. CloudWatch provides you with data and actionable insights to monitor your applications, respond to system-wide performance changes, and optimize resource utilization.

## 📂 CloudWatch Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Log Group** | Centralized log storage with retention rules. | `01-log-group.tf` |
| 2 | **CPU Alarm** | Threshold-based alerting for EC2 instances. | `02-cpu-alarm.tf` |
| 3 | **Metric Filter** | extracting metrics from unstructured text logs. | `03-metric-filter.tf` |
| 4 | **Dashboard** | Visualizing infrastructure health in one place. | `04-dashboard.tf` |
| 5 | **Composite Alarm** | Multi-metric logical alerts (AND/OR). | `05-composite-alarm.tf` |
| 6 | **Synthetics Canary**| Uptime and latency heartbeats (Puppeteer). | `06-synthetics-canary.tf` |
| 7 | **Log Subscription**| Streaming logs to Kinesis or S3. | `07-log-subscription.tf` |
| 8 | **Anomaly Detect** | Machine learning-based alert thresholds. | `08-anomaly-detection.tf` |
| 9 | **EB Pipe** | Connecting event sources to targets with pipes. | `09-eventbridge-pipes.tf` |
| 10 | **Resource Policy**| allowing services to write to log groups. | `10-resource-policy.tf` |
| 11 | **Insight Query** | Saved Log Insight queries for debugging. | `11-insight-queries.tf` |
| 12 | **Lambda Alarm** | monitoring function errors and timeouts. | `12-lambda-error-alarm.tf` |
| 13 | **S3 Alarm** | monitoring bucket storage size and metrics. | `13-s3-metrics-alarm.tf` |
| 14 | **RDS Alarm** | Warning for low database storage space. | `14-rds-storage-alarm.tf` |
| 15 | **Scheduled Rule** | Recurring EventBridge maintenance triggers. | `15-scheduled-rule.tf` |
| 16 | **Metric Stream** | bulk export of metrics to external tools. | `16-metric-stream.tf` |
| 17 | **Insight Rule** | identifying top contributors (e.g., Top IP). | `17-insight-rules.tf` |
| 18 | **Log Destination**| cross-account centralized logging setup. | `18-log-destination.tf` |
| 19 | **Metric Math** | logic-based triggers (e.g., % Error Rate). | `19-metric-math.tf` |
| 20 | **Minimalist** | Baseline alert boilerplate. | `20-minimalist-cw.tf` |

## 🚀 Key Best Practices
1.  **Retention Policies**: Never leave log retention as "Never Expire". Set a reasonable policy (e.g., 30-90 days) to avoid unnecessary storage costs.
2.  **Infrastructure as Code Dashboards**: manage your dashboards in Terraform to ensure they reflect the current state of your resources.
3.  **Actionable Alarms**: Every alarm should have an action (SNS, Lambda, Autoscaling). If an alarm fires and no one is notified, it's not useful.
4.  **Metric Math**: Use math expressions to create "Service Level Indicators" (SLIs) like Availability % or Success Rate instead of raw counts.
5.  **Audit Logs**: Enable **CloudTrail** and send those logs to CloudWatch to monitor for unauthorized API calls or security breaches.

## 🛠 Prerequisites
These resources typically require an **SNS Topic** for notifications. refers to the `messaging` directory for topic patterns.
