# Jumphost Module

## Overview

The Jumphost module creates and manages a bastion host (jump server) for secure access to private resources in the Finishline infrastructure. It provisions an EC2 instance running Amazon Linux 2023 with SSH access, security group, and IAM role for AWS service integration.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Jumphost Module                           │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    EC2 Instance                            │  │
│  │  aws_instance.jumphost                                     │  │
│  │                                                            │  │
│  │  • AMI: Amazon Linux 2023 (AL2023)                         │  │
│  │  • Instance Type: Configurable (e.g., t3.micro)            │  │
│  │  • Subnet: Public subnet for SSH access                    │  │
│  │  • Key Pair: SSH authentication                            │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                   │
│              ┌───────────────┼───────────────┐                   │
│              │               │               │                   │
│              ▼               ▼               ▼                   │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐    │
│  │ Security Group  │ │   IAM Role      │ │   Key Pair      │    │
│  │ jumphost-sg     │ │ jumphost_role   │ │ (existing)      │    │
│  │                 │ │                 │ │                 │    │
│  │ Ingress:        │ │ Trust Policy:   │ │ • SSH access    │    │
│  │ • SSH (22)      │ │ • EC2 service   │ │ • RSA 4096-bit  │    │
│  │ Egress:         │ │                 │ │                 │    │
│  │ • All outbound  │ │ Attached:       │ │                 │    │
│  │                 │ │ • None (basic)  │ │                 │    │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘    │
│                                                                  │
│  Associated VPC: var.vpc_id                                      │
│  Target Subnet: var.jumphost_subnet_id (public)                  │
└─────────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource Type              | Resource Name      | Description                                    |
| -------------------------- | ------------------ | ---------------------------------------------- |
| `aws_security_group`       | `jumphost-sg`      | Security group with SSH ingress and all egress |
| `aws_iam_role`             | `jumphost_role`    | IAM role for EC2 instance                      |
| `aws_iam_instance_profile` | `jumphost_profile` | Instance profile to attach IAM role to EC2     |
| `aws_instance`             | `jumphost`         | EC2 instance running Amazon Linux 2023         |

### Data Sources

| Name             | Description                                             |
| ---------------- | ------------------------------------------------------- |
| `aws_ami.al2023` | Fetches latest Amazon Linux 2023 AMI (x86_64, HVM, EBS) |

## Inputs

### Project Configuration

| Name                | Type           | Description                                               | Required |
| ------------------- | -------------- | --------------------------------------------------------- | -------- |
| `project_name`      | `string`       | Name of the project (4-24 chars, alphanumeric + hyphens)  | Yes      |
| `environment`       | `string`       | Environment name (e.g., `development`, `staging`, `prod`) | Yes      |
| `manage_by`         | `bool`         | Whether managed by Terraform                              | Yes      |
| `availability_zone` | `list(string)` | List of availability zones                                | Yes      |

### VPC Configuration

| Name     | Type     | Description                                      | Required |
| -------- | -------- | ------------------------------------------------ | -------- |
| `vpc_id` | `string` | ID of the VPC where the jumphost will be created | Yes      |

### Jumphost Configuration

| Name                           | Type     | Description                              | Required | Default               |
| ------------------------------ | -------- | ---------------------------------------- | -------- | --------------------- |
| `jumphost_security_group_name` | `string` | Name of the security group               | No       | `""` (auto-generated) |
| `jumphost_instance_type`       | `string` | EC2 instance type (e.g., `t3.micro`)     | Yes      | -                     |
| `jumphost_subnet_id`           | `string` | ID of the public subnet for the jumphost | Yes      | -                     |
| `key_pair_name`                | `string` | Name of the SSH key pair for access      | Yes      | -                     |

## Outputs

### Instance Information

| Name                  | Description                        |
| --------------------- | ---------------------------------- |
| `jumphost_id`         | EC2 instance ID                    |
| `jumphost_public_ip`  | Public IP address (for SSH access) |
| `jumphost_private_ip` | Private IP address                 |

### Security Group

| Name                                  | Description                |
| ------------------------------------- | -------------------------- |
| `jumphost_security_group_id`          | Security group ID          |
| `jumphost_security_group_name`        | Security group name        |
| `jumphost_security_group_description` | Security group description |

### IAM Role

| Name                 | Description   |
| -------------------- | ------------- |
| `jumphost_role_name` | IAM role name |
| `jumphost_role_arn`  | IAM role ARN  |

### Connection Info

| Name                       | Description                                                     | Sensitive |
| -------------------------- | --------------------------------------------------------------- | --------- |
| `jumphost_connection_info` | Connection details (host, username, key_file, IPs, instance_id) | **Yes**   |

## Security Group Rules

### Ingress Rules

| Description      | Port | Protocol | CIDR Block  |
| ---------------- | ---- | -------- | ----------- |
| Allow SSH access | 22   | TCP      | `0.0.0.0/0` |

### Egress Rules

| Description                | Port | Protocol | CIDR Block  |
| -------------------------- | ---- | -------- | ----------- |
| Allow all outbound traffic | All  | All      | `0.0.0.0/0` |

## Usage Example

### Basic Jumphost

```hcl
module "jumphost" {
  source = "./modules/jumphost"

  # Project Configuration
  project_name        = "finishline-infra"
  environment         = "development"
  manage_by           = true
  availability_zone   = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # VPC Configuration
  vpc_id              = module.vpc.vpc_id

  # Jumphost Configuration
  jumphost_instance_type = "t3.micro"
  jumphost_subnet_id     = module.vpc.public_subnet_ids[0]
  key_pair_name          = module.vpc.key_pair_key_name
}
```

### Accessing the Jumphost

```bash
# Get the public IP from Terraform outputs
JUMPHOST_IP=$(terraform output -raw jumphost_public_ip)

# SSH into the jumphost
ssh -i /path/to/private-key.pem ec2-user@$JUMPHOST_IP

# From jumphost, access private resources
ssh -i /path/to/private-key.pem ec2-user@<private-instance-ip>
```

### Using Jumphost for Private Cluster Access

```hcl
# Output connection info
output "jumphost_ssh" {
  value       = module.jumphost.jumphost_connection_info
  sensitive   = true
}

# SSH proxy command for accessing private resources
# Add to ~/.ssh/config:
# Host jumphost
#   HostName ${module.jumphost.jumphost_public_ip}
#   User ec2-user
#   IdentityFile /path/to/key.pem
#
# Host private-*.internal
#   ProxyJump jumphost
#   User ec2-user
#   IdentityFile /path/to/key.pem
```

## Dependencies

- **VPC Module**: Requires VPC ID and public subnet ID
- **Key Pair Module**: Requires existing SSH key pair name
- **AWS Provider**: For EC2, IAM, and security group resources

## File Structure

```
jumphost/
├── main.tf         # EC2 instance, security group, IAM resources
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── locals.tf       # Local values (security group name, rules, tags)
├── data.tf         # AMI lookup for Amazon Linux 2023
└── README.md       # This documentation
```

## AMI Selection

The module uses the latest Amazon Linux 2023 AMI:

```hcl
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
```

This ensures the jumphost always uses the most recent AL2023 image with security patches.

## IAM Configuration

### Trust Policy

The jumphost IAM role uses a standard EC2 trust policy:

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
```

### Attached Policies

By default, no additional policies are attached. Add policies as needed for specific use cases:

- S3 access for artifact storage
- CloudWatch Logs for centralized logging
- Systems Manager for session management

## Security Considerations

### SSH Access

**Current Configuration**: SSH is open to `0.0.0.0/0` for development convenience.

**Production Recommendation**: Restrict SSH access to specific CIDR blocks:

```hcl
# In local.tf, modify ingress_rules:
ingress_rules = [
  {
    description = "Allow SSH from office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<your-office-ip>/32"]
  }
]
```

### Alternative Access Methods

For production environments, consider:

1. **AWS Systems Manager Session Manager** - No SSH required
2. **Site-to-Site VPN** - Connect corporate network to VPC
3. **AWS Client VPN** - Managed OpenVPN-based access
4. **VPC Peering** - Access from trusted VPCs

### Instance Hardening

Recommended security measures:

1. Enable automatic security updates (AL2023 default)
2. Configure CloudWatch Logs for audit trails
3. Use AWS Systems Manager Patch Manager
4. Implement least-privilege IAM policies
5. Enable EC2 instance metadata v2 (IMDSv2)

### Key Management

1. Store private key securely (chmod 600)
2. Consider AWS Secrets Manager or Parameter Store
3. Rotate keys periodically
4. Never commit keys to version control

## Tags

All resources are tagged with:

- `project_name` - Project identifier
- `environment` - Environment name
- `manage_by` - Terraform management flag
- `module` - Module name (`jumphost-sg`)
- `Name` - Resource-specific name

## Troubleshooting

### Cannot Connect via SSH

1. **Check Security Group**: Ensure port 22 is open to your IP
2. **Verify Key Pair**: Confirm key pair name matches AWS
3. **Check Subnet Route**: Public subnet must route to Internet Gateway
4. **Verify NACL**: Network ACL must allow SSH traffic

### Jumphost Cannot Access Private Resources

1. **Check Route Table**: Private subnets must route through NAT Gateway
2. **Verify Security Groups**: Private instances must allow traffic from jumphost SG
3. **Check NACL**: Ensure bidirectional traffic is allowed

### Instance Launch Fails

1. **Check AMI**: Verify AL2023 AMI is available in region
2. **Check Quotas**: Ensure EC2 instance quota is sufficient
3. **Verify Subnet**: Confirm subnet has available IP addresses

## Cost Considerations

| Component             | Estimated Monthly Cost (us-east-1) |
| --------------------- | ---------------------------------- |
| t3.micro (on-demand)  | ~$7.50                             |
| t3.small (on-demand)  | ~$15.00                            |
| EBS GP3 (8 GB)        | ~$0.80                             |
| NAT Gateway (if used) | ~$32.40 + data processing          |

**Cost Optimization**:

- Use Spot instances for non-critical jumphosts
- Stop instance when not in use (manual or automated)
- Use smaller instance types for occasional access
