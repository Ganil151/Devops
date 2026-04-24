# ALB Module

Application Load Balancer (ALB) module for distributing traffic across EKS pods and services.

## Overview

This module creates and manages an AWS Application Load Balancer with:
- HTTP/HTTPS listeners
- Target groups for pod traffic
- Health checks
- Session stickiness
- Access logging (optional)
- Automatic HTTP to HTTPS redirect (optional)

## Architecture

```
Internet
    ↓
[ALB - Public Subnets]
    ↓
[Target Group - EKS Pods]
    ↓
[EKS Cluster - Private Subnets]
```

## Module Structure

```
alb/
├── main.tf          # ALB, target groups, listeners
├── variables.tf     # Input variables
├── local.tf         # Local values and tagging
├── output.tf        # Output values
└── README.md        # This file
```

## Usage

### Basic Configuration

```hcl
module "alb" {
  source = "../../modules/alb"

  project_name       = "finishline-infra"
  environment        = "dev"
  managedBy          = "finishline-infra-team"
  additional_tags    = {}

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = [module.security_group.sg_id]

  # ALB Configuration
  alb_internal                     = false
  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  # Target Group Configuration
  target_group_port     = 80
  target_group_protocol = "HTTP"
  target_type           = "ip"

  # Health Check Configuration
  health_check_enabled             = true
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  health_check_timeout             = 5
  health_check_interval            = 30
  health_check_path                = "/"
  health_check_matcher             = "200"

  # Listener Configuration
  listener_port     = 80
  listener_protocol = "HTTP"

  # Stickiness Configuration
  stickiness_enabled          = true
  stickiness_cookie_duration  = 86400

  # Deregistration Delay
  deregistration_delay = 30
}
```

### With HTTPS

```hcl
module "alb" {
  source = "../../modules/alb"

  # ... other configuration ...

  listener_port     = 80
  listener_protocol = "HTTP"
  ssl_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
}
```

### With Access Logs

```hcl
module "alb" {
  source = "../../modules/alb"

  # ... other configuration ...

  enable_access_logs      = true
  access_logs_s3_bucket   = "my-alb-logs-bucket"
  access_logs_s3_prefix   = "alb-logs"
}
```

## Inputs

### Project Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `project_name` | Project name | string | Yes |
| `environment` | Environment name (dev, staging, prod) | string | Yes |
| `managedBy` | Team managing resources | string | Yes |
| `additional_tags` | Additional tags for resources | map(string) | No |

### Network Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `vpc_id` | VPC ID for ALB | string | Yes |
| `public_subnet_ids` | Public subnet IDs for ALB | list(string) | Yes |
| `security_group_ids` | Security group IDs for ALB | list(string) | Yes |

### ALB Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `alb_name` | ALB name | string | `{project}-{environment}-alb` |
| `alb_internal` | Internal ALB | bool | `false` |
| `alb_load_balancer_type` | Load balancer type | string | `application` |
| `enable_deletion_protection` | Enable deletion protection | bool | `false` |
| `enable_http2` | Enable HTTP/2 | bool | `true` |
| `enable_cross_zone_load_balancing` | Cross-zone load balancing | bool | `true` |
| `enable_access_logs` | Enable access logs | bool | `false` |
| `access_logs_s3_bucket` | S3 bucket for logs | string | `` |
| `access_logs_s3_prefix` | S3 prefix for logs | string | `alb-logs` |

### Target Group Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `target_group_name` | Target group name | string | `{project}-{environment}-tg` |
| `target_group_port` | Target group port | number | `80` |
| `target_group_protocol` | Target group protocol | string | `HTTP` |
| `target_type` | Target type (instance, ip, lambda, alb) | string | `ip` |

### Health Check Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `health_check_enabled` | Enable health checks | bool | `true` |
| `health_check_healthy_threshold` | Healthy threshold | number | `2` |
| `health_check_unhealthy_threshold` | Unhealthy threshold | number | `2` |
| `health_check_timeout` | Health check timeout (seconds) | number | `5` |
| `health_check_interval` | Health check interval (seconds) | number | `30` |
| `health_check_path` | Health check path | string | `/` |
| `health_check_matcher` | HTTP status codes | string | `200` |

### Listener Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `listener_port` | Listener port | number | `80` |
| `listener_protocol` | Listener protocol | string | `HTTP` |
| `listener_default_action` | Default action | string | `forward` |
| `ssl_certificate_arn` | SSL certificate ARN | string | `` |

### Stickiness Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `stickiness_type` | Stickiness type | string | `lb_cookie` |
| `stickiness_enabled` | Enable stickiness | bool | `true` |
| `stickiness_cookie_duration` | Cookie duration (seconds) | number | `86400` |

### Deregistration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `deregistration_delay` | Deregistration delay (seconds) | number | `30` |

## Outputs

| Name | Description |
|------|-------------|
| `alb_id` | ALB ID |
| `alb_arn` | ALB ARN |
| `alb_dns_name` | ALB DNS name |
| `alb_zone_id` | ALB canonical hosted zone ID |
| `alb_security_groups` | ALB security groups |
| `target_group_id` | Target group ID |
| `target_group_arn` | Target group ARN |
| `target_group_name` | Target group name |
| `listener_http_arn` | HTTP listener ARN |
| `listener_https_arn` | HTTPS listener ARN (if configured) |
| `alb_endpoint` | ALB endpoint URL |

## Features

### Health Checks
- Configurable health check path, interval, and thresholds
- Automatic unhealthy target removal
- Customizable HTTP status code matching

### Session Stickiness
- Load balancer cookie-based stickiness
- Configurable cookie duration
- Ensures requests from same client go to same target

### HTTPS Support
- Optional HTTPS listener
- Automatic HTTP to HTTPS redirect
- SSL certificate management

### Access Logging
- Optional S3-based access logging
- Configurable S3 bucket and prefix
- Useful for security and compliance

### Cross-Zone Load Balancing
- Distributes traffic across availability zones
- Improves fault tolerance
- Enabled by default

## Integration with EKS

### Target Registration

Targets (EKS pods) are registered via:
1. **AWS Load Balancer Controller** - Automatically registers pods
2. **Manual registration** - For non-EKS targets

### Kubernetes Service Integration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

## Tagging Strategy

All resources are tagged with:
- `Project` - Project name
- `Environment` - Environment (dev, staging, prod)
- `ManagedBy` - Team managing resources
- `Module` - Module name (alb)
- `Name` - Resource name
- Additional custom tags

## Best Practices

1. **Health Checks** - Use appropriate health check paths and intervals
2. **Stickiness** - Enable for stateful applications
3. **Deregistration Delay** - Allow time for graceful shutdown
4. **Access Logs** - Enable for production environments
5. **HTTPS** - Use SSL certificates for secure communication
6. **Security Groups** - Restrict ALB access appropriately

## Troubleshooting

### Targets Unhealthy

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids <security-group-id>
```

### ALB Not Responding

```bash
# Check ALB status
aws elbv2 describe-load-balancers \
  --load-balancer-arns <alb-arn>

# Check listener configuration
aws elbv2 describe-listeners \
  --load-balancer-arn <alb-arn>
```

### High Latency

- Increase health check interval
- Adjust deregistration delay
- Check target capacity
- Monitor CloudWatch metrics

## References

- [AWS ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
