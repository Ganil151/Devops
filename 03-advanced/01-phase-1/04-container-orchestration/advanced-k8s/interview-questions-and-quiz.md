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

5.  **What is the Operator Pattern in Kubernetes?**
    *   *Answer*: A method of packaging, deploying, and managing a Kubernetes application. A custom controller watches a Custom Resource (CR) and performs tasks to ensure the application's current state matches the desired state (e.g., database backups, upgrades).

6.  **Explain the difference between Taints/Tolerations and Node Affinity.**
    *   *Answer*: **Taints/Tolerations** allow a *Node* to repel Pods (e.g., "don't schedule here unless you have a specific need"). **Node Affinity** allows a *Pod* to attract itself to a set of Nodes (e.g., "schedule me on SSD nodes").

7.  **How does `kube-proxy` work and what modes does it support?**
    *   *Answer*: `kube-proxy` runs on each node and manages network rules to allow communication to Services. It supports **iptables** (legacy, linear lookup) and **IPVS** (newer, faster hash table lookup) modes.

8.  **What is a Headless Service and when would you use it?**
    *   *Answer*: A Service defined with `ClusterIP: None`. It doesn't provide load balancing or a single IP. Instead, it returns multiple A records for each Pod IP. It's used for stateful applications (like databases) where clients need to connect to specific Pod instances.

9.  **Explain the concept of "Static Pods".**
    *   *Answer*: Pods managed directly by the `kubelet` daemon on a specific node, without the API server observing them. They are defined by files in a specific directory (e.g., `/etc/kubernetes/manifests`) and are typically used to bootstrap the Control Plane components themselves.

10. **What is OPA (Open Policy Agent) Gatekeeper?**
    *   *Answer*: A policy engine that functions as a Validating Admission Controller. It allows you to enforce CRD-based policies (Rego) on your cluster, such as "all images must come from a private registry" or "all pods must have limits set".

11. **Differentiate between HPA, VPA, and Cluster Autoscaler.**
    *   *Answer*: **HPA (Horizontal)** adds more *replicas* (pods). **VPA (Vertical)** increases the *size* (CPU/RAM) of existing pods. **Cluster Autoscaler** adds more *nodes* (VMs) when pods are pending due to resource starvation.

12. **How do you troubleshoot a `CrashLoopBackOff` status?**
    *   *Answer*: Check `kubectl logs <pod>` (previous instance if needed `kubectl logs <pod> --previous`), `kubectl describe pod <pod>` (for events like OOMKilled), and verify the application configuration/environment variables.

13. **What is a Service Mesh and why might you need one?**
    *   *Answer*: A dedicated infrastructure layer for handling service-to-service communication. It provides advanced features like traffic management (canary, mirroring), security (mTLS), and observability (tracing) that are difficult to implement in the application code.

14. **How does Leader Election work in Kubernetes components?**
    *   *Answer*: Critical components (like Scheduler, Controller Manager) run in high-availability modes. They use a distributed lock mechanism stored in endpoints/leases in Etcd. The instance holding the lock is the active leader, while others stand by.

15. **What are Network Policies?**
    *   *Answer*: Kubernetes resources that control traffic flow at the IP address or port level (Layer 3/4). They act as a firewall for Pods, allowing you to whitelist ingress and egress traffic based on labels, namespaces, or CIDR blocks.

16. **Explain the difference between a Deployment and a StatefulSet.**
    *   *Answer*: **Deployments** treat pods as interchangeable (stateless). **StatefulSets** provide a stick identity (ordinal index 0, 1, 2...), stable network ID, and persistent storage association, required for distributed databases and clustered apps.

17. **What is a DaemonSet?**
    *   *Answer*: A controller that ensures that all (or some) Nodes run a copy of a specific Pod. As nodes are added to the cluster, Pods are added to them. Typical uses: logging agents (Fluentd), monitoring agents (Prometheus Node Exporter), or CNI plugins.

18. **How do you handle Secrets management securely?**
    *   *Answer*: Native `Secret` objects are base64 encoded (not encrypted) by default. For production: enable **Encryption at Rest** in Etcd, use **RBAC** to restrict access, and consider external providers like **HashiCorp Vault** or **AWS Secrets Manager** via CSI drivers.

19. **What is the purpose of a Pod Disruption Budget (PDB)?**
    *   *Answer*: It limits the number of Pods of a replicated application that are down simultaneously from voluntary disruptions (like node drains for upgrades). It ensures application availability during maintenance.

20. **Explain GitOps.**
    *   *Answer*: An operating model where the Git repository is the source of truth for the infrastructure and application configuration. Tools like ArgoCD or Flux detect drift between Git and the Cluster and automatically synchronize the state.

---

## 🧠 Advanced K8s Knowledge Quiz (20+ Questions)

<b>1. What is the default port for the Kubernetes API Server?</b>
<details>
<summary>Show Answer</summary>
Answer: 6443
</details>

<b>2. Which component is responsible for node-level resource management?</b>
<details>
<summary>Show Answer</summary>
Answer: Kubelet
</details>

<b>3. What is a 'DaemonSet'?</b>
<details>
<summary>Show Answer</summary>
Answer: Ensures all/some nodes run a copy of a specific Pod
</details>

<b>4. What is 'Taint' and 'Toleration' used for?</b>
<details>
<summary>Show Answer</summary>
Answer: Node-based scheduling constraints
</details>

<b>5. True/False: A Service Mesh replaces the CNI.</b>
<details>
<summary>Show Answer</summary>
Answer: False
</details>

<b>6. What is the purpose of 'Pod Disruption Budgets'</b>
<details>
<summary>Show Answer</summary>
Answer: PDB)?** (Limits the number of Pods that can be down simultaneously
</details>

<b>7. What is 'Horizontal Pod Autoscaler'</b>
<details>
<summary>Show Answer</summary>
Answer: HPA) base scaling on?** (Typically CPU/Memory usage or custom metrics
</details>

<b>8. What is 'Cluster Autoscaler'?</b>
<details>
<summary>Show Answer</summary>
Answer: Automatically adjusts the number of nodes in a cluster
</details>

<b>9. Which component handles the distribution of traffic within the cluster?</b>
<details>
<summary>Show Answer</summary>
Answer: Kube-proxy
</details>

<b>10. What is an 'Operator' in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: A method of packaging, deploying, and managing a Kubernetes application using CRDs
</details>

<b>11. What is 'RBAC'?</b>
<details>
<summary>Show Answer</summary>
Answer: Role-Based Access Control
</details>

<b>12. What is 'mTLS' in the context of Istio?</b>
<details>
<summary>Show Answer</summary>
Answer: Mutual TLS for encrypted service communication
</details>

<b>13. Which file stores the cluster-wide state?</b>
<details>
<summary>Show Answer</summary>
Answer: Etcd
</details>

<b>14. What is a 'PersistentVolumeClaim'</b>
<details>
<summary>Show Answer</summary>
Answer: PVC)?** (A request for storage by a user
</details>

<b>15. What is 'Ingress'?</b>
<details>
<summary>Show Answer</summary>
Answer: An API object that manages external access to the services in a cluster
</details>

<b>16. What is the difference between 'NodePort' and 'LoadBalancer' service types?</b>
<details>
<summary>Show Answer</summary>
Answer: NodePort opens a port on every Node; LoadBalancer creates a cloud-specific balancer
</details>

<b>17. What is 'Vertical Pod Autoscaler'</b>
<details>
<summary>Show Answer</summary>
Answer: VPA)?** (Adjusts the CPU and memory reservations for your pods
</details>

<b>18. What is 'Helm'?</b>
<details>
<summary>Show Answer</summary>
Answer: The package manager for Kubernetes
</details>

<b>19. What is 'CRD' stand for?</b>
<details>
<summary>Show Answer</summary>
Answer: Custom Resource Definition
</details>

<b>20. What is 'Namespace' used for?</b>
<details>
<summary>Show Answer</summary>
Answer: Logical isolation of resources within a cluster
</details>

<b>21. What is 'Cilium'?</b>
<details>
<summary>Show Answer</summary>
Answer: An open-source software for providing, securing and observing network connectivity between workloads
</details>


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