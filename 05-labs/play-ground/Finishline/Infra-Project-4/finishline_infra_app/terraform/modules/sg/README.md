# Security Group (SG) Module

## Overview

The Security Group module creates and manages AWS security groups for the Finishline infrastructure. It provides flexible ingress and egress rule configuration with optional EKS-specific rules for Kubernetes cluster networking.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Group                            │
│                   finishline-sg                              │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                  Ingress Rules                        │   │
│  │  ┌─────────────────────────────────────────────────┐  │   │
│  │  │  • SSH (22)                                      │  │   │
│  │  │  • HTTP (80)                                     │  │   │
│  │  │  • HTTPS (443)                                   │  │   │
│  │  │  • Custom ports (configurable)                   │  │   │
│  │  │  • EKS rules (optional):                         │  │   │
│  │  │    - Kubernetes API (443)                        │  │   │
│  │  │    - Kubelet API (10250)                         │  │   │
│  │  │    - NodePort services (30000-32767)             │  │   │
│  │  └─────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                   Egress Rules                        │   │
│  │  ┌─────────────────────────────────────────────────┐  │   │
│  │  │  • All outbound traffic (default)                │  │   │
│  │  │  • Custom rules (configurable)                   │  │   │
│  │  └─────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  Associated VPC: var.vpc_id                                  │
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource Type        | Resource Name   | Description                                 |
| -------------------- | --------------- | ------------------------------------------- |
| `aws_security_group` | `finishline-sg` | Main security group with configurable rules |

## Inputs

### Project Configuration

| Name                | Type           | Description                                               | Required |
| ------------------- | -------------- | --------------------------------------------------------- | -------- |
| `project_name`      | `string`       | Name of the project (4-24 chars, alphanumeric + hyphens)  | Yes      |
| `environment`       | `string`       | Environment name (e.g., `development`, `staging`, `prod`) | Yes      |
| `manage_by`         | `bool`         | Whether managed by Terraform                              | Yes      |
| `availability_zone` | `list(string)` | List of availability zones                                | Yes      |

### VPC Configuration

| Name     | Type     | Description                                            | Required |
| -------- | -------- | ------------------------------------------------------ | -------- |
| `vpc_id` | `string` | ID of the VPC where the security group will be created | Yes      |

### Security Group Configuration

| Name                  | Type           | Description                                                        | Required |
| --------------------- | -------------- | ------------------------------------------------------------------ | -------- |
| `security_group_name` | `string`       | Name of the security group (default: `{project}-{environment}-sg`) | No       |
| `ingress_rules`       | `list(object)` | List of ingress rules (see below)                                  | Yes      |
| `egress_rules`        | `list(object)` | List of egress rules (see below)                                   | Yes      |

### Ingress/Egress Rule Object

```hcl
{
  description = string  # Description of the rule
  from_port   = number  # Starting port
  to_port     = number  # Ending port
  protocol    = string  # Protocol (tcp, udp, -1 for all)
  cidr_blocks = string  # Comma-separated CIDR blocks
}
```

### EKS Security Group Configuration

| Name                            | Type     | Description                              | Required |
| ------------------------------- | -------- | ---------------------------------------- | -------- |
| `enable_eks_rules`              | `bool`   | Enable EKS-specific security group rules | No       |
| `eks_cluster_security_group_id` | `string` | ID of the EKS cluster security group     | No       |

## Outputs

| Name                  | Description                |
| --------------------- | -------------------------- |
| `security_group_id`   | Security group ID          |
| `security_group_arn`  | Security group ARN         |
| `security_group_name` | Security group name        |
| `vpc_id`              | Associated VPC ID          |
| `description`         | Security group description |
| `ingress_rules`       | Configured ingress rules   |
| `egress_rules`        | Configured egress rules    |

## EKS-Specific Rules

When `enable_eks_rules = true`, the following rules are automatically added:

| Direction | Port Range  | Protocol | Source/Destination | Description                   |
| --------- | ----------- | -------- | ------------------ | ----------------------------- |
| Ingress   | 443         | TCP      | VPC CIDR           | EKS Kubernetes API            |
| Ingress   | 10250       | TCP      | VPC CIDR           | Kubelet API from worker nodes |
| Ingress   | 30000-32767 | TCP      | 0.0.0.0/0          | NodePort services             |

## Usage Example

### Basic Security Group

```hcl
module "security_group" {
  source = "./modules/sg"

  # Project Configuration
  project_name        = "finishline-infra"
  environment         = "development"
  manage_by           = true
  availability_zone   = ["us-east-1a", "us-east-1b"]
  vpc_id              = module.vpc.vpc_id

  # Security Group Name
  security_group_name = "finishline-main-sg"

  # Ingress Rules
  ingress_rules = [
    {
      description = "Allow SSH from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # Egress Rules
  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
```

### EKS-Enabled Security Group

```hcl
module "eks_security_group" {
  source = "./modules/sg"

  project_name      = "finishline-infra"
  environment       = "development"
  manage_by         = true
  availability_zone = ["us-east-1a", "us-east-1b"]
  vpc_id            = module.vpc.vpc_id

  # Enable EKS rules
  enable_eks_rules = true

  ingress_rules = [
    {
      description = "Allow HTTPS from VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  egress_rules = []  # Empty = allow all outbound
}
```

## Dependencies

- AWS Provider
- VPC (must exist before creating security group)

## File Structure

```
sg/
├── main.tf         # Security group resource definition
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── locals.tf       # Local values and rule transformations
├── data.tf         # Data sources (VPC lookup)
└── README.md       # This documentation
```

## Lifecycle Configuration

The security group has the following lifecycle rules:

```hcl
lifecycle {
  prevent_destroy = true
  ignore_changes  = [ingress, egress]
}
```

- **prevent_destroy**: Prevents accidental deletion of the security group
- **ignore_changes**: Ignores changes to ingress/egress rules made outside Terraform

## Dynamic Rule Processing

The module uses Terraform's `dynamic` blocks to process ingress and egress rules:

1. **ingress_rules_transformed**: Transforms input rules, splitting comma-separated CIDR blocks
2. **eks_ingress_rules**: Conditionally adds EKS-specific rules
3. **all_ingress_rules**: Combines standard and EKS rules
4. **egress_rules_transformed**: Transforms egress rules with default "allow all" if empty

## Security Considerations

1. **CIDR Block Validation**: Ensure CIDR blocks in rules are appropriate for your security requirements.

2. **EKS Rules**: When enabling EKS rules, the module uses `var.vpc_id` as a placeholder for CIDR blocks. This should be replaced with the actual VPC CIDR block for proper functionality.

3. **NodePort Access**: The default EKS configuration allows NodePort access from `0.0.0.0/0`. Consider restricting this to specific CIDR blocks in production environments.

4. **Prevent Destroy**: The `prevent_destroy = true` lifecycle rule protects against accidental deletion but may require manual intervention if the security group needs to be recreated.

## Tags

All resources are tagged with:

- `project_name` - Project identifier
- `environment` - Environment name
- `manage_by` - Terraform management flag
- `module` - Module name (`sg`)
