#============================================================
#  Terragrunt Configuration - Production Environment
#============================================================

# Include the root root.hcl for common configuration
include {
  path = find_in_parent_folders("root.hcl")
}

#============================================================
#  Production Environment Inputs
#============================================================

inputs = {
  # Project Configuration
  project_name = "finishline-infra"
  environment  = "production"
  managed_by       = true
  aws_region   = "us-east-1"

  # VPC Configuration (Different CIDR for production)
  vpc_cidr             = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  availability_zone    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidr   = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  private_subnet_cidr  = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]

  # Security Group Configuration
  security_group_name        = "finishline-sg-prod"
  security_group_description = "Security group for Finishline production infrastructure"

  ingress_rules = [
    {
      description = "Allow SSH from within VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.2.0.0/16"]
    },
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "EKS worker node communication"
      from_port   = 1025
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.2.0.0/16"]
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Key Pair Configuration
  key_name              = "finishline-key-prod"
  key_algorithm         = "RSA"
  rsa_bits              = 4096
  private_key_directory = "."
  private_key_filename  = "finishline-key-prod.pem"

  # IAM Configuration
  is_role_enabled               = true
  is_eks_nodegroup_role_enabled = true
  is_eks_cluster_enabled        = true
  oidc_namespace                = "kube-system"
  oidc_service_account          = "aws-node"
  s3_bucket_arn                 = ""
  s3_access_type                = "read"
  s3_prefix                     = ""

  # EKS Cluster Configuration
  cluster_name              = "finishline-eks-cluster-prod"
  cluster_version           = "1.35"
  cluster_enabled_log_types = ["api", "audit", "authenticator"]
  endpoint_private_access   = true
  endpoint_public_access    = false

  # EKS Node Group Configuration
  ami_type          = "BOTTLEROCKET_x86_64"
  cluster_disk_size = 50

  # On-Demand Node Group (Higher capacity for production)
  create_ondemand_nodegroup  = true
  desired_capacity_on_demand = 3
  min_capacity_on_demand     = 3
  max_capacity_on_demand     = 5
  ondemand_instance_types    = ["t3.large"]
  ondemand_taints            = []

  # Spot Node Group (Higher capacity for production)
  desired_capacity_on_spot = 2
  min_capacity_on_spot     = 1
  max_capacity_on_spot     = 4
  spot_instance_types      = ["t3.large", "t3.xlarge"]
  spot_taints              = []

  # ALB Configuration (Production-grade)
  alb_name                         = "finishline-prod-alb"
  alb_internal                     = false
  alb_load_balancer_type           = "application"
  enable_deletion_protection       = true
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  enable_access_logs               = true
  access_logs_s3_bucket            = "finishline-alb-logs-prod"
  access_logs_s3_prefix            = "alb-logs"

  # Target Group Configuration
  target_group_name     = "finishline-prod-tg"
  target_group_port     = 80
  target_group_protocol = "HTTP"
  target_type           = "ip"

  # Health Check Configuration
  health_check_enabled             = true
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 3
  health_check_timeout             = 5
  health_check_interval            = 30
  health_check_path                = "/"
  health_check_matcher             = "200"

  # Listener Configuration (HTTPS for production)
  listener_port            = 80
  listener_protocol        = "HTTP"
  listener_default_action  = "forward"
  ssl_certificate_arn      = ""  # Add production SSL certificate ARN

  # Stickiness Configuration
  stickiness_type             = "lb_cookie"
  stickiness_enabled          = true
  stickiness_cookie_duration  = 86400
  deregistration_delay        = 60

  # Bootstrap/Jumphost Configuration
  jumphost_instance_type = "t3.small"
  jumphost_name          = "finishline-jump-host-prod"

  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
    encrypted             = true
  }

  # Tags
  computed_tags   = {}
  additional_tags = {
    CostCenter = "Engineering"
    Compliance = "Required"
  }
}
