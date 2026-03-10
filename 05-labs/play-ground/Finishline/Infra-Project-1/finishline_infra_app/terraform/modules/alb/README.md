# ALB Module — Application Load Balancer

**Module Path:** `terraform/modules/alb/`  
**Version:** 1.0.0  
**Terraform Version:** >= 1.6.0  
**AWS Provider Version:** ~> 6.0  

---

## Overview

This module provisions a **Shared Application Load Balancer (ALB)** for the Finish Line 2026 infrastructure project. The ALB is configured with the **AWS Load Balancer Controller IngressGroup mechanism** for Kubernetes ingress management.

### Assignment Requirements Compliance

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| Shared ALB | ✅ | Internet-facing ALB shared across namespaces |
| `group-tag=finishline` | ✅ | `ingress_group` variable (default: "finishline") |
| AWS LB Controller IngressGroup | ✅ | Tags: `elbv2.k8s.aws/cluster`, `ingress_group` |
| HTTP to HTTPS redirect | ✅ | Port 80 redirects to 443 |
| SSL/TLS termination | ✅ | ACM certificate ARN support |

---

## Architecture

```
                                    ┌─────────────────────────────────┐
                                    │         Internet                │
                                    └───────────────┬─────────────────┘
                                                    │
                                    ┌───────────────▼─────────────────┐
                                    │      Application Load           │
                                    │         Balancer (ALB)          │
                                    │  DNS: finishline-dev-alb-       │
                                    │       xxx.elb.us-east-1.amazonaws│
                                    └───────────────┬─────────────────┘
                                                    │
                    ┌───────────────────────────────┼───────────────────────────────┐
                    │                               │                               │
        ┌───────────▼───────────┐       ┌───────────▼───────────┐       ┌───────────▼───────────┐
        │   HTTP Listener       │       │   HTTPS Listener      │       │   Security Group      │
        │   Port 80             │       │   Port 443            │       │   - Port 80           │
        │   → Redirect 301      │       │   → ACM Cert          │       │   - Port 443          │
        │   → Port 443          │       │   → Target Groups     │       │   - All outbound      │
        └───────────────────────┘       └───────────────────────┘       └───────────────────────┘
                                                    │
                                    ┌───────────────▼─────────────────┐
                                    │     Default Target Group        │
                                    │     Port 80 (HTTP)              │
                                    │     Health Check: /             │
                                    └───────────────┬─────────────────┘
                                                    │
                    ┌───────────────────────────────┼───────────────────────────────┐
                    │                               │                               │
        ┌───────────▼───────────┐       ┌───────────▼───────────┐       ┌───────────▼───────────┐
        │  Kubernetes Service   │       │  Kubernetes Service   │       │  Kubernetes Service   │
        │  (via IngressGroup)   │       │  (via IngressGroup)   │       │  (via IngressGroup)   │
        └───────────────────────┘       └───────────────────────┘       └───────────────────────┘
```

---

## IngressGroup Mechanism

The ALB is configured for **AWS Load Balancer Controller IngressGroup** which allows multiple Kubernetes Ingress resources to share the same ALB.

### Required Kubernetes Annotations

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/group.name: finishline
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

### Key Annotations

| Annotation | Value | Description |
|------------|-------|-------------|
| `kubernetes.io/ingress.class` | `alb` | Use AWS ALB controller |
| `alb.ingress.kubernetes.io/group.name` | `finishline` | IngressGroup name (must match Terraform) |
| `alb.ingress.kubernetes.io/scheme` | `internet-facing` | Public ALB |
| `alb.ingress.kubernetes.io/target-type` | `ip` | Route to pod IPs |
| `alb.ingress.kubernetes.io/ssl-redirect` | `443` | Redirect HTTP to HTTPS |

---

## Resources Created

| Resource | Type | Description |
|----------|------|-------------|
| `aws_security_group.alb_sg` | Security Group | ALB security group (HTTP/HTTPS) |
| `aws_lb.main` | Application Load Balancer | Internet-facing ALB |
| `aws_lb_listener.http` | Listener | HTTP listener (port 80, redirects to HTTPS) |
| `aws_lb_listener.https` | Listener | HTTPS listener (port 443, optional) |
| `aws_lb_target_group.default` | Target Group | Default target group |
| `aws_cloudwatch_metric_alarm.alb_5xx` | CloudWatch Alarm | 5XX error monitoring (ALB) |
| `aws_cloudwatch_metric_alarm.target_5xx` | CloudWatch Alarm | 5XX error monitoring (Targets) |

---

## Usage

### Basic Example (HTTP Only)

```hcl
module "alb" {
  source = "../../modules/alb"

  project_name      = "finishline-infra"
  environment       = "dev"
  manage_by         = "Terraform"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  cluster_name      = "finishline-eks"
  ingress_group     = "finishline"
  
  certificate_arn = "" # HTTP only
}
```

### With SSL/TLS (HTTPS)

```hcl
module "alb" {
  source = "../../modules/alb"

  project_name      = "finishline-infra"
  environment       = "dev"
  manage_by         = "Terraform"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  cluster_name      = "finishline-eks"
  ingress_group     = "finishline"
  
  # ACM Certificate ARN
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxx-xxxx-xxxx"
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  
  # Enable access logs
  enable_access_logs   = true
  access_logs_bucket   = "finishline-alb-logs"
  access_logs_prefix   = "dev/alb"
}
```

---

## Variables

### Required

| Name | Type | Description |
|------|------|-------------|
| `project_name` | `string` | Project name for resource naming |
| `environment` | `string` | Environment name (dev, staging, prod) |
| `vpc_id` | `string` | VPC ID where ALB will be created |
| `public_subnet_ids` | `list(string)` | Public subnet IDs (minimum 2 for HA) |
| `cluster_name` | `string` | EKS cluster name for controller tagging |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `manage_by` | `string` | `"Terraform"` | Managing entity |
| `ingress_group` | `string` | `"finishline"` | IngressGroup name for LB controller |
| `certificate_arn` | `string` | `""` | ACM certificate ARN (empty = HTTP only) |
| `ssl_policy` | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | SSL policy |
| `deletion_protection` | `bool` | `false` | Enable ALB deletion protection |
| `idle_timeout` | `number` | `60` | Idle timeout in seconds |
| `enable_access_logs` | `bool` | `false` | Enable S3 access logs |
| `enable_5xx_alarm` | `bool` | `true` | Enable CloudWatch 5XX alarms |
| `additional_tags` | `map(string)` | `{}` | Additional tags |

---

## Outputs

| Name | Description |
|------|-------------|
| `alb_id` | ALB ID |
| `alb_arn` | ALB ARN |
| `alb_name` | ALB name |
| `alb_dns_name` | ALB DNS name |
| `alb_zone_id` | Route53 Zone ID for alias records |
| `security_group_id` | ALB security group ID |
| `http_listener_arn` | HTTP listener ARN |
| `https_listener_arn` | HTTPS listener ARN |
| `default_target_group_arn` | Default target group ARN |
| `ingress_group_name` | IngressGroup name |
| `kubernetes_annotations` | Map of Kubernetes annotations for Ingress |

---

## AWS Load Balancer Controller Installation

Before using IngressGroup, install the AWS Load Balancer Controller:

```bash
# Add helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=finishline-eks \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<VPC_ID>
```

---

## Security Considerations

### 1. Security Group Configuration

The ALB security group allows:
- **Ingress:** HTTP (80) and HTTPS (443) from `0.0.0.0/0`
- **Egress:** All traffic

For production, consider restricting ingress to specific CIDRs if possible.

### 2. SSL/TLS Best Practices

- Use ACM certificates for automatic renewal
- Use `ELBSecurityPolicy-TLS13-1-2-2021-06` for TLS 1.3 support
- Enable HTTP to HTTPS redirect (default behavior)

### 3. Deletion Protection

Enable `deletion_protection = true` for production environments to prevent accidental deletion.

### 4. Access Logs

Enable access logs for security auditing:

```hcl
enable_access_logs = true
access_logs_bucket = aws_s3_bucket.alb_logs.id
access_logs_prefix = "alb-logs"
```

---

## Troubleshooting

### Ingress Not Creating ALB Rules

1. Verify `ingress_group` matches between Terraform and Kubernetes
2. Check AWS LB Controller logs: `kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`
3. Verify cluster tag matches: `elbv2.k8s.aws/cluster`

### 5XX Errors

1. Check target health: AWS Console → EC2 → Target Groups
2. Verify security group allows traffic from ALB
3. Check application logs in CloudWatch

### Certificate Issues

1. Verify ACM certificate is in the same region as ALB
2. Ensure certificate domain matches Ingress host
3. Check certificate validation status

---

## References

- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [IngressGroup Specification](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/ingress_spec/#ingressgroup)
- [ALB Best Practices](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-best-practices.html)
- [Finish Line 2026 Assignment PDF §31, §62, §65]

---

## License

This module is part of the Finish Line 2026 Infrastructure Project.  
**Reporter:** Joseph Ndzoh Dong  
**Timeline:** Feb 26, 2026 – March 2, 2026
