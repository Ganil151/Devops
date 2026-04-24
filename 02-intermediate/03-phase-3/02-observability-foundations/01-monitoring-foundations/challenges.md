# Monitoring Foundations Challenges 📊

Master the metrics that tell you when your system is healthy—or about to fail.

---

## 🏆 Challenge 01: The Golden Signals
**Objective**: Identify and monitor the 4 Golden Signals of SRE.

1.  **Task**: Define the 4 Golden Signals: **Latency**, **Traffic**, **Errors**, and **Saturation**.
2.  **Scenario**: A web server is responding slowly but CPU usage is low. 
    *   Which of the 4 signals is spiking?
    *   What might be the bottleneck? (Hint: Database connection thread exhaustion).
3.  **Discovery**: Research how **Prometheus** handles "Counters" vs "Gauges." Which one would you use to track the number of 500 errors?

---

## 🏆 Challenge 02: Building a Dashboard (Prometheus/Grafana)
**Objective**: Visualize system health with a professional dashboard.

1.  **Requirement**: Use the `prometheus-stack.yml` docker-compose boilerplate.
2.  **Task**: 
    *   Add a **Node Exporter** container to collect host metrics.
    *   Import a community dashboard (e.g., ID 1860) into Grafana.
3.  **Verification**: Take a screenshot of your local CPU and Memory graphs.

---

## 🏆 Challenge 03: The Alert Architect
**Objective**: Notify the team before a critical failure occurs.

1.  **Requirement**: Configure an alert rule in Prometheus.
2.  **Logic**: Trigger an alert if **Storage Usage** exceeds 80% on any node.
3.  **Advanced**: Research **AlertManager**. How can you group alerts so you don't get 100 emails for one disk-full event?
4.  **Goal**: Write a simple alerting rule in YAML format.

---

## 📁 Solutions
Prometheus configuration files and Grafana dashboard IDs are in the `Boilerplates/` directory.
