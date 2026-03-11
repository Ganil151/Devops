# Finishline Infrastructure Troubleshooting Guide

## Table of Contents

1. [EKS Node Join Issues](#eks-node-join-issues)
2. [Security Issues](#security-issues)
3. [VPC and Network Issues](#vpc-and-network-issues)
4. [IAM and Authentication Issues](#iam-and-authentication-issues)
5. [Terraform Configuration Issues](#terraform-configuration-issues)
6. [Monitoring and Logging Issues](#monitoring-and-logging-issues)
7. [General Debugging](#general-debugging)

---

## EKS Node Join Issues

### Problem: Instances Failed to Join Kubernetes Cluster

#### Symptoms
- Nodes not appearing in `kubectl get nodes`
- Nodes stuck in "NotReady" state
- Kubelet unable to register with API server
- CNI plugin unable to initialize
- Pod scheduling failures

#### Root Causes

**1. Missing or Incorrect Node Role ARN**
- Node groups not receiving proper IAM role
- Instances cannot assume required permissions

**Solution**:
```bash
# Verify node role exists
aws iam get-role \
  --role-name finishline-eks-cluster-nodegroup-role-XXXX

# Verify role has required policies
aws iam list-attached-role-policies \
  --role-name finishline-eks-cluster-nodegroup-role-XXXX

# Expected policies:
# - AmazonEKSWorkerNodePolicy
# - AmazonEKS_CNI_Policy
# - AmazonEC2ContainerRegistryReadOnly
# - AmazonEBSCSIDriverPolicy
```

**2. Instance Profile Not Associated**
- EC2 instances don't have instance profile
- Cannot assume node role

**Solution**:
```bash
# Check instance profile
aws iam get-instance-profile \
  --instance-profile-name finishline-eks-cluster-nodegroup-profile

# Verify instance has profile
aws ec2 describe-instances \
  --filters "Name=tag:aws:eks:cluster-name,Values=finishline-eks-cluster" \
  --query 'Reservations[].Instances[].[InstanceId,IamInstanceProfile.Arn]'

# Expected: Instance should have IamInstanceProfile.Arn set
```

**3. Nodes in Public Subnets**
- Nodes should be in private subnets
- Public subnets cause node creation failures

**Solution**:
```bash
# Verify node group subnet configuration
aws eks describe-nodegroup \
  --cluster-name finishline-eks-cluster \
  --nodegroup-name finishline-eks-cluster-ondemand-nodes \
  --query 'nodegroup.subnets'

# Expected: Private subnets (10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24)

# Verify NAT Gateway exists
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=<vpc-id>"
```

**4. Security Group Rules Missing**
- Nodes cannot communicate with EKS control plane
- Missing ingress/egress rules

**Solution**:
```bash
# Check security group rules
aws ec2 describe-security-groups \
  --group-ids <security-group-id>

# Required ingress rules:
# - Port 22 (SSH) from 0.0.0.0/0
# - Port 80 (HTTP) from 0.0.0.0/0
# - Port 443 (HTTPS) from 0.0.0.0/0
# - Ports 1025-65535 (EKS worker communication) from 10.0.0.0/16

# Required egress rules:
# - All traffic to 0.0.0.0/0
```

#### Verification Steps

```bash
# 1. Check cluster status
aws eks describe-cluster \
  --name finishline-eks-cluster \
  --query 'cluster.status'
# Expected: ACTIVE

# 2. Check node group status
aws eks describe-nodegroup \
  --cluster-name finishline-eks-cluster \
  --nodegroup-name finishline-eks-cluster-ondemand-nodes \
  --query 'nodegroup.status'
# Expected: ACTIVE

# 3. Check node health
kubectl get nodes -o wide

# 4. Check node details
kubectl describe node <node-name>

# 5. Check kubelet logs
kubectl logs -n kube-system -l k8s-app=kubelet --tail=50

# 6. Check system pods
kubectl get pods -n kube-system
```

#### SSH to Node for Debugging

```bash
# 1. SSH to jumphost
ssh -i finishline-key.pem ec2-user@<jumphost-public-ip>

# 2. SSH to node from jumphost
ssh -i finishline-key.pem ec2-user@<node-private-ip>

# 3. Check kubelet status
sudo systemctl status kubelet

# 4. Check kubelet logs
sudo journalctl -u kubelet -f

# 5. Check system logs
sudo tail -f /var/log/messages

# 6. Check container runtime
sudo systemctl status containerd

# 7. Check network connectivity
ping 8.8.8.8  # Test internet access via NAT
curl https://eks.amazonaws.com  # Test AWS API access
```

---

## Security Issues

### Issue 1: Instance Does Not Require IMDS Access to Require a Token

#### Problem
EC2 instances not configured to require IMDSv2 (Instance Metadata Service Version 2)

#### Symptoms
- Potential SSRF (Server-Side Request Forgery) attacks
- Metadata accessible without token requirement

#### Solution

**File**: `terraform/modules/bootstrap/main.tf`

```hcl
resource "aws_instance" "jumphost" {
  # ... other configuration ...

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # ... rest of configuration ...
}
```

**Verification**:
```bash
# Check instance metadata options
aws ec2 describe-instances \
  --instance-ids <instance-id> \
  --query 'Reservations[].Instances[].MetadataOptions'

# Expected:
# {
#   "State": "pending",
#   "HttpTokens": "required",
#   "HttpPutResponseHopLimit": 1,
#   "HttpEndpoint": "enabled"
# }
```

### Issue 2: Cluster Does Not Have Secret Encryption Enabled

#### Problem
EKS cluster secrets not encrypted at rest using AWS KMS

#### Symptoms
- Secrets stored unencrypted in etcd
- Compliance violations
- Data exposure risk

#### Solution

**File**: `terraform/modules/eks/main.tf`

```hcl
# Create KMS key for secret encryption
resource "aws_kms_key" "eks_secrets" {
  count                   = var.is_eks_cluster_enabled ? 1 : 0
  description             = "KMS key for EKS secret encryption - ${var.cluster_name}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-secrets-key"
  })
}

resource "aws_kms_alias" "eks_secrets" {
  count         = var.is_eks_cluster_enabled ? 1 : 0
  name          = "alias/${var.cluster_name}-secrets"
  target_key_id = aws_kms_key.eks_secrets[0].key_id
}

# Add encryption config to EKS cluster
resource "aws_eks_cluster" "eks" {
  # ... other configuration ...

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets[0].arn
    }
    resources = ["secrets"]
  }

  # ... rest of configuration ...
}
```

**Verification**:
```bash
# Check cluster encryption configuration
aws eks describe-cluster \
  --name finishline-eks-cluster \
  --query 'cluster.encryptionConfig'

# Expected:
# [
#   {
#     "resources": ["secrets"],
#     "provider": {
#       "keyArn": "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
#     }
#   }
# ]
```

### Issue 3: Cluster Allows Access from Public CIDR (0.0.0.0/0)

#### Problem
EKS cluster endpoint publicly accessible without CIDR restrictions

#### Symptoms
- Anyone on internet can attempt to access cluster API
- Security vulnerability
- Compliance violations

#### Solution

**File**: `terraform/modules/eks/main.tf`

```hcl
resource "aws_eks_cluster" "eks" {
  # ... other configuration ...

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false  # ✅ Disable public access
    public_access_cidrs     = []     # ✅ No public CIDRs
    security_group_ids      = var.security_group_ids
  }

  # ... rest of configuration ...
}
```

**Verification**:
```bash
# Check cluster endpoint configuration
aws eks describe-cluster \
  --name finishline-eks-cluster \
  --query 'cluster.resourcesVpcConfig'

# Expected:
# {
#   "endpointPrivateAccess": true,
#   "endpointPublicAccess": false,
#   "publicAccessCidrs": []
# }
```

---

## VPC and Network Issues

### Issue: VPC Flow Logs Not Enabled

#### Problem
VPC Flow Logs not configured for network traffic monitoring

#### Symptoms
- No visibility into network traffic
- Cannot troubleshoot connectivity issues
- Compliance violations
- Security monitoring gaps

#### Solution

**File**: `terraform/modules/vpc/main.tf`

```hcl
# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(local.vpc_tags, {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  })
}

# Create IAM Role for Flow Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.project_name}-${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = merge(local.vpc_tags, {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs-role"
  })
}

# Create IAM Policy for Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.project_name}-${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# Create Flow Log Resource
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.finishline_vpc.id

  tags = merge(local.vpc_tags, {
    Name = "${var.project_name}-${var.environment}-vpc-flow-logs"
  })
}
```

**Verification**:
```bash
# Check VPC Flow Logs
aws ec2 describe-flow-logs \
  --filter "Name=resource-id,Values=<vpc-id>"

# Check CloudWatch Log Group
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/vpc/flowlogs"

# View flow logs
aws logs tail /aws/vpc/flowlogs/finishline-infra-dev --follow
```

### Issue: Nodes Cannot Reach Internet

#### Problem
Nodes in private subnets cannot reach internet

#### Symptoms
- Container image pull failures
- Package installation failures
- External API calls fail
- DNS resolution issues

#### Solution

**Verify NAT Gateway Configuration**:
```bash
# Check NAT Gateway
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=<vpc-id>"

# Check route table
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --query 'RouteTables[?Tags[?Key==`Type` && Value==`Private`]]'

# Expected: Route to 0.0.0.0/0 via NAT Gateway

# Check Elastic IP
aws ec2 describe-addresses \
  --filter "Name:association.nat-gateway-id,Values=<nat-gateway-id>"
```

**SSH to Node and Test**:
```bash
# SSH to node via jumphost
ssh -i finishline-key.pem ec2-user@<node-private-ip>

# Test internet connectivity
ping 8.8.8.8
curl https://www.google.com

# Test DNS
nslookup amazon.com
dig amazon.com

# Check route table
ip route

# Check NAT Gateway connectivity
traceroute 8.8.8.8
```

---

## IAM and Authentication Issues

### Issue: Node Role Missing Required Policies

#### Problem
Node role doesn't have all required AWS managed policies

#### Symptoms
- Nodes cannot register with cluster
- CNI plugin fails to initialize
- Cannot pull images from ECR
- Cannot manage EBS volumes

#### Solution

**Verify Required Policies**:
```bash
# List attached policies
aws iam list-attached-role-policies \
  --role-name finishline-eks-cluster-nodegroup-role-XXXX

# Required policies:
# 1. AmazonEKSWorkerNodePolicy
# 2. AmazonEKS_CNI_Policy
# 3. AmazonEC2ContainerRegistryReadOnly
# 4. AmazonEBSCSIDriverPolicy

# Attach missing policies
aws iam attach-role-policy \
  --role-name finishline-eks-cluster-nodegroup-role-XXXX \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
```

**File**: `terraform/modules/secret/iam/main.tf`

```hcl
resource "aws_iam_role_policy_attachment" "node-policies" {
  for_each = var.is_eks_nodegroup_role_enabled ? toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]) : []

  policy_arn = each.value
  role       = aws_iam_role.eks-nodegroup-role[0].name
}
```

### Issue: Cluster Role Missing Policies

#### Problem
EKS cluster role doesn't have required policies

#### Symptoms
- Cluster creation fails
- Cluster stuck in CREATING state
- VPC resource management fails

#### Solution

**Verify Cluster Role Policies**:
```bash
# List attached policies
aws iam list-attached-role-policies \
  --role-name finishline-eks-cluster-cluster-role-XXXX

# Required policies:
# 1. AmazonEKSClusterPolicy
# 2. AmazonEKSVPCResourceController
```

**File**: `terraform/modules/secret/iam/main.tf`

```hcl
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count = var.is_role_enabled ? 1 : 0  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster_role[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  count = var.is_role_enabled ? 1 : 0  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster_role[0].name
}
```

---

## Terraform Configuration Issues

### Issue: Unsupported Argument in Node Group

#### Problem
`iam_instance_profile` argument used in `aws_eks_node_group` resource

#### Symptoms
- Terraform validation fails
- Error: "An argument named 'iam_instance_profile' is not expected here"

#### Solution

**Incorrect Configuration**:
```hcl
resource "aws_eks_node_group" "ondemand_nodes" {
  # ... other configuration ...
  iam_instance_profile = var.iam_instance_profile_name  # ❌ WRONG
  # ...
}
```

**Correct Configuration**:
```hcl
resource "aws_eks_node_group" "ondemand_nodes" {
  # ... other configuration ...
  node_role_arn = var.node_role_arn  # ✅ CORRECT
  # AWS automatically creates instance profile from role
  # ...
}
```

**Explanation**:
- `aws_eks_node_group` does NOT accept `iam_instance_profile` directly
- Use `node_role_arn` to specify the IAM role
- AWS automatically creates and manages the instance profile internally

### Issue: Duplicate Variables

#### Problem
Variables defined multiple times with conflicting types

#### Symptoms
- Terraform validation fails
- Variable type mismatch errors

#### Solution

**Audit Variables**:
```bash
# Check for duplicate variable definitions
grep -n "^variable" terraform/environments/dev/variables.tf | sort | uniq -d

# Check for conflicting types
grep -A 2 "^variable" terraform/environments/dev/variables.tf | grep -B 1 "type ="
```

**Fix**:
- Remove duplicate variable declarations
- Keep only one definition per variable
- Ensure consistent types across all files

### Issue: Missing Variable Values in terraform.tfvars

#### Problem
Variables declared but not provided values in terraform.tfvars

#### Symptoms
- Terraform apply fails
- Error: "No value for required variable"

#### Solution

**Identify Missing Values**:
```bash
# Compare variables.tf with terraform.tfvars
grep "^variable" terraform/environments/dev/variables.tf | \
  sed 's/variable "\(.*\)".*/\1/' | \
  while read var; do
    if ! grep -q "^$var =" terraform/environments/dev/terraform.tfvars; then
      echo "Missing: $var"
    fi
  done
```

**Add Missing Values**:
```hcl
# In terraform.tfvars, add all missing variables with appropriate values
variable_name = "value"
```

---

## Monitoring and Logging Issues

### Issue: EKS Control Plane Logging Not Fully Enabled

#### Problem
Not all control plane log types enabled

#### Symptoms
- Missing logs for troubleshooting
- Cannot audit cluster activity
- Compliance violations

#### Solution

**File**: `terraform/environments/dev/terraform.tfvars`

```hcl
# Enable all control plane log types
cluster_enabled_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]
```

**Verification**:
```bash
# Check enabled log types
aws eks describe-cluster \
  --name finishline-eks-cluster \
  --query 'cluster.logging.clusterLogging'

# Expected: All 5 log types should be enabled

# View logs in CloudWatch
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/eks/finishline-eks-cluster"

# Tail logs
aws logs tail /aws/eks/finishline-eks-cluster/cluster --follow
```

### Issue: No Visibility into Network Traffic

#### Problem
VPC Flow Logs not enabled for network monitoring

#### Symptoms
- Cannot troubleshoot connectivity issues
- No network traffic visibility
- Security incidents cannot be investigated

#### Solution

See [VPC Flow Logs Not Enabled](#issue-vpc-flow-logs-not-enabled) section above.

---

## General Debugging

### Terraform Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run terraform command
terraform plan

# View logs
tail -f terraform.log

# Disable debug logging
unset TF_LOG
unset TF_LOG_PATH
```

### AWS CLI Debugging

```bash
# Enable debug output
aws eks describe-cluster \
  --name finishline-eks-cluster \
  --debug

# Save output to file
aws eks describe-cluster \
  --name finishline-eks-cluster \
  > cluster-info.json

# Pretty print JSON
cat cluster-info.json | jq .
```

### Kubernetes Debugging

```bash
# Check cluster connectivity
kubectl cluster-info

# Check node status
kubectl get nodes -o wide

# Check pod status
kubectl get pods -A

# Describe problematic pod
kubectl describe pod <pod-name> -n <namespace>

# View pod logs
kubectl logs <pod-name> -n <namespace>

# Execute command in pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Check events
kubectl get events -A --sort-by='.lastTimestamp'
```

### Common Commands for Troubleshooting

```bash
# Check cluster status
aws eks describe-cluster \
  --name finishline-eks-cluster \
  --query 'cluster.status'

# Check node group status
aws eks describe-nodegroup \
  --cluster-name finishline-eks-cluster \
  --nodegroup-name finishline-eks-cluster-ondemand-nodes \
  --query 'nodegroup.status'

# Check node health
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Check CNI plugin
kubectl get daemonset -n kube-system

# Check metrics
kubectl top nodes
kubectl top pods -A

# Check persistent volumes
kubectl get pv
kubectl get pvc -A

# Check ingress
kubectl get ingress -A

# Check services
kubectl get svc -A
```

### Performance Troubleshooting

```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods -A

# Check node capacity
kubectl describe nodes | grep -A 5 "Allocated resources"

# Check for pod evictions
kubectl get events -A | grep Evicted

# Check for pending pods
kubectl get pods -A --field-selector=status.phase=Pending
```

### Security Troubleshooting

```bash
# Check RBAC permissions
kubectl auth can-i create pods --as=system:serviceaccount:default:default

# Check network policies
kubectl get networkpolicies -A

# Check pod security policies
kubectl get psp

# Check security groups
aws ec2 describe-security-groups \
  --group-ids <security-group-id>

# Check IAM roles
aws iam get-role \
  --role-name finishline-eks-cluster-nodegroup-role-XXXX
```

---

## Quick Reference

### Useful Commands

```bash
# Get cluster info
aws eks describe-cluster --name finishline-eks-cluster

# Get node groups
aws eks list-nodegroups --cluster-name finishline-eks-cluster

# Get nodes
kubectl get nodes -o wide

# Get pods
kubectl get pods -A

# Get events
kubectl get events -A --sort-by='.lastTimestamp'

# Get logs
kubectl logs <pod-name> -n <namespace>

# Describe resource
kubectl describe <resource-type> <resource-name> -n <namespace>

# SSH to node
ssh -i finishline-key.pem ec2-user@<node-private-ip>

# Port forward
kubectl port-forward <pod-name> <local-port>:<pod-port> -n <namespace>

# Execute command
kubectl exec -it <pod-name> -n <namespace> -- <command>
```

### Log Locations

**Jumphost Logs**:
```bash
/var/log/messages
/var/log/secure
```

**Node Logs**:
```bash
/var/log/messages
/var/log/kubelet.log
/var/log/pods/
```

**EKS Control Plane Logs**:
```bash
CloudWatch Logs: /aws/eks/finishline-eks-cluster/cluster
```

**VPC Flow Logs**:
```bash
CloudWatch Logs: /aws/vpc/flowlogs/finishline-infra-dev
```

---

## Support and Escalation

### When to Escalate

1. **Cluster Creation Fails**
   - Check IAM permissions
   - Verify VPC configuration
   - Check service quotas

2. **Nodes Not Joining**
   - Verify IAM roles and policies
   - Check security groups
   - Verify subnet configuration

3. **Pods Not Scheduling**
   - Check node capacity
   - Verify resource requests
   - Check node selectors and taints

4. **Network Connectivity Issues**
   - Check security groups
   - Verify route tables
   - Check NAT Gateway

### Contact Information

For issues or questions, contact the Platform Team.

---

**Last Updated**: March 11, 2025
**Version**: 1.0
**Status**: Complete
