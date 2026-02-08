# 10. ALB Access Logs to S3
# enabling detailed access logging for audit and troubleshooting.

resource "aws_lb" "logged_alb" {
  name               = "logged-lb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids

  access_logs {
    bucket  = var.logs_bucket_name
    prefix  = "alb-logs"
    enabled = true
  }
}
