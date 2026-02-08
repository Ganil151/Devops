# 07. ALB Host-Based Routing
# Route requests to different services based on the domain name.

resource "aws_lb_listener_rule" "api_subdomain" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_service.arn
  }

  condition {
    host_header {
      values = ["api.example.com"]
    }
  }
}
