#============================================================
#  ALB Resource
#============================================================

resource "aws_lb" "finishline_alb" {
  name               = "${local.project_name}-alb"
  internal           = var.alb_internal
  load_balancer_type = var.alb_load_balancer_type
  security_groups    = [aws_security_group.finishline_alb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  access_logs {
    bucket  = var.enable_access_logs ? var.access_logs_s3_bucket : ""
    prefix  = var.enable_access_logs ? var.access_logs_s3_prefix : ""
    enabled = var.enable_access_logs
  }

  tags = merge(local.common_tags, {
    Name        = "${local.project_name}-alb"
    Environment = var.environment
  })
}

#============================================================
#  Target Group
#============================================================

resource "aws_lb_target_group" "finishline_alb_tg" {
  name        = "${local.project_name}-tg"
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

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name        = "${local.project_name}-tg"
    Environment = var.environment
  })
}

#============================================================
#  ALB Listener
#============================================================

resource "aws_lb_listener" "finishline_alb_listener" {
  load_balancer_arn = aws_lb.finishline_alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = var.listener_default_action
    target_group_arn = aws_lb_target_group.finishline_alb_tg.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

#============================================================
#  Security Group for ALB
#============================================================

resource "aws_security_group" "finishline_alb_sg" {
  name        = "${local.project_name}-alb-sg"
  description = "Security group for ALB ${local.project_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name        = "${local.project_name}-alb-sg"
    Environment = var.environment
  })
}
