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

<b>1. What does 'SLA' stand for?</b>
<details>
<summary>Show Answer</summary>
Answer: Service Level Agreement
</details>

<b>2. Which tool is primarily used for visualization in the Kube-Prometheus-Stack?</b>
<details>
<summary>Show Answer</summary>
Answer: Grafana
</details>

<b>3. What is 'PromQL'?</b>
<details>
<summary>Show Answer</summary>
Answer: The query language for Prometheus
</details>

<b>4. What is a 'Metric' in observability?</b>
<details>
<summary>Show Answer</summary>
Answer: A numerical representation of data measured over intervals
</details>

<b>5. True/False: Logs are better for high-level trends than metrics.</b>
<details>
<summary>Show Answer</summary>
Answer: False
</details>

<b>6. What is 'Distributed Tracing'?</b>
<details>
<summary>Show Answer</summary>
Answer: Tracking a single request as it passes through multiple microservices
</details>

<b>7. What is a 'Span' in tracing?</b>
<details>
<summary>Show Answer</summary>
Answer: The basic building block of a trace; represents a unit of work
</details>

<b>8. Which library is the industry standard for tracing?</b>
<details>
<summary>Show Answer</summary>
Answer: OpenTelemetry
</details>

<b>9. What is 'Sampling' in tracing?</b>
<details>
<summary>Show Answer</summary>
Answer: Capturing only a percentage of traces to save storage/bandwidth
</details>

<b>10. What is an 'Alertmanager'?</b>
<details>
<summary>Show Answer</summary>
Answer: The component that handles deduplication and routing of alerts from Prometheus
</details>

<b>11. What is 'TSDB'?</b>
<details>
<summary>Show Answer</summary>
Answer: Time Series Database
</details>

<b>12. Which component of ELK stores the data?</b>
<details>
<summary>Show Answer</summary>
Answer: Elasticsearch
</details>

<b>13. What is 'Loki'?</b>
<details>
<summary>Show Answer</summary>
Answer: A log-aggregation system inspired by Prometheus
</details>

<b>14. What is 'Saturation' in SRE?</b>
<details>
<summary>Show Answer</summary>
Answer: How "full" your service is; measure of system constraints
</details>

<b>15. What is 'White-box Monitoring'?</b>
<details>
<summary>Show Answer</summary>
Answer: Monitoring based on internal logs/metrics from the application
</details>

<b>16. What is 'Black-box Monitoring'?</b>
<details>
<summary>Show Answer</summary>
Answer: Monitoring from the outside, like health checks or probes
</details>

<b>17. What is an 'Exporter' in Prometheus?</b>
<details>
<summary>Show Answer</summary>
Answer: A component that translates system metrics into Prometheus format
</details>

<b>18. What is 'Service Level Indicator'</b>
<details>
<summary>Show Answer</summary>
Answer: SLI)?** (A quantitative measure of some aspect of the level of service
</details>

<b>19. What is 'MTTR'?</b>
<details>
<summary>Show Answer</summary>
Answer: Mean Time To Resolution
</details>

<b>20. Which tool is used for tracing in AWS?</b>
<details>
<summary>Show Answer</summary>
Answer: X-Ray
</details>

<b>21. What is 'OpenTelemetry Collector'?</b>
<details>
<summary>Show Answer</summary>
Answer: A vendor-agnostic proxy that receives, processes, and exports telemetry data
</details>

<b>22. What is a CloudWatch 'Metric Filter'?</b>
<details>
<summary>Show Answer</summary>
Answer: A feature that turns log patterns into numerical metrics
</details>

<b>23. What is the Datadog 'Unified Service Tagging'?</b>
<details>
<summary>Show Answer</summary>
Answer: Using env, service, and version tags to correlate all telemetry
</details>

<b>24. True/False: Datadog can monitor multiple cloud providers in one dashboard.</b>
<details>
<summary>Show Answer</summary>
Answer: True
</details>

<b>25. What is 'DogStatsD'?</b>
<details>
<summary>Show Answer</summary>
Answer: A metrics aggregation service that sends custom metrics to the Datadog Agent
</details>


---

## 🏗️ Real-Life Scenarios

### Scenario 1: The Silent 500s
**Problem**: An API was returning 500 errors, but the CPU and Memory were normal.
**Solution**: Looking at Traces (Jaeger/Honeycomb or Datadog APM), the team found that a specific downstream database query was timing out. Monitoring only metrics would have missed this granular failure.

### Scenario 2: Cardinality Explosion
**Problem**: Prometheus memory usage spiked following a release.
**Solution**: Using `topk` queries, the team discovered a developer added `user_email` as a label in a custom metric. Removing the label and using a log for that data fixed the memory leak.

### Scenario 3: SaaS Cost Optimization (Datadog)
**Problem**: The monthly Datadog bill spiked due to high log volume.
**Solution**: The team implemented "Inclusion Filters" to only index logs with levels `ERROR` and `WARN`. They used CloudWatch for archival logs to reduce Datadog ingestion costs.