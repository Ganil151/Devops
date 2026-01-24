# ☁️ AWS CloudWatch: Foundational Monitoring

Welcome to the AWS native visibility hub. CloudWatch is the central nervous system of AWS, providing data for metrics, log storage, and automated event triggers.

---

## 🏗️ Core Components

### 1. CloudWatch Metrics
Time-series data for all AWS resources.
- **Resolution**: Standard (5 min), Detailed (1 min), or Custom (up to 1 sec).
- **Pro Tip**: AWS doesn't track RAM or Disk space by default. Use the **CloudWatch Agent**.

### 2. CloudWatch Logs
The storage and analysis layer for server and application output.
- **Log Groups**: Organized containers for streams.
- **Insights**: SQL-like querying for rapid log analysis.

### 3. Alarms & Dashboards
The visualization and reaction layer.
- **Static Alarms**: "Notify me if CPU > 80%".
- **Composite Alarms**: Combine multiple metrics to reduce alert fatigue.

---

## 🛠️ Essential Automation
CloudWatch integrates directly with **Amazon EventBridge** to trigger:
- **Auto Scaling**: Based on real-time traffic demand.
- **Lambda Functions**: To auto-remediate common system failures.
- **SNS Notifications**: Slacking or Texting the on-call engineer.

---

## 📖 Real-World DevOps Story: "The Hidden Cost of High Resolution"
Observability isn't free. Learn how a startup's bill exploded by $15k because they enabled high-resolution monitoring for non-critical services.

---

## 👔 Interview Prep & Deep Dives
Learn how to install the Unified Agent, configure Logs Insights queries, and manage monitoring costs at scale.

---

## 🔗 Internal Navigation
- [Next Part: Distributed Tracing](../../Part-3-Distributed-Tracing-and-APM/README.md)
- [Back: Log Management](../02-Log-Management/README.md)

---
*Cloud visibility is the foundation of cloud control.*
