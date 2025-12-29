# Observability: Interview Questions, Quiz & Scenarios

Master the art of debugging distributed systems with advanced observability patterns.

---

## ❓ Interview Questions (Advanced)

1.  **Explain the "Three Pillars of Observability" and how they differ.**
    *   *Answer*: **Metrics** (Numbers over time - Aggregated), **Logs** (Events - Granular), and **Traces** (Request path - Distributed). Metrics tell you *if* there is a problem; Logs and Traces tell you *where* and *why*.
2.  **What are the "Four Golden Signals" of SRE?**
    *   *Answer*: Latency, Traffic, Errors, and Saturation.
3.  **How do you handle "Cardinality" in Prometheus?**
    *   *Answer*: High cardinality (too many unique label values like UserIDs) causes memory spikes. Solution: Avoid unique IDs in labels and use recording rules to aggregate frequently used data.
4.  **Describe the difference between Pull-based (Prometheus) and Push-based (OTLP) collection.**
    *   *Answer*: Prometheus scrapes endpoints (scaling depends on the scraper). OTLP pushes data to a collector (scaling depends on the endpoint).

---

## 🧠 Observability Knowledge Quiz (20+ Questions)

1.  **What does 'SLA' stand for?** (Service Level Agreement)
2.  **Which tool is primarily used for visualization in the Kube-Prometheus-Stack?** (Grafana)
3.  **What is 'PromQL'?** (The query language for Prometheus)
4.  **What is a 'Metric' in observability?** (A numerical representation of data measured over intervals)
5.  **True/False: Logs are better for high-level trends than metrics.** (False)
6.  **What is 'Distributed Tracing'?** (Tracking a single request as it passes through multiple microservices)
7.  **What is a 'Span' in tracing?** (The basic building block of a trace; represents a unit of work)
8.  **Which library is the industry standard for tracing?** (OpenTelemetry)
9.  **What is 'Sampling' in tracing?** (Capturing only a percentage of traces to save storage/bandwidth)
10. **What is an 'Alertmanager'?** (The component that handles deduplication and routing of alerts from Prometheus)
11. **What is 'TSDB'?** (Time Series Database)
12. **Which component of ELK stores the data?** (Elasticsearch)
13. **What is 'Loki'?** (A log-aggregation system inspired by Prometheus)
14. **What is 'Saturation' in SRE?** (How "full" your service is; measure of system constraints)
15. **What is 'White-box Monitoring'?** (Monitoring based on internal logs/metrics from the application)
16. **What is 'Black-box Monitoring'?** (Monitoring from the outside, like health checks or probes)
17. **What is an 'Exporter' in Prometheus?** (A component that translates system metrics into Prometheus format)
18. **What is 'Service Level Indicator' (SLI)?** (A quantitative measure of some aspect of the level of service)
19. **What is 'MTTR'?** (Mean Time To Resolution)
20. **Which tool is used for tracing in AWS?** (X-Ray)
21. **What is 'OpenTelemetry Collector'?** (A vendor-agnostic proxy that receives, processes, and exports telemetry data)

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The Silent 500s
**Problem**: An API was returning 500 errors, but the CPU and Memory were normal.
**Solution**: Looking at Traces (Jaeger/Honeycomb), the team found that a specific downstream database query was timing out. Monitoring only metrics would have missed this granular failure.

### Scenario 2: Cardinality Explosion
**Problem**: Prometheus memory usage spiked following a release.
**Solution**: Using `topk` queries, the team discovered a developer added `user_email` as a label in a custom metric. Removing the label and using a log for that data fixed the memory leak.

### Scenario 3: Log overload in ELK
**Problem**: Elasticsearch became unreachable during an traffic spike.
**Solution**: The team implemented Logstash and a Redis buffer to handle peaks. They also configured Index Lifecycle Management (ILM) to automatically move old logs to "cold" storage.
