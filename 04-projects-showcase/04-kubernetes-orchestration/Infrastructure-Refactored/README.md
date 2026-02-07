# 🚀 Production-Ready EKS Infrastructure with Service Mesh

## 📋 Overview

This is a **senior-level, production-ready** Terraform configuration for deploying an Amazon EKS cluster with Istio service mesh, comprehensive monitoring, and GitOps capabilities.

### Key Features

- ✅ **Multi-AZ High Availability** - Spans 3 availability zones
- ✅ **Service Mesh** - Istio with ingress/egress gateways
- ✅ **Observability** - Prometheus, Grafana, Kiali, Jaeger
- ✅ **GitOps** - ArgoCD for continuous deployment
- ✅ **Security** - Pod Security Policies, Network Policies, Secrets Store CSI
- ✅ **Autoscaling** - Cluster Autoscaler and HPA support
- ✅ **Monitoring** - CloudWatch Container Insights
- ✅ **Remote State** - S3 backend with DynamoDB locking
- ✅ **Variable Validation** - Comprehensive input validation
- ✅ **Environment-Specific** - Dev, Staging, Production configurations

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Region                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                  │  │
│  │                                                       │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │  │
│  │  │   AZ-1a      │  │   AZ-1b      │  │   AZ-1c    │ │  │
│  │  │              │  │              │  │            │ │  │
│  │  │ Public       │  │ Public       │  │ Public     │ │  │
│  │  │ 10.0.1.0/24  │  │ 10.0.2.0/24  │  │ 10.0.3.0/24│ │  │
│  │  │ ┌──────────┐ │  │ ┌──────────┐ │  │ ┌────────┐ │ │  │
│  │  │ │ NAT GW   │ │  │ │ NAT GW   │ │  │ │ NAT GW │ │ │  │
│  │  │ └──────────┘ │  │ └──────────┘ │  │ └────────┘ │ │  │
│  │  │              │  │              │  │            │ │  │
│  │  │ Private      │  │ Private      │  │ Private    │ │  │
│  │  │ 10.0.11.0/24 │  │ 10.0.12.0/24 │  │10.0.13.0/24│ │  │
│  │  │ ┌──────────┐ │  │ ┌──────────┐ │  │ ┌────────┐ │ │  │
│  │  │ │EKS Nodes │ │  │ │EKS Nodes │ │  │ │EKS Nodes│ │ │  │
│  │  │ └──────────┘ │  │ └──────────┘ │  │ └────────┘ │ │  │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │           EKS Control Plane                     │ │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐     │ │  │
│  │  │  │ Istio    │  │ ArgoCD   │  │Prometheus│     │ │  │
│  │  │  │ Mesh     │  │ GitOps   │  │ Monitor  │     │ │  │
│  │  │  └──────────┘  └──────────┘  └──────────┘     │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
Infrastructure-Refactored/
├── main.tf                 # Main resource definitions
├── variables.tf            # Input variables with validation
├── outputs.tf              # Output values
├── providers.tf            # Provider configurations
├── README.md               # This file
├── terraform.tfvars.example # Example variable values
├── modules/
│   ├── networking/         # VPC, subnets, NAT gateways
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── eks/                # EKS cluster and node groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── service-mesh/       # Istio installation
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── monitoring/         # Prometheus, Grafana
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── security/           # Security policies
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── gitops/             # ArgoCD
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
└── environments/
    ├── dev.tfvars
    ├── staging.tfvars
    └── production.tfvars
```

---

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.5.0
3. **kubectl** >= 1.28
4. **helm** >= 3.12
5. **S3 bucket** for remote state
6. **DynamoDB table** for state locking

### Step 1: Create Remote Backend

```bash
# Create S3 bucket for state
aws s3 mb s3://my-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket my-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 2: Configure Variables

```bash
# Copy example tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
vim terraform.tfvars
```

### Step 3: Initialize Terraform

```bash
# Initialize backend and download providers
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

### Step 4: Plan and Apply

```bash
# Create execution plan
terraform plan -out=tfplan

# Review plan carefully
terraform show tfplan

# Apply changes
terraform apply tfplan
```

### Step 5: Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --region us-east-1 \
  --name <cluster-name>

# Verify connection
kubectl get nodes
kubectl get pods --all-namespaces
```

---

## 🔧 Configuration

### Environment-Specific Deployments

**Development:**
```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

**Staging:**
```bash
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"
```

**Production:**
```bash
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
```

### Key Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_name` | Project identifier | - | Yes |
| `environment` | Environment (dev/staging/production) | - | Yes |
| `aws_region` | AWS region | `us-east-1` | No |
| `eks_cluster_version` | Kubernetes version | `1.28` | No |
| `enable_service_mesh` | Enable Istio | `true` | No |
| `enable_monitoring` | Enable monitoring stack | `true` | No |
| `enable_gitops` | Enable ArgoCD | `true` | No |

---

## 📊 Outputs

After successful deployment, Terraform provides:

- **VPC ID** and subnet IDs
- **EKS cluster endpoint** and certificate
- **Istio ingress gateway** hostname
- **Grafana URL** and credentials
- **ArgoCD URL** and admin password
- **kubectl configuration** command

View outputs:
```bash
terraform output
terraform output -json > outputs.json
```

---

## 🔐 Security Best Practices

### 1. Least Privilege IAM

The Terraform service account requires these permissions:
- EC2: VPC, subnet, security group management
- EKS: Cluster and node group management
- IAM: Role and policy management (scoped to project)
- CloudWatch: Log group management
- S3: State bucket access
- DynamoDB: State lock table access

### 2. Secrets Management

**Never store secrets in variables!**

```hcl
# Use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "grafana_password" {
  secret_id = "${var.project_name}/grafana/admin-password"
}

# Reference in configuration
grafana_admin_password = data.aws_secretsmanager_secret_version.grafana_password.secret_string
```

### 3. Network Security

- Private subnets for EKS nodes
- Security groups with minimal ingress rules
- VPC Flow Logs enabled
- Network policies enforced

### 4. Encryption

- EKS secrets encryption with KMS
- S3 state encryption
- EBS volumes encrypted by default

---

## 🧪 Testing

### Pre-deployment Validation

```bash
# Validate Terraform syntax
terraform validate

# Check formatting
terraform fmt -check -recursive

# Security scanning
tfsec .
checkov -d .

# Cost estimation
infracost breakdown --path .
```

### Post-deployment Verification

```bash
# Verify cluster health
kubectl get nodes
kubectl get pods --all-namespaces

# Check Istio installation
kubectl get pods -n istio-system
kubectl get svc -n istio-ingress

# Verify monitoring
kubectl get pods -n monitoring

# Check ArgoCD
kubectl get pods -n argocd
```

---

## 🔄 Maintenance

### Upgrading EKS Version

```bash
# Update variable
eks_cluster_version = "1.29"

# Plan upgrade
terraform plan

# Apply upgrade (control plane first)
terraform apply

# Upgrade node groups (rolling update)
# Nodes will be replaced automatically
```

### Scaling Node Groups

```bash
# Update in tfvars or variables
# For production:
desired_size = 7
max_size     = 15
min_size     = 5

# Apply changes
terraform apply
```

### Backup and Disaster Recovery

```bash
# Backup state
terraform state pull > backup-$(date +%Y%m%d).json

# Backup EKS resources
kubectl get all --all-namespaces -o yaml > k8s-backup-$(date +%Y%m%d).yaml

# Backup persistent volumes
velero backup create full-backup --include-namespaces '*'
```

---

## 🚨 Troubleshooting

### Issue: State Lock Timeout

```bash
# Check lock status
aws dynamodb scan --table-name terraform-state-lock

# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

### Issue: EKS Nodes Not Joining

```bash
# Check node IAM role
aws iam get-role --role-name <node-role-name>

# Verify security groups
aws ec2 describe-security-groups --group-ids <sg-id>

# Check CloudWatch logs
aws logs tail /aws/eks/<cluster-name>/cluster --follow
```

### Issue: Istio Pods Pending

```bash
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name> -n istio-system

# Verify service mesh configuration
istioctl analyze
```

---

## 📚 Additional Resources

- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Istio Documentation](https://istio.io/latest/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## 🤝 Contributing

1. Create feature branch
2. Make changes with proper validation
3. Run `terraform fmt` and `terraform validate`
4. Test in dev environment
5. Submit pull request

---

## 📄 License

MIT License

---

## 👥 Maintainers

- Platform Team (@platform-team)
- DevOps Team (@devops-team)

---

**Last Updated:** 2024  
**Terraform Version:** >= 1.5.0  
**AWS Provider Version:** ~> 5.0
