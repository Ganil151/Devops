# High-Fidelity Refinement for Kubernetes Deep Dives (02-Intermediate)

This module provides focused deep dives into specific cluster components and specialized tools.

---

## 🏗️ The Kubelet internals

The **Kubelet** is the most complex component of a worker node. It acts as the "Manager" for all pods assigned to that node.

### The Sync Loop
Kubelet runs a continuous loop (Sync Loop). Every few seconds, it compares the current state of containers on the node against the PodSpecs it has received.

### PLEG (Pod Lifecycle Event Generator)
PLEG is a sub-system of the Kubelet that detects container state changes by polling the container runtime. If PLEG becomes unhealthy, the node often enters `NotReady` state.

---

## 📦 Helm: The Package Manager for K8s

If Kubernetes is an OS, **Helm** is the `apt-get` or `brew` of the cluster.

1. **Charts**: Bundles of YAML templates.
2. **Values**: Configuration for the charts (e.g., `replicaCount: 5`).
3. **Releases**: A specific instance of a chart running in your cluster.

---

## 🛡️ ServiceAccounts: Identity for Pods

While Users are for humans, **ServiceAccounts** are for Pods.
- By default, every namespace has a `default` ServiceAccount.
- In production, create dedicated ServiceAccounts for apps (e.g., `prometheus-sa`) to follow the **Principle of Least Privilege**.

---

## 📖 Real-World DevOps Story: "The Infinite Loop of PLEG"

**The Scenario:** A high-traffic node randomly switched between `Ready` and `NotReady` for weeks. The pods were healthy, but the node status kept flipping.

**The Cause:** After digging into the Kubelet logs, the team found `PLEG is not healthy: transition took too long`. A container was crashing so fast (100+ times per second) that the Kubelet's PLEG subsystem couldn't keep up with the events, causing the whole Kubelet to hang.

**The Lesson:** 
- Monitor **Kubelet Metrics** (`kubelet_pleg_relist_duration_seconds`).
- Set a **Backoff Limit** for failing containers to prevent "Event Storms."

---

## 👨‍💻 Interview Preparation (Deep Dive)

1. **Q: How does the Kubelet talk to the container runtime?**
   *   *A: Through the **Container Runtime Interface (CRI)**, which is a gRPC protocol.*

2. **Q: What is a "Static Pod"?**
   *   *A: A pod defined in a local file on a node (usually `/etc/kubernetes/manifests`). The Kubelet starts these without any command from the API Server.*

3. **Q: What is the benefit of Helm over raw YAML?**
   *   *A: Templating (DRY - Don't Repeat Yourself), Release Management (Rollbacks), and sharing configurations through Repositories.*

---

## 🧠 Knowledge Check

1. Which Kubelet component tracks container changes? (PLEG)
2. What is the main configuration file for a Helm chart called? (`values.yaml`)
3. Which object provides an identity to a process running in a Pod? (ServiceAccount)
