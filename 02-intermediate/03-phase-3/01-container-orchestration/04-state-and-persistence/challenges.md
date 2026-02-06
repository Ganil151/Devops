# K8s State & Persistence Challenges 💾

Master the management of persistent data in an ephemeral container world.

---

## 🏆 Challenge 01: Persistent Volume Basics
**Objective**: Ensure data survives a pod crash.

1.  **Task**: Create a **PersistentVolumeClaim (PVC)** requesting 1Gi of storage.
2.  **Requirement**: Mount this PVC into an Nginx pod at `/usr/share/nginx/html`.
3.  **Simulation**: Write a file to that directory, then delete the pod using `kubectl delete pod`.
4.  **Verification**: Wait for the pod to restart (if using a Deployment) and verify the file still exists.

---

## 🏆 Challenge 02: StorageClasses & Dynamic Provisioning
**Objective**: Automate the creation of infrastructure storage.

1.  **Requirement**: Research your cluster's default **StorageClass**.
2.  **Task**: Create a PVC that uses a specific StorageClass (e.g., `gp2` on AWS or `standard` on GKE).
3.  **Observation**: Watch your cloud provider dashboard to see the real EBS/VHD disk being created automatically.

---

## 🏆 Challenge 03: StatefulSets (Database Deployment)
**Objective**: Deploy a database with ordered identity.

1.  **Requirement**: Create a **StatefulSet** for MongoDB or PostgreSQL.
2.  **Task**: Observe the pod names (e.g., `db-0`, `db-1`) vs. random Deployment names.
3.  **Question**: Why is stable network identity (ordered naming) important for database clusters?

---

## 📁 Solutions
Storage manifests and Persistence patterns are in the `Boilerplates/` directory.
