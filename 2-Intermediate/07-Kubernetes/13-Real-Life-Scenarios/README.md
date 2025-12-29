# Kubernetes Real-Life Scenarios

Put your orchestration skills into practice with these real-world DevOps challenges.

---

## 🛠️ Scenario 1: The Zero-Downtime Rolling Update
**Problem:** Your application is highly active. You need to deploy a new feature, but you cannot afford any downtime during the transition.

**The Solution:**
1. Use a **Deployment** with a `RollingUpdate` strategy.
2. Define `maxUnavailable` (e.g., 25%) and `maxSurge` (e.g., 25%).
3. Run `kubectl apply -f deployment.yaml`.
4. Kubernetes will start new pods (v2) and only shutdown old pods (v1) once v2 passes its **Readiness Probe**.
5. If monitoring shows errors, run `kubectl rollout undo deployment/my-app` to revert immediately.
**Goal**: Master high-availability application updates.

---

## 🏗️ Scenario 2: Troubleshooting "ImagePullBackOff"
**Problem:** You deploy a pod using an image from a private registry (e.g., AWS ECR or Docker Hub Private), but the pod status says `ImagePullBackOff`.

**The Investigation:**
1. Run `kubectl describe pod <pod_name>`.
2. Find the "Events" section. It likely says `ErrImagePull` and `unauthorized: authentication required`.
3. **The Fix**:
   - Create a `kubernetes.io/dockerconfigjson` Secret containing your registry credentials.
   - Add `imagePullSecrets: [{name: my-registry-key}]` to your pod's `spec`.
   - Re-apply the configuration.
**Goal**: Manage secure private registry integrations.

---

## 🌩️ Scenario 3: Autoscaling for Traffic Spikes
**Problem:** Your e-commerce app experiences massive traffic spikes during sales. You need to scale automatically without manual intervention.

**The Solution:**
1. Ensure the **Metrics Server** is installed in the cluster.
2. Define **Resource Requests** and **Limits** in your deployment (e.g., request 100m CPU).
3. Create a **Horizontal Pod Autoscaler (HPA)**:
   ```bash
   kubectl autoscale deployment my-app --cpu-percent=50 --min=2 --max=10
   ```
4. As CPU usage hits the 50% threshold, Kubernetes automatically launches more replicas.
**Goal**: Implement dynamic, cost-effective infrastructure scaling.

---

## 🔄 Scenario 4: Investigating a "CrashLoopBackOff"
**Problem:** A pod starts, but immediately crashes and enters the `CrashLoopBackOff` state.

**The Investigation:**
1. **Check Logs**: `kubectl logs <pod_name>`. Often the application prints an error message (e.g., `Missing environment variable: DB_PASSWORD`).
2. **Check Events**: `kubectl describe pod <pod_name>`. Look for "Exit Code".
   - `Exit Code 0`: The application finished its task (maybe it should be a Job, not a Deployment?).
   - `Exit Code 137`: Out of Memory (OOMKilled). Increase the memory limit!
   - `Exit Code 1`: General application error.
3. **The Fix**: Fix the configuration (ConfigMap/Secret) or increase resources.
**Goal**: Become an expert debugger of containerized workloads.

---

## 🛍️ Scenario 5: Persistent Storage for a Stateful Database
**Problem:** You are running a database (PostgreSQL) in Kubernetes. When the pod restarts, all the data is gone because it was stored inside the container.

**The Solution:**
1. Define a **PersistentVolumeClaim (PVC)** requesting 10Gi of storage.
2. Use a **StorageClass** (e.g., `gp2` in AWS) for dynamic provisioning.
3. Update the **StatefulSet** spec to mount the PVC into `/var/lib/postgresql/data`.
4. Kubernetes will automatically provision a cloud disk (EBS/Azure Disk) and attach it to the node where the pod is running.
**Goal**: Handle stateful workloads and persistent data lifecycles.

---

## 💡 Key Takeaway
Kubernetes is a **Self-Healing** orchestrator. Most real-world scenarios involve providing the right "Desired State" (probes, secrets, storage) so that the cluster can manage the "Actual State" autonomously.
