# 🔰 GCP Config Connector Beginner Level

## 📋 Learning Objectives
- ✅ Install Config Connector on a GKE cluster
- ✅ Configure IAM for the operator
- ✅ Deploy a simple S3-equivalent (GCS) bucket via `kubectl`

---

## 🚀 Getting Started

### 1. Installation Modes
- **Namespaced Mode (Recommended)**: Each Kubernetes namespace is mapped to a specific GCP project.
- **Cluster Mode**: One instance of Config Connector manages resources across the entire cluster.

### 2. Basic Manifest
Config Connector resources look exactly like Kubernetes resources.

```yaml
apiVersion: storage.cnrm.cloud.google.com/v1beta1
kind: StorageBucket
metadata:
  name: my-gitops-bucket
  namespace: config-connector # Namespace mapped to a project
spec:
  location: US
  storageClass: STANDARD
```

---

## 🛠️ Essential Commands

### Apply a Resource
```bash
kubectl apply -f bucket.yaml
```

### Check Status
```bash
kubectl get storagebucket my-gitops-bucket -o yaml
```
Look at the `status` section:
- `Ready`: If `True`, the resource is fully provisioned in GCP.
- `Conditions`: Detailed information about errors or progress.

### List all GCP Resources
```bash
kubectl get gcp --all-namespaces
```

---

## 🔑 Key Concepts
- **Custom Resource Definitions (CRDs)**: Config Connector installs hundreds of CRDs for GCP services.
- **Namespaced ID**: The GCP project ID is typically specified as an annotation or via the namespace configuration.
- **Reconciliation**: The controller checks every few minutes to see if the cloud resource matches the YAML.
