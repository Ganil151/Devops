# 🔄 Part 2: Workload Management

Once you understand the architecture, it's time to run workloads. This part focuses on the lifecycle of applications in Kubernetes, from the smallest Pod to the most complex high-availability deployment.

---

## 📂 Modules in this Part

### 1. [03-Pods-and-Nodes](./03-pods-and-nodes/readme.md)
The building blocks of Kubernetes.
- **Pod Lifecycle Hooks**: Using `postStart` and `preStop` for clean shutdowns.
- **Design Patterns**: Deep dive into **Sidecars** (logging), **Adapters** (metrics), and **Ambassadors** (proxies).
- **Advanced Scheduling**: Utilizing `nodeSelector`, `Affinity/Anti-Affinity`, and `Taints/Tolerations` to control workload placement.

### 2. [04-Deployments-and-Scaling](./04-deployments-and-scaling/readme.md)
Managed state for stateless applications.
- **Advanced Update Strategies**: **Blue/Green** vs. **Canary** deployments using standard K8s objects.
- **Zero-Downtime Rollouts**: Tuning `maxSurge` and `maxUnavailable` for safe updates.
- **Scaling Architecture**: Implementing the **Horizontal Pod Autoscaler (HPA)** based on custom metrics (via Metrics Server).

---

## 🚀 Learning Path
1. Master **Pods and Nodes** to understand the runtime environment.
2. Advance to **Deployments and Scaling** to learn enterprise deployment patterns.

---
[Back to Main Curriculum](../readme.md)
