# Observability Foundations: Monitoring & Logging

Observability is the ability to measure the internal state of a system by examining its outputs. In the DevOps lifecycle, it moves us from reactive troubleshooting to proactive system management.

---

## 🗺️ The Observability Learning Path

Follow these modules in order to master system visibility:

1.  **[01-Monitoring-Basics](./01-Monitoring-Basics/README.md)**: Master the Four Golden Signals (Latency, Traffic, Errors, Saturation).
2.  **[02-Log-Management](./02-Log-Management/README.md)**: Learn log levels, stdout redirection, and structured logging (JSON).
3.  **[03-Health-Checks-and-Probers](./03-Health-Checks-and-Probers/README.md)**: Difference between Liveness, Readiness, and Synthetic probes.
4.  **[04-Tracing-Foundations](./04-Tracing-Foundations/README.md)**: Introduction to Distributed Tracing and APM tools.
5.  **[05-Interview-Questions-and-Quizzes](./05-Interview-Questions-and-Quizzes/README.md)**: Test your knowledge and prepare for job screenings.
6.  **[06-Real-Life-Scenarios](./06-Real-Life-Scenarios/README.md)**: Practical troubleshooting and architecture challenges.
7.  **[07-AWS-CloudWatch](./07-AWS-CloudWatch/README.md)**: Native AWS monitoring, metrics, and logs.
8.  **[📺 YouTube Lessons](./Youtube_Lessons.md)**: Curated video tutorials for visual learning.

---

## 🏗️ 1. Core Philosophies
- **MTTR > MTBF**: In modern systems, failures are inevitable. Focus on reducing the **Mean Time To Repair** through visibility.
- **Symptom-Based Alerting**: Only alert when an actual user is affected, not every time a metric fluctuates.
- **Data over Guessing**: Use metrics and traces to find the root cause, never guess.

---

## 🛡️ Tool Overview
- **Metrics**: Prometheus, Grafana, CloudWatch.
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana), Loki, Splunk.
- **Tracing**: Jaeger, Zipkin, New Relic.
- **Health Checks**: Kubernetes Probes, Uptime-Kuma.

---

## ✅ Knowledge Check
- [x] Explain the Four Golden Signals.
- [x] Differentiate between White-box and Black-box monitoring.
- [x] Configure a proper Liveness and Readiness probe.
- [x] Understand the benefit of Structured Logging (JSON).
- [x] Identify a "bottleneck" service using a distributed trace.
- [x] Pass the 20-Question assessment in module 05.

---

## 🔗 Next Steps
- **[Advanced Observability](../../3-Advanced/02-Observability/README.md)** - Scale these concepts using Prometheus and the ELK Stack.
- **[Kubernetes Mastery](../07-Kubernetes/)** - Implement probers and log collectors in a K8s cluster.

---
*If you can't measure it, you can't improve it.*