# 🟢 Part 1: The Signals

> **"You can't manage what you can't measure."**

## 📖 Overview

This part focuses on the theoretical foundations of Observability. We dive deep into the **MELT** framework—the four pillars of data that tell you everything about your system's behavior.

---

## 📊 The Four Pillars (MELT)

```mermaid
graph TD
    Obs[Observability] --> M[Metrics]
    Obs --> E[Events]
    Obs --> L[Logs]
    Obs --> T[Traces]
    
    M --> Ex1[CPU/RAM Usage]
    E --> Ex2[Deployments/Alerts]
    L --> Ex3[Application Output]
    T --> Ex4[Request Journey]
    
    style Obs fill:#f9f9f9,stroke:#333
    style M fill:#4285f4,stroke:#333,color:#fff
```

---

## 🎯 Learning Objectives

- ✅ Define **Metrics** (Aggregatable numbers).
- ✅ Define **Logs** (Discrete events).
- ✅ Define **Traces** (Causal chains).
- ✅ Understand when to use which signal.

---

## 🗺️ Included Modules

1. **[01-MELT-Introduction](./01-MELT-Introduction/README.md)**: A deep dive into the 4 pillars.

---

**Next Step**: Learn the pillars in **[01-MELT-Introduction](./01-MELT-Introduction/README.md)** 🚀
