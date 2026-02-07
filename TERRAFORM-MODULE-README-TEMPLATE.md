# Terraform Module: [MODULE_NAME]

## 📋 Overview

**Purpose:** [Brief description of what this module provisions]  
**Maturity Level:** Production-Ready  
**Terraform Version:** >= 1.5.0  
**Provider Version:** AWS ~> 5.0

---

## 🏗️ Architecture

```
[Include architecture diagram or ASCII art]
```

### Resources Created
- [ ] VPC with public/private subnets
- [ ] Internet Gateway & NAT Gateways
- [ ] Route tables and associations
- [ ] Security groups with least-privilege rules
- [ ] [Add other resources]

---

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0 installed
- S3 bucket for remote state (see [State Management](#state-management))
- DynamoDB table for state locking

### Basic Usage

```hcl
module "vpc" {
  source = "git::https://github.com/your-org/terraform-modules.git//vpc?ref=v1.0.0"

  project_name         = "my-project"
  environment          = "production"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = false  # Use one NAT per AZ for HA
  enable_dns_hostnames = true
  enable_flow_logs     = true
  
  tags = {
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}
```

---

## 📥 Inputs

### Required Variables

| Name | Type | Description | Example |
|------|------|-------------|---------|
| `project_name` | `string` | Project identifier for resource naming | `"my-app"` |
| `environment` | `string` | Environment name (dev/staging/prod) | `"production"` |
| `vpc_cidr` | `string` | CIDR block for VPC | `"10.0.0.0/16"` |
| `availability_zones` | `list(string)` | List of AZs to deploy subnets | `["us-east-1a", "us-east-1b"]` |

### Optional Variables

| Name | Type | Default | Description | Validation |
|------|------|---------|-------------|------------|
| `enable_nat_gateway` | `bool` | `true` | Create NAT Gateways for private subnets | N/A |
| `single_nat_gateway` | `bool` | `false` | Use single NAT (cost optimization) | N/A |
| `enable_flow_logs` | `bool` | `true` | Enable VPC Flow Logs to CloudWatch | N/A |
| `flow_logs_retention_days` | `number` | `30` | CloudWatch log retention period | Must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 |

### Variable Validation Examples

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
  
  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) <= 16
    error_message = "VPC CIDR block must be /16 or larger."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Must specify at least 2 availability zones for high availability."
  }
  
  validation {
    condition     = alltrue([for az in var.availability_zones : can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", az))])
    error_message = "All availability zones must be valid AWS AZ identifiers (e.g., us-east-1a)."
  }
}
```

---

## 📤 Outputs

### Network Outputs

| Name | Type | Description | Sensitive |
|------|------|-------------|-----------|
| `vpc_id` | `string` | VPC identifier | No |
| `vpc_cidr_block` | `string` | VPC CIDR block | No |
| `public_subnet_ids` | `list(string)` | List of public subnet IDs | No |
| `private_subnet_ids` | `list(string)` | List of private subnet IDs | No |
| `nat_gateway_ips` | `list(string)` | Elastic IPs of NAT Gateways | No |
| `vpc_flow_log_id` | `string` | VPC Flow Log ID | No |

### Usage in Downstream Modules

```hcl
# In another module or root configuration
module "vpc" {
  source = "./modules/vpc"
  # ... configuration
}

module "eks" {
  source = "./modules/eks"
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  
  # EKS configuration
}
```

---

## 🔧 Advanced Configuration

### Using for_each for Dynamic Subnets

```hcl
locals {
  # Create a map of subnets with meaningful keys
  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs : 
    "public-${var.availability_zones[idx]}" => {
      cidr_block        = cidr
      availability_zone = var.availability_zones[idx]
      map_public_ip     = true
    }
  }
  
  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs : 
    "private-${var.availability_zones[idx]}" => {
      cidr_block        = cidr
      availability_zone = var.availability_zones[idx]
      map_public_ip     = false
    }
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${each.key}"
      Type = "public"
      Tier = "web"
    }
  )
}
```

**Benefits of for_each over count:**
- ✅ Stable resource addresses (no index shifts when removing items)
- ✅ More readable state file
- ✅ Easier to target specific resources: `terraform destroy -target=module.vpc.aws_subnet.public[\"public-us-east-1a\"]`

### Dynamic Blocks for Security Groups

```hcl
variable "security_group_rules" {
  description = "Map of security group rules"
  type = map(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  
  default = {
    ssh = {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH from VPN"
    }
    https = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from internet"
    }
  }
}

resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name}"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = { for k, v in var.security_group_rules : k => v if v.type == "ingress" }
    
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = { for k, v in var.security_group_rules : k => v if v.type == "egress" }
    
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-sg" })
}
```

### Conditional Resource Creation

```hcl
# Create NAT Gateway only if enabled
resource "aws_nat_gateway" "main" {
  for_each = var.enable_nat_gateway ? local.public_subnets : {}
  
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  
  tags = {
    Name = "${var.project_name}-nat-${each.key}"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# Create single NAT or one per AZ based on variable
locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.availability_zones)
}
```

### Lookup Function for Environment-Specific Values

```hcl
locals {
  # Environment-specific configurations
  instance_types = {
    dev        = "t3.micro"
    staging    = "t3.small"
    production = "t3.large"
  }
  
  backup_retention = {
    dev        = 7
    staging    = 14
    production = 30
  }
  
  # Use lookup with default fallback
  instance_type    = lookup(local.instance_types, var.environment, "t3.micro")
  retention_period = lookup(local.backup_retention, var.environment, 7)
}
```

---

## 🔐 Security Best Practices

### 1. Least Privilege IAM Policies

```hcl
# Terraform service account IAM policy
data "aws_iam_policy_document" "terraform_permissions" {
  statement {
    sid    = "VPCManagement"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcs",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:DescribeSubnets",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:DescribeRouteTables",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:DescribeInternetGateways",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:DescribeAddresses",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",
      "ec2:DescribeNatGateways",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
  
  statement {
    sid    = "FlowLogsManagement"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
      "ec2:CreateFlowLogs",
      "ec2:DeleteFlowLogs",
      "ec2:DescribeFlowLogs"
    ]
    resources = ["*"]
  }
  
  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:PassRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy"
    ]
    resources = [
      "arn:aws:iam::*:role/${var.project_name}-*"
    ]
  }
}
```

### 2. Secrets Management with AWS Secrets Manager

```hcl
# Never store secrets in variables or tfvars!
# Use AWS Secrets Manager instead

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "${var.project_name}/database/master"
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"
  
  username = local.db_creds.username
  password = local.db_creds.password
  
  # Other configuration...
}
```

### 3. Encryption at Rest

```hcl
# Enable EBS encryption by default
resource "aws_ebs_encryption_by_default" "enabled" {
  enabled = true
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}
```

### 4. VPC Flow Logs for Audit Trail

```hcl
resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0
  
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  
  tags = {
    Name = "${var.project_name}-vpc-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name              = "/aws/vpc/${var.project_name}"
  retention_in_days = var.flow_logs_retention_days
  kms_key_id        = aws_kms_key.logs[0].arn
}
```

---

## 🔄 State Management

### Remote Backend Configuration

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Enable versioning on the S3 bucket!
  }
}
```

### State Locking with DynamoDB

```hcl
# Create DynamoDB table for state locking (run once)
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock"
    Environment = "global"
  }
}
```

### Migrating from Local to Remote State

```bash
# 1. Add backend configuration to your code
# 2. Initialize backend migration
terraform init -migrate-state

# 3. Verify state was migrated
terraform state list

# 4. Remove local state files (after verification!)
rm terraform.tfstate*
```

---

## 🧪 Testing Strategy

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec
```

### Automated Testing with Terratest

```go
// test/vpc_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic",
        Vars: map[string]interface{}{
            "project_name": "test-vpc",
            "environment":  "dev",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vpcID := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcID)
}
```

---

## 📊 Dependency Management

### Using Data Sources

```hcl
# Lookup existing VPC
data "aws_vpc" "existing" {
  id = var.vpc_id
}

# Lookup latest AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

### Using terraform_remote_state

```hcl
# Reference outputs from another stack
data "terraform_remote_state" "networking" {
  backend = "s3"
  
  config = {
    bucket = "my-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [
    data.terraform_remote_state.networking.outputs.app_security_group_id
  ]
}
```

**When to use each:**
- **Data Sources:** For AWS-managed resources, AMI lookups, availability zones
- **terraform_remote_state:** For cross-stack dependencies you control
- **Best Practice:** Minimize use of remote_state to reduce coupling

---

## 🚨 Troubleshooting

### Common Issues

#### Issue 1: State Lock Timeout
```bash
Error: Error acquiring the state lock
```

**Solution:**
```bash
# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>

# Check DynamoDB for stuck locks
aws dynamodb scan --table-name terraform-state-lock
```

#### Issue 2: Resource Already Exists
```bash
Error: VPC already exists
```

**Solution:**
```bash
# Import existing resource
terraform import module.vpc.aws_vpc.main vpc-12345678

# Or use data source instead
data "aws_vpc" "existing" {
  id = "vpc-12345678"
}
```

#### Issue 3: Circular Dependency
```bash
Error: Cycle: module.a, module.b
```

**Solution:**
- Use `depends_on` explicitly
- Break circular dependencies by using data sources
- Refactor into separate stacks

---

## 📚 Examples

### Example 1: Development Environment

```hcl
module "vpc_dev" {
  source = "../../modules/vpc"

  project_name         = "myapp"
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  
  # Cost optimization for dev
  enable_nat_gateway = true
  single_nat_gateway = true  # Single NAT to save costs
  
  enable_flow_logs = false  # Disable for dev
  
  tags = {
    Owner      = "dev-team"
    CostCenter = "engineering"
  }
}
```

### Example 2: Production Environment

```hcl
module "vpc_prod" {
  source = "../../modules/vpc"

  project_name         = "myapp"
  environment          = "production"
  vpc_cidr             = "10.100.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.12.0/24", "10.100.13.0/24"]
  
  # High availability for production
  enable_nat_gateway = true
  single_nat_gateway = false  # One NAT per AZ
  
  enable_flow_logs          = true
  flow_logs_retention_days  = 90
  
  tags = {
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Compliance  = "pci-dss"
  }
}
```

---

## 🔄 Migration Guide

### Migrating from count to for_each

**Before (count):**
```hcl
resource "aws_subnet" "public" {
  count      = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
}
```

**After (for_each):**
```hcl
resource "aws_subnet" "public" {
  for_each   = toset(var.public_subnet_cidrs)
  cidr_block = each.value
}
```

**Migration Steps:**
```bash
# 1. Remove resources from state
terraform state rm 'aws_subnet.public[0]'
terraform state rm 'aws_subnet.public[1]'

# 2. Import with new addresses
terraform import 'aws_subnet.public["10.0.1.0/24"]' subnet-abc123
terraform import 'aws_subnet.public["10.0.2.0/24"]' subnet-def456

# 3. Verify
terraform plan  # Should show no changes
```

---

## 📖 Additional Resources

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terratest Documentation](https://terratest.gruntwork.io/)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Run `terraform fmt` and `terraform validate`
4. Submit a pull request with tests

---

## 📄 License

MIT License - See LICENSE file for details

---

## 👥 Maintainers

- Platform Team (@platform-team)
- DevOps Team (@devops-team)

---

**Last Updated:** 2024  
**Module Version:** 1.0.0  
**Terraform Version:** >= 1.5.0
