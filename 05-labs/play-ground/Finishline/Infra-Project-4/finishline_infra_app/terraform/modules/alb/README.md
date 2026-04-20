# ALB (Application Load Balancer) Module

## Overview

The ALB module is a **placeholder** for Application Load Balancer resources. It is intended to manage AWS ALB for ingress traffic to the EKS cluster, including target groups, listeners, and rules.

## Status

⚠️ **Placeholder** - This module is not yet implemented.

## Planned Functionality

### Resources to be Created

| Resource Type | Description |
|--------------|-------------|
| `lb` | Application Load Balancer |
| `lb_target_group` | Target groups for backend services |
| `lb_listener` | Listeners for HTTP/HTTPS traffic |
| `lb_listener_rule` | Routing rules for paths/hosts |
| `security_group` | ALB security group |

### Planned Features

1. **Load Balancer Configuration**
   - Internet-facing or internal ALB
   - HTTP and HTTPS listeners
   - SSL/TLS termination
   - Health check configuration

2. **Target Group Management**
   - IP-based or instance-based targets
   - Custom health check paths
   - Stickiness configuration
   - Connection draining

3. **Listener Rules**
   - Path-based routing
   - Host-based routing
   - Header-based routing
   - Redirect rules

4. **Security**
   - Security group configuration
   - ACM certificate integration
   - WAF integration (optional)

## Dependencies

- **VPC Module**: Requires VPC and subnet IDs
- **SG Module**: Requires security group configuration
- **EKS Module**: Requires cluster for target registration
- **ACM**: SSL certificates for HTTPS

## Planned Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| `project_name` | `string` | Name of the project | Yes |
| `environment` | `string` | Environment name | Yes |
| `manage_by` | `bool` | Whether managed by Terraform | Yes |
| `vpc_id` | `string` | VPC ID for ALB | Yes |
| `subnet_ids` | `list(string)` | Subnet IDs for ALB placement | Yes |
| `alb_name` | `string` | Name of the ALB | Yes |
| `is_internal` | `bool` | Internal or internet-facing | No |
| `certificate_arn` | `string` | ACM certificate ARN for HTTPS | No |
| `security_group_ids` | `list(string)` | Security group IDs | Yes |
| `target_groups` | `map(object)` | Target group configurations | No |
| `listeners` | `map(object)` | Listener configurations | No |
| `rules` | `map(object)` | Listener rule configurations | No |

## Planned Outputs

| Name | Description |
|------|-------------|
| `alb_id` | ALB ID |
| `alb_arn` | ALB ARN |
| `alb_dns_name` | ALB DNS name |
| `alb_zone_id` | ALB Zone ID |
| `target_group_arns` | Map of target group ARNs |
| `listener_arns` | Map of listener ARNs |

## Usage Example (Planned)

```hcl
module "alb" {
  source = "./modules/alb"

  project_name     = "finishline-infra"
  environment      = "development"
  manage_by        = true
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  security_group_ids = [module.sg.security_group_id]

  alb_name        = "finishline-alb"
  is_internal     = false
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"

  target_groups = {
    "api" = {
      port        = 80
      protocol    = "HTTP"
      health_path = "/health"
      target_type = "ip"
    },
    "web" = {
      port        = 80
      protocol    = "HTTP"
      health_path = "/"
      target_type = "ip"
    }
  }

  listeners = {
    "https" = {
      port     = 443
      protocol = "HTTPS"
      ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
    },
    "http_redirect" = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port     = "443"
        protocol = "HTTPS"
        status   = "HTTP_301"
      }
    }
  }

  rules = {
    "api" = {
      listener     = "https"
      priority     = 100
      conditions   = [{ path_pattern = "/api/*" }]
      target_group = "api"
    },
    "web" = {
      listener     = "https"
      priority     = 200
      conditions   = [{ path_pattern = "/*" }]
      target_group = "web"
    }
  }
}
```

## Implementation Notes

### ALB Configuration

```hcl
resource "aws_lb" "main" {
  name               = var.alb_name
  internal           = var.is_internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false
  drop_invalid_header_fields = true
  enable_http2              = true
}
```

### Target Group Configuration

```hcl
resource "aws_lb_target_group" "main" {
  name     = "${var.alb_name}-${tg_name}"
  port     = tg_config.port
  protocol = tg_config.protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = tg_config.health_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    enabled         = tg_config.stickiness_enabled
    cookie_duration = tg_config.stickiness_duration
    type            = "lb_cookie"
  }
}
```

## Security Considerations

1. **Security Groups**: Restrict inbound traffic to HTTP/HTTPS only
2. **SSL/TLS**: Use strong cipher suites and TLS 1.2+
3. **WAF**: Consider AWS WAF for application-layer protection
4. **Logging**: Enable access logs for audit and troubleshooting
5. **Internal ALB**: Use internal ALB for private services

## ALB vs. AWS Load Balancer Controller

| Feature | ALB Module | AWS Load Balancer Controller |
|---------|-----------|------------------------------|
| Management | Terraform | Kubernetes Ingress resources |
| Use Case | Static, infrastructure-level ALBs | Dynamic, application-level ALBs |
| Deployment | Pre-provisioned | On-demand via Ingress |
| Best For | Shared ALBs, centralized routing | Per-namespace/service ALBs |

**Recommendation**: Use this module for shared infrastructure ALBs. For application-specific ingress, use the AWS Load Balancer Controller with Kubernetes Ingress resources.

## Next Steps

1. Implement core ALB resources
2. Add target group support
3. Create listener and rule configurations
4. Add ACM certificate integration
5. Implement access logging
6. Add WAF integration option
7. Write comprehensive tests

## Related Modules

- [VPC Module](../vpc/README.md) - VPC and subnets
- [SG Module](../sg/README.md) - Security groups
- [EKS Module](../eks/README.md) - EKS cluster
- [Jumphost Module](../jumphost/README.md) - Bastion host access
