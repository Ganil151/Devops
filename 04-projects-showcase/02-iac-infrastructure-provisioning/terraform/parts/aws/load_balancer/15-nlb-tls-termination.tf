# 15. NLB with TLS Termination
# handling SSL/TLS encryption at the L4 load balancer level.

resource "aws_lb_listener" "nlb_tls" {
  load_balancer_arn = aws_lb.public_nlb.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}
