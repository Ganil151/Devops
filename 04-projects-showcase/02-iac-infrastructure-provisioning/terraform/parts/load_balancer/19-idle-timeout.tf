# 19. ALB with Idle Timeout Configuration
# Adjusting how long the balancer keeps connections open.

resource "aws_lb" "custom_timeout_alb" {
  name               = "long-connection-lb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids

  idle_timeout = 300 # 5 minutes (Default is 60 seconds)
}
