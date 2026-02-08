# 20. Minimalist Load Balancer
# The baseline configuration for an application load balancer.

resource "aws_lb" "minimal" {
  name               = "baseline-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.minimal_sg_id]
}
