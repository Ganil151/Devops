# 📊 Module 01: The MELT Framework

> **"Data is not information. Information is not knowledge. Knowledge is not wisdom. MELT gives us the data; Observability gives us the wisdom."**

## 📚 Overview

To understand any system, we need signals. In the Observability world, these signals are universally categorized into four pillars, known by the acronym **MELT**: **M**etrics, **E**vents, **L**ogs, and **T**races.

## 🎓 Learning Objectives

- ✅ **Metrics**: "Is there a problem?" (Aggregates)
- ✅ **Events**: "What changed?" (Discrete occurrences)
- ✅ **Logs**: "Why did it happen?" (Descriptive text)
- ✅ **Traces**: "Where did it happen?" (Request paths)

---

## 🏗️ The 4 Pillars

### 1. Metrics (Numbers)
A numeric representation of data measured over time.
- **Example**: `cpu_usage = 85%`
- **Use Case**: triggering alarms (e.g., "Alert me if CPU > 90%").

### 2. Events (Changes)
A discrete record of a significant change.
- **Example**: `Deployment 3.2.1 completed`. `Server Restarted`.
- **Use Case**: Correlating changes with outages.

### 3. Logs (Text)
A timestamped record of discrete events.
- **Example**: `2023-10-27 10:00:01 [ERROR] Database connection failed`.
- **Use Case**: Deep debugging and root cause analysis.

### 4. Traces (Journeys)
A representation of a series of causally related distributed events that encode the end-to-end request flow through a distributed system.
- **Example**: User clicked "Buy" -> Frontend -> Auth Service -> Payment Service -> Database.
- **Use Case**: Finding latency bottlenecks in microservices.

---

**Next Step**: Apply this knowledge in **[Module 02: Manual Health Checks](../../Part-02-Active-Monitoring/02-Manual-Health-Checks/README.md)** 🚀
