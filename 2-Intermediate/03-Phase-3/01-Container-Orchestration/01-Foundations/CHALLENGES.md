# K8s Foundations Challenges ☸️

Start your journey into the world of Kubernetes by mastering the Control Plane and the Pod lifecycle.

---

## 🏆 Challenge 01: The Control Plane Audit
**Objective**: Understand the components that keep the cluster alive.

1.  **Task**: Diagram the interaction between the following components:
    *   **kube-apiserver** (The Front Door)
    *   **etcd** (The Database)
    *   **kube-scheduler** (The Matchmaker)
    *   **kube-controller-manager** (The Enforcer)
2.  **Scenario**: If the `etcd` node dies, can you still schedule new pods? Explain why or why not.
3.  **Discovery**: What is the role of the `kubelet` on a Worker Node?

---

## 🏆 Challenge 02: Your First Multi-Container Pod
**Objective**: Master the Pod abstraction.

1.  **Task**: Create a YAML file named `sidecar-pod.yaml`.
2.  **Requirements**:
    *   **Container 1**: `nginx` (The Main App).
    *   **Container 2**: `busybox` (The Sidecar).
3.  **Logic**: Have the sidecar container write a file `index.html` to a shared volume, and have Nginx serve that file.
4.  **Verification**: Use `kubectl port-forward` to access the pod and see the content from the sidecar.

---

## 🏆 Challenge 03: Desired State Management
**Objective**: Witness Kubernetes' self-healing powers.

1.  **Requirement**: Deploy a standard Nginx Pod.
2.  **Action**: Use `kubectl delete pod <name>` while observing the cluster.
3.  **Analysis**: What happens when you delete a standalone Pod vs. a Pod managed by a Deployment?
4.  **Goal**: Explain the concept of the "Reconciliation Loop."

---

## 📁 Solutions
Component diagrams and YAML templates are in the `Boilerplates/` directory.
