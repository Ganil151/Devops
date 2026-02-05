# 💾 Part 4: State & Persistence

Kubernetes was originally designed for stateless apps, but the world runs on data. This part covers the complex world of persistent storage and stateful orchestration.

---

## 📂 Modules in this Part

### 1. [08-Persistence-and-Storage](./08-Persistence-and-Storage/README.md)
The foundation of data in containers.
- **Volumes**: PV (PersistentVolume) and PVC (PersistentVolumeClaim).
- **Provisioning**: StorageClasses and CSI Drivers.
- **Lifecycles**: Retain, Delete, and Recycle.

### 2. [09-StatefulSets-and-Jobs](./09-StatefulSets-and-Jobs/README.md)
Orchestrating stateful apps and one-off tasks.
- **StatefulSets**: Stable network IDs and persistent disk mapping.
- **Jobs**: Batch processing and "run to completion" tasks.
- **CronJobs**: Automated scheduling for maintenance tasks.

---

## 🚀 Learning Path
1. Master **Persistence and Storage** before attempting to run databases.
2. Advance to **StatefulSets** to understand how to manage databases and stateful clusters.

---
[Back to Main Curriculum](../README.md)
