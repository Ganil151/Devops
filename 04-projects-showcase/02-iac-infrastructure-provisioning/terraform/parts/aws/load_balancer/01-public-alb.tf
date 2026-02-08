# 01. Public Application Load Balancer (ALB)
# The standard choice for web applications with L7 routing.

resource "aws_lb" "public_alb" {
  name               = "external-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_lb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}
