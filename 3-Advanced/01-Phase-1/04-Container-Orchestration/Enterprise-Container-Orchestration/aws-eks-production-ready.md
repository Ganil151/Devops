# AWS EKS Production-Ready Guide

Amazon Elastic Kubernetes Service (EKS) is a managed service that you can use to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane or nodes.

## 1. Cluster Setup: `eksctl` vs. Terraform

For production, you should use Infrastructure as Code (IaC) to manage your clusters.

- **eksctl**: The official CLI tool for EKS. Great for quick setups and standard patterns.
- **Terraform**: Preferred for enterprise-grade, multi-account, and complex architectures.

### Quick Setup with `eksctl`
```yaml
# cluster-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: production-cluster
  region: us-east-1

managedNodeGroups:
  - name: standard-nodes
    instanceType: t3.medium
    minSize: 2
    maxSize: 5
    desiredCapacity: 2
    volumeSize: 20
    ssh:
      allow: true
```

```bash
eksctl create cluster -f cluster-config.yaml
```

## 2. IAM Roles for Service Accounts (IRSA)

The **Best Practice** for giving Kubernetes pods access to AWS resources. Instead of hardcoding credentials, you assign an IAM role directly to a Kubernetes ServiceAccount.

1. **OIDC Provider**: Enable IAM OIDC provider for your cluster.
2. **IAM Role**: Create a role with a trust policy that allows the OIDC provider to assume it.
3. **ServiceAccount**: Annotate the Kubernetes ServiceAccount with the IAM Role ARN.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-app-role
```

## 3. Networking & Load Balancing

### AWS Load Balancer Controller
An open-source controller that manages Elastic Load Balancers for a Kubernetes cluster.
- **Ingress**: Provisions an Application Load Balancer (ALB).
- **Service Type LoadBalancer**: Provisions a Network Load Balancer (NLB).

### VPC CNI
The default networking plugin for EKS. It assigns real VPC IP addresses to each Kubernetes pod, enabling high performance and easy integration with security groups.

## 4. Observability: Container Insights & FluentBit

- **CloudWatch Container Insights**: Collects, aggregates, and summarizes metrics and logs from your containerized applications.
- **AWS Distro for OpenTelemetry (ADOT)**: (Recommended) Provides a secure, AWS-supported distribution for metrics and traces.
- **FluentBit**: The standard for log shipping in EKS, sending logs from nodes and pods directly to CloudWatch Logs or S3.

## 5. Security Best Practices

- **Private Endpoints**: Disable public access to the Kubernetes API server; use a Bastion host or VPN to manage the cluster.
- **Node Security**: Use Amazon Linux 2 EKS-Optimized AMIs and keep nodes in private subnets.
- **Pod Security Admission**: Replace Pod Security Policies (PSP) with the native Kubernetes admission controller.
- **Network Policies**: Use Calico or the AWS VPC CNI Network Policy support to restrict pod-to-pod communication.

## 6. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **Nodes stuck in NotReady** | Communication failure between nodes and control plane | Check security groups for port 10250 and 443; verify NAT Gateway for private nodes. |
| **Pod stuck in ImagePullBackOff** | ECR permission missing or incorrect image path | Verify IRSA or Node Role has `ecr:GetDownloadUrlForLayer`. |
| **ALB not provisioning** | AWS LB Controller not installed or misconfigured | Check the LB Controller logs; ensure subnets have `kubernetes.io/cluster/<cluster-name>: shared` tag. |
| **OIDC errors** | Mismatch between OIDC provider and IAM Role trust policy | Re-verify the OIDC URL and the `sub` claim in the trust policy. |

---
**Next Step**: Learn how to monitor everything together in the [AWS X-Ray Observability Guide](../../Advanced-Level/17-Observability-Governance/aws-xray-observability.md)
