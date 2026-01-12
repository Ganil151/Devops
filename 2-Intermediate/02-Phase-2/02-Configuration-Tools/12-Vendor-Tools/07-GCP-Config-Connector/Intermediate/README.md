# 🚀 GCP Config Connector Intermediate Level

## 📋 Learning Objectives
- ✅ Manage **Resources Dependencies** and References
- ✅ Implement **IAM Policy** management
- ✅ Control resource lifecycle using **Annotations**

---

## 🏗️ Resource References
Config Connector allows resources to point to one another using `resourceRef`.

```yaml
apiVersion: compute.cnrm.cloud.google.com/v1beta1
kind: ComputeInstance
metadata:
  name: my-vm
spec:
  location: us-central1-a
  confidentialInstanceConfig:
    enableConfidentialCompute: false
  networkInterface:
  - networkRef:
      name: my-vpc-network # References another K8s resource
```

---

## 🔐 IAM Management
You can manage IAM roles and policies just like any other resource.

```yaml
apiVersion: iam.cnrm.cloud.google.com/v1beta1
kind: IAMPolicyMember
metadata:
  name: storage-admin-member
spec:
  resourceRef:
    apiVersion: storage.cnrm.cloud.google.com/v1beta1
    kind: StorageBucket
    name: my-bucket
  role: roles/storage.admin
  member: "serviceAccount:my-sa@my-project.iam.gserviceaccount.com"
```

---

## 🛠️ Resource Lifecycle Annotations
Sometimes you want to delete the Kubernetes object but keep the cloud resource.

### 1. Abandon on Delete
```yaml
annotations:
  cnrm.cloud.google.com/deletion-policy: "abandon"
```

### 2. Management Mode
You can set a resource to `unmanaged` if you only want to use it for references but don't want the controller to change its properties.
```yaml
annotations:
  cnrm.cloud.google.com/management-mode: "unmanaged"
```
