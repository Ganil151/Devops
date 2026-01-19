# 🟡 Monitoring & Alerting (Intermediate)

## 📚 Overview

Monitoring is the practice of observing the state of your infrastructure using tools like **Prometheus** and **Grafana**. In this module, we transition from manual checks to automated data collection and sophisticated alerting.

## 🎯 Learning Objectives

- ✅ Deploy the **Prometheus + Grafana** stack using Helm.
- ✅ Implement monitoring for **The 4 Golden Signals**.
- ✅ Create custom Grafana dashboards for application health.
- ✅ Configure **Alertmanager** for Slack/Email notifications.

---

## 🏗️ Professional Pattern: The 4 Golden Signals
If you can only monitor four metrics, these are the ones:

1.  **Latency**: The time it takes to service a request.
2.  **Traffic**: A measure of how much demand is being placed on your system (e.g., HTTP req/sec).
3.  **Errors**: The rate of requests that fail, either explicitly (e.g., HTTP 500s) or implicitly.
4.  **Saturation**: How "full" your service is (e.g., memory usage, thread pool utilization).

```mermaid
graph TD
    A[4 Golden Signals] --> B[Latency - ms]
    A --> C[Traffic - req/s]
    A --> D[Errors - %]
    A --> E[Saturation - %]
    
    style B fill:#e74c3c,color:#fff
    style C fill:#3498db,color:#fff
    style D fill:#f1c40f,color:#000
    style E fill:#2ecc71,color:#fff
```

---

## 🛠️ Tooling: Prometheus recording_rules.yml
In production, we use **Recording Rules** to pre-calculate frequently needed or computationally expensive expressions.

**Boilerplate:** `prometheus_rules.yml`
```yaml
groups:
  - name: example_rules
    rules:
      - record: job:http_inprogress_requests:sum
        expr: sum by (job) (http_inprogress_requests)
      - alert: HighRequestLatency
        expr: job:request_latency_seconds:mean5m{job="my-app"} > 0.5
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High request latency on {{ $labels.instance }}"
```

---
**Next Step**: [Prometheus & Grafana via Helm](./01-Prometheus-Grafana-Helm/) 🚀
