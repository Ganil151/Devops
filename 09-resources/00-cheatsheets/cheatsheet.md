# 05-terraform-iac

## 🛡️ Best Practices (Junior to Senior)
- **Remote State**: Never store `terraform.tfstate` locally. Use S3 + DynamoDB (locking).
- **Pin Versions**: Explicitly pin provider and module versions to avoid breaking changes.
- **Small State Files**: Break infrastructure into layers (Networking, Data, App) to reduce "blast radius."
- **Format & Validate**: Always run `terraform fmt` and `terraform validate` in CI pipelines.

---

## 🏗️ Modules & Dynamic Blocks

### Calling a Reusable Module
Don't reinvent the wheel; use modules for VPCs, Clusters, etc.
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "production-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

### Dynamic Blocks (DRY Security Groups)
Iterate over a list of ports instead of writing multiple `ingress` blocks.
```hcl
variable "ingress_ports" {
  type    = list(number)
  default = [80, 443, 22]
}

resource "aws_security_group" "web" {
  name = "web-sg"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

---

## 🔄 State Management

### Inspecting State
List all resources currently tracked by Terraform.
```bash
terraform state list
```

### Moving Resources (Refactoring)
Move a resource into a module (or rename it) without destroying/recreating it.
```bash
terraform state mv aws_instance.web module.web_server.aws_instance.this
```

### Importing Existing Infrastructure
Bring a manually created S3 bucket under Terraform management.
```bash
# 1. Define empty resource in main.tf
# resource "aws_s3_bucket" "legacy" {}

# 2. Import
terraform import aws_s3_bucket.legacy my-existing-bucket-name
```

---

## ⚡ Lifecycle Hooks

### Create Before Destroy
Essential for zero-downtime replacements (e.g., Launch Templates, ASGs).
```hcl
resource "aws_launch_template" "app" {
  name_prefix   = "app-v1-"
  image_id      = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

### Prevent Destruction
Safety lock for critical stateful resources (Databases, S3 Buckets).
```hcl
resource "aws_db_instance" "production" {
  allocated_storage = 100
  engine            = "postgres"
  
  lifecycle {
    prevent_destroy = true
  }
}
```
