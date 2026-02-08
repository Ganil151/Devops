# 13. ALB Target Group (IP)
# flexible target group for manual IP addresses or microservices in Fargate.

resource "aws_lb_target_group" "ip_tg" {
  name        = "microservice-ip-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}
