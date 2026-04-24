# Bootstrap Module — Jumphost EC2 Instance

**Module Path:** `terraform/modules/bootstrap/`  
**Version:** 1.0.0  
**Terraform Version:** >= 1.6.0  
**AWS Provider Version:** ~> 6.0  

---

## Overview

This module provisions the **Jumphost EC2 instance** for the Finish Line 2026 infrastructure project. The jumphost serves as a secure bastion host for accessing the EKS cluster and managing AWS resources.

### Assignment Requirements Compliance

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| Amazon Linux 2023 AMI | ✅ | Default AMI: `al2023-ami-*-x86_64` |
| SSH restricted to home IP CIDRs | ⚠️ | Security group must be configured externally |
| IAM role for EKS RBAC auth | ✅ | `iam_instance_profile` variable |
| Terraform-managed SSH keypair | ✅ | `key_name` variable (use `secret/key_pair` module) |
| User-data for tool installation | ✅ | `user_data_base64` variable |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         VPC (Public Subnet)                     │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Jumphost EC2                         │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │  Amazon Linux 2023 (al2023-ami-*-x86_64)          │  │   │
│  │  │  Instance Type: t3.micro (configurable)           │  │   │
│  │  │  Root Volume: gp3, 20GB, Encrypted                │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  │         │                    │                          │   │
│  │    ┌────▼────┐         ┌─────▼─────┐                    │   │
│  │    │ Security │         │   IAM     │                    │   │
│  │    │  Group   │         │ Instance  │                    │   │
│  │    │ (SSH 22) │         │  Profile  │                    │   │
│  │    └─────────┘         └───────────┘                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                    ┌─────────▼─────────┐                       │
│                    │  Internet Gateway  │                       │
│                    │   (Public Access)  │                       │
│                    └───────────────────┘                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   SSH (Port 22)   │
                    │  Home IP CIDRs    │
                    └───────────────────┘
```

---

## Resources Created

| Resource | Type | Description |
|----------|------|-------------|
| `data.aws_ami.amazon_linux_2023` | Data Source | Fetches latest Amazon Linux 2023 x86_64 AMI |
| `aws_instance.jump_host` | EC2 Instance | Jumphost bastion instance |

---

## Usage

### Basic Example

```hcl
module "jumphost" {
  source = "../../modules/bootstrap"

  # General
  project_name      = "finishline-infra"
  environment       = "dev"
  manage_by         = "Terraform"
  availability_zone = "us-east-1a"

  # Network
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.jumphost_sg.security_group_id

  # Authentication
  key_name                  = module.key_pair.key_name
  iam_instance_profile_name = aws_iam_instance_profile.jumphost.name

  # Optional: User data for tool installation
  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    # Install aws-cli v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    # Install helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    # Install kustomize
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    mv kustomize /usr/local/bin/
    # Install mysql-client
    dnf install -y mysql
  EOF
  )
}
```

### With Custom AMI

```hcl
module "jumphost" {
  source = "../../modules/bootstrap"

  project_name      = "finishline-infra"
  environment       = "dev"
  availability_zone = "us-east-1a"

  ami_id            = "ami-0c55b159cbfafe1f0" # Custom AL2023 AMI
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = aws_security_group.jumphost.id
  key_name          = "finishline-key-pair"
}
```

---

## Variables

### Required

| Name | Type | Description |
|------|------|-------------|
| `project_name` | `string` | Project name (3-21 chars, lowercase letters, numbers, hyphens) |
| `environment` | `string` | Environment name (`dev`, `staging`, `prod`, `sandbox`) |
| `availability_zone` | `string` | AZ for instance placement (e.g., `us-east-1a`) |
| `public_subnet_ids` | `list(string)` | List of public subnet IDs (first one used) |
| `security_group_id` | `string` | Security group ID allowing SSH from trusted CIDRs |
| `key_name` | `string` | EC2 key pair name for SSH access |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `manage_by` | `string` | `"Terraform"` | Entity managing this resource |
| `ami_id` | `string` | `""` | Custom AMI ID (empty = Amazon Linux 2023) |
| `instance_type` | `string` | `"t3.micro"` | EC2 instance type |
| `root_volume_size` | `number` | `20` | Root volume size in GB |
| `root_volume_iops` | `number` | `3000` | gp3 volume IOPS |
| `iam_instance_profile_name` | `string` | `null` | IAM instance profile for EKS auth |
| `user_data_base64` | `string` | `null` | Base64-encoded user data script |
| `additional_tags` | `map(string)` | `{}` | Additional tags to apply |

---

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_arn` | EC2 instance ARN |
| `public_ip` | Public IP address (for SSH) |
| `private_ip` | Private IP address |
| `public_dns` | Public DNS name |
| `private_dns` | Private DNS name |
| `availability_zone` | Deployment AZ |
| `subnet_id` | Subnet ID |
| `vpc_id` | VPC ID |
| `ami_id` | AMI ID used |
| `instance_type` | Instance type |
| `key_name` | Key pair name |
| `iam_instance_profile` | IAM instance profile |
| `security_groups` | Associated security groups |
| `primary_network_interface_id` | Primary ENI ID |
| `root_block_device_id` | Root volume ID |
| `root_block_device_arn` | Root volume ARN |
| `connection_ssh` | SSH connection block (sensitive) |
| `tags_all` | All applied tags |

---

## Security Considerations

### 1. SSH Access Restriction

The security group **must** restrict SSH (port 22) to trusted CIDR blocks only:

```hcl
resource "aws_security_group" "jumphost" {
  name        = "finishline-jumphost-sg"
  description = "Security group for jumphost - SSH restricted to home IPs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from home IPs only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<YOUR_HOME_IP>/32"] # Replace with actual CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 2. IMDSv2 Enforcement

The module enforces IMDSv2 (Instance Metadata Service v2) to prevent SSRF attacks:

```hcl
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"  # IMDSv2 only
  http_put_response_hop_limit = 1
}
```

### 3. Encrypted Root Volume

The root EBS volume is encrypted by default:

```hcl
root_block_device {
  encrypted             = true
  delete_on_termination = true
}
```

### 4. IAM Least Privilege

Attach an IAM instance profile with minimal permissions for EKS authentication:

```hcl
resource "aws_iam_role" "jumphost" {
  name = "finishline-jumphost-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach EKS access policy
resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.jumphost.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
```

---

## User Data Script Template

For installing required tools on the jumphost:

```bash
#!/bin/bash
set -e

# Update system
dnf update -y

# Install aws-cli v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
rm -rf aws awscliv2.zip

# Install kubectl
K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
mv kustomize /usr/local/bin/

# Install mysql-client
dnf install -y mysql

# Verify installations
aws --version
kubectl version --client
helm version
kustomize version
mysql --version
```

Encode and pass as `user_data_base64`:

```hcl
user_data_base64 = base64encode(file("${path.module}/scripts/jumphost-userdata.sh"))
```

---

## Validation Checklist

After deployment, verify:

- [ ] Instance is in `running` state
- [ ] Public IP is assigned (if in public subnet)
- [ ] SSH access works from allowed CIDRs only
- [ ] `aws --version` returns v2.x on jumphost
- [ ] `kubectl version --client` works
- [ ] `helm version` works
- [ ] `kustomize version` works
- [ ] IAM role is attached for EKS authentication
- [ ] Root volume is encrypted

---

## Troubleshooting

### SSH Connection Refused

1. Verify security group allows SSH from your IP
2. Check instance is in a public subnet with route to IGW
3. Verify key pair permissions: `chmod 400 <keyfile>.pem`

### User Data Not Executing

1. Check `/var/log/cloud-init-output.log` on the instance
2. Ensure script has proper shebang (`#!/bin/bash`)
3. Verify base64 encoding is valid

### EKS Authentication Fails

1. Verify IAM instance profile is attached
2. Check IAM role has `eks:DescribeCluster` permission
3. Ensure RBAC ConfigMap or Access Entry is configured in EKS

---

## References

- [Amazon Linux 2023 Documentation](https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html)
- [EC2 User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [IMDSv2 Security](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)
- [EKS IAM Authentication](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Finish Line 2026 Assignment PDF §69, §70, §73, §83, §84, §87, §89]

---

## License

This module is part of the Finish Line 2026 Infrastructure Project.  
**Reporter:** Joseph Ndzoh Dong  
**Timeline:** Feb 26, 2026 – March 2, 2026
