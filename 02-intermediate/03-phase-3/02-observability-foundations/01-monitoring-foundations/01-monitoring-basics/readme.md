# 📊 Monitoring Basics & The Four Golden Signals

Welcome to the foundational module of system visibility. Monitoring is the process of collecting, aggregating, and analyzing metrics to improve the awareness of your system's state.

---

## 🏗️ The Four Golden Signals
If you can only monitor four things, monitor these critical markers of service health:

1.  **Latency**: The time it takes to service a request. (Focus on p99, not averages).
2.  **Traffic**: Demand placed on the system (e.g., HTTP requests/sec).
3.  **Errors**: The rate of requests that fail (Explicitly or Implicitly).
4.  **Saturation**: How "full" your service is (e.g., CPU, Memory, I/O).

---

## 🌩️ White-box vs Black-box Monitoring

### White-box Monitoring
Monitoring based on metrics exposed by the internals of the system.
- **Tools**: Logs, Prometheus metrics, JMX.
- **Goal**: Understand **WHY** something is failing.

### Black-box Monitoring
Testing from the outside as a user would.
- **Tools**: Pings, synthetic transactions, port checks.
- **Goal**: Understand **IF** the system is currently working.

---

## 🛡️ Infrastructure Health Matrix
| Component | Metric | Metric Type |
| :--- | :--- | :--- |
| **CPU** | Load Average | Saturation |
| **Memory** | RAM Utilization | Saturation |
| **Network** | Packet Drops | Errors |
| **API** | Response Time | Latency |

---

## 📖 Real-World DevOps Story: "The 200 OK Disaster"
Monitoring can be deceptive. A server returning "200 OK" for an empty page is a failure that metrics alone might miss. Learn how "Black-box" probers saved the day.

---

## 👔 Interview Prep & Deep Dives
Ready to master the Four Golden Signals? Explore technical interview questions and deeper architectural patterns.

---

## 🔗 Internal Navigation
- [Next: Health Checks and Probers](../03-Health-Checks-and-Probers/README.md)
- [Back: Foundations Overview](../README.md)

---
*If you can't measure it, you can't improve it.*
