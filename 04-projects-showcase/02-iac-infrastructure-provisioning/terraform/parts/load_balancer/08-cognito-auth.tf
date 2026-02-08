# 08. ALB with Cognito Authentication
# Protecting the load balancer with user authentication at the edge.

resource "aws_lb_listener_rule" "protected_app" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = var.cognito_user_pool_arn
      user_pool_client_id = var.cognito_user_pool_client_id
      user_pool_domain    = var.cognito_domain
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/admin/*"]
    }
  }
}
