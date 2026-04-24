# 🩺 Spring Boot Actuator: Observability
*Production Monitoring for Enterprise Microservices*

---

## 📖 Overview
Actuator brings production-ready features to your application. It provides built-in HTTP endpoints that let you monitor and interact with your application.

---

## 🏗️ Essential Endpoints

- **`/health`**: Shows application health information (UP/DOWN).
- **`/metrics`**: Provides detailed performance counters (CPU, JVM Memory, HTTP errors).
- **`/env`**: Displays current environment variables (Masked by default).
- **`/info`**: Arbitrary application information (Git commit hash, version).

---

## 🚀 Monitoring Stacks

- **Prometheus**: Actuator can expose metrics in Prometheus format via `/actuator/prometheus`.
- **Grafana**: Use the Prometheus data to build visual dashboards of your service health.

---

## 🛡️ SRE Standard Checklist
- [ ] Are `/actuator` endpoints restricted to the internal network?
- [ ] Is the `/health` endpoint integrated with Kubernetes Liveness/Readiness probes?
- [ ] Are custom metrics created to track business-specific logic (e.g., "Deployment Success Count")?

---
**Back to Module**: [SpringBoot Main Guide](../readme.md)
