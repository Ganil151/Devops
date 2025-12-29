# Advanced Kubernetes: Interview Questions, Quiz & Scenarios

Deepen your Kubernetes mastery with these high-level technical and operational challenges.

---

## ❓ Interview Questions (Advanced)

1.  **Explain the Kubernetes Control Plane architecture and the role of Etcd.**
    *   *Answer*: The Control Plane manages the cluster's state. **Etcd** is the consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data. If Etcd is down, the API server cannot function.
2.  **What are Admission Controllers and why are they used?**
    *   *Answer*: They are plugins that intercept requests to the API server prior to persistence. **Mutating** controllers can modify requests (e.g., adding default labels), while **Validating** controllers can reject them (e.g., blocking images without a specific tag).
3.  **Describe the difference between CSI and CNI.**
    *   *Answer*: **CNI (Container Network Interface)** handles networking (IPAM, routing). **CSI (Container Storage Interface)** handles storage (volume mounting, snapshots).
4.  **How does Istio handle Service-to-Service communication?**
    *   *Answer*: It uses an **Envoy Proxy** (Sidecar) injected into each pod. The **Control Plane (Istiod)** manages these proxies to handle traffic routing, mutual TLS, and observability.

---

## 🧠 Advanced K8s Knowledge Quiz (20+ Questions)

1.  **What is the default port for the Kubernetes API Server?** (6443)
2.  **Which component is responsible for node-level resource management?** (Kubelet)
3.  **What is a 'DaemonSet'?** (Ensures all/some nodes run a copy of a specific Pod)
4.  **What is 'Taint' and 'Toleration' used for?** (Node-based scheduling constraints)
5.  **True/False: A Service Mesh replaces the CNI.** (False)
6.  **What is the purpose of 'Pod Disruption Budgets' (PDB)?** (Limits the number of Pods that can be down simultaneously)
7.  **What is 'Horizontal Pod Autoscaler' (HPA) base scaling on?** (Typically CPU/Memory usage or custom metrics)
8.  **What is 'Cluster Autoscaler'?** (Automatically adjusts the number of nodes in a cluster)
9.  **Which component handles the distribution of traffic within the cluster?** (Kube-proxy)
10. **What is an 'Operator' in Kubernetes?** (A method of packaging, deploying, and managing a Kubernetes application using CRDs)
11. **What is 'RBAC'?** (Role-Based Access Control)
12. **What is 'mTLS' in the context of Istio?** (Mutual TLS for encrypted service communication)
13. **Which file stores the cluster-wide state?** (Etcd)
14. **What is a 'PersistentVolumeClaim' (PVC)?** (A request for storage by a user)
15. **What is 'Ingress'?** (An API object that manages external access to the services in a cluster)
16. **What is the difference between 'NodePort' and 'LoadBalancer' service types?** (NodePort opens a port on every Node; LoadBalancer creates a cloud-specific balancer)
17. **What is 'Vertical Pod Autoscaler' (VPA)?** (Adjusts the CPU and memory reservations for your pods)
18. **What is 'Helm'?** (The package manager for Kubernetes)
19. **What is 'CRD' stand for?** (Custom Resource Definition)
20. **What is 'Namespace' used for?** (Logical isolation of resources within a cluster)
21. **What is 'Cilium'?** (An open-source software for providing, securing and observing network connectivity between workloads)

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The Cascading Failure
**Problem**: A memory leak in one pod caused the Node to run out of memory, killing other critical pods.
**Solution**: Implemented **Resource Quotas** and **LimitRanges** to ensure no single deployment could starve the rest of the cluster.

### Scenario 2: The Security Breach at the Edge
**Problem**: An external attacker tried to access the K8s API directly.
**Solution**: Configured **RBAC** with the principle of least privilege and restricted API access to a specific private bastard host (VPN).

### Scenario 3: The Scaling Headache
**Problem**: During a flash sale, the HPA scaled pods, but the new pods couldn't schedule because the nodes were full.
**Solution**: Implemented **Cluster Autoscaler** to dynamically spin up new AWS EC2 instances when pods were in 'Pending' status.
