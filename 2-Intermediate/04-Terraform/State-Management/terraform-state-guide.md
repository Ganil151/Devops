# Terraform State Management Guide

## Table of Contents
1. [State Fundamentals](#state-fundamentals)
2. [Local vs Remote State](#local-vs-remote-state)
3. [Remote State Backends](#remote-state-backends)
4. [State Locking](#state-locking)
5. [State Operations](#state-operations)
6. [State Security](#state-security)
7. [State Migration](#state-migration)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)
10. [Advanced Patterns](#advanced-patterns)

## State Fundamentals

### What is Terraform State
```yaml
Terraform State:
  Purpose:
    - Track resource metadata
    - Map configuration to real resources
    - Cache resource attributes
    - Improve performance
    - Dependency tracking
  
  Contents:
    - Resource mappings
    - Metadata
    - Dependencies
    - Provider configurations
    - Outputs
```

### State File Structure
```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "serial": 1,
  "lineage": "12345678-1234-1234-1234-123456789012",
  "outputs": {
    "vpc_id": {
      "value": "vpc-12345678",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_vpc",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "id": "vpc-12345678",
            "cidr_block": "10.0.0.0/16",
            "enable_dns_hostnames": true
          },
          "dependencies": []
        }
      ]
    }
  ]
}
```

## Local vs Remote State

### Local State
```hcl
# Default local state (terraform.tfstate)
terraform {
  # No backend configuration = local state
}

# Advantages:
# - Simple setup
# - No additional infrastructure
# - Fast operations

# Disadvantages:
# - No collaboration
# - No locking
# - Risk of loss
# - No encryption
```

### Remote State Benefits
```yaml
Remote State Benefits:
  Collaboration:
    - Shared state access
    - Team coordination
    - Consistent view
  
  Security:
    - Encryption at rest
    - Encryption in transit
    - Access controls
    - Audit logging
  
  Reliability:
    - Backup and versioning
    - High availability
    - Disaster recovery
  
  Locking:
    - Prevent concurrent modifications
    - State consistency
    - Operation safety
```

## Remote State Backends

### S3 Backend Configuration
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    
    # Optional: Role assumption
    role_arn = "arn:aws:iam::123456789012:role/TerraformRole"
    
    # Optional: Server-side encryption
    kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

# S3 bucket setup for state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-${random_string.suffix.result}"
  
  tags = {
    Name        = "Terraform State"
    Environment = "shared"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "Terraform State Locks"
    Environment = "shared"
  }
}

# KMS key for encryption
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 7
  
  tags = {
    Name        = "Terraform State Key"
    Environment = "shared"
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}
```

### Terraform Cloud Backend
```hcl
# Terraform Cloud backend
terraform {
  cloud {
    organization = "my-organization"
    
    workspaces {
      name = "production-infrastructure"
    }
  }
}

# Or using tags for workspace selection
terraform {
  cloud {
    organization = "my-organization"
    
    workspaces {
      tags = ["production", "infrastructure"]
    }
  }
}
```

### Azure Backend
```hcl
# Azure Storage backend
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatestorage"
    container_name       = "tfstate"
    key                  = "infrastructure.terraform.tfstate"
    
    # Optional: Use service principal
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    subscription_id = var.subscription_id
  }
}
```

### Google Cloud Backend
```hcl
# Google Cloud Storage backend
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "infrastructure"
    
    # Optional: Encryption key
    encryption_key = var.encryption_key
    
    # Optional: Service account
    credentials = "path/to/service-account-key.json"
  }
}
```

## State Locking

### DynamoDB Locking (AWS)
```hcl
# DynamoDB table for locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  # Optional: Point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }
  
  tags = {
    Name        = "Terraform State Locks"
    Environment = "shared"
  }
}

# Backend configuration with locking
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Manual Lock Management
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID

# Check lock status
aws dynamodb scan \
  --table-name terraform-locks \
  --filter-expression "attribute_exists(LockID)"

# Manual lock cleanup (emergency)
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"terraform-state-bucket/infrastructure/terraform.tfstate-md5"}}'
```

## State Operations

### Basic State Commands
```bash
# View current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Pull remote state to local
terraform state pull

# Push local state to remote
terraform state push terraform.tfstate

# Refresh state from real infrastructure
terraform refresh
```

### State Manipulation
```bash
# Move resource in state
terraform state mv aws_instance.old_name aws_instance.new_name

# Move resource to different state file
terraform state mv -state-out=other.tfstate aws_instance.web aws_instance.web

# Remove resource from state (without destroying)
terraform state rm aws_instance.web

# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Replace resource (mark for recreation)
terraform apply -replace=aws_instance.web
```

### Advanced State Operations
```bash
# Backup state before operations
cp terraform.tfstate terraform.tfstate.backup

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# State file validation
terraform validate

# Format state file (rarely needed)
terraform fmt

# Show state file statistics
terraform show -json | jq '.values.root_module.resources | length'

# Extract outputs from state
terraform output
terraform output -json
terraform output vpc_id
```

## State Security

### Encryption Configuration
```hcl
# S3 backend with KMS encryption
terraform {
  backend "s3" {
    bucket     = "terraform-state-bucket"
    key        = "infrastructure/terraform.tfstate"
    region     = "us-west-2"
    encrypt    = true
    kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
    
    # Server-side encryption
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = aws_kms_key.terraform_state.arn
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }
}
```

### Access Control
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformStateAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:role/TerraformRole",
          "arn:aws:iam::123456789012:user/terraform-user"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::terraform-state-bucket/*"
    },
    {
      "Sid": "TerraformStateBucketAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:role/TerraformRole"
        ]
      },
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::terraform-state-bucket"
    },
    {
      "Sid": "TerraformLockAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:role/TerraformRole"
        ]
      },
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-west-2:123456789012:table/terraform-locks"
    }
  ]
}
```

### Sensitive Data Handling
```hcl
# Mark outputs as sensitive
output "database_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true
}

# Mark variables as sensitive
variable "api_key" {
  description = "API key for external service"
  type        = string
  sensitive   = true
}

# Use external data sources for secrets
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

## State Migration

### Backend Migration
```bash
# Step 1: Update backend configuration
# Change from local to S3 backend in backend.tf

# Step 2: Initialize with new backend
terraform init

# Step 3: Terraform will prompt to migrate state
# Answer 'yes' to copy existing state to new backend

# Step 4: Verify migration
terraform state list

# Step 5: Remove local state file (optional)
rm terraform.tfstate terraform.tfstate.backup
```

### Cross-Account Migration
```bash
# Step 1: Export state from source account
terraform state pull > exported-state.json

# Step 2: Switch to target account credentials
export AWS_PROFILE=target-account

# Step 3: Initialize new backend
terraform init

# Step 4: Import state
terraform state push exported-state.json

# Step 5: Verify resources
terraform plan
```

### State Splitting
```bash
# Split monolithic state into multiple states

# Step 1: Create new directory structure
mkdir -p environments/{dev,staging,prod}

# Step 2: Move resources to new state files
terraform state mv -state-out=environments/dev/terraform.tfstate \
  aws_instance.dev_web aws_instance.dev_web

terraform state mv -state-out=environments/prod/terraform.tfstate \
  aws_instance.prod_web aws_instance.prod_web

# Step 3: Update configurations for each environment
# Step 4: Initialize each environment separately
cd environments/dev && terraform init
cd ../prod && terraform init
```

## Troubleshooting

### Common State Issues
```bash
# Issue 1: State lock timeout
# Solution: Force unlock (use carefully)
terraform force-unlock LOCK_ID

# Issue 2: State drift
# Solution: Refresh and plan
terraform refresh
terraform plan

# Issue 3: Corrupted state
# Solution: Restore from backup
aws s3 cp s3://terraform-state-bucket/infrastructure/terraform.tfstate.backup \
  s3://terraform-state-bucket/infrastructure/terraform.tfstate

# Issue 4: Resource not in state
# Solution: Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Issue 5: Duplicate resources
# Solution: Remove from state and re-import
terraform state rm aws_instance.duplicate
terraform import aws_instance.web i-1234567890abcdef0
```

### State Recovery
```bash
# Recover from S3 versioning
aws s3api list-object-versions \
  --bucket terraform-state-bucket \
  --prefix infrastructure/terraform.tfstate

# Restore specific version
aws s3api get-object \
  --bucket terraform-state-bucket \
  --key infrastructure/terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate.recovered

# Validate recovered state
terraform state pull > current-state.json
terraform validate
```

### Debug State Operations
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run operation with logging
terraform plan

# Analyze logs
grep -i "state" terraform.log
grep -i "lock" terraform.log
```

## Best Practices

### State Organization
```yaml
State Organization Strategies:

1. Environment Separation:
   - Separate state per environment
   - environments/dev/terraform.tfstate
   - environments/prod/terraform.tfstate

2. Component Separation:
   - Separate state per component
   - networking/terraform.tfstate
   - compute/terraform.tfstate
   - database/terraform.tfstate

3. Team Separation:
   - Separate state per team
   - platform/terraform.tfstate
   - application/terraform.tfstate

4. Lifecycle Separation:
   - Separate state by lifecycle
   - foundation/terraform.tfstate
   - application/terraform.tfstate
```

### State Security Best Practices
```hcl
# 1. Always use remote state for teams
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# 2. Enable versioning and backup
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Use least privilege access
data "aws_iam_policy_document" "terraform_state_policy" {
  statement {
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    
    resources = [
      "${aws_s3_bucket.terraform_state.arn}/infrastructure/*"
    ]
    
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.terraform_role.arn]
    }
  }
}

# 4. Regular state backups
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "state_backup"
    status = "Enabled"
    
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
```

## Advanced Patterns

### State Data Sources
```hcl
# Reference remote state from another configuration
data "terraform_remote_state" "vpc" {
  backend = "s3"
  
  config = {
    bucket = "terraform-state-bucket"
    key    = "networking/terraform.tfstate"
    region = "us-west-2"
  }
}

# Use outputs from remote state
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnet_id
  
  tags = {
    Name = "web-server"
  }
}
```

### Workspace-based State Management
```bash
# Create workspaces for different environments
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch between workspaces
terraform workspace select prod

# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Use workspace in configuration
locals {
  environment = terraform.workspace
  
  config = {
    dev = {
      instance_type = "t3.micro"
      instance_count = 1
    }
    prod = {
      instance_type = "t3.large"
      instance_count = 3
    }
  }
}

resource "aws_instance" "web" {
  count         = local.config[local.environment].instance_count
  ami           = "ami-12345678"
  instance_type = local.config[local.environment].instance_type
  
  tags = {
    Name        = "web-${local.environment}-${count.index + 1}"
    Environment = local.environment
  }
}
```

This comprehensive state management guide provides the foundation for secure, reliable, and scalable Terraform state management across teams and environments.