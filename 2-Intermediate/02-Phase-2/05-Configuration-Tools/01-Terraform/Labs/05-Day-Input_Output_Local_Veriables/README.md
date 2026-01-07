# Day 5: Terraform Project Structure and Organization

## Overview
This lab demonstrates proper Terraform project organization using multiple files, variables, locals, and outputs. Learn how to structure a maintainable and scalable Terraform codebase following industry best practices.

## 📚 Related Fundamentals
Before diving into this lab, review these foundational concepts:
- [Terraform Core Concepts](../../01-Fundamentals/03-Core-Concepts/Terraform%20Core%20Concepts.md) - Understanding Terraform basics
- [Variables and Outputs](../../01-Fundamentals/08-Variables-and-Outputs/Variables%20and%20Outputs.md) - Input variables and output values
- [Providers](../../01-Fundamentals/06-Providers/Providers.md) - Provider configuration and management
- [Terraform Commands](../../01-Fundamentals/02-Commands/README.md) - CLI commands reference
- [Configuration Language (HCL)](../../01-Fundamentals/05-Configuration-Language/Configuration%20Language%20(HCL).md) - HCL syntax and structure

## File Structure Explanation

```
05-Day/
├── .terraform/                 # Terraform working directory (auto-generated)
│   ├── providers/              # Downloaded provider binaries
│   └── terraform.tfstate       # Local state file (if using local backend)
├── .terraform.lock.hcl         # Provider version lock file
├── backend.tf                  # Backend configuration
├── locals.tf                   # Local values and computed expressions
├── main.tf                     # Primary resource definitions
├── output.tf                   # Output value definitions
├── providers.tf                # Provider configurations
├── README.md                   # Project documentation
├── task.md                     # Learning tasks and exercises
├── tfplan                      # Terraform execution plan (generated)
└── variables.tf                # Input variable definitions
```
## File-by-File Breakdown

### 1. **providers.tf** - Provider Configuration
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```
**Purpose**: 
- Defines required providers and their versions
- Configures provider settings (region, credentials, etc.)
- Separates provider logic from resource definitions

**🔗 Learn More**: [Providers Deep Dive](../../01-Fundamentals/06-Providers/Providers.md)
### 2. **backend.tf** - State Management
```hcl
terraform {
  backend "s3" {
    bucket         = "gsmash-demo-bucket-name-123456"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "gsmash-demo-lock-table"
  }
}
```
**Purpose**:
- Configures remote state storage in S3
- Enables state locking with DynamoDB
- Isolates backend configuration for easy environment switching
### 3. **variables.tf** - Input Variables
```hcl
variable "environment" {
  description = "The name of the environment this infra resource belongs to."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the channel."
  type        = string
  default     = "demo_bucket"
}
```
**Purpose**:
- Defines configurable input parameters
- Provides descriptions and type constraints
- Sets default values for common scenarios
- Enables reusability across environments

**🔗 Learn More**: [Variables and Outputs Guide](../../01-Fundamentals/08-Variables-and-Outputs/Variables%20and%20Outputs.md)

### 4. **locals.tf** - Local Values
```hcl
locals {
  common_tags = {
    Project     = "Terraform-Gsmash-Demo"
    Environment = var.environment
    Owner       = "Gsmash"
  }

  full_bucket_name = "${var.bucket_name}-${var.environment}-${random_string.suffix.result}"
}
```
**Purpose**:
- Defines computed values and expressions
- Creates reusable tag sets
- Combines variables into complex expressions
- Reduces code duplication

### 5. **main.tf** - Resource Definitions
```hcl
resource "aws_s3_bucket" "demo_bucket" {
  bucket = local.full_bucket_name
  
  tags = merge(local.common_tags, {
    Name = "Demo Bucket"
  })
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
```
**Purpose**:
- Contains primary infrastructure resources
- Uses variables and locals for configuration
- Implements consistent tagging strategy

### 6. **output.tf** - Output Values
```hcl
output "bucket_name" {
  description = "Name of the S3 Bucket"
  value       = aws_s3_bucket.demo_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.arn
}

output "environment" {
  description = "Environment from input variable"
  value       = var.environment
}

output "tags" {
  description = "Tags from local variable"
  value       = local.common_tags
}
```
**Purpose**:
- Exposes important resource attributes
- Provides values for other Terraform configurations
- Enables integration with external systems
- Documents key infrastructure outputs

## Auto-Generated Files

### **.terraform/** Directory
- **Purpose**: Terraform's working directory
- **Contents**: Downloaded providers, modules, cached data
- **Management**: Auto-generated, should be in `.gitignore`

### **.terraform.lock.hcl**
- **Purpose**: Locks provider versions for consistency
- **Contents**: Exact provider versions and checksums
- **Management**: Should be committed to version control

### **tfplan** File
- **Purpose**: Stores execution plan from `terraform plan`
- **Contents**: Planned changes in binary format
- **Management**: Temporary file, can be deleted after apply

## Benefits of This Structure

### 1. **Separation of Concerns**
- Each file has a specific purpose
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

### 4. **Collaboration**
- Team members can work on different files simultaneously
- Clear file purposes reduce confusion
- Standardized structure improves onboarding

## Best Practices Demonstrated

### Variable Management
- Descriptive variable names and descriptions
- Appropriate default values
- Type constraints for validation

### Tagging Strategy
- Consistent tagging using locals
- Environment-aware tag values
- Merge function for combining tag sets

### Resource Naming
- Dynamic naming using variables and locals
- Environment-specific resource names
- Unique identifiers to prevent conflicts

### State Management
- Remote state storage for team collaboration
- State locking to prevent conflicts
- Environment-specific state file paths

## Common Patterns

### 1. **Environment Parameterization**
```hcl
# Use variables for environment-specific values
bucket = "${var.project}-${var.environment}-bucket"
```

### 2. **Tag Standardization**
```hcl
# Apply consistent tags across all resources
tags = local.common_tags
```

### 3. **Resource Dependencies**
```hcl
# Reference other resources using interpolation
bucket = aws_s3_bucket.demo_bucket.bucket
```

## Workflow Commands

1. **Initialize Project**:
   ```bash
   terraform init
   ```
   **🔗 Reference**: [Init Command Guide](../../01-Fundamentals/02-Commands/01-Init.md)

2. **Validate Configuration**:
   ```bash
   terraform validate
   ```
   **🔗 Reference**: [Validate Command Guide](../../01-Fundamentals/02-Commands/02-Validate.md)

3. **Plan Changes**:
   ```bash
   terraform plan -out=tfplan
   ```
   **🔗 Reference**: [Plan Command Guide](../../01-Fundamentals/02-Commands/03-Plan.md)

4. **Apply Changes**:
   ```bash
   terraform apply tfplan
   ```
   **🔗 Reference**: [Apply Command Guide](../../01-Fundamentals/02-Commands/04-Apply.md)

5. **View Outputs**:
   ```bash
   terraform output
   ```
   **🔗 Reference**: [Output Command Guide](../../01-Fundamentals/02-Commands/11-Output.md)

## Key Learning Objectives

1. **File Organization**: Understand the purpose of each Terraform file type
2. **Variable Usage**: Learn to parameterize configurations effectively
3. **Local Values**: Use locals for computed expressions and reusability
4. **Output Management**: Expose important values for external consumption
5. **Best Practices**: Apply industry-standard project structure patterns

## Next Steps

After mastering this structure:
- Learn about Terraform modules for further organization
- Explore workspace management for multiple environments ([Workspace Commands](../../01-Fundamentals/02-Commands/12-Workspace.md))
- Implement automated testing and validation
- Study advanced state management techniques ([State Commands](../../01-Fundamentals/02-Commands/06-State.md))

## 🔗 Additional Resources

### Fundamentals Review
- [Terraform Workflow](../../01-Fundamentals/10-Terraform-Workflow/Terraform%20Workflow.md) - Complete development workflow
- [Basic Examples](../../01-Fundamentals/11-Basic-Examples/Basic%20Examples.md) - Simple configuration examples
- [Data Sources](../../01-Fundamentals/09-Data-Sources/Data%20Sources.md) - Using external data
- [Resources](../../01-Fundamentals/07-Resources/Resources.md) - Resource management

### Command References
- [Commands Quick Reference](../../01-Fundamentals/02-Commands/21-Quick-Reference.md) - Cheat sheet
- [Format Command](../../01-Fundamentals/02-Commands/09-Fmt.md) - Code formatting
- [Show Command](../../01-Fundamentals/02-Commands/10-Show.md) - Inspecting state and plans

### Previous Labs
- [Day 4: Remote State Management](../04-Day/README.md) - S3 backend configuration
- [Day 3: Variables and Locals](../03-Day/README.md) - Variable usage patterns