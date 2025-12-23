# Kubernetes (K8s) Orchestration Guide

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications. It has become the "OS of the Data Center."

---

## 🏗️ 1. Cluster Architecture Deep Dive

A Kubernetes cluster is divided into two parts: the **Control Plane** and the **Worker Nodes**.

- **Control Plane**: The brain. It contains `kube-apiserver` (the entry point), `etcd` (the database), and `kube-scheduler`.
- **Worker Nodes**: Where the work happens. Each node runs `kubelet` (the manager) and `kube-proxy` (the networker).

## 🛠️ 2. Essential Kubectl Commands

### 🔍 Discovery and Inspection
*When to use: Checking the state of your cluster and debugging resources.*

```bash
# Get all pods in all namespaces
kubectl get pods -A

# Detailed view of a specific pod (Events are here!)
kubectl describe pod <pod_name>

# View logs from a specific container in a pod
kubectl logs <pod_name> -c <container_name> -f

# List all services and their external IPs
kubectl get svc
```

### ⚙️ Management and Scaling
*When to use: Deploying updates and responding to traffic spikes.*

```bash
# Apply a YAML configuration
kubectl apply -f deployment.yaml

# Scale a deployment to 5 replicas
kubectl scale deployment/my-app --replicas=5

# Rollout undo (Revert to previous version)
kubectl rollout undo deployment/my-app

# Port-forward to access a service locally
kubectl port-forward svc/my-service 8080:80
```

---

## 💡 Kubernetes Best Practices

- **Use Declarative Files**: Avoid `kubectl run`. Always use `kubectl apply -f <file>.yaml` so your cluster state is documented.
- **Set Resource Requests/Limits**: Prevent "Noisy Neighbor" issues by defining exactly how much CPU/RAM each pod needs.
- **Liveness & Readiness Probes**: Ensure K8s only sends traffic to pods that are actually ready to handle it.
- **Namespace Everything**: Never deploy to the `default` namespace. Use `dev`, `prod`, `monitoring` to stay organized.
- **Labels are Metadata**: Use labels (`app: web`, `env: production`) for selecting and grouping resources effectively.

---

## 🧠 Training & Assessment

### Knowledge Quiz

**1. Which component is responsible for maintaining the state of the cluster (the "source of truth")?**
- A) `kube-scheduler`
- B) `etcd`
- C) `kubelet`
- D) `kube-proxy`

**2. What happens if a Pod's 'Readiness Probe' fails?**
- A) The pod is deleted and recreated
- B) The pod is removed from the Service's endpoint list (no traffic)
- C) The node is marked as Unhealthy
- D) Kubernetes ignores the failure

**3. Which command is used to see the internal events of a Pod (e.g., Pulling image, Started)?**
- A) `kubectl logs`
- B) `kubectl events`
- C) `kubectl describe pod`
- D) `kubectl get logs`

---

### Real-World Troubleshooting Scenarios

#### Scenario 1: The "CrashLoopBackOff" Cycle
**Problem:** You deploy an update, but the pods keep restarting.
**Investigation:**
1.  **Check Status:** `kubectl get pods` shows `CrashLoopBackOff`.
2.  **View Events:** `kubectl describe pod <name>` shows `Back-off restarting failed container`.
3.  **Check Logs:** `kubectl logs <name>` reveals `Error: Database connection failed (Timeout)`.
**Solution:** The new version has an incorrect DB connection string in its ConfigMap. Fix the ConfigMap and redeploy.

#### Scenario 2: Service is Unreachable
**Problem:** You can reach the pod IP, but the Service DNS/IP isn't working.
**Investigation:**
1.  **Check Selectors:** Run `kubectl get svc <name> -o yaml` and check the `selector`.
2.  **Check Pod Labels:** Run `kubectl get pods --show-labels`.
**Solution:** The Service selector `app: web` doesn't match the Pod's label `app: micro-web`. Fix the selector to match.

---

## ✅ Knowledge Check
- [ ] Install `kubectl` and `minikube`/`kind`
- [ ] Navigate namespaces and contexts
- [ ] Understand the Pod-Deployment-Service hierarchy
- [ ] Manage ConfigMaps and Secrets
- [ ] Troubleshoot with `describe`, `logs`, and `exec`

## 🔗 Next Steps
- **[Helm Charts](../02-Helm/)** - Package your K8s apps.
- **[ArgoCD GitOps](../../3-Advanced/01-GitOps/)** - Automate your deployments.
- **[Monitoring with Prometheus](../../3-Advanced/02-Observability/)** - Keep an eye on your cluster.

---
*Kubernetes is the orchestrator of the future—master the score, and you can conduct any scale.*