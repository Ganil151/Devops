#==============================================================
# Application Load Balancer
#==============================================================
resource "aws_lb" "alb" {
  name               = local.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.alb_load_balancer_type
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_s3_bucket
      prefix  = var.access_logs_s3_prefix
      enabled = true
    }
  }

  tags = local.alb_tags
}

#==============================================================
# Target Group
#==============================================================
resource "aws_lb_target_group" "alb_tg" {
  name        = local.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = var.health_check_matcher
  }

  stickiness {
    type            = var.stickiness_type
    enabled         = var.stickiness_enabled
    cookie_duration = var.stickiness_cookie_duration
  }

  deregistration_delay = var.deregistration_delay

  tags = local.target_group_tags

  lifecycle {
    create_before_destroy = true
  }
}

#==============================================================
# ALB Listener - HTTP
#==============================================================
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = var.listener_default_action
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  tags = local.alb_tags
}

#==============================================================
# ALB Listener - HTTPS (Optional)
#==============================================================
resource "aws_lb_listener" "alb_listener_https" {
  count = var.ssl_certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = var.listener_default_action
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  tags = local.alb_tags
}

#==============================================================
# HTTP to HTTPS Redirect (Optional)
#==============================================================
resource "aws_lb_listener_rule" "http_to_https_redirect" {
  count = var.ssl_certificate_arn != "" ? 1 : 0

  listener_arn = aws_lb_listener.alb_listener_http.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
