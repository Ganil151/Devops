# 🏥 Health Checks and Probers: Tracking the Pulse

Welcome to the module on automated system checks. Health checks are the "heartbeat" of your applications, enabling orchestrators like Kubernetes to make intelligent decisions about traffic and recovery.

---

## 🏗️ The Probe Trinity
Kubernetes uses three distinct probes to manage the lifecycle of your containers:

1.  **Readiness Probe**: "Am I ready to handle requests?" (Controls traffic steering).
2.  **Liveness Probe**: "Am I still alive?" (Controls container restarts).
3.  **Startup Probe**: "Am I finished with my initial boot-up?" (Protects slow-starting apps).

---

## 🛠️ Execution Methods
- **HTTP Get**: Checks a specific URL (Return code 200-399 is healthy).
- **TCP Socket**: Verifies if a network port is open and listening.
- **Exec**: Runs a command inside the container (Exit code 0 is healthy).

---

## 🌐 Synthetic Probing (External Visibility)
Black-box monitoring that simulates a real user's behavior from outside the cluster.
- **Goal**: Detect user-facing outages (DNS, CDN, Networking) that internal probes cannot see.

---

## 📖 Real-World DevOps Story: "The Cascading Restart Crisis"
Learn how a misconfigured Liveness probe turned a simple database hiccup into a total platform meltdown, and how to prevent "Self-Healing" from becoming "Self-Destruction."

---

## 👔 Interview Prep & Deep Dives
Master the senior-level trade-offs between different probing strategies and dependency management.

---

## 🔗 Internal Navigation
- [Next: Part 2 Overview](../../Part-2-Logging-and-Cloud-Metrics/README.md)
- [Back: Monitoring Basics](../01-Monitoring-Basics/README.md)

---
*Self-healing systems require accurate signals. Be precise.*
