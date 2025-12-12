# EKS Cluster Setup and Management Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Using eksctl (Recommended)](#using-eksctl-recommended)
4. [Using AWS CLI and kubectl](#using-aws-cli-and-kubectl)
5. [Using Terraform](#using-terraform)
6. [Cluster Configuration](#cluster-configuration)
7. [Node Group Management](#node-group-management)
8. [Add-ons Installation](#add-ons-installation)
9. [Access Configuration](#access-configuration)
10. [Cluster Maintenance](#cluster-maintenance)

## Prerequisites

### Required Tools
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installations
aws --version
kubectl version --client
eksctl version
```

### AWS Configuration
```bash
# Configure AWS credentials
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-west-2
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### IAM Permissions Required
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "cloudformation:*",
        "autoscaling:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Installation Methods

### Method Comparison
| Method | Ease of Use | Flexibility | Production Ready |
|--------|-------------|-------------|------------------|
| eksctl | High | Medium | Yes |
| AWS CLI | Medium | High | Yes |
| Terraform | Medium | Very High | Yes |
| AWS Console | High | Low | Limited |

## Using eksctl (Recommended)

### Basic Cluster Creation
```bash
# Create basic cluster
eksctl create cluster \
  --name production-cluster \
  --region us-west-2 \
  --version 1.28 \
  --nodegroup-name worker-nodes \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 10 \
  --managed

# Check cluster status
eksctl get cluster --region us-west-2
```

### Advanced Cluster Configuration
```yaml
# cluster-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: production-cluster
  region: us-west-2
  version: "1.28"
  tags:
    Environment: production
    Project: web-platform
    ManagedBy: eksctl

# VPC Configuration
vpc:
  cidr: "10.0.0.0/16"
  nat:
    gateway: Single # or HighlyAvailable
  clusterEndpoints:
    privateAccess: true
    publicAccess: true
    publicAccessCIDRs: ["0.0.0.0/0"]

# IAM Configuration
iam:
  withOIDC: true
  serviceAccounts:
  - metadata:
      name: aws-load-balancer-controller
      namespace: kube-system
    wellKnownPolicies:
      awsLoadBalancerController: true
  - metadata:
      name: cluster-autoscaler
      namespace: kube-system
    wellKnownPolicies:
      autoScaler: true

# Managed Node Groups
managedNodeGroups:
  - name: worker-nodes-general
    instanceType: t3.medium
    minSize: 1
    maxSize: 10
    desiredCapacity: 3
    volumeSize: 20
    volumeType: gp3
    amiFamily: AmazonLinux2
    ssh:
      allow: true
      publicKeyName: my-key-pair
    labels:
      node-type: general
      environment: production
    tags:
      NodeGroup: general-workers
    iam:
      withAddonPolicies:
        imageBuilder: true
        autoScaler: true
        externalDNS: true
        certManager: true
        appMesh: true
        ebs: true
        fsx: true
        efs: true
        awsLoadBalancerController: true
        xRay: true
        cloudWatch: true

  - name: worker-nodes-spot
    instanceTypes: ["t3.medium", "t3.large", "t2.medium"]
    spot: true
    minSize: 0
    maxSize: 20
    desiredCapacity: 3
    volumeSize: 20
    labels:
      node-type: spot
      environment: production
    taints:
      - key: spot-instance
        value: "true"
        effect: NoSchedule
    tags:
      NodeGroup: spot-workers

# Fargate Profiles
fargateProfiles:
  - name: serverless-profile
    selectors:
      - namespace: serverless
        labels:
          compute-type: fargate
      - namespace: kube-system
        labels:
          k8s-app: aws-load-balancer-controller

# Add-ons
addons:
  - name: vpc-cni
    version: latest
    configurationValues: |-
      env:
        ENABLE_PREFIX_DELEGATION: "true"
        WARM_PREFIX_TARGET: "1"
  - name: coredns
    version: latest
  - name: kube-proxy
    version: latest
  - name: aws-ebs-csi-driver
    version: latest
    wellKnownPolicies:
      ebsCSIController: true

# CloudWatch Logging
cloudWatch:
  clusterLogging:
    enable: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    logRetentionInDays: 30
```

### Create Cluster with Configuration File
```bash
# Create cluster using config file
eksctl create cluster -f cluster-config.yaml

# Monitor cluster creation
eksctl utils describe-stacks --region us-west-2 --cluster production-cluster

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name production-cluster

# Verify cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

## Using AWS CLI and kubectl

### Step-by-Step Cluster Creation
```bash
# 1. Create IAM role for EKS cluster
aws iam create-role \
  --role-name EKSClusterRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# 2. Attach required policies
aws iam attach-role-policy \
  --role-name EKSClusterRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# 3. Create VPC and subnets (or use existing)
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=EKS-VPC}]'

# 4. Create EKS cluster
aws eks create-cluster \
  --name production-cluster \
  --version 1.28 \
  --role-arn arn:aws:iam::ACCOUNT-ID:role/EKSClusterRole \
  --resources-vpc-config subnetIds=subnet-12345,subnet-67890,endpointConfigPrivateAccess=true,endpointConfigPublicAccess=true

# 5. Wait for cluster to be active
aws eks wait cluster-active --name production-cluster

# 6. Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name production-cluster
```

### Node Group Creation
```bash
# Create IAM role for node group
aws iam create-role \
  --role-name EKSNodeGroupRole \
  --assume-role-policy-document '{
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
  }'

# Attach required policies
aws iam attach-role-policy --role-name EKSNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name EKSNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-role-policy --role-name EKSNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

# Create managed node group
aws eks create-nodegroup \
  --cluster-name production-cluster \
  --nodegroup-name worker-nodes \
  --subnets subnet-12345 subnet-67890 \
  --instance-types t3.medium \
  --ami-type AL2_x86_64 \
  --node-role arn:aws:iam::ACCOUNT-ID:role/EKSNodeGroupRole \
  --scaling-config minSize=1,maxSize=10,desiredSize=3 \
  --disk-size 20 \
  --remote-access ec2SshKey=my-key-pair
```

## Using Terraform

### Main Terraform Configuration
```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "aws" {
  region = var.region
}

# Data sources
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 4, k + 4)]
  
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  
  tags = var.tags
}

# EKS Module
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  
  # EKS Managed Node Groups
  eks_managed_node_groups = {
    general = {
      name = "general-workers"
      
      instance_types = ["t3.medium"]
      
      min_size     = 1
      max_size     = 10
      desired_size = 3
      
      disk_size = 20
      disk_type = "gp3"
      
      labels = {
        Environment = var.environment
        NodeGroup   = "general"
      }
      
      tags = {
        Environment = var.environment
        NodeGroup   = "general"
      }
    }
    
    spot = {
      name = "spot-workers"
      
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"
      
      min_size     = 0
      max_size     = 20
      desired_size = 3
      
      disk_size = 20
      disk_type = "gp3"
      
      labels = {
        Environment = var.environment
        NodeGroup   = "spot"
      }
      
      taints = [
        {
          key    = "spot-instance"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
      
      tags = {
        Environment = var.environment
        NodeGroup   = "spot"
      }
    }
  }
  
  # Fargate Profiles
  fargate_profiles = {
    serverless = {
      name = "serverless-profile"
      selectors = [
        {
          namespace = "serverless"
          labels = {
            compute-type = "fargate"
          }
        }
      ]
    }
  }
  
  # Cluster access entry
  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  
  # Cluster add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  
  # Enable cluster logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  tags = var.tags
}
```

### Variables Configuration
```hcl
# variables.tf
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "production-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "web-platform"
    ManagedBy   = "terraform"
  }
}
```

### Outputs Configuration
```hcl
# outputs.tf
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "node_groups" {
  description = "EKS node groups"
  value       = module.eks.eks_managed_node_groups
}
```

### Deploy with Terraform
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var="cluster_name=my-cluster" -var="region=us-west-2"

# Apply configuration
terraform apply -var="cluster_name=my-cluster" -var="region=us-west-2"

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name my-cluster

# Verify deployment
kubectl get nodes
```

## Cluster Configuration

### Networking Configuration
```yaml
# Custom CNI configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: amazon-vpc-cni
  namespace: kube-system
data:
  enable-network-policy: "true"
  enable-pod-eni: "true"
  warm-eni-target: "1"
  warm-ip-target: "5"
```

### Security Configuration
```yaml
# Pod Security Policy
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

## Node Group Management

### Scaling Node Groups
```bash
# Scale managed node group
aws eks update-nodegroup-config \
  --cluster-name production-cluster \
  --nodegroup-name worker-nodes \
  --scaling-config minSize=2,maxSize=20,desiredSize=5

# Using eksctl
eksctl scale nodegroup \
  --cluster production-cluster \
  --name worker-nodes \
  --nodes 5 \
  --nodes-min 2 \
  --nodes-max 20
```

### Update Node Group
```bash
# Update AMI version
aws eks update-nodegroup-version \
  --cluster-name production-cluster \
  --nodegroup-name worker-nodes \
  --kubernetes-version 1.28

# Force update
aws eks update-nodegroup-version \
  --cluster-name production-cluster \
  --nodegroup-name worker-nodes \
  --force
```

### Add New Node Group
```bash
# Create additional node group with different instance types
eksctl create nodegroup \
  --cluster production-cluster \
  --name compute-optimized \
  --node-type c5.large \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 10 \
  --node-labels workload=compute-intensive
```

## Add-ons Installation

### AWS Load Balancer Controller
```bash
# Create IAM service account
eksctl create iamserviceaccount \
  --cluster production-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess \
  --approve

# Install using Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=production-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Cluster Autoscaler
```yaml
# cluster-autoscaler.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 100m
            memory: 300Mi
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/production-cluster
        - --balance-similar-node-groups
        - --skip-nodes-with-system-pods=false
```

### Metrics Server
```bash
# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify installation
kubectl get deployment metrics-server -n kube-system
```

## Access Configuration

### RBAC Configuration
```yaml
# developer-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developer-binding
subjects:
- kind: User
  name: developer@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

### AWS IAM Integration
```bash
# Create IAM user for developers
aws iam create-user --user-name eks-developer

# Create access keys
aws iam create-access-key --user-name eks-developer

# Add user to aws-auth ConfigMap
kubectl edit configmap aws-auth -n kube-system
```

```yaml
# Add to aws-auth ConfigMap
mapUsers: |
  - userarn: arn:aws:iam::ACCOUNT-ID:user/eks-developer
    username: developer
    groups:
    - system:masters
```

## Cluster Maintenance

### Cluster Updates
```bash
# Check current version
kubectl version --short

# Update cluster control plane
aws eks update-cluster-version \
  --name production-cluster \
  --kubernetes-version 1.28

# Monitor update progress
aws eks describe-update \
  --name production-cluster \
  --update-id UPDATE-ID

# Update node groups after control plane
aws eks update-nodegroup-version \
  --cluster-name production-cluster \
  --nodegroup-name worker-nodes \
  --kubernetes-version 1.28
```

### Backup Strategies
```bash
# Backup etcd (managed by AWS)
# Create cluster snapshot using Velero
velero backup create cluster-backup-$(date +%Y%m%d) \
  --include-namespaces default,kube-system \
  --storage-location aws

# Backup persistent volumes
kubectl get pv -o yaml > pv-backup-$(date +%Y%m%d).yaml
```

### Monitoring Cluster Health
```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces
kubectl top nodes
kubectl top pods --all-namespaces

# Check cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

# Describe cluster
eksctl get cluster --region us-west-2
```

### Troubleshooting Commands
```bash
# Check node logs
kubectl logs -n kube-system -l k8s-app=aws-node

# Check DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# Check cluster autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler

# Describe problematic pods
kubectl describe pod <pod-name> -n <namespace>

# Check resource usage
kubectl describe node <node-name>
```

## Cleanup

### Delete Resources
```bash
# Delete using eksctl
eksctl delete cluster --name production-cluster --region us-west-2

# Delete using Terraform
terraform destroy

# Manual cleanup if needed
aws eks delete-nodegroup --cluster-name production-cluster --nodegroup-name worker-nodes
aws eks delete-cluster --name production-cluster
```

## Best Practices

### Security Best Practices
1. **Enable private endpoint access**
2. **Use IAM roles for service accounts**
3. **Implement network policies**
4. **Enable audit logging**
5. **Use Pod Security Standards**
6. **Regular security updates**

### Performance Best Practices
1. **Right-size node instances**
2. **Use multiple availability zones**
3. **Implement cluster autoscaling**
4. **Monitor resource utilization**
5. **Optimize container images**
6. **Use appropriate storage classes**

### Cost Optimization
1. **Use Spot instances for non-critical workloads**
2. **Implement horizontal pod autoscaling**
3. **Right-size resources**
4. **Use Fargate for serverless workloads**
5. **Monitor and optimize costs regularly**

## Next Steps

1. **Deploy sample applications**
2. **Set up monitoring and logging**
3. **Implement CI/CD pipelines**
4. **Configure backup and disaster recovery**
5. **Explore advanced features like service mesh**