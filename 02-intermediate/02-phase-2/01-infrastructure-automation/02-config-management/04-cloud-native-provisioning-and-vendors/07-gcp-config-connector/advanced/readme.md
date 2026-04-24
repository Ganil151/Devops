# 🏆 GCP Config Connector Advanced Level

## 📋 Learning Objectives
- ✅ Deploy resources across **Multi-Projects** and **Multi-Regions**
- ✅ Integrate with **GitOps** workflows (Config Sync / ArgoCD)
- ✅ Perform **Resource Import** to bring existing assets under management
- ✅ Troubleshoot controller performance and reconciliation errors

---

## 🚀 GitOps Integration
By using Config Connector, you can store your entire infrastructure in a Git repository.
1. **Developer** pushes a new `StorageBucket` YAML to Git.
2. **ArgoCD/Flux/Config Sync** detects the change and applies it to GKE.
3. **Config Connector** provisions the actual bucket in GCP.

---

## 🔄 Resource Import
You can take resources created manually and have Config Connector start managing them.
1. Create a YAML manifest that matches the existing resource's properties.
2. Add the `cnrm.cloud.google.com/management-mode: "unmanaged"` annotation.
3. Apply the YAML.
4. Verify the status matches.
5. Remove the `unmanaged` annotation to let CC take over management.

---

## 🏢 Enterprise Governance
- **Organization-level Resources**: Managing Folders and Projects using the high-level CRDs.
- **Conflict Management**: Using `state-into-spec` annotation to control how the controller updates the Kubernetes object's status field from the cloud provider's values.

---

## 🔍 Troubleshooting at Scale
Check the operator logs for common errors:
- **Rate Limiting**: Too many requests to GCP API.
- **RBAC Errors**: Kubernetes service account doesn't have permissions to read/write specific CRDs.
- **IAM Errors**: The Google Service Account (GSA) bound to the KSA lacks the required GCP permissions.
