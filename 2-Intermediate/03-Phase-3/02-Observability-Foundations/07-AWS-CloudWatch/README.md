# AWS CloudWatch: Foundational Monitoring

CloudWatch is the native observability service for AWS, providing metrics, logs, and actionable insights for your cloud resources.

---

## 🏗️ Core Components

### 1. CloudWatch Metrics
- **Definition**: Time-series data points about your AWS resources (EC2, RDS, Lambda, etc.).
- **Resolution**: Standard (1-minute) or High (1-second).
- **Namespaces**: Logical containers for metrics (e.g., `AWS/EC2`).

### 2. CloudWatch Logs
- **Log Groups**: Logical containers for log streams.
- **Log Streams**: Sequences of log events from a specific source (pod, instance).
- **Metric Filters**: Search and filter log data to turn it into numerical metrics.

### 3. CloudWatch Alarms
- **Static Threshold**: Alerts when a metric crosses a fixed value.
- **Anomaly Detection**: Uses ML to predict expected behavior and alert on deviations.

---

## 🛠️ Hands-On: Basic Monitoring

1. **EC2 Monitoring**: By default, EC2 sends metrics every 5 minutes. Enable "Detailed Monitoring" for 1-minute intervals.
2. **Log Agent**: Install the `Unified CloudWatch Agent` on servers to collect system-level metrics (RAM, Disk) and log files.
3. **Dashboards**: Create a unified view of your application's health by pinning multiple metric widgets.

---

> [!IMPORTANT]
> **CloudWatch Agent**: AWS resources don't send memory or disk usage metrics by default. You MUST install the CloudWatch Agent to capture these OS-level metrics.

---

## 📺 Recommended YouTube Lessons
- **[AWS CloudWatch Tutorial for Beginners](https://www.youtube.com/watch?v=hiKPPy582vg)**
- **[Monitoring AWS Infrastructure with CloudWatch](https://www.youtube.com/watch?v=tK9Oc6AEnR4)**
