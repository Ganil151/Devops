# Observability Interview Questions & Quiz

Solidify your knowledge of monitoring, logging, and tracing to ensure system reliability.

---

## 🎤 Top 20 Observability Interview Questions

<b>1. </b>
<details>
<summary>Show Answer</summary>
Answer: * Monitoring tells you *that* something is wrong (based on predefined metrics). Observability allows you to understand *why* something is wrong by providing deep insights into the internal state of the system using metrics, logs, and traces.
</details>


<b>2. </b>
<details>
<summary>Show Answer</summary>
Answer: * Latency, Traffic, Errors, and Saturation.
</details>


<b>3. </b>
<details>
<summary>Show Answer</summary>
Answer: * Mean Time To Repair. It measures the average time taken to fix a system failure. It's a key metric for measuring the efficiency of an operations team.
</details>


<b>4. </b>
<details>
<summary>Show Answer</summary>
Answer: * A Metric is a numerical measurement over a period of time (e.g., 80% CPU). A Log is a text record of a discrete event (e.g., "User login failed").
</details>


<b>5. </b>
<details>
<summary>Show Answer</summary>
Answer: * **SLA** (Agreement) is the legal contract with the user. **SLO** (Objective) is the target level you want to reach (e.g., 99.9% uptime). **SLI** (Indicator) is the actual measurement (e.g., the current uptime).
</details>


<b>6. </b>
<details>
<summary>Show Answer</summary>
Answer: * Logging in a machine-readable format like JSON, which allows for easy searching and filtering compared to plain text.
</details>


<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: * The process of collecting logs from many servers into a central location so you can search them all at once during troubleshooting.
</details>


<b>8. </b>
<details>
<summary>Show Answer</summary>
Answer: * The number of unique time series produced by a metric. High cardinality (e.g., using `user_id` as a label) can crash many monitoring systems.
</details>


<b>9. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use tools like `logrotate` to prevent disks from filling up, and ship logs to long-term storage (like S3) for audit compliance.
</details>


<b>10. </b>
<details>
<summary>Show Answer</summary>
Answer: * A visual representation of metrics. An effective dashboard is simple, shows the most critical information first (Golden Signals), and has clear thresholds for alerts.
</details>


<b>11. </b>
<details>
<summary>Show Answer</summary>
Answer: * Liveness checks if the app is alive (restarts if it fails). Readiness checks if the app can handle traffic (removes from service if it fails).
</details>


<b>12. </b>
<details>
<summary>Show Answer</summary>
Answer: * Running automated scripts that simulate user behavior (e.g., a "canary" that pings your login page every minute).
</details>


<b>13. </b>
<details>
<summary>Show Answer</summary>
Answer: * Tracking a single user request as it moves through multiple microservices to find performance bottlenecks.
</details>


<b>14. </b>
<details>
<summary>Show Answer</summary>
Answer: * The metadata (like Trace ID) passed between services to link separate spans into one coherent trace.
</details>


<b>15. </b>
<details>
<summary>Show Answer</summary>
Answer: * White-box looks at internal metrics (logs, memory). Black-box looks at external behavior (is the website responding?).
</details>


<b>16. </b>
<details>
<summary>Show Answer</summary>
Answer: * By only alerting on high-impact issues (symptom-based) rather than every small metric flutter, and by ensuring alerts are actionable.
</details>


<b>17. </b>
<details>
<summary>Show Answer</summary>
Answer: * The amount of time a service is allowed to be down without violating its SLO. If the budget is used up, feature releases are typically paused.
</details>


<b>18. </b>
<details>
<summary>Show Answer</summary>
Answer: * **U**tilization, **S**aturation, and **E**rrors. Primarily used for infrastructure monitoring.
</details>


<b>19. </b>
<details>
<summary>Show Answer</summary>
Answer: * **R**ate, **E**rrors, and **D**uration. Primarily used for request-driven applications.
</details>


<b>20. </b>
<details>
<summary>Show Answer</summary>
Answer: * Application Performance Monitoring tools (like New Relic or Datadog) that provide deep code-level insights and automated tracing.
</details>


---

## 🧠 Observability Knowledge Quiz

<b>1. Which "Golden Signal" measures the rate of requests failing?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>2. Which probe should be used to determine if a pod is ready to receive traffic from a service?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>3. What is the preferred format for "Structured Logging"?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>4. Which type of monitoring tests your website from the "outside-in"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Distributed Tracing is most useful for which architecture?</b>
<details>
<summary>Show Answer</summary>
Answer: D (But especially microservices)
</details>


<b>6. MTTR stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. Which metric tells you how close a resource is to its maximum capacity?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>8. A "Span" in tracing represents:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. "Symptom-based alerting" means you alert when:</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>10. What is "Context Propagation"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. Which log level is used for messages that require immediate action?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>12. "Cardinality" refers to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. A "Liveness Probe" failure results in:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. Which monitoring method focuses on Rate, Errors, and Duration?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. "Log Aggregation" typically uses which architecture component to collect logs?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. An "Error Budget" is essentially:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>17. APM stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. "stdout" stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>19. Which tool is famous for being a distributed tracing system?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. Monitoring "Saturation" often helps identify:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between Liveness and Readiness