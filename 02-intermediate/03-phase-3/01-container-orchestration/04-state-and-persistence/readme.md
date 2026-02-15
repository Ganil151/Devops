# 💾 Part 4: State & Persistence

Kubernetes was originally designed for stateless apps, but the world runs on data. This part covers the complex world of persistent storage and stateful orchestration.

---

## 📂 Modules in this Part

### 1. [08-Persistence-and-Storage](./08-persistence-and-storage/readme.md)
The foundation of durable data.
- **Abstraction Layer**: Understanding the decoupling of **PVs**, **PVCs**, and **StorageClasses**.
- **CSI Interface**: Exploring the **Container Storage Interface (CSI)** for AWS EBS, EFS, and local storage.
- **Dynamic Provisioning**: How StorageClasses automate the creation of physical disks based on demand.

### 2. [09-StatefulSets-and-Jobs](./09-statefulsets-and-jobs/readme.md)
Orchestrating databases and batch operations.
- **StatefulSet guarantees**: Stable **Network Identities** and **Persistent Storage** that sticks to pods even after migration.
- **Distributed Databases**: Patterns for running **MySQL Clusters**, **Redis**, and **MongoDB** on Kubernetes.
- **Atomic Operations**: Using **Jobs** for database migrations and **CronJobs** for periodic backups and maintenance.

---

## 🚀 Learning Path
1. Master **Persistence and Storage** before attempting to run databases.
2. Advance to **StatefulSets** to understand how to manage databases and stateful clusters.

---
[Back to Main Curriculum](../readme.md)
