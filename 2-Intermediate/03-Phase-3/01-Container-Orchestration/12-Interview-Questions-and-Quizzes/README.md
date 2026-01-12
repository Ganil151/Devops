# Kubernetes Interview Questions & Quiz

Master the "OS of the Data Center" and prepare for the CKA/CKAD technical screenings.

---

## 🎤 Top 20 Kubernetes Interview Questions

<b>1. What are the main components of the Kubernetes Control Plane?</b>
<details>
<summary>Show Answer</summary>
Answer: The Control Plane is the brain of the cluster. Components include `kube-apiserver` (API), `etcd` (state storage), `kube-scheduler` (assigns pods to nodes), and `kube-controller-manager` (runs controller processes).
</details>


<b>2. What is the role of kubelet in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: An agent that runs on each node in the cluster. It ensures that containers are running in a Pod according to the PodSpecs provided by the API server.
</details>


<b>3. What is etcd and why is it important?</b>
<details>
<summary>Show Answer</summary>
Answer: A distributed, reliable key-value store used as Kubernetes' backing store for all cluster data.
</details>


<b>4. What is a Pod in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: The smallest deployable unit in Kubernetes. A Pod represents a single instance of a running process and can contain one or more containers.
</details>


<b>5. What is the purpose of kube-proxy?</b>
<details>
<summary>Show Answer</summary>
Answer: It maintains network rules on nodes, allowing network communication to your Pods from inside or outside the cluster.
</details>


<b>6. What is the difference between a Service and an Ingress?</b>
<details>
<summary>Show Answer</summary>
Answer: A Service (like LoadBalancer or NodePort) exposes an application internally or externally. An Ingress is an API object that manages external access to services, typically via HTTP, providing features like name-based virtual hosting and SSL termination.
</details>


<b>7. What is a Headless Service?</b>
<details>
<summary>Show Answer</summary>
Answer: A service that does not have a ClusterIP. It is used when you want to discover the individual Pod IPs directly (often used for StatefulSets).
</details>


<b>8. What is CNI in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: It is a specification and set of libraries for configuring network interfaces in Linux containers. Kubernetes uses CNI plugins (like Calico or Flannel) to manage pod networking.
</details>


<b>9. Explain the different Service types in Kubernetes.</b>
<details>
<summary>Show Answer</summary>
Answer: **ClusterIP** is internal-only. **NodePort** exposes the service on a static port on every node. **LoadBalancer** uses a cloud provider's external load balancer to route traffic.
</details>


<b>10. How does DNS work in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: It provides DNS-based service discovery. When a service is created, a DNS entry is automatically created so pods can reach it by name (e.g., `my-service.namespace.svc.cluster.local`).
</details>


<b>11. What is the difference between Deployments and StatefulSets?</b>
<details>
<summary>Show Answer</summary>
Answer: **Deployments** are for stateless applications (pods are interchangeable). **StatefulSets** are for stateful applications (pods have unique, persistent identities and stable storage).
</details>


<b>12. What are Liveness and Readiness probes?</b>
<details>
<summary>Show Answer</summary>
Answer: **Liveness** probes check if the container is alive (if it fails, K8s restarts it). **Readiness** probes check if the container is ready to handle traffic (if it fails, K8s removes it from the service endpoints).
</details>


<b>13. How do you handle secrets in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: Using the `Secret` object. Secrets are stored in `etcd` (should be encrypted at rest) and can be mounted as volumes or environment variables in Pods.
</details>


<b>14. What is Horizontal Pod Autoscaler (HPA)?</b>
<details>
<summary>Show Answer</summary>
Answer: An automated system that scales the number of pod replicas in a deployment or statefulset based on observed CPU utilization or other metrics.
</details>


<b>15. What is a sidecar container?</b>
<details>
<summary>Show Answer</summary>
Answer: A container that runs in the same Pod as the main application container to provide supporting features like logging, monitoring, or proxying (e.g., Istio Envoy).
</details>


<b>16. What is the difference between ConfigMaps and Secrets?</b>
<details>
<summary>Show Answer</summary>
Answer: Both store configuration data. **ConfigMaps** are for non-sensitive data (plain text). **Secrets** are for sensitive data (base64 encoded and potentially encrypted).
</details>


<b>17. What is a Namespace in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: A virtual cluster within a physical cluster. It provides a scope for names and helps organize resources (e.g., `dev`, `test`, `prod`).
</details>


<b>18. How do you troubleshoot ImagePullBackOff errors?</b>
<details>
<summary>Show Answer</summary>
Answer: Check `kubectl describe pod`, verify the image name/tag, and ensure the node has permissions to pull from the registry (using `imagePullSecrets` if private).
</details>


<b>19. What are Taints and Tolerations?</b>
<details>
<summary>Show Answer</summary>
Answer: **Taints** are applied to Nodes to repel certain pods. **Tolerations** are applied to Pods to allow them to stay on nodes with matching taints.
</details>


<b>20. What is Helm?</b>
<details>
<summary>Show Answer</summary>
Answer: A package manager for Kubernetes that uses "Charts" to define, install, and upgrade complex Kubernetes applications.
</details>


---

## 🧠 Kubernetes Knowledge Quiz

<b>1. Which component schedules pods to nodes?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>2. Which object is best for running a database like MySQL?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>3. What is the default service type?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>4. Which command shows the resource usage (CPU/RAM) of nodes?</b>
<details>
<summary>Show Answer</summary>
Answer: B (Requires Metrics Server)
</details>


<b>5. How do you mount a ConfigMap as a file inside a pod?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. Which status indicates a container is crashing immediately after start?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>7. A "DaemonSet" ensures that:</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>8. Which port range is typically used for NodePort services?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>9. What is the "kubeconfig" file used for?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>10. Which probe determines if a container should be restarted?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. In a YAML file, `kind: Service` defines which API object?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>12. What does `kubectl exec -it <pod_name> -- bin/bash` do?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>13. Which object is used to manage persistent storage lifecycle?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>14. What is "Affinity"?</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>15. Which command rolls back a deployment to a previous version?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. What is the purpose of "Namespaces"?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>17. Which resource allows you to expose multiple services under a single IP/Domain using HTTP paths?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. "Requests" in a pod specification define:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. What is a "Job" in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. What is "Zero Downtime Deployment" in K8s?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between Control Plane and Worker Nodes