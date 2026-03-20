#============================================================
#  ALB Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

# Dependency on VPC module
dependency "vpc" {
  config_path = "../vpc"
}

# Dependency on Security Group module (optional - for reference)
dependency "sg" {
  config_path = "../sg"
}

terraform {
  source = "../../../../modules//networking/alb"
}

inputs = {
  project_name = "finishline-infra-app"
  environment  = "dev"
  managed_by   = "finishline-infra-team"
  aws_region   = "us-east-1"

  # ALB Configuration
  alb_internal                   = false
  alb_load_balancer_type         = "application"
  enable_deletion_protection     = false
  enable_http2                   = true
  enable_cross_zone_load_balancing = true

  # VPC Configuration from VPC module
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.public_subnet_ids

  # Access Logs Configuration
  enable_access_logs      = false
  access_logs_s3_bucket   = ""
  access_logs_s3_prefix   = ""

  # Target Group Configuration
  target_group_port     = 80
  target_group_protocol = "HTTP"
  target_type           = "instance"

  # Health Check Configuration
  health_check_enabled      = true
  healthy_threshold         = 2
  unhealthy_threshold       = 3
  health_check_timeout      = 5
  health_check_interval     = 30
  health_check_path         = "/health"
  health_check_matcher      = "200"

  # Stickiness Configuration
  stickiness_type                   = "lb_cookie"
  stickiness_enabled                = false
  stickiness_cookie_duration        = 86400

  # Listener Configuration
  listener_port             = 80
  listener_protocol         = "HTTP"
  listener_default_action   = "forward"

  # ALB Security Group Ingress Rules
  ingress_rules = [
    {
      description = "HTTP ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # ALB Security Group Egress Rules (empty = allow all)
  egress_rules = []

  computed_tags = {}

}
