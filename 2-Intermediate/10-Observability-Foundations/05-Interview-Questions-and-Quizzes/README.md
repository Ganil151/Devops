# Observability Interview Questions & Quiz

Solidify your knowledge of monitoring, logging, and tracing to ensure system reliability.

---

## 🎤 Top 20 Observability Interview Questions

### 🔰 Basics
1. **What is the difference between Monitoring and Observability?**
   - *Answer:* Monitoring tells you *that* something is wrong (based on predefined metrics). Observability allows you to understand *why* something is wrong by providing deep insights into the internal state of the system using metrics, logs, and traces.
2. **What are the "Four Golden Signals"?**
   - *Answer:* Latency, Traffic, Errors, and Saturation.
3. **What is "MTTR" and why is it important?**
   - *Answer:* Mean Time To Repair. It measures the average time taken to fix a system failure. It's a key metric for measuring the efficiency of an operations team.
4. **Explain the difference between a Metric and a Log.**
   - *Answer:* A Metric is a numerical measurement over a period of time (e.g., 80% CPU). A Log is a text record of a discrete event (e.g., "User login failed").
5. **What is a "SLA", "SLO", and "SLI"?**
   - *Answer:* **SLA** (Agreement) is the legal contract with the user. **SLO** (Objective) is the target level you want to reach (e.g., 99.9% uptime). **SLI** (Indicator) is the actual measurement (e.g., the current uptime).

### ⚙️ Logging & Metrics
6. **What is "Structured Logging"?**
   - *Answer:* Logging in a machine-readable format like JSON, which allows for easy searching and filtering compared to plain text.
7. **What is "Log Aggregation" and why do we need it?**
   - *Answer:* The process of collecting logs from many servers into a central location so you can search them all at once during troubleshooting.
8. **What is a "Cardinality" in metrics?**
   - *Answer:* The number of unique time series produced by a metric. High cardinality (e.g., using `user_id` as a label) can crash many monitoring systems.
9. **How do you handle log rotation and retention?**
   - *Answer:* Use tools like `logrotate` to prevent disks from filling up, and ship logs to long-term storage (like S3) for audit compliance.
10. **What is a "Dashboard" and what makes it effective?**
    - *Answer:* A visual representation of metrics. An effective dashboard is simple, shows the most critical information first (Golden Signals), and has clear thresholds for alerts.

### 🚀 Advanced & Probing
11. **Explain Liveness vs. Readiness probes.**
    - *Answer:* Liveness checks if the app is alive (restarts if it fails). Readiness checks if the app can handle traffic (removes from service if it fails).
12. **What is "Synthetic Monitoring"?**
    - *Answer:* Running automated scripts that simulate user behavior (e.g., a "canary" that pings your login page every minute).
13. **What is "Distributed Tracing"?**
    - *Answer:* Tracking a single user request as it moves through multiple microservices to find performance bottlenecks.
14. **What is a "Context" in tracing?**
    - *Answer:* The metadata (like Trace ID) passed between services to link separate spans into one coherent trace.
15. **What is "White-box" vs "Black-box" monitoring?**
    - *Answer:* White-box looks at internal metrics (logs, memory). Black-box looks at external behavior (is the website responding?).
16. **How do you prevent "Alert Fatigue"?**
    - *Answer:* By only alerting on high-impact issues (symptom-based) rather than every small metric flutter, and by ensuring alerts are actionable.
17. **What is an "Error Budget"?**
    - *Answer:* The amount of time a service is allowed to be down without violating its SLO. If the budget is used up, feature releases are typically paused.
18. **Explain the "USE" method for monitoring.**
    - *Answer:* **U**tilization, **S**aturation, and **E**rrors. Primarily used for infrastructure monitoring.
19. **Explain the "RED" method for monitoring.**
    - *Answer:* **R**ate, **E**rrors, and **D**uration. Primarily used for request-driven applications.
20. **What is an "APM" tool?**
    - *Answer:* Application Performance Monitoring tools (like New Relic or Datadog) that provide deep code-level insights and automated tracing.

---

## 🧠 Observability Knowledge Quiz

**1. Which "Golden Signal" measures the rate of requests failing?**
- A) Latency
- B) Traffic
- C) Errors
- D) Saturation
*Answer: C*

**2. Which probe should be used to determine if a pod is ready to receive traffic from a service?**
- A) Liveness Probe
- B) Readiness Probe
- C) Startup Probe
- D) Logic Probe
*Answer: B*

**3. What is the preferred format for "Structured Logging"?**
- A) Plain Text
- B) PDF
- C) JSON
- D) Binary
*Answer: C*

**4. Which type of monitoring tests your website from the "outside-in"?**
- A) White-box
- B) Black-box
- C) Red-box
- D) Blue-box
*Answer: B*

**5. Distributed Tracing is most useful for which architecture?**
- A) Monolith
- B) Microservices
- C) Serverless
- D) All of the above
*Answer: D (But especially microservices)*

**6. MTTR stands for:**
- A) Maximum Time To Run
- B) Mean Time To Recover/Repair
- C) Minimum Time To Resolve
- D) Major Task To Release
*Answer: B*

**7. Which metric tells you how close a resource is to its maximum capacity?**
- A) Latency
- B) Saturation
- C) Throughput
- D) Health
*Answer: B*

**8. A "Span" in tracing represents:**
- A) The entire request path
- B) A single unit of work in one service
- C) A type of database
- D) A time period
*Answer: B*

**9. "Symptom-based alerting" means you alert when:**
- A) CPU is at 90%
- B) Memory usage is high
- C) Users are seeing 500 errors
- D) A developer logs in
*Answer: C*

**10. What is "Context Propagation"?**
- A) Moving data to a new database
- B) Passing trace identifiers between services
- C) Replicating logs
- D) Updating software
*Answer: B*

**11. Which log level is used for messages that require immediate action?**
- A) INFO
- B) WARN
- C) ERROR
- D) FATAL/CRITICAL
*Answer: D*

**12. "Cardinality" refers to:**
- A) The importance of an alert
- B) The number of unique time series in a metric
- C) The frequency of logging
- D) The number of servers being monitored
*Answer: B*

**13. A "Liveness Probe" failure results in:**
- A) The pod being removed from the load balancer
- B) The pod being deleted and restarted
- C) The server shutting down
- D) A Slack notification only
*Answer: B*

**14. Which monitoring method focuses on Rate, Errors, and Duration?**
- A) USE
- B) RED
- C) ACID
- D) BASE
*Answer: B*

**15. "Log Aggregation" typically uses which architecture component to collect logs?**
- A) Master Server
- B) Client Agent (e.g., Fluentd)
- C) Web Browser
- D) Database Trigger
*Answer: B*

**16. An "Error Budget" is essentially:**
- A) A financial plan for bugs
- B) $1 - SLO (The allowed downtime)
- C) The cost of monitoring
- D) A list of all errors
*Answer: B*

**17. APM stands for:**
- A) Advanced Process Management
- B) Application Performance Monitoring
- C) Automated Pipeline Maintenance
- D) Application Plugin Manager
*Answer: B*

**18. "stdout" stands for:**
- A) Standard Output
- B) Status Output
- C) Static Out
- D) State Out
*Answer: A*

**19. Which tool is famous for being a distributed tracing system?**
- A) Prometheus
- B) Jaeger
- C) Grafana
- D) ELK
*Answer: B*

**20. Monitoring "Saturation" often helps identify:**
- A) Coding bugs
- B) Resource bottlenecks (CPU/Memory/Disk)
- C) Network configuration errors
- D) Human errors
*Answer: B*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between Liveness and Readiness
