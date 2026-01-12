# Day 6: Terraform Project Structure and Organization

## Overview
This lab demonstrates proper Terraform project organization using multiple files, variables, locals, and outputs. Learn how to structure a maintainable and scalable Terraform codebase following industry best practices with VPC, subnets, and S3 bucket resources.

## 📚 Related Fundamentals
Before diving into this lab, review these foundational concepts:
- [Terraform Core Concepts](../../../01-Fundamentals/03-Core-Concepts/README.md) - Understanding Terraform basics
- [Variables and Outputs](../../../01-Fundamentals/08-Variables-and-Outputs/README.md) - Input variables and output values
- [Providers](../../../01-Fundamentals/06-Providers/README.md) - Provider configuration and management
- [Terraform Commands](../../../01-Fundamentals/02-Commands/README.md) - CLI commands reference
- [Configuration Language (HCL)](../../../01-Fundamentals/05-Configuration-Language/README.md) - HCL syntax and structure

## File Structure Explanation

```
06-Day-Project_Structure/
├── .terraform/                 # Terraform working directory (auto-generated)
│   ├── providers/              # Downloaded provider binaries
│   └── terraform.tfstate       # Local state file (if using local backend)
├── .terraform.lock.hcl         # Provider version lock file
├── backend.tf                  # Backend and provider requirements
├── challenges.md               # Lab challenges and exercises
├── locals.tf                   # Local values and computed expressions
├── main.tf                     # Main configuration file
├── output.tf                   # Output value definitions
├── providers.tf                # Provider configurations
├── README.md                   # Project documentation
├── storage.tf                  # S3 bucket resources
├── terraform.tfvars            # Variable values
├── tfplan                      # Terraform execution plan (generated)
├── variables.tf                # Input variable definitions
└── vpc.tf                      # VPC and networking resources
```

## File-by-File Breakdown

### 1. **backend.tf** - Backend Configuration & Requirements
```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket       = "gsmash-demo-bucket-name-123456"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```
**Purpose**: 
- Defines Terraform and provider version requirements
- Configures remote state storage in S3
- Enables state locking for team collaboration

### 2. **providers.tf** - Provider Configuration
```hcl
provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}
```
**Purpose**:
- Configures AWS provider with dynamic region
- Applies default tags to all resources automatically
- Separates provider logic from resource definitions

### 3. **variables.tf** - Input Variables
```hcl
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "staging"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}
```
**Purpose**:
- Defines configurable input parameters with validation
- Provides descriptions and type constraints
- Sets default values for common scenarios
- Enables reusability across environments

### 4. **locals.tf** - Local Values
```hcl
locals {
  # Common tags to be applied to all resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })

  # Naming convention for resources
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Storage configuration
  bucket_name = "${local.name_prefix}-${random_id.bucket_suffix.hex}"
}

# Random suffix for globally unique resource names
resource "random_id" "bucket_suffix" {
  byte_length = 4

  keepers = {
    project = var.project_name
    environment = var.environment
  }
}
```
**Purpose**:
- Defines computed values and expressions
- Creates reusable tag sets with dynamic values
- Implements consistent naming conventions
- Reduces code duplication across resources

### 5. **vpc.tf** - VPC and Networking Resources
```hcl
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = local.vpc_name
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Type = "Public"
  })
}
```
**Purpose**:
- Creates VPC with DNS support enabled
- Provisions public subnets across multiple AZs
- Uses dynamic CIDR calculation with cidrsubnet()
- Implements consistent tagging strategy

### 6. **storage.tf** - S3 Bucket Resources
```hcl
# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, {
    Name = local.bucket_name
    Purpose = "General storage"
    Environment = var.environment
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id  

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}
```
**Purpose**:
- Creates S3 bucket with security best practices
- Enables versioning for data protection
- Configures server-side encryption
- Blocks public access for security

### 7. **output.tf** - Output Values
```hcl
# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket
}
```
**Purpose**:
- Exposes important resource attributes
- Provides values for other Terraform configurations
- Enables integration with external systems
- Documents key infrastructure outputs

### 8. **terraform.tfvars** - Variable Values
```hcl
# Project Configuration
project_name = "aws-terraform-course"
environment  = "dev"
region       = "us-east-1"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Tags
tags = {
  Owner      = "Gsmash"
  Department = "Engineering"
  CostCenter = "Engineering-001"
  Project    = "TerraformLearning"
}
```
**Purpose**:
- Provides actual values for variables
- Environment-specific configuration
- Separates values from variable definitions
- Enables easy environment switching

## Benefits of This Structure

### 1. **Separation of Concerns**
- Each file has a specific purpose (networking, storage, variables)
- Easy to locate and modify specific configurations
- Reduces merge conflicts in team environments

### 2. **Maintainability**
- Clear organization makes code easier to understand
- Consistent structure across projects
- Simplified debugging and troubleshooting

### 3. **Reusability**
- Variables enable environment-specific deployments
- Locals reduce code duplication
- Modular structure supports code reuse

### 4. **Security & Best Practices**
- Default tags applied automatically via provider
- Input validation for critical variables
- Secure S3 configuration with encryption

## Key Features Demonstrated

### Advanced Variable Management
- Input validation with custom conditions
- Type constraints and descriptions
- Environment-aware default values

### Dynamic Resource Creation
- Count-based subnet creation across AZs
- Dynamic CIDR block calculation
- Random resource naming for uniqueness

### Comprehensive Tagging Strategy
- Provider-level default tags
- Resource-specific tag merging
- Timestamp and computed tag values

### Security Best Practices
- S3 bucket encryption and versioning
- Public access blocking
- State file encryption in backend

## Workflow Commands

1. **Initialize Project**:
   ```bash
   terraform init
   ```

2. **Validate Configuration**:
   ```bash
   terraform validate
   ```

3. **Plan Changes**:
   ```bash
   terraform plan -out=tfplan
   ```

4. **Apply Changes**:
   ```bash
   terraform apply tfplan
   ```

5. **View Outputs**:
   ```bash
   terraform output
   ```

6. **Destroy Resources**:
   ```bash
   terraform destroy
   ```

## Key Learning Objectives

1. **File Organization**: Understand the purpose of each Terraform file type
2. **Variable Management**: Learn advanced variable usage with validation
3. **Local Values**: Use locals for computed expressions and naming conventions
4. **Resource Dependencies**: Understand implicit and explicit dependencies
5. **Security Practices**: Implement encryption, tagging, and access controls
6. **Dynamic Configuration**: Use count, for_each, and functions effectively

## Common Patterns Demonstrated

### 1. **Environment Parameterization**
```hcl
name_prefix = "${var.project_name}-${var.environment}"
```

### 2. **Dynamic Resource Naming**
```hcl
bucket_name = "${local.name_prefix}-${random_id.bucket_suffix.hex}"
```

### 3. **Consistent Tagging**
```hcl
tags = merge(local.common_tags, {
  Name = "specific-resource-name"
})
```

### 4. **CIDR Calculation**
```hcl
cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
```

## Next Steps

After mastering this structure:
- Learn about Terraform modules for further organization
- Explore workspace management for multiple environments
- Implement automated testing and validation
- Study advanced state management techniques
- Practice with more complex multi-tier architectures

## Troubleshooting Tips

1. **Provider Inconsistent Plan Errors**: Ensure consistent tagging between provider default_tags and resource tags
2. **Undeclared Resource Errors**: Verify all referenced resources exist in the configuration
3. **CIDR Conflicts**: Use terraform console to test cidrsubnet() calculations
4. **State Lock Issues**: Check S3 bucket and ensure proper permissions

This project structure provides a solid foundation for scalable, maintainable Terraform configurations while demonstrating industry best practices for infrastructure as code.