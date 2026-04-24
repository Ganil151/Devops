# GCP IAM Reference

GCP Identity and Access Management (IAM) lets you manage access control by defining who (identity) has what access (role) for which resource.

## 🏗️ Hierarchy
- **Organization**: Root level.
- **Folder**: Grouping projects.
- **Project**: The boundary for resources and billing.
- **Resource**: Specific services (e.g., GCS Bucket).

## 🛡️ Key Concepts
- **Service Accounts**: Identites for non-human users (applications/VMs).
- **Custom Roles**: Tailoring permissions precisely.
- **Workload Identity**: Mapping external identities (Kubernetes) to GCP IAM.

---

## 🛠️ IaC (Terraform)
```hcl
resource "google_project_iam_member" "viewer" {
  project = "prod-123"
  role    = "roles/viewer"
  member  = "serviceAccount:my-sa@prod-123.iam.gserviceaccount.com"
}
```
