# Observability Foundations: Monitoring & Logging

In the Intermediate level, we move beyond "Is it up?" to "How is it performing?". Observability foundations provide the baseline visibility needed to manage clusters and infrastructure.

---

## 1. The Four Golden Signals
If you can only monitor four things, monitor these:
- **Latency**: The time it takes to service a request (e.g., HTTP response time).
- **Traffic**: A measure of how much demand is being placed on your system (e.g., Requests per second).
- **Errors**: The rate of requests that fail, either explicitly (e.g., HTTP 500s) or implicitly (e.g., HTTP 200 but incorrect content).
- **Saturation**: How "full" your service is. A measure of your system fraction (e.g., CPU load or Memory usage).

---

## 2. Basic Infrastructure Metrics
Every DevOps engineer should track these baseline metrics for every server:
- **CPU Utilization**: Is the processor bottlenecked?
- **Memory (RAM) Usage**: Is the system close to OOM (Out of Memory)?
- **Disk I/O & Usage**: Is the disk full or slow?
- **Network In/Out**: Is there unexpected traffic or saturated bandwidth?

---

## 3. Log Aggregation Basics
Logs are chronological records of events. At the intermediate level, we focus on:
- **Standard Out (stdout)**: Everything a process prints should go to stdout so it can be captured.
- **Log Levels**: Using `INFO`, `WARN`, `ERROR`, and `DEBUG` correctly.
- **Centralization**: The concept of moving logs from 10 different servers into a single searchable place.

---

## 4. Introduction to Probing
- **Liveness Probes**: Checks if the application is still running (if not, restart it).
- **Readiness Probes**: Checks if the application is ready to receive traffic.

---

**Next Step**: Learn how to implement these concepts at enterprise scale with [Advanced Observability](../../3-Advanced/02-Observability/README.md) (Prometheus, ELK, Splunk).
