# ☸️ Technical Deep Dive: Kubernetes (K8s) Interview Mastery

Master the orchestration questions that separate a "kubectl explorer" from a Platform Engineer.

## 📋 Table of Contents
- [🟢 Junior Tier: The Fundamentals](#-junior-tier-the-fundamentals)
- [🟡 Intermediate Tier: The Professional](#-intermediate-tier-the-professional)
- [🔴 Senior Tier: The Staff Engineer](#-senior-tier-the-staff-engineer)
- [🗝️ Master Key: Interviewer's Secret Summary](#️-master-key-interviewers-secret-summary)

---

## 🟢 Junior Tier: The Fundamentals

#### Q: What is Kubernetes? [Junior]
**Problem:** Defining the platform's core purpose.
**Solution:** Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It handles the "scheduling" of containers across a cluster of machines.
**Insight (The Interviewer's Secret):** Don't just say "it runs containers." Mention that it is a **declarative system**—you tell it the "desired state" (e.g., "I want 3 replicas of Nginx"), and it works to maintain that state regardless of failures.

#### Q: What is a Pod in Kubernetes? [Junior]
**Problem:** Explaining the basic unit of scheduling.
**Solution:** A Pod is the smallest deployable unit in Kubernetes. It represents a single instance of a running process. Pods can contain one or more containers (e.g., an App container and a Sidecar) that share the same network (localhost) and storage volumes.
**Insight (The Interviewer's Secret):** They are looking for your understanding of **Sidecars**. Mentioning that a Pod allows a "helper" container (like a logging agent) to run alongside the main app shows architectural awareness.
**Lab Correlation:** [[kubernetes-mastery#lab-1|Pod Basics and Multi-container Pods]]

#### Q: What is a Service in Kubernetes? [Junior]
**Problem:** Service discovery and stable networking for ephemeral pods.
**Solution:** A Service is an abstraction that defines a logical set of Pods and a policy by which to access them. Since Pods are ephemeral (they die and get new IPs), a Service provides a stable IP address and DNS name.
**Insight (The Interviewer's Secret):** Mention **Labels and Selectors**. A Service tracks Pods with matching labels and maintains an `Endpoints` object containing their current IP addresses.
**Lab Correlation:** [[kubernetes-mastery#lab-2|Networking with Services]]

#### Q: How does a Service reach a Pod? [Junior]
**Problem:** Internal traffic routing.
**Solution:** Services use **Labels and Selectors**. A Service tracks Pods with matching labels.
**Insight (The Interviewer's Secret):** Mention **kube-proxy**. Explaining that it manages the iptables or IPVS rules on each node to route traffic from the Service IP to the Pod IP is a massive "plus."

---

## 🟡 Intermediate Tier: The Professional

#### Q: What are the main components of Kubernetes architecture? [Intermediate]
**Problem:** Explaining the Control Plane vs. Data Plane.
**Solution:** 
1. **Control Plane (Master):** API Server (the gateway), etcd (the brain/store), Scheduler (the decision-maker), and Controller Manager (the enforcer).
2. **Node (Worker):** Kubelet (the agent), Kube-proxy (the networker), and Container Runtime (the engine, like containerd).
**Insight (The Interviewer's Secret):** Focus on **etcd**. Mention that losing etcd means losing the cluster's state. Discussing its distributed consistency (Raft consensus) marks you as an intermediate engineer.
[DIAGRAM: Kubernetes Control Plane Components]

#### Q: What are DaemonSets in Kubernetes? [Intermediate]
**Problem:** Running background agents on every node.
**Solution:** A DaemonSet ensures that all (or a specific subset of) Nodes run a copy of a Pod. When a new node is added, the pod is automatically scheduled on it.
**Insight (The Interviewer's Secret):** Common use cases: **Log Collectors** (Fluentd/Logstash) and **Monitoring Agents** (Prometheus Node Exporter). Mentioning that DaemonSets ignore "unschedulable" taints if configured correctly shows deep expertise.

#### Q: What is Helm? [Intermediate]
**Problem:** Managing complex application manifests.
**Solution:** Helm is a **package manager** for Kubernetes. It uses "Charts" (templates + value files) to package K8s resources, allowing for versioning, rollbacks, and reusable deployments across environments.
**Insight (The Interviewer's Secret):** They want to hear about **Release Management**. Discussing `helm rollback` and how it manages the state of your deployments across different environments is key.
**Lab Correlation:** [[kubernetes-mastery#lab-3|Helm Charts and Templating]]

#### Q: What is a "Liveness Probe" vs. a "Readiness Probe"? [Intermediate]
**Problem:** Self-healing logic.
**Solution:** 
- **Liveness**: Decides if a container should be restarted. 
- **Readiness**: Decides if a container should receive traffic.
**Insight (The Interviewer's Secret):** They want to hear about **Cascading Failures**. If you use a Liveness probe to check a database and the DB goes down, all your pods will restart in a loop. Readiness is for external dependencies; Liveness is for internal deadlocks.

---

## 🔴 Senior Tier: The Staff Engineer

#### Q: What are StatefulSets in Kubernetes? [Senior]
**Problem:** Managing stateful applications like Databases.
**Solution:** StatefulSets provide stable network identities (`pod-0`, `pod-1`) and stable, persistent storage. Unlike Deployments, Pods are created and deleted in a strict, predictable order.
**Insight (The Interviewer's Secret):** They are looking for **Ordered Provisioning/Termination**. Mentioning that StatefulSets prevent "split-brain" scenarios in distributed databases like Cassandra or ElasticSearch is the high-value answer.
**Lab Correlation:** [[kubernetes-mastery#lab-4|Deploying StatefulSets and PV/PVCs]]

#### Q: Walk me through the lifecycle of a `kubectl apply`. What happens in the Control Plane? [Senior]
**Problem:** Deep dive into the internal reconciliation loop.
**Solution:** 
1. `API Server` validates and stores the YAML in `etcd`.
2. `Controller Manager` detects the change and creates the Pod object (but no node assignment).
3. `Scheduler` filters and scores nodes to find the best fit, then "binds" the Pod to a Node in the API.
4. `Kubelet` on the target Node sees the binding, pulls the image, and starts the container.
**Insight (The Interviewer's Secret):** They are looking for **Declarative State vs Edge Triggering**. Mentioning that K8s is "Level Triggered" (acting to match current state to desired state) shows you understand its core philosophy.

#### Q: What is an Istio Service Mesh? [Senior]
**Problem:** Managing complex service-to-service communication.
**Solution:** Istio is a service mesh that provides a transparent layer to handle **Traffic Management** (canary, circuit breaking), **Security** (mTLS by default), and **Observability** (tracing, metrics) without changing application code.
**Insight (The Interviewer's Secret):** Mention the **Sidecar Proxy (Envoy)**. Explain how Istio intercepts all L7 traffic and provides a unified "Control Plane" to manage policy.

#### Q: What is the Sidecar Pattern? [Senior]
**Problem:** Extending container functionality without modifying code.
**Solution:** A container (the "sidecar") is deployed in the same Pod as the main application. They share the same network namespace and volumes.
**Insight (The Interviewer's Secret):** This is the foundation of **Service Meshes** (Istio/Envoy) and **Observability** (logging/metrics agents). It allows for "Separation of Concerns."

#### Q: How do you secure a multi-tenant cluster? [Senior]
**Problem:** Hardening Shared Infrastructure.
**Solution:** 
- **Namespaces**: Logical isolation.
- **RBAC**: Fine-grained access control.
- **NetworkPolicies**: Restricting Pod-to-Pod traffic (Zero Trust).
- **PSA/Gatekeeper**: Enforcing security standards via Admission Controllers.
**Insight (The Interviewer's Secret):** Mention **Pod Security Admissions (PSA)**. Moving beyond basic RBAC into automated "Policy as Code" is what identifies a Staff level engineer.

---

## 🗝️ Master Key: Interviewer's Secret Summary
| Concept | What they are REALLY looking for |
| :--- | :--- |
| **Ingress** | Do you understand Layer 7 routing and SSL termination? |
| **CRI / OCI** | Do you know the difference between Docker, Containerd, and the Runtime Interface? |
| **HPA / VPA** | Do you know the difference between scaling on CPU vs custom metrics (Prometheus)? |
| **Admission Controllers** | Do you understand how to intercept and validate requests before they hit Etcd? |
