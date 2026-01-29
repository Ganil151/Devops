# 📊 Monitoring & Observability: Definition of Done Checklist

> **"If you aren't measuring it, it isn't in production. Observability is the ability to understand a system's internal state from its external outputs."**

---

## 1. Logging Strategy

- [ ] **Implementation of Structured (JSON) Logging**
    - **The "Why"**: Allows logging platforms (ELK, Loki) to parse and index log fields automatically, enabling fast searching and dashboarding.
    - **Verification**: Check application output; it should be single-line JSON objects, not pretty-printed text.
    - **Command**: `kubectl logs <pod_name> | head -n 1` (should look like `{"level":"info", "msg":...}`).

- [ ] **Log Level Governance (Environment-Based)**
    - **The "Why"**: Prevents "Log Exhaustion" in production by limiting verbose (Debug) logs while ensuring critical errors are always captured.
    - **Verification**: Switch an environment variable (e.g., `LOG_LEVEL`) and verify the volume of output changes.
    - **Command**: `grep "DEBUG" log_output.txt` should be empty in a production-mode run.

---

## 2. Infrastructure & Application Metrics

- [ ] **Exposed Health & Metric Endpoints**
    - **The "Why"**: Allows metrics collectors (Prometheus) to periodically scrape the state of the application (Up/Down, Requests/Sec).
    - **Verification**: Hit the `/metrics` or `/health` endpoint of the application.
    - **Command**: `curl localhost:8080/metrics` or `kubectl get endpoints`.

- [ ] **The "Four Golden Signals" Monitoring**
    - **The "Why"**: SRE standard for monitoring user-facing systems: Latency, Traffic, Errors, and Saturation.
    - **Verification**: Ensure dashboards (Grafana) or alerts cover at least these four metrics.
    - **Command**: Verify Prometheus queries like `sum(rate(http_requests_total{status=~"5.."}[5m]))`.

---

## 3. Alerting & Incident Readiness

- [ ] **Actionable Alerting Thresholds**
    - **The "Why"**: Prevents "Alert Fatigue" by only paging engineers when an actual customer-impacting event or critical exhaustion is imminent.
    - **Verification**: Describe the alert logic; it must include a link to a **Runbook** for the operator.
    - **Command**: Check Alertmanager or cloud-native alert definitions (e.g., CloudWatch Alarms).

- [ ] **Distributed Tracing (for Microservices)**
    - **The "Why"**: Enables tracking a single request across multiple services to find bottlenecks in a distributed system.
    - **Verification**: Verify that a Trace ID is propagated in headers (e.g., Jaeger, Zipkin, or X-Ray).
    - **Command**: Check HTTP headers for `X-B3-TraceId` or equivalent.

---

## ❓ Professional Validation (Interview Readiness)

1. **Q: What is the difference between Monitoring and Observability?**
   - *A: Monitoring tells you **when** something is wrong (e.g., CPU is 100%). Observability allows you to understand **why** something is wrong by providing high-cardinality data and traces.*

2. **Q: Why are 'Runbooks' linked in every alert?**
   - *A: To reduce MTTR (Mean Time To Recovery). An engineer at 3:00 AM shouldn't be guessing the fix; they should have a step-by-step guide ready.*
