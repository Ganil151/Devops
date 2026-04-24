# K8s Cloud Ops & Admin Challenges 🛠️

Master the administration and governance of a production Kubernetes cluster.

---

## 🏆 Challenge 01: RBAC (Security Control)
**Objective**: Implement "Least Privilege" access.

1.  **Requirement**: Create a **ServiceAccount** named `developer-limited`.
2.  **Task**: Create a **Role** that only allows `get`, `list`, and `watch` for Pods.
3.  **Action**: Bind the Role to the ServiceAccount using a **RoleBinding**.
4.  **Verification**: Use `kubectl auth can-i create pods --as=system:serviceaccount:default:developer-limited`. It should return `no`.

---

## 🏆 Challenge 02: Resource Quotas
**Objective**: Protect the cluster from "Resource Hunger."

1.  **Scenario**: A developer deploys a pod that consumes 100% of the node's CPU.
2.  **Task**: Create a **ResourceQuota** in the `default` namespace.
3.  **Constraint**: Limit the namespace to a total of 2 CPUs and 4Gi of Memory.
4.  **Verification**: Try to deploy a pod that requests 3 CPUs. Observe the error message.

---

## 🏆 Challenge 03: Cluster Observability
**Objective**: Learn to debug a "Broken Cluster."

1.  **Task**: Use `kubectl top nodes` and `kubectl top pods` (requires Metrics Server).
2.  **Steps**:
    *   Find the pod consuming the most memory.
    *   Identify a node that is in a `NotReady` state (simulated).
    *   **Action**: Use `kubectl describe node` to find the reason for failure (e.g., DiskPressure).

---

## 📁 Solutions
RBAC policies and Quota templates are in the `Boilerplates/` directory.
