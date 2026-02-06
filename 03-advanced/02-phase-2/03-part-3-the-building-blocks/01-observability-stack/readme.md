# Observability Stack

> **Advanced monitoring, logging, and distributed tracing**

## Core Concept: The Unified Observability Fabric
**[REFERENCE: Observability Strategy & Architecture](./reference/observability-strategy-architecture-ref.md)**

Moving beyond simple monitoring to deep systems understanding:
- **Unified Data Model**: Utilizing OpenTelemetry to bridge metrics, logs, and traces into a single correlated context.
- **SLO-Driven Operations**: Shifting focus from "noisy alerts" to business-aligned Service Level Objectives.
- **High-Cardinality Analysis**: Enabling granular debugging through advanced metric and trace indexing.

## Enterprise Governance: Observability Compliance
**[REFERENCE: Log Aggregation & Compliance](./reference/log-aggregation-compliance-ref.md)**

Scaling visibility while maintaining security and cost control:
- **Centralized Audit Trails**: Ensuring every API call and system change is immutably recorded for regulatory proof.
- **Cost-Optimized Retention**: Implementing multi-tier storage strategies (Loki/S3) to balance troubleshooting speed with long-term cost.
- **PII Redaction & Security**: Automatically stripping sensitive data at the edge before it enters the storage backend.
- **Standardized Metadata**: Enforcing consistent labeling across the fleet to enable global dashboarding and chargeback.

---

## 📚 Modules in This Part

1. **[01-Observability-Advanced](./01-observability-advanced/)** - 01 Observability Advanced
2. **[02-Logging-Loki-FluentBit](./02-logging-loki-fluentbit/)** - 02 Logging Loki FluentBit

---

## 🎯 Learning Path

These modules should be completed in the order shown above for optimal learning progression.

### Prerequisites

- Solid understanding of Kubernetes
- Experience with cloud platforms (AWS/GCP/Azure)
- Familiarity with GitOps principles

### Estimated Time

- Total: 16-24 hours
- Per module: ~8-12 hours

---

## 📂 Practical Code & Scripts

Accelerate your observability skills with production-ready monitoring:

- **[Prometheus Lab Scripts](./prometheus/)**: Installation guides and node exporter setup.
- **[Loki & Grafana Dashboards](readme.md)**: Examples of log aggregation and visualization.

---

## 🔗 Related Parts

- [Part 1: Service Mesh](readme.md) - Service metrics
- [Part 8: Resilience](readme.md) - Incident response

---

**Part of**: [Advanced Phase-2: Strategic Skills](../readme.md)
