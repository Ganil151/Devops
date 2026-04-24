# Bootstrap Module

## Overview
Deploys a jumphost EC2 instance for administrative access to the infrastructure, using Amazon Linux 2023 AMI.

## Functions
- **Jumphost Instance**: Creates EC2 instance for SSH access to infrastructure
- **AMI Selection**: Automatically selects latest Amazon Linux 2023 AMI
- **Security**: Encrypts root volume and enables monitoring
- **Networking**: Deploys in public subnet with security group access

## Inputs
- `jumphost_name`: Name of the jumphost instance
- `jumphost_instance_type`: EC2 instance type (e.g., t3.micro)
- `key_name`: SSH key pair name for instance access
- `subnet_ids`: List of subnet IDs (uses first public subnet)
- `security_group_ids`: Security group IDs for network access
- `iam_instance_profile_name`: IAM instance profile name
- `project_name`, `environment`, `managedBy`: Tagging variables

## Outputs
- `jumphost_id`: Instance ID
- `jumphost_public_ip`: Public IP address
- `jumphost_private_ip`: Private IP address
- `jumphost_arn`: Instance ARN

## Connections
- **Depends on**: VPC module (requires subnet IDs), Security Group module (requires SG IDs), Key Pair module (requires key name)
- **Used by**: Infrastructure administrators for SSH access
- **Purpose**: Provides secure administrative access point to infrastructure
