# ☸️ Technical Deep Dive: Kubernetes (K8s) Interview Mastery

Master the orchestration questions that separate a "kubectl explorer" from a Platform Engineer.

---

## 🟢 Junior Tier: The Fundamentals

### 1. What is the difference between a Pod and a Container?
**Problem:** Explaining the basic unit of scheduling.
**Solution:** A Container is the runtime image (Docker). A Pod is a K8s abstraction that can hold one or more containers that share the same network (localhost) and storage.
**Insight (The Interviewer's Secret):** They are looking for your understanding of **Sidecars**. Mentioning that a Pod allows a "helper" container (like a logging agent) to run alongside the main app shows architectural awareness.
**Lab Correlation:** [05-labs/02-kubernetes-fundamentals-v1](../../05-labs/)

### 2. How does a Service reach a Pod?
**Problem:** Service discovery and networking.
**Solution:** Services use **Labels and Selectors**. A Service tracks Pods with matching labels and maintains an `Endpoints` object containing their IP addresses.
**Insight (The Interviewer's Secret):** Mention **kube-proxy**. Explaining that it manages the iptables or IPVS rules on each node to route traffic from the Service IP to the Pod IP is a massive "plus."

---

## 🟡 Intermediate Tier: The Professional

### 1. Explain the difference between Case A: Deployment and Case B: StatefulSet.
**Problem:** Handling ephemeral vs. persistent workloads.
**Solution:** `Deployments` are for stateless apps where pods are interchangeable and have random names. `StatefulSets` are for apps (like DBs) that require stable network IDs (`pod-0`, `pod-1`) and persistent storage linkage.
**Insight (The Interviewer's Secret):** They are looking for **Ordered Provisioning**. Mentioning that StatefulSets spin up (and down) one by one to prevent database split-brain is the key differentiator here.

### 2. What is a "Liveness Probe" vs. a "Readiness Probe"?
**Problem:** Health check logic.
**Solution:** 
- **Liveness**: Tells K8s if the container is alive. If it fails, K8s kills and restarts it.
- **Readiness**: Tells K8s if the app is ready to serve traffic. If it fails, the Pod is removed from the Service endpoints.
**Insight (The Interviewer's Secret):** They want to hear about **Cascading Failures**. If you use a Liveness probe to check a database connection and the DB goes down, all your pods will restart in a loop (Death Spiral). Readiness is for external dependencies; Liveness is for internal deadlocks.

---

## 🔴 Senior Tier: The Staff Engineer

### 1. Walk me through the lifecycle of a `kubectl apply`. What happens in the Control Plane?
**Problem:** Internal K8s architecture.
**Solution:** 
1. `API Server` receives the request and validates it.
2. `Etcd` stores the new desired state.
3. `Controller Manager` notices the change and creates a Pod object.
4. `Scheduler` assigns the Pod to a Node based on resources.
5. `Kubelet` on the node sees the assignment and tells the Container Runtime to pull the image.
**Insight (The Interviewer's Secret):** They are looking for **Declarative State vs Edge Triggering**. Mentioning that K8s is "Level Triggered" (continuously working to match desired state) shows you understand its core philosophy.

### 2. How do you secure a multi-tenant cluster?
**Problem:** Security and Isolation (CKS level).
**Solution:** 
- **Namespaces**: Logical isolation.
- **RBAC**: Restricting who can do what.
- **NetworkPolicies**: Restricting Pod-to-Pod communication (Zero Trust).
- **ResourceQuotas**: Preventing one team from exhausting all CPU/RAM.
**Insight (The Interviewer's Secret):** Mention **Pod Security Admissions (PSA)** or **Opa/Gatekeeper**. Moving beyond basic RBAC into "Policy as Code" is what identifies a Staff Engineer.
**Lab Correlation:** [03-advanced/01-phase-1/04-container-orchestration/advanced-k8s/](../../03-advanced/)

---

## 🗝️ Master Key: "Interviewer's Secret" Summary
| Concept | What they are REALLY looking for |
| :--- | :--- |
| **Ingress** | Do you understand Layer 7 routing and SSL termination? |
| **Helm** | Do you understand templating and release management? |
| **HPA** | Do you know the difference between scaling on CPU vs custom metrics (Prometheus)? |
| **Etcd** | Do you understand the risks of losing the cluster's state? |
