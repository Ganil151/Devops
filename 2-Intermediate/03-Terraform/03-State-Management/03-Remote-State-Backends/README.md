# Remote State Backends

A backend defines where Terraform stores its state file and how it performs operations.

## Popular Backends

### 1. AWS S3 (with DynamoDB)
The most common setup for AWS users.
```hcl
terraform {
  backend "s3" {
    bucket         = "tf-state-prod"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock" # For locking
  }
}
```

### 2. Azure RM
Using Blob Storage.
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tstateacc"
    container_name       = "tstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

### 3. GCS (Google Cloud Storage)
```hcl
terraform {
  backend "gcs" {
    bucket = "tf-state-bucket"
    prefix = "terraform/state"
  }
}
```

### 4. Terraform Cloud
The managed SaaS offering from HashiCorp.
```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces { name = "my-app" }
  }
}
```

---

## 🏗️ Real-Life Scenario: The Multi-Backend Disaster
**Problem**: A company uses AWS for compute but Azure for data. They try to store the state file for an AWS resource in an Azure backend.
**Outcome**: This works! Terraform backends are independent of the resources being managed. However, it's a best practice to keep state in the same cloud provider to reduce cross-cloud dependencies.

---

## ❓ Interview Questions
1.  **What happens if the backend is unreachable?**
    *   *Answer*: Terraform will fail to initialize or perform any plan/apply operations as it cannot read the current source of truth.
2.  **What is the `terraform init -reconfigure` command used for?**
    *   *Answer*: It is used to initialize a backend while ignoring any existing backend configuration in the `.terraform` directory (useful for changing backends manually).

---

## 🧠 Quiz Snippet (5/20+)
1.  **Which AWS service provides locking for the S3 backend?** (DynamoDB)
2.  **Can you use variables inside a `backend` block?** (No, backends are initialized before variables are loaded)
3.  **What command initializes the backend?** (`terraform init`)
4.  **True/False: GCS supports locking natively.** (True)
5.  **Which backend is managed by HashiCorp?** (Terraform Cloud / Enterprise)
