# Kubernetes Interview Questions & Quiz

Master the "OS of the Data Center" and prepare for the CKA/CKAD technical screenings.

---

## 🎤 Top 20 Kubernetes Interview Questions

### 🔰 Cluster Architecture
1. **What is the Control Plane and what are its components?**
   - *Answer:* The Control Plane is the brain of the cluster. Components include `kube-apiserver` (API), `etcd` (state storage), `kube-scheduler` (assigns pods to nodes), and `kube-controller-manager` (runs controller processes).
2. **What is `kubelet`?**
   - *Answer:* An agent that runs on each node in the cluster. It ensures that containers are running in a Pod according to the PodSpecs provided by the API server.
3. **What is `etcd`?**
   - *Answer:* A distributed, reliable key-value store used as Kubernetes' backing store for all cluster data.
4. **What is a Pod?**
   - *Answer:* The smallest deployable unit in Kubernetes. A Pod represents a single instance of a running process and can contain one or more containers.
5. **What is the purpose of `kube-proxy`?**
   - *Answer:* It maintains network rules on nodes, allowing network communication to your Pods from inside or outside the cluster.

### ⚙️ Networking & Services
6. **Explain the difference between a Service and an Ingress.**
   - *Answer:* A Service (like LoadBalancer or NodePort) exposes an application internally or externally. An Ingress is an API object that manages external access to services, typically via HTTP, providing features like name-based virtual hosting and SSL termination.
7. **What is a "Headless Service"?**
   - *Answer:* A service that does not have a ClusterIP. It is used when you want to discover the individual Pod IPs directly (often used for StatefulSets).
8. **What is the role of the CNI (Container Network Interface)?**
   - *Answer:* It is a specification and set of libraries for configuring network interfaces in Linux containers. Kubernetes uses CNI plugins (like Calico or Flannel) to manage pod networking.
9. **Explain "ClusterIP" vs "NodePort" vs "LoadBalancer".**
   - *Answer:* **ClusterIP** is internal-only. **NodePort** exposes the service on a static port on every node. **LoadBalancer** uses a cloud provider's external load balancer to route traffic.
10. **How does CoreDNS work in Kubernetes?**
    - *Answer:* It provides DNS-based service discovery. When a service is created, a DNS entry is automatically created so pods can reach it by name (e.g., `my-service.namespace.svc.cluster.local`).

### 🚀 Advanced & Troubleshooting
11. **What is a "Deployment" and how does it differ from a "StatefulSet"?**
    - *Answer:* **Deployments** are for stateless applications (pods are interchangeable). **StatefulSets** are for stateful applications (pods have unique, persistent identities and stable storage).
12. **What are "Liveness" and "Readiness" probes?**
    - *Answer:* **Liveness** probes check if the container is alive (if it fails, K8s restarts it). **Readiness** probes check if the container is ready to handle traffic (if it fails, K8s removes it from the service endpoints).
13. **How do you handle secrets in Kubernetes?**
    - *Answer:* Using the `Secret` object. Secrets are stored in `etcd` (should be encrypted at rest) and can be mounted as volumes or environment variables in Pods.
14. **What is "Horizontal Pod Autoscaler" (HPA)?**
    - *Answer:* An automated system that scales the number of pod replicas in a deployment or statefulset based on observed CPU utilization or other metrics.
15. **What is a "Sidecar" container?**
    - *Answer:* A container that runs in the same Pod as the main application container to provide supporting features like logging, monitoring, or proxying (e.g., Istio Envoy).
16. **Explain "ConfigMaps" vs "Secrets".**
   - *Answer:* Both store configuration data. **ConfigMaps** are for non-sensitive data (plain text). **Secrets** are for sensitive data (base64 encoded and potentially encrypted).
17. **What is a "Namespace"?**
   - *Answer:* A virtual cluster within a physical cluster. It provides a scope for names and helps organize resources (e.g., `dev`, `test`, `prod`).
18. **How do you troubleshoot a Pod in `ImagePullBackOff` status?**
    - *Answer:* Check `kubectl describe pod`, verify the image name/tag, and ensure the node has permissions to pull from the registry (using `imagePullSecrets` if private).
19. **What is a "Taint" and a "Toleration"?**
    - *Answer:* **Taints** are applied to Nodes to repel certain pods. **Tolerations** are applied to Pods to allow them to stay on nodes with matching taints.
20. **What is "Helm"?**
    - *Answer:* A package manager for Kubernetes that uses "Charts" to define, install, and upgrade complex Kubernetes applications.

---

## 🧠 Kubernetes Knowledge Quiz

**1. Which component schedules pods to nodes?**
- A) `kubelet`
- B) `kube-apiserver`
- C) `kube-scheduler`
- D) `etcd`
*Answer: C*

**2. Which object is best for running a database like MySQL?**
- A) Deployment
- B) ReplicaSet
- C) StatefulSet
- D) DaemonSet
*Answer: C*

**3. What is the default service type?**
- A) NodePort
- B) LoadBalancer
- C) ClusterIP
- D) ExternalName
*Answer: C*

**4. Which command shows the resource usage (CPU/RAM) of nodes?**
- A) `kubectl get nodes`
- B) `kubectl top nodes`
- C) `kubectl describe nodes`
- D) `kubectl check nodes`
*Answer: B (Requires Metrics Server)*

**5. How do you mount a ConfigMap as a file inside a pod?**
- A) Using `env`
- B) Using `volumes` and `volumeMounts`
- C) Using `labels`
- D) Using `annotations`
*Answer: B*

**6. Which status indicates a container is crashing immediately after start?**
- A) Pending
- B) Running
- C) CrashLoopBackOff
- D) Unknown
*Answer: C*

**7. A "DaemonSet" ensures that:**
- A) A pod runs on every node in the cluster
- B) A pod runs only on master nodes
- C) A pod runs as a background process
- D) A pod runs only once and exits
*Answer: A*

**8. Which port range is typically used for NodePort services?**
- A) 80-443
- B) 1024-5000
- C) 30000-32767
- D) 60000-65535
*Answer: C*

**9. What is the "kubeconfig" file used for?**
- A) Storing application logs
- B) Configuring the K8s API server
- C) Storing cluster access information for `kubectl`
- D) Defining deployments
*Answer: C*

**10. Which probe determines if a container should be restarted?**
- A) Readiness Probe
- B) Liveness Probe
- C) Startup Probe
- D) Health Probe
*Answer: B*

**11. In a YAML file, `kind: Service` defines which API object?**
- A) A networking endpoint
- B) A storage unit
- C) A security policy
- D) A compute unit
*Answer: A*

**12. What does `kubectl exec -it <pod_name> -- bin/bash` do?**
- A) Restarts the pod
- B) Views pod logs
- C) Opens an interactive shell inside the pod
- D) Deletes the pod
*Answer: C*

**13. Which object is used to manage persistent storage lifecycle?**
- A) StorageClass
- B) PersistentVolume (PV)
- C) PersistentVolumeClaim (PVC)
- D) All of the above
*Answer: D*

**14. What is "Affinity"?**
- A) A way to attract pods to specific nodes based on labels
- B) A security setting
- C) A storage type
- D) A network protocol
*Answer: A*

**15. Which command rolls back a deployment to a previous version?**
- A) `kubectl delete deployment`
- B) `kubectl rollout undo deployment`
- C) `kubectl revert deployment`
- D) `kubectl fix deployment`
*Answer: B*

**16. What is the purpose of "Namespaces"?**
- A) To name servers
- B) To provide isolation and resource grouping
- C) To speed up the network
- D) To backup the cluster
*Answer: B*

**17. Which resource allows you to expose multiple services under a single IP/Domain using HTTP paths?**
- A) LoadBalancer
- B) Ingress
- C) Proxy
- D) Router
*Answer: B*

**18. "Requests" in a pod specification define:**
- A) The maximum CPU/RAM a pod can use
- B) The minimum CPU/RAM guaranteed to a pod
- C) The number of HTTP requests allowed
- D) The network bandwidth
*Answer: B*

**19. What is a "Job" in Kubernetes?**
- A) A task that runs forever
- B) A task that runs until completion (e.g., a batch process)
- C) A scheduled task (e.g., cron)
- D) A user account
*Answer: B*

**20. What is "Zero Downtime Deployment" in K8s?**
- A) Deploying at midnight
- B) Using Rolling Updates to replace pods one by one without stopping service
- C) Never updating the app
- D) Running only one replica
*Answer: B*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between Control Plane and Worker Nodes
