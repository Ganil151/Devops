# Security Group Module

## Overview
Manages security group rules for network traffic control, including ingress and egress rules for EKS cluster communication.

## Functions
- **Ingress Rules**: Controls inbound traffic (SSH, HTTP, HTTPS, EKS node communication)
- **Egress Rules**: Controls outbound traffic (default allow all)
- **Dynamic Rules**: Supports flexible rule configuration via variables
- **EKS Integration**: Includes hardcoded rules for EKS worker node communication (ports 1025-65535)

## Inputs
- `vpc_id`: VPC ID where security group is created
- `security_group_name`: Name of the security group
- `security_group_description`: Description of the security group
- `ingress_rules`: List of ingress rule objects
- `egress_rules`: List of egress rule objects
- `project_name`, `environment`, `managedBy`: Tagging variables

## Outputs
- `finishline_sg_id`: Security group ID

## Connections
- **Depends on**: VPC module (requires VPC ID)
- **Used by**: EKS module (requires security group ID)
- **Purpose**: Provides network access control for EKS cluster and applications
