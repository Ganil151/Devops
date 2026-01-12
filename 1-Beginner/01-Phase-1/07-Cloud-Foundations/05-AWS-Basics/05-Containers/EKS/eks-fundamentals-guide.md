# Amazon EKS (Elastic Kubernetes Service) - Fundamentals Guide

## Table of Contents
1. [What is Amazon EKS](#what-is-amazon-eks)
2. [EKS Architecture](#eks-architecture)
3. [Core Components](#core-components)
4. [EKS vs Self-Managed Kubernetes](#eks-vs-self-managed-kubernetes)
5. [Networking in EKS](#networking-in-eks)
6. [Security Model](#security-model)
7. [Storage Options](#storage-options)
8. [Monitoring and Logging](#monitoring-and-logging)
9. [Cost Optimization](#cost-optimization)
10. [DevOps Integration](#devops-integration)

## What is Amazon EKS

Amazon Elastic Kubernetes Service (EKS) is a fully managed Kubernetes service that makes it easy to run Kubernetes on AWS without needing to install and operate your own Kubernetes control plane or nodes.

### Key Benefits
- **Fully Managed Control Plane**: AWS manages the Kubernetes control plane
- **High Availability**: Multi-AZ deployment by default
- **Security**: Integrated with AWS IAM and VPC
- **Scalability**: Auto-scaling capabilities
- **Cost Effective**: Pay only for worker nodes
- **Compliance**: SOC, PCI, ISO, FedRAMP certified

### Use Cases
- **Microservices Architecture**: Container orchestration for microservices
- **CI/CD Pipelines**: Kubernetes-native deployment workflows
- **Batch Processing**: Running batch jobs and data processing workloads
- **Machine Learning**: ML model training and inference
- **Hybrid Cloud**: Consistent Kubernetes experience across environments

## EKS Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Cloud                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              EKS Control Plane                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   API       │  │   etcd      │  │ Controller  │ │   │
│  │  │   Server    │  │   Store     │  │   Manager   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Scheduler   │  │   Cloud     │  │   Add-ons   │ │   │
│  │  │             │  │ Controller  │  │             │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 VPC Network                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Subnet    │  │   Subnet    │  │   Subnet    │ │   │
│  │  │    AZ-1     │  │    AZ-2     │  │    AZ-3     │ │   │
│  │  │             │  │             │  │             │ │   │
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │ │   │
│  │  │ │ Worker  │ │  │ │ Worker  │ │  │ │ Worker  │ │ │   │
│  │  │ │  Nodes  │ │  │ │  Nodes  │ │  │ │  Nodes  │ │ │   │
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Control Plane Components
- **API Server**: Kubernetes API endpoint
- **etcd**: Distributed key-value store
- **Controller Manager**: Manages controllers
- **Scheduler**: Pod scheduling decisions
- **Cloud Controller Manager**: AWS-specific controllers

## Core Components

### 1. EKS Cluster
```bash
# Cluster configuration example
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: production-cluster
  region: us-west-2
  version: "1.28"

vpc:
  cidr: "10.0.0.0/16"
  nat:
    gateway: Single

nodeGroups:
  - name: worker-nodes
    instanceType: t3.medium
    desiredCapacity: 3
    minSize: 1
    maxSize: 10
    volumeSize: 20
    ssh:
      allow: true
```

### 2. Node Groups
- **Managed Node Groups**: AWS-managed EC2 instances
- **Self-Managed Node Groups**: User-managed EC2 instances
- **Fargate**: Serverless compute for pods

### 3. Add-ons
- **VPC CNI**: Container networking
- **CoreDNS**: DNS resolution
- **kube-proxy**: Network proxy
- **EBS CSI Driver**: Storage provisioning

## EKS vs Self-Managed Kubernetes

| Feature | EKS | Self-Managed |
|---------|-----|--------------|
| Control Plane Management | AWS Managed | User Managed |
| High Availability | Built-in Multi-AZ | Manual Setup |
| Security Patches | Automatic | Manual |
| Backup & Recovery | AWS Managed | User Responsibility |
| Cost | Control plane fee + nodes | Infrastructure only |
| Customization | Limited | Full control |
| Compliance | AWS Certified | User Responsibility |

## Networking in EKS

### VPC Configuration
```yaml
# VPC requirements for EKS
VPC:
  CIDR: "10.0.0.0/16"
  Subnets:
    Private:
      - "10.0.1.0/24"  # AZ-1
      - "10.0.2.0/24"  # AZ-2
    Public:
      - "10.0.101.0/24"  # AZ-1
      - "10.0.102.0/24"  # AZ-2
  
  Requirements:
    - Minimum 2 subnets in different AZs
    - Internet Gateway for public subnets
    - NAT Gateway for private subnets
    - Proper route tables
```

### Container Networking Interface (CNI)
- **AWS VPC CNI**: Default networking plugin
- **Pod IP Assignment**: Each pod gets VPC IP
- **Security Groups**: Applied to pods
- **Network Policies**: Kubernetes-native network segmentation

### Service Types
```yaml
# ClusterIP Service
apiVersion: v1
kind: Service
metadata:
  name: internal-service
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 8080

---
# LoadBalancer Service
apiVersion: v1
kind: Service
metadata:
  name: external-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 3000
```

## Security Model

### Identity and Access Management
```yaml
# RBAC Configuration
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "delete"]

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

### Pod Security Standards
```yaml
# Pod Security Policy
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Network Security
- **Security Groups**: EC2-level firewall rules
- **Network ACLs**: Subnet-level network control
- **Network Policies**: Kubernetes-native network segmentation
- **Service Mesh**: Istio/Linkerd for advanced security

## Storage Options

### Persistent Volume Types
```yaml
# EBS Storage Class
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3-encrypted
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
  fsType: ext4
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true

---
# EFS Storage Class
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-12345678
  directoryPerms: "700"
```

### Storage Comparison
| Storage Type | Use Case | Performance | Scalability |
|--------------|----------|-------------|-------------|
| EBS | Single pod, high IOPS | High | Limited to AZ |
| EFS | Multi-pod, shared storage | Moderate | Unlimited |
| FSx | High-performance workloads | Very High | High |

## Monitoring and Logging

### CloudWatch Integration
```yaml
# CloudWatch Logs Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: amazon-cloudwatch
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf
        HTTP_Server   On
        HTTP_Listen   0.0.0.0
        HTTP_Port     2020

    [INPUT]
        Name              tail
        Tag               application.*
        Path              /var/log/containers/*.log
        Parser            docker
        DB                /var/log/flb_kube.db
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On
        Refresh_Interval  10

    [OUTPUT]
        Name                cloudwatch_logs
        Match               application.*
        region              us-west-2
        log_group_name      /aws/eks/cluster-logs
        log_stream_prefix   application-
        auto_create_group   true
```

### Prometheus and Grafana
```yaml
# Prometheus ServiceMonitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-metrics
spec:
  selector:
    matchLabels:
      app: my-application
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

## Cost Optimization

### Right-Sizing Strategies
```yaml
# Resource requests and limits
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cost-optimized-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cost-optimized-app
  template:
    metadata:
      labels:
        app: cost-optimized-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
```

### Spot Instances
```yaml
# Spot instance node group
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

nodeGroups:
  - name: spot-workers
    instanceTypes: ["t3.medium", "t3.large", "t2.medium"]
    spot: true
    desiredCapacity: 3
    minSize: 1
    maxSize: 10
    labels:
      node-type: spot
    taints:
      - key: spot-instance
        value: "true"
        effect: NoSchedule
```

### Cluster Autoscaler
```yaml
# Cluster Autoscaler deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/production-cluster
```

## DevOps Integration

### CI/CD Pipeline Integration
```yaml
# GitLab CI/CD Pipeline
stages:
  - build
  - test
  - deploy

variables:
  CLUSTER_NAME: production-cluster
  AWS_REGION: us-west-2

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy:
  stage: deploy
  script:
    - aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
    - kubectl set image deployment/app app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - kubectl rollout status deployment/app
  only:
    - main
```

### Infrastructure as Code
```hcl
# Terraform EKS module
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = "production-cluster"
  cluster_version = "1.28"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  node_groups = {
    main = {
      desired_capacity = 3
      max_capacity     = 10
      min_capacity     = 1
      
      instance_types = ["t3.medium"]
      
      k8s_labels = {
        Environment = "production"
        Application = "web"
      }
    }
  }
  
  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

### GitOps with ArgoCD
```yaml
# ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web-application
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/k8s-manifests
    targetRevision: HEAD
    path: applications/web
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Best Practices

### Security Best Practices
1. **Enable Pod Security Standards**
2. **Use RBAC for access control**
3. **Implement Network Policies**
4. **Enable audit logging**
5. **Use secrets management**
6. **Regular security scanning**

### Performance Best Practices
1. **Right-size resources**
2. **Use horizontal pod autoscaling**
3. **Implement cluster autoscaling**
4. **Optimize container images**
5. **Use appropriate storage classes**
6. **Monitor resource utilization**

### Operational Best Practices
1. **Implement comprehensive monitoring**
2. **Set up centralized logging**
3. **Use GitOps for deployments**
4. **Implement backup strategies**
5. **Plan for disaster recovery**
6. **Regular cluster updates**

## Troubleshooting Common Issues

### Node Issues
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check node logs
kubectl logs -n kube-system -l k8s-app=aws-node

# Drain and replace problematic node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Networking Issues
```bash
# Check CNI plugin status
kubectl get pods -n kube-system -l k8s-app=aws-node

# Verify security groups
aws ec2 describe-security-groups --group-ids <sg-id>

# Test pod connectivity
kubectl exec -it <pod-name> -- nslookup kubernetes.default
```

### Storage Issues
```bash
# Check persistent volumes
kubectl get pv,pvc

# Verify CSI driver
kubectl get pods -n kube-system -l app=ebs-csi-controller

# Check storage class
kubectl get storageclass
```

## Next Steps

1. **Set up your first EKS cluster** - Follow the cluster setup guide
2. **Deploy sample applications** - Practice with workload deployment
3. **Implement monitoring** - Set up CloudWatch and Prometheus
4. **Configure CI/CD** - Integrate with your deployment pipeline
5. **Explore advanced features** - Service mesh, serverless, ML workloads

## Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [eksctl Documentation](https://eksctl.io/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)