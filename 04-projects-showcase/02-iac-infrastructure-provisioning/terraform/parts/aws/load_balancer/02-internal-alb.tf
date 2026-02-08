# 02. Internal Application Load Balancer
# Used for private microservices communication within the VPC.

resource "aws_lb" "internal_alb" {
  name               = "internal-app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_lb_sg_id]
  subnets            = var.private_subnet_ids

  tags = {
    Name = "Internal-ALB"
  }
}
