# =============================================================================
# ALB Module - Application Load Balancer
# Module: alb
# Assignment Reference: Finish Line 2026 §31, §62, §65
# - Shared Application Load Balancer (ALB)
# - Tagged with 'group-tag=finishline' for AWS LB Controller IngressGroup
# - Internet-facing with SSL/TLS termination
# =============================================================================

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # ALB name with environment prefix
  alb_name = "${var.project_name}-${var.environment}-alb"

  # Ingress group tag for AWS Load Balancer Controller
  ingress_group_tag = var.ingress_group

  # Merge default tags with additional tags
  tags = merge({
    Name        = local.alb_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
    # Critical tag for AWS LB Controller IngressGroup mechanism
    "elbv2.k8s.aws/cluster" = var.cluster_name
    "ingress_group"         = local.ingress_group_tag
  }, var.additional_tags)

  # Security group name
  sg_name = "${var.project_name}-${var.environment}-alb-sg"
}

# =============================================================================
# ALB Security Group
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
# =============================================================================

resource "aws_security_group" "alb_sg" {
  name        = local.sg_name
  description = "Security group for ${local.alb_name} - HTTP/HTTPS access"
  vpc_id      = var.vpc_id

  # HTTP ingress from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS ingress from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# =============================================================================
# Application Load Balancer
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html
# Assignment: §31, §62 (Internet-facing shared ALB)
# =============================================================================

resource "aws_lb" "main" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  # Enable HTTP/2
  enable_http2   = true
  enable_deletion_protection = var.deletion_protection

  # Drop invalid header fields
  drop_invalid_header_fields = true

  # Enable cross-zone load balancing
  enable_cross_zone_load_balancing = true

  # Idle timeout
  idle_timeout = var.idle_timeout

  # Desync mitigation mode
  desync_mitigation_mode = var.desync_mitigation_mode

  tags = local.tags

  # Access logs (optional)
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = var.enable_access_logs
    }
  }
}

# =============================================================================
# HTTP Listener (Port 80)
# Redirects to HTTPS by default
# =============================================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: Redirect to HTTPS
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.tags
}

# =============================================================================
# HTTPS Listener (Port 443)
# =============================================================================

resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  # Default action: Return 503 (no backend configured)
  # Ingress resources will add rules via IngressGroup mechanism
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable - No backend configured"
      status_code  = "503"
    }
  }

  tags = local.tags
}

# =============================================================================
# Target Group (Default)
# Used as fallback for listener rules
# =============================================================================

resource "aws_lb_target_group" "default" {
  name     = "${local.alb_name}-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-299"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  # Stickiness (disabled by default)
  stickiness {
    enabled  = false
    type     = "lb_cookie"
  }

  tags = local.tags
}

# =============================================================================
# Listener Rule: IngressGroup Support
# AWS Load Balancer Controller will manage ingress rules via tags
# Reference: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/ingress_spec/#ingressgroup
# =============================================================================

# Note: Actual ingress rules are managed by AWS Load Balancer Controller
# via Kubernetes Ingress resources with the following annotations:
#
# annotations:
#   kubernetes.io/ingress.class: alb
#   alb.ingress.kubernetes.io/group.name: ${var.ingress_group}
#   alb.ingress.kubernetes.io/scheme: internet-facing
#   alb.ingress.kubernetes.io/target-type: ip
#
# The controller will automatically:
# 1. Discover this ALB via the ingress_group tag
# 2. Create listener rules for each Ingress resource
# 3. Manage target groups for Kubernetes services

# =============================================================================
# CloudWatch Alarm for ALB 5XX Errors
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.enable_5xx_alarm ? 1 : 0

  alarm_name          = "${local.alb_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "ALB 5XX error rate exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = local.tags
}

# =============================================================================
# CloudWatch Alarm for ALB Target 5XX Errors
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  count = var.enable_5xx_alarm ? 1 : 0

  alarm_name          = "${local.alb_name}-target-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "Target 5XX error rate exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = local.tags
}
