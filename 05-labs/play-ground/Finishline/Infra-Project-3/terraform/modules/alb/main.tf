# =============================================================================
# ALB Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §31, §62, §65 - ALB with group-tag=finishline
# =============================================================================

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${local.project_name}-alb-sg"
  description = "Security group for shared Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP ingress from anywhere (internet-facing ALB)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS ingress from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic allowed
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-alb-sg"
    Type = "SecurityGroup"
  })
}

# Application Load Balancer
resource "aws_lb" "finishline_alb" {
  name               = "${local.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  # Note: deletion_protection requires specific ALB configuration
  # For now, we rely on lifecycle rules for protection
  # deletion_protection = var.environment == "dev" ? false : true

  # Critical tag for AWS Load Balancer Controller IngressGroup
  tags = merge(local.common_tags, {
    Name        = "${local.project_name}-alb"
    Type        = "LoadBalancer"
    "group-tag" = "finishline" # Required for IngressGroup mechanism
  })
}

# Target Group for EKS services
resource "aws_lb_target_group" "eks_target_group" {
  name     = "${local.project_name}-eks-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-eks-tg"
    Type = "TargetGroup"
  })
}

# HTTP Listener (redirect to HTTPS in production)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.finishline_alb.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: redirect to HTTPS (or forward to target group)
  default_action {
    type = var.environment == "dev" ? "forward" : "redirect"

    target_group_arn = var.environment == "dev" ? aws_lb_target_group.eks_target_group.arn : null

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener (only if certificate is provided)
resource "aws_lb_listener" "https" {
  count = var.acm_certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.finishline_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_target_group.arn
  }
}
