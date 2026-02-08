# 06. ALB Path-Based Routing
# Route requests to different services based on the URL path.

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.static_assets.arn
  }

  condition {
    path_pattern {
      values = ["/static/*", "/images/*"]
    }
  }
}
