# Jumphost Module

This module creates a bastion host (jumphost) EC2 instance for accessing infrastructure resources.

## Overview

The jumphost module provides:

- **Bastion EC2 Instance** - Public-facing instance for SSH access
- **Security Groups** - Controlled access to the instance
- **User Data Script** - Automatic installation of common tools
- **CloudWatch Integration** - Logging and monitoring

## Resources Created

### EC2 Resources

- EC2 Instance (bastion host)
- IAM Instance Profile (optional)
- Elastic IP (optional)

### Security

- Security group for jumphost access

## Usage

```hcl
terraform {
  source = "../../modules/compute/jumphost"
}

include {
  path = find_in_parent_folders("root.hcl")
}

# Dependencies
dependency "vpc" {
  config_path = "../../networking/vpc"
}

dependency "sg" {
  config_path = "../../networking/sg"
}

dependency "key_pair" {
  config_path = "../../security/key_pair"
}

inputs = {
  project_name = "finishline-infra-app"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"

  instance_name = "jumphost"

  # Network
  subnet_id          = dependency.vpc.outputs.public_subnet_ids[0]
  security_group_ids = [dependency.sg.outputs.jumphost_security_group_id]
  key_pair_name      = dependency.key_pair.outputs.key_pair_name

  # Instance
  instance_type = "t3.micro"

  # Access
  associate_public_ip_address = true

  # Tools Installation
  use_install_tools_script      = true
  install_tools_script_path     = "../../../scripts/jumphost-install-tools.sh"
}
```

## Variables

### Instance Configuration

| Variable                    | Description                              | Type   | Default    |
| --------------------------- | ---------------------------------------- | ------ | ---------- |
| `instance_name`             | Name of the instance                     | string | required   |
| `is_jumphost_enabled`       | Enable instance creation                 | bool   | false      |
| `ami_id`                    | Custom AMI ID (empty for Amazon Linux 2) | string | ""         |
| `instance_type`             | EC2 instance type                        | string | "t3.micro" |
| `install_tools_script_path` | Path to the install-tools script         | string | ""         |

### Network Configuration

| Variable                      | Description            | Type         | Default  |
| ----------------------------- | ---------------------- | ------------ | -------- |
| `subnet_id`                   | Subnet ID for instance | string       | required |
| `security_group_ids`          | Security groups        | list(string) | []       |
| `associate_public_ip_address` | Assign public IP       | bool         | true     |
| `private_ip`                  | Private IP (optional)  | string       | ""       |

### Storage Configuration

| Variable                | Description           | Type   | Default |
| ----------------------- | --------------------- | ------ | ------- |
| `root_volume_type`      | Root volume type      | string | "gp3"   |
| `root_volume_size`      | Root volume size (GB) | number | 30      |
| `root_volume_encrypted` | Enable encryption     | bool   | true    |

### Monitoring

| Variable                        | Description               | Type   | Default |
| ------------------------------- | ------------------------- | ------ | ------- |
| `enable_cloudwatch_logs`        | Enable CloudWatch logging | bool   | false   |
| `cloudwatch_log_retention_days` | Log retention days        | number | 30      |

### User Data Configuration

| Variable                    | Description                                     | Type   | Default |
| --------------------------- | ----------------------------------------------- | ------ | ------- |
| `use_install_tools_script`  | Whether to use the default install-tools script | bool   | true    |
| `install_tools_script_path` | Path to the install-tools script                | string | ""      |
| `user_data`                 | Custom user data script                         | string | ""      |

## Outputs

| Output                | Description        |
| --------------------- | ------------------ |
| `instance_id`         | EC2 instance ID    |
| `instance_public_ip`  | Public IP address  |
| `instance_private_ip` | Private IP address |
| `security_group_id`   | Security group ID  |

## User Data Script

The jumphost includes a user data script that automatically installs:

- **AWS CLI v2** - Latest AWS command-line tools
- **kubectl** - Kubernetes CLI
- **helm** - Kubernetes package manager
- **terraform** - Infrastructure as Code tool
- **jq** - JSON processor
- **git** - Version control

### Script Path Configuration

When using Terragrunt with the `source` parameter, the install-tools script path must be provided explicitly:

```hcl
inputs = {
  use_install_tools_script      = true
  install_tools_script_path     = "../../../scripts/jumphost-install-tools.sh"
}
```

The path is relative to the Terragrunt configuration file location.

### Customizing the Script

To use a custom user data script:

```hcl
inputs = {
  use_install_tools_script = false
  user_data = <<-EOF
              #!/bin/bash
              # Your custom installation commands
              EOF
}
```

## Security Considerations

1. **SSH Access**: Use key pair authentication only
2. **Security Groups**: Restrict SSH access to known IP ranges
3. **IMDSv2**: Enable Instance Metadata Service v2
4. **Logging**: Enable CloudWatch Logs for audit
5. **EIP**: Consider using Elastic IP for persistent access

## Connecting to the Jumphost

```bash
# SSH to jumphost
ssh -i your-key.pem ec2-user@<jumphost-public-ip>

# SSH to private instances through jumphost
ssh -J ec2-user@<jumphost-ip> ec2-user@<private-instance-ip>
```

## Dependencies

- VPC with public subnet
- Security group with SSH rules
- Key pair for SSH access
- IAM instance profile (optional)
