# 🔐 Provisioning & IaC: The Terraform Engine

> **"Infrastructure as Code means your datacenter is versioned in Git. 'Clicking around' in the console is strictly forbidden."**

This reference covers **Terraform** and the Declarative Provisioning model.

---

## 🏗️ 1. The Terraform Lifecycle

The standard "Plan-Apply" loop.

| Phase | Command | Purpose | Staff Tip |
| :--- | :--- | :--- | :--- |
| **Init** | `terraform init` | Download providers/modules. | Use `-backend-config` for dynamic envs. |
| **Plan** | `terraform plan` | Dry-Run. Shows "The Diff". | Always save it: `-out=tfplan`. |
| **Apply** | `terraform apply` | Execute API calls. | Apply the *saved plan* only. |
| **Destroy**| `terraform destroy`| Nuke everything. | Dangerous. Use `prevent_destroy` on DBs. |

---

## 📦 2. Essential HCL Keywords

HashiCorp Configuration Language.

| Keyword | Use Case | Example |
| :--- | :--- | :--- |
| `resource` | Create something (EC2, S3). | `resource "aws_instance" "web" {}` |
| `data` | Read existing thing. | `data "aws_ami" "ubuntu" {}` |
| `variable` | Input parameter. | `variable "region" { default = "us-east-1" }` |
| `output` | Return value. | `output "ip" { value = aws_instance.web.public_ip }` |
| `local` | Internal variable. | `locals { common_tags = { Team = "Dev" } }` |
| `module` | Reusable component. | `module "vpc" { source = "./modules/vpc" }` |

**Staff Pattern (Dynamic Metadata)**:
```hcl
locals {
  service_name = "payment-api"
  # Standardize naming: env-service-resource
  bucket_name  = "${var.environment}-${local.service_name}-logs"
  
  common_tags = {
    Owner       = "Platform"
    CostCenter  = "1001"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = local.bucket_name
  tags   = local.common_tags
}
```

---

## 💾 3. State Management

The `terraform.tfstate` file is the "Brain".

### Remote Backend (S3 + DynamoDB)
Never store state locally or in Git.
```hcl
terraform {
  backend "s3" {
    bucket         = "company-tf-state"
    key            = "prod/app.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" # Prevents concurrent writes
    encrypt        = true
  }
}
```

### State Commands
| Command | Purpose |
| :--- | :--- |
| `state list` | Show all resources tracked. |
| `state show` | Inspect specific resource attributes. |
| `state mv` | Rename/Move resource without destroying it (Refactoring). |
| `state rm` | Stop tracking a resource (Manual Drift). |

---

## 🤝 4. Meta-Arguments

Change how resources behave.

- **`count`**: Loop using Index.
  `count = var.is_prod ? 3 : 1`
- **`for_each`**: Loop using Map/Set (Safer).
  `for_each = var.subnet_cidrs`
- **`lifecycle`**: Guardrails.
  ```hcl
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags] # Drift Ignored
  }
  ```

---

[⬅️ Back to Reference Hub](./readme.md)
