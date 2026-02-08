# 14. ALB with Stickiness (Cookies)
# Ensuring users stay connected to the same backend server.

resource "aws_lb_target_group" "sticky_tg" {
  name     = "sticky-session-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400 # 1 day
    enabled         = true
  }
}
