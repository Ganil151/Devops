# 18. Dual-Stack Load Balancer (IPv4/IPv6)
# supporting both modern IPv6 and legacy IPv4 clients.

resource "aws_lb" "dual_stack_alb" {
  name               = "dual-stack-lb"
  load_balancer_type = "application"
  ip_address_type    = "dualstack"
  subnets            = var.public_subnet_ids
  security_groups    = [var.public_lb_sg_id]
}
