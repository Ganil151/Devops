# =============================================================================
# Main Configuration: dev Environment
# Project: FinishLine Infra
# =============================================================================

# VPC Module
module "finishline_vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  project_name         = var.project_name
  environment          = var.environment
  managedBy            = var.managedBy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  aws_region           = var.aws_region
  availability_zone    = var.availability_zone
}

# Security Group Module
module "finishline_sg" {
  source = "../../modules/security_group"

  vpc_id                     = module.finishline_vpc.vpc_id
  project_name               = var.project_name
  environment                = var.environment
  managedBy                  = var.managedBy
  ingress_rules              = var.ingress_rules
  egress_rules               = var.egress_rules
  security_group_name        = var.security_group_name
  security_group_description = var.security_group_description
}

# ALB Module
module "finishline_alb" {
  source = "../../modules/alb"

  project_name    = var.project_name
  environment     = var.environment
  managedBy       = var.managedBy
  additional_tags = var.additional_tags

  vpc_id             = module.finishline_vpc.vpc_id
  public_subnet_ids  = module.finishline_vpc.public_subnet_id
  security_group_ids = [module.finishline_sg.finishline_sg_id]

  alb_internal                     = var.alb_internal
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_access_logs               = var.enable_access_logs
  access_logs_s3_bucket            = var.access_logs_s3_bucket
  access_logs_s3_prefix            = var.access_logs_s3_prefix

  target_group_port     = var.target_group_port
  target_group_protocol = var.target_group_protocol
  target_type           = var.target_type

  health_check_enabled             = var.health_check_enabled
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_timeout             = var.health_check_timeout
  health_check_interval            = var.health_check_interval
  health_check_path                = var.health_check_path
  health_check_matcher             = var.health_check_matcher

  listener_port       = var.listener_port
  listener_protocol   = var.listener_protocol
  ssl_certificate_arn = var.ssl_certificate_arn

  stickiness_type            = var.stickiness_type
  stickiness_enabled         = var.stickiness_enabled
  stickiness_cookie_duration = var.stickiness_cookie_duration

  deregistration_delay = var.deregistration_delay

  depends_on = [module.finishline_vpc, module.finishline_sg]
}

# Key Pair Module
module "finishline_key" {
  source = "../../modules/secret/key_pair"

  project_name          = var.project_name
  environment           = var.environment
  managedBy             = var.managedBy
  key_name              = var.key_name
  key_algorithm         = var.key_algorithm
  rsa_bits              = var.rsa_bits
  private_key_filename  = var.private_key_filename
  private_key_directory = var.private_key_directory
  computed_tags         = var.computed_tags
  additional_tags       = var.additional_tags
}

# IAM Module
module "finishline_iam" {
  source = "../../modules/secret/iam"

  project_name                  = var.project_name
  environment                   = var.environment
  managedBy                     = var.managedBy
  cluster_name                  = var.cluster_name
  additional_tags               = var.additional_tags
  is_role_enabled               = var.is_role_enabled
  is_eks_nodegroup_role_enabled = var.is_eks_nodegroup_role_enabled
  is_eks_cluster_enabled        = false
  eks_oidc_url                  = ""
  oidc_thumbprint               = []
  oidc_namespace                = var.oidc_namespace
  oidc_service_account          = var.oidc_service_account
  s3_bucket_arn                 = var.s3_bucket_arn
  s3_access_type                = var.s3_access_type
  s3_prefix                     = var.s3_prefix
}

# EKS Module
module "finishline_eks" {
  source = "../../modules/eks"

  project_name               = var.project_name
  environment                = var.environment
  managedBy                  = var.managedBy
  cluster_name               = var.cluster_name
  ami_type                   = var.ami_type
  cluster_disk_size          = var.cluster_disk_size
  additional_tags            = var.additional_tags
  is_eks_cluster_enabled     = var.is_eks_cluster_enabled
  cluster_version            = var.cluster_version
  cluster_enabled_log_types  = var.cluster_enabled_log_types
  cluster_role_arn           = module.finishline_iam.eks_cluster_role_arn
  node_role_arn              = module.finishline_iam.eks_nodegroup_role_arn
  iam_instance_profile_name  = module.finishline_iam.eks_nodegroup_instance_profile_name
  subnet_ids                 = module.finishline_vpc.private_subnet_id
  security_group_ids         = [module.finishline_sg.finishline_sg_id]
  endpoint_private_access    = var.endpoint_private_access
  endpoint_public_access     = var.endpoint_public_access
  create_ondemand_nodegroup  = var.create_ondemand_nodegroup
  desired_capacity_on_demand = var.desired_capacity_on_demand
  min_capacity_on_demand     = var.min_capacity_on_demand
  max_capacity_on_demand     = var.max_capacity_on_demand
  ondemand_instance_types    = var.ondemand_instance_types
  desired_capacity_on_spot   = var.desired_capacity_on_spot
  min_capacity_on_spot       = var.min_capacity_on_spot
  max_capacity_on_spot       = var.max_capacity_on_spot
  spot_instance_types        = var.spot_instance_types
  ondemand_taints            = var.ondemand_taints
  spot_taints                = var.spot_taints

  depends_on = [module.finishline_iam]
}

# Bootstrap Jumphost Module
module "finishline_bootstrap" {
  source = "../../modules/bootstrap"

  project_name              = var.project_name
  environment               = var.environment
  managedBy                 = var.managedBy
  jumphost_name             = var.jumphost_name
  jumphost_instance_type    = var.jumphost_instance_type
  key_name                  = var.key_name
  subnet_ids                = module.finishline_vpc.public_subnet_id
  security_group_ids        = [module.finishline_sg.finishline_sg_id]
  iam_instance_profile_name = ""
  additional_tags           = var.additional_tags

  depends_on = [module.finishline_vpc, module.finishline_sg, module.finishline_key]
}
