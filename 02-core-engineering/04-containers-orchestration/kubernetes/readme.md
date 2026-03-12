---

## 🎯 Junior's Mission: The Multi-Cluster Meltdown
**Scenario**: You are managing a global fleet of 5 Kubernetes clusters. A misconfigured Helm chart was deployed to all of them, causing a "CrashLoopBackOff" on the core auth service.
**Your Goal**: Use **Kubectl** with context switching to identify the failing pods across all clusters and execute a **Rollback** before global login services fail.

---

## 🏗️ Operational Reality: Production Hazards
Kubernetes is the "Operating System of the Cloud," but its complexity is its greatest risk.
1.  **The "Resource Limit" Trap**: Deploying a pod without CPU/Memory limits. The pod has a memory leak, eats all the RAM on the physical node, and causes the Linux Kernel to kill the Kubelet itself.
2.  **Configmap Sync Lag**: You update a ConfigMap, but the application doesn't reload. You realize the app only reads the config at boot, or the Kubelet hasn't synced the volume yet.
3.  **The Orphan Load Balancer**: You delete a K8s `Service` of type `LoadBalancer`, but the Cloud Provider (AWS/GCP) fails to delete the actual hardware. You are now paying for a load balancer that points to nothing.
4.  **RBAC Over-Privilege**: Giving a developer `cluster-admin` for "troubleshooting." They accidentally delete the `kube-system` namespace while trying to clean up their own test environment.

---

## 🛠️ The K8s Engineer's Toolbelt (Deep Diagnostics)
| Tool/Command | Why it matters |
| :--- | :--- |
| `kubectl get pods -A` | See every single "Worker" in the cluster, regardless of namespace. |
| `kubectl describe pod <name>` | The "Autopsy Report." Why did the pod crash? Check the Events at the bottom. |
| `kubectl logs -f <name> --previous` | Seeing the "Final Words" of a pod that just crashed. |
| `kubectl top nodes` | Checking if the physical servers are "Screaming" under the data load. |
| `k9s` | The terminal-based UI that every Senior SRE uses to navigate clusters at lightning speed. |

---

## 📂 Modules
- [Advanced K8s](./advanced-k8s/readme.md) - Deep dive into K8s internals, operators, and CRDs.
- [Enterprise Orchestration](./enterprise-container-orchestration/readme.md) - Managed Kubernetes (EKS/GKE) and production scaling.

---
**Next Step**: Learn about [Enterprise Security (DevSecOps)](../05-security/readme.md).
