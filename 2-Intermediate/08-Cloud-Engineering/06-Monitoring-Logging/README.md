# Monitoring, Logging & Observability - Intermediate

You cannot manage what you do not measure. This module teaches you how to gain deep visibility into your cloud infrastructure and applications.

---

## 1. Pillars of Cloud Observability

- **Metrics (CloudWatch)**: Quantitative data over time (e.g., CPU %, Error Count).
- **Logs (CloudWatch Logs)**: Discreet events with detailed information (e.g., Application errors, Access logs).
- **Traces**: End-to-end paths of requests (Covered in Advanced Level).
- **Audit (CloudTrail)**: Recording of every API call made in your account (Who did what, when).

---

## 2. Core Services Reference

| Service | Primary Use | Example |
| :--- | :--- | :--- |
| **CloudWatch Metrics** | Real-time monitoring. | Alarm if CPU > 80%. |
| **CloudWatch Alarms** | Automated response. | Trigger Auto Scaling or SNS. |
| **CloudWatch Logs** | Debugging & Archiving. | Analyze Nginx access logs. |
| **CloudTrail** | Auditing & Compliance. | Tracking who deleted an S3 bucket. |

---

## 3. Learning Path

1.  **[AWS Monitoring Comprehensive](aws-monitoring-comprehensive.md)**: Deep dive into CloudWatch, Alarms, and Dashboards.
2.  **[CloudWatch Log Insights](log-insights-guide.md)**: Master the query language to parse millions of log lines in seconds.

---

## 4. Best Practices
- **Custom Metrics**: Don't just monitor CPU; send business metrics (e.g., Orders/Min) to CloudWatch.
- **Log Retention**: Set appropriate retention periods to save costs.
- **Centralized Logging**: Stream logs to a central account for enterprise visibility.

---
**Advanced Observability**: Check out [AWS X-Ray](../../Advanced-Level/17-Observability-Governance/README.md) for distributed tracing.