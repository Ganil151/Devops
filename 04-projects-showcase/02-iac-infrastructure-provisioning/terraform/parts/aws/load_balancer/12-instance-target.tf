# 12. ALB Target Group (Instance)
# Standard target group for EC2 instances.

resource "aws_lb_target_group" "instance_tg" {
  name     = "app-instance-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance_attach" {
  target_group_arn = aws_lb_target_group.instance_tg.arn
  target_id        = var.ec2_instance_id
  port             = 80
}
