# K8s Workload Management Challenges 🚀

Master the controllers that manage your application lifecycle: Deployments, ReplicaSets, and Jobs.

---

## 🏆 Challenge 01: The Rolling Update
**Objective**: Update an application with zero downtime.

1.  **Requirement**: Deploy an Nginx deployment with 3 replicas using version `nginx:1.14.2`.
2.  **Task**: Update the image version to `nginx:1.16.1` using the `kubectl set image` command.
3.  **Observation**: Watch the rollout in real-time with `kubectl rollout status`.
4.  **Verification**: Confirm that at no point did the number of available replicas drop below 2.

---

## 🏆 Challenge 02: Scaling & High Availability
**Objective**: Handle traffic spikes by scaling out.

1.  **Requirement**: Create a CPU-intensive deployment (e.g., using an app that calculates Pi).
2.  **Task**: Manually scale the deployment from 3 to **10 replicas**.
3.  **Advanced Goal**: Research the **Horizontal Pod Autoscaler (HPA)**. Write a command to automatically scale if CPU usage hits 50%.
4.  **Question**: What happens if your cluster doesn't have enough physical worker nodes to host all 10 replicas?

---

## 🏆 Challenge 03: The One-Off Task
**Objective**: Use Kubernetes for "Batch Processing" instead of long-running apps.

1.  **Task**: Create a **Job** definition that runs a simple shell script to backup a database (e.g., `pg_dump`).
2.  **Logic**: The job must retry 4 times if it fails (`backoffLimit: 4`).
3.  **Verification**: Check `kubectl get jobs` and verify the completion status.

---

## 📁 Solutions
Advanced rollout strategies and YAML manifests are in the `Boilerplates/` directory.
