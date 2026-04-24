#============================================================
#  ALB Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//alb"
}

inputs = {
  project_name    = "finishline-infra"
  environment     = "development"
  manage_by      = true
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # ALB Configuration
  alb_name                         = "finishline-dev-alb"
  alb_internal                     = false
  alb_load_balancer_type           = "application"
  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  enable_access_logs               = false
  access_logs_s3_bucket            = ""
  access_logs_s3_prefix            = "alb-logs"

  # Target Group Configuration
  target_group_name     = "finishline-dev-tg"
  target_group_port     = 80
  target_group_protocol = "HTTP"
  target_type           = "ip"

  # Health Check Configuration
  health_check_enabled             = true
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  health_check_timeout             = 5
  health_check_interval            = 30
  health_check_path                = "/"
  health_check_matcher             = "200"

  # Listener Configuration
  listener_port            = 80
  listener_protocol        = "HTTP"
  listener_default_action  = "forward"
  ssl_certificate_arn      = ""

  # Stickiness Configuration
  stickiness_type             = "lb_cookie"
  stickiness_enabled          = true
  stickiness_cookie_duration  = 86400
  deregistration_delay        = 30

  # VPC and Subnet IDs
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.public_subnet_ids
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "mock-vpc-id"
    public_subnet_ids  = ["mock-subnet-1", "mock-subnet-2"]
  }
}

dependencies {
  paths = ["../vpc"]
}
