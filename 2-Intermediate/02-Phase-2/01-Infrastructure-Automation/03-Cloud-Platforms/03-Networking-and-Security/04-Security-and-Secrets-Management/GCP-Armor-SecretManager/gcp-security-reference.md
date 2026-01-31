# GCP Secret Manager & KMS Reference

GCP Secret Manager and Cloud KMS provide integrated encryption and secrets storage for Google Cloud applications.

## 🔐 Key Features
- **Secret Manager**: Versioned secrets with fine-grained IAM control.
- **Cloud KMS**: Manage encryption keys for use with other GCP services.
- **Automatic Rotation**: Integrated rotation for secrets.

## 🛠️ IaC (Terraform)
```hcl
resource "google_secret_manager_secret" "db_secret" {
  secret_id = "db-password"
  replication {
    automatic = true
  }
}
```
