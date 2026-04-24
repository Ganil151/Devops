# Security Group Module

## Overview

This Terraform module creates and manages an AWS Security Group for the **Finishline Infrastructure project**. The Security Group module provides network traffic filtering at the instance level, controlling both inbound and outbound traffic to AWS resources deployed within the project's VPC.

## Function in the Project

The Security Group module is a **critical network security component** within the Finishline Infrastructure project. It serves as the primary mechanism for controlling network access to and from cloud resources deployed across different environments (dev, staging, prod).

### Role in the Infrastructure Architecture

The security group module integrates with other Finishline infrastructure components as follows:

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    Finishline Infrastructure Project                     │
│                                                                          │
│  ┌──────────────┐      ┌──────────────────┐      ┌──────────────────┐   │
│  │     VPC      │──────│  Security Group  │──────│       EKS        │   │
│  │   Module     │      │     Module       │      │     Cluster      │   │
│  └──────────────┘      └──────────────────┘      └──────────────────┘   │
│         │                     │                          │               │
│         │              ┌──────┴──────┐                   │               │
│         │              │             │                   │               │
│         │        ┌─────▼─────┐ ┌─────▼─────┐       ┌──────▼──────┐       │
│         │        │    ALB    │ │   RDS/    │       │  Worker     │       │
│         │        │           │ │  Database │       │   Nodes     │       │
│         │        └───────────┘ └───────────┘       └─────────────┘       │
│         │                                                        │        │
│         └────────────────────────────────────────────────────────┘        │
│                              AWS Cloud                                    │
└──────────────────────────────────────────────────────────────────────────┘
```

### Key Functions

1. **VPC-Level Network Security**: Associates with resources within the VPC created by the [`terraform/modules/vpc`](terraform/modules/vpc) module, providing network isolation and security boundaries

2. **Application Protection**: Secures access to:
   - **EKS Clusters**: Controls traffic to Kubernetes worker nodes and cluster API
   - **Application Load Balancers (ALB)**: Manages ingress traffic to application endpoints
   - **Databases**: Controls access to RDS instances and other data stores
   - **EC2 Instances**: Provides instance-level firewall rules

3. **Environment-Based Segmentation**: Creates environment-specific security groups (dev, staging, prod) to maintain proper network isolation between development and production workloads

4. **Ingress Traffic Control**: Defines which external traffic sources can reach protected resources based on:
   - Protocol (TCP, UDP, ICMP)
   - Port ranges (e.g., 443 for HTTPS, 22 for SSH)
   - Source CIDR blocks (IP ranges)

5. **Egress Control**: By default, allows all outbound traffic to enable application functionality while maintaining controlled inbound access

## Architecture

The module creates a security group with configurable ingress rules:

```
┌─────────────────────────────────────────────────────────────┐
│                     AWS Security Group                       │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                  Ingress Rules                           ││
│  │  • Custom TCP/UDP rules based on var.ingress_rules       ││
│  │  • Configurable CIDR blocks for each rule                ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │                  Egress Rules                            ││
│  │  • Allow all outbound traffic (0.0.0.0/0)               ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    Tags                                 ││
│  │  • Name: {project}-{environment}-sg                     ││
│  │  • Environment: {environment}                            ││
│  │  • Project: {project_name}                               ││
│  │  • ManageBy: {manage_by}                                ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource             | Description                                                        |
| -------------------- | ------------------------------------------------------------------ |
| `aws_security_group` | The main security group with configurable ingress and egress rules |

## Inputs

| Variable        | Type              | Description                                                 | Required |
| --------------- | ----------------- | ----------------------------------------------------------- | -------- |
| `project_name`  | string            | The name of the project                                     | Yes      |
| `aws_region`    | string            | The AWS region for the VPC                                  | Yes      |
| `environment`   | string            | The environment for the security group (dev, staging, prod) | Yes      |
| `manage_by`     | string            | The entity responsible for managing the security group      | Yes      |
| `vpc_id`        | string            | The ID of the VPC where the security group is created       | Yes      |
| `vpc_cidr`      | string            | The CIDR block for the VPC (not currently used)             | No       |
| `ingress_rules` | list(map(string)) | The ingress rules for the security group                    | Yes      |

### ingress_rules Structure

Each ingress rule should be a map with the following keys:

```hcl
ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
]
```

| Key           | Type         | Description                                  |
| ------------- | ------------ | -------------------------------------------- |
| `from_port`   | number       | The start of the port range for the rule     |
| `to_port`     | number       | The end of the port range for the rule       |
| `protocol`    | string       | The protocol (tcp, udp, icmp, or -1 for all) |
| `cidr_blocks` | list(string) | The CIDR blocks to allow traffic from        |

## Outputs

| Output                       | Description                                    |
| ---------------------------- | ---------------------------------------------- |
| `security_group_id`          | The ID of the security group                   |
| `security_group_name`        | The name of the security group                 |
| `security_group_vpc_id`      | The VPC ID where the security group is created |
| `security_group_arn`         | The ARN of the security group                  |
| `security_group_description` | The description of the security group          |
| `security_group_owner_id`    | The owner ID of the security group             |
| `security_group_tags`        | The tags applied to the security group         |

## Usage Example

```hcl
module "security_group" {
  source = "./modules/security_group"

  project_name = "finishline"
  aws_region   = "us-east-1"
  environment  = "dev"
  manage_by    = "terraform"
  vpc_id       = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

## Security Considerations

1. **Least Privilege**: Always grant the minimum required permissions by restricting CIDR blocks
2. **Stateful Nature**: Security groups are stateful, so return traffic is automatically allowed
3. **Lifecycle Management**: The security group has `prevent_destroy` enabled to prevent accidental deletion
4. **Ingress Rules**: Changes to ingress rules are ignored in the lifecycle to prevent accidental lockout

## IAM Integration

The Security Group module works alongside the IAM module ([`terraform/modules/secret/iam`](terraform/modules/secret/iam)) to provide comprehensive security for the Finishline infrastructure:

| Component           | Purpose                                          | Security Layer          |
| ------------------- | ------------------------------------------------ | ----------------------- |
| **IAM Roles**       | Authentication and authorization to AWS services | Identity-level security |
| **Security Groups** | Network traffic filtering to resources           | Network-level security  |

### IAM Resources Created by the IAM Module

The IAM module creates the following roles that work with resources protected by security groups:

1. **EKS Cluster Role** (`${cluster_name}-cluster-role`)
   - Required for EKS cluster creation
   - Attaches `AmazonEKSClusterPolicy`
   - Secured by security group rules controlling cluster API access

2. **EKS Node Group Role** (`${cluster_name}-nodegroup-role`)
   - Required for worker nodes to join the cluster
   - Attaches worker node policies (AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonEBSCSIDriverPolicy)
   - Node-to-node communication secured by security group rules

3. **OIDC IAM Role** (`${cluster_name}-oidc-role`)
   - Enables Kubernetes service accounts to assume IAM roles
   - Attached with S3 access policies for bucket operations
   - Access controlled through Kubernetes RBAC and security group network policies

### Security Group + IAM Together

- **IAM** answers: "Who can access this resource?"
- **Security Groups** answer: "From where and how can it be accessed?"

Both must be properly configured for secure resource access in the Finishline project.

## Troubleshooting

### Common Issues

1. **Connection Timeout**: Verify that ingress rules allow traffic from the correct CIDR blocks
2. **Security Group Not Found**: Ensure the VPC exists before creating the security group
3. **Permission Denied**: Check IAM permissions for creating security groups

### Best Practices

- Use specific CIDR blocks instead of `0.0.0.0/0` when possible
- Document all ingress rules with comments
- Review security group rules periodically
- Use naming conventions for easy identification

## Maintenance

- **Updates**: Ingress rules can be updated by modifying the `ingress_rules` variable
- **Monitoring**: Enable AWS CloudTrail for auditing security group changes
- **Versioning**: Track changes to security group rules in version control
