# VPC Module

## Overview

The VPC (Virtual Private Cloud) module creates the foundational networking infrastructure for the Finishline infrastructure on AWS. It provisions a complete network environment including VPC, subnets, gateways, route tables, and network ACLs.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          VPC (10.0.0.0/16)                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Internet Gateway                       │   │
│  │                           (IGW)                           │   │
│  └─────────────────────────┬─────────────────────────────────┘   │
│                            │                                      │
│  ┌─────────────────────────┼─────────────────────────────────┐   │
│  │              Public Route Table                           │   │
│  │              0.0.0.0/0 → IGW                              │   │
│  │         ┌───────────────┴───────────────┐                 │   │
│  │         │                               │                 │   │
│  │    ┌────▼────┐                     ┌────▼────┐           │   │
│  │    │ Public  │                     │  NAT    │           │   │
│  │    │ Subnet  │                     │ Gateway │           │   │
│  │    │  10.0.1 │                     │ (EIP)   │           │   │
│  │    │  /24    │                     └────┬────┘           │   │
│  │    └─────────┘                          │                 │   │
│  │                                         │                 │   │
│  │  ┌──────────────────────────────────────▼──────────────┐ │   │
│  │  │              Private Route Table                    │ │   │
│  │  │              0.0.0.0/0 → NAT Gateway                │ │   │
│  │  │         ┌───────────────┴───────────────┐           │ │   │
│  │  │    ┌────▼────┐                     ┌────▼────┐      │ │   │
│  │  │    │ Private │                     │ Private │      │ │   │
│  │  │    │ Subnet  │                     │ Subnet  │      │ │   │
│  │  │    │ 10.0.10 │                     │ 10.0.11 │      │ │   │
│  │  │    │  /24    │                     │  /24    │      │ │   │
│  │  │    └─────────┘                     └─────────┘      │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource Type                 | Resource Name                    | Description                                         |
| ----------------------------- | -------------------------------- | --------------------------------------------------- |
| `aws_vpc`                     | `finishline_vpc`                 | Main VPC with configurable CIDR block               |
| `aws_internet_gateway`        | `finishline_igw`                 | Internet Gateway for public subnet access           |
| `aws_subnet`                  | `finishline_public_subnet`       | Public subnets (multiple AZs)                       |
| `aws_subnet`                  | `finishline_private_subnet`      | Private subnets (multiple AZs)                      |
| `aws_eip`                     | `finishline_nat_eip`             | Elastic IP for NAT Gateway                          |
| `aws_nat_gateway`             | `finishline_nat_gw`              | NAT Gateway for private subnet outbound access      |
| `aws_route_table`             | `finishline_public_route_table`  | Route table for public subnets                      |
| `aws_route_table`             | `finishline_private_route_table` | Route table for private subnets                     |
| `aws_route`                   | `finishline_public_route`        | Default route to IGW                                |
| `aws_route`                   | `finishline_private_route`       | Default route to NAT Gateway                        |
| `aws_route_table_association` | `finishline_public_subnet`       | Associates public subnets with public route table   |
| `aws_route_table_association` | `finishline_private_subnet`      | Associates private subnets with private route table |
| `aws_network_acl`             | `finishline_network_acl`         | Network ACL for public subnets (internet-facing)    |

### Nested Module

| Module     | Source        | Description                                  |
| ---------- | ------------- | -------------------------------------------- |
| `key_pair` | `../key_pair` | Creates SSH key pair for EC2 instance access |

## Inputs

### Project Configuration

| Name                | Type           | Description                                                       | Required |
| ------------------- | -------------- | ----------------------------------------------------------------- | -------- |
| `project_name`      | `string`       | Name of the project (4-24 chars, alphanumeric + hyphens)          | Yes      |
| `environment`       | `string`       | Environment name (e.g., `development`, `staging`, `prod`)         | Yes      |
| `managed_by`        | `bool`         | Whether managed by Terraform                                      | Yes      |
| `availability_zone` | `list(string)` | List of availability zones (e.g., `["us-east-1a", "us-east-1b"]`) | Yes      |

### VPC Configuration

| Name                   | Type           | Description                                  | Required |
| ---------------------- | -------------- | -------------------------------------------- | -------- |
| `vpc_cidr`             | `string`       | CIDR block for the VPC (e.g., `10.0.0.0/16`) | Yes      |
| `enable_dns_support`   | `bool`         | Enable DNS resolution in VPC                 | Yes      |
| `enable_dns_hostnames` | `bool`         | Enable DNS hostnames in VPC                  | Yes      |
| `public_subnet_cidr`   | `list(string)` | List of CIDR blocks for public subnets       | Yes      |
| `private_subnet_cidr`  | `list(string)` | List of CIDR blocks for private subnets      | Yes      |

### Key Pair Configuration

| Name                    | Type          | Description                                        | Required |
| ----------------------- | ------------- | -------------------------------------------------- | -------- |
| `key_name`              | `string`      | Name of the SSH key pair                           | Yes      |
| `key_algorithm`         | `string`      | Algorithm for key generation (e.g., `RSA`)         | Yes      |
| `rsa_bits`              | `number`      | Number of bits for RSA key (e.g., `4096`)          | Yes      |
| `file_permission`       | `string`      | File permissions for private key (default: `0600`) | No       |
| `private_key_filename`  | `string`      | Filename for the private key                       | Yes      |
| `private_key_directory` | `string`      | Directory to store the private key                 | Yes      |
| `computed_tags`         | `map(string)` | Computed tags for key pair                         | No       |

## Outputs

### VPC Outputs

| Name                            | Description                           |
| ------------------------------- | ------------------------------------- |
| `vpc_id`                        | The VPC ID                            |
| `vpc_cidr`                      | The VPC CIDR block                    |
| `vpc_default_security_group_id` | Default security group ID for the VPC |

### Subnet Outputs

| Name                 | Description                                    |
| -------------------- | ---------------------------------------------- |
| `public_subnet_ids`  | List of public subnet IDs                      |
| `private_subnet_ids` | List of private subnet IDs                     |
| `public_subnet_azs`  | List of availability zones for public subnets  |
| `private_subnet_azs` | List of availability zones for private subnets |

### Gateway Outputs

| Name                        | Description                       |
| --------------------------- | --------------------------------- |
| `internet_gateway_id`       | Internet Gateway ID               |
| `nat_gateway_id`            | NAT Gateway ID                    |
| `nat_gateway_allocation_id` | Allocation ID for NAT Gateway EIP |

### Route Table Outputs

| Name                     | Description            |
| ------------------------ | ---------------------- |
| `public_route_table_id`  | Public route table ID  |
| `private_route_table_id` | Private route table ID |

### Network ACL Outputs

| Name                    | Description                                    |
| ----------------------- | ---------------------------------------------- |
| `public_network_acl_id` | Public subnet network ACL ID (internet-facing) |

### Key Pair Outputs

| Name                | Description                         |
| ------------------- | ----------------------------------- |
| `key_pair_id`       | Key pair ID                         |
| `key_pair_key_name` | Key pair name                       |
| `private_key_path`  | Path where the private key is saved |

## Network ACL Rules

### Public Subnet NACL

This NACL is associated with the first public subnet to ensure proper multi-AZ support. AWS NACLs can only be associated with one subnet at a time.

| Rule # | Type    | Protocol | Port Range  | Source/Destination | Action |
| ------ | ------- | -------- | ----------- | ------------------ | ------ |
| 100    | Ingress | TCP      | 22 (SSH)    | 0.0.0.0/0          | Allow  |
| 110    | Ingress | TCP      | 443 (HTTPS) | 0.0.0.0/0          | Allow  |
| 120    | Ingress | TCP      | 80 (HTTP)   | 0.0.0.0/0          | Allow  |
| 130    | Ingress | TCP      | 1024-65535  | 0.0.0.0/0          | Allow  |
| 140    | Ingress | ICMP     | All         | 0.0.0.0/0          | Allow  |
| 200    | Egress  | All      | All         | VPC CIDR           | Allow  |

**Note:** The egress rule allows all traffic within the VPC CIDR for internal communication.

## Usage Example

```hcl
module "vpc" {
  source = "./modules/vpc"

  # Project Configuration
  project_name     = "finishline-infra"
  environment      = "development"
  managed_by       = true
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  public_subnet_cidr   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidr  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  # Key Pair Configuration
  key_name              = "finishline-key"
  key_algorithm         = "RSA"
  rsa_bits              = 4096
  private_key_directory = path.module
  private_key_filename  = "finishline-key.pem"
}
```

## Dependencies

- AWS Provider
- TLS Provider (for key pair generation via nested module)

## File Structure

```
vpc/
├── main.tf         # Resource definitions
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── locals.tf       # Local values and tags
├── data.tf         # Data sources
└── README.md       # This documentation
```

## Security Considerations

1. **Single NAT Gateway**: The module uses a single NAT Gateway in the first public subnet. For high availability across multiple AZs, consider deploying multiple NAT Gateways.

2. **NACL Configuration**: The implementation now uses only an internet-facing NACL associated with the first public subnet to ensure compatibility with multi-AZ deployments. This simplifies the architecture while maintaining security for internet-accessible services.

3. **Private Key Storage**: The private key is stored locally. Ensure proper file permissions (`0600`) and secure storage practices.

## Tags

All resources are tagged with:

- `project_name` - Project identifier
- `environment` - Environment name
- `managed_by` - Terraform management flag
- `module` - Module name (`vpc`)
- `Name` - Resource-specific name
