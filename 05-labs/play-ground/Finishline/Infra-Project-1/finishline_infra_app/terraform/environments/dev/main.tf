# =============================================================================
# Main Configuration: dev Environment
# Project: Finish Line 2026 Infrastructure
# Assignment Reference: Finish Line 2026 §2, §21 (Target: us-east-1)
# Reporter: Joseph Ndzoh Dong
# Timeline: Feb 26, 2026 – March 2, 2026
# =============================================================================

# =============================================================================
# VPC Module
# Reference: terraform/modules/vpc/
# Assignment: §51, §55, §56, §57 (3 subnets across 3 AZs with IGW, Route Tables)
# =============================================================================

module "finishline_vpc" {
  source = "../../modules/vpc"

  project_name          = var.project_name
  aws_region            = var.aws_region
  environment           = var.environment
  manage_by             = var.manage_by
  vpc_cidr              = var.vpc_cidr
  enable_dns_support    = var.enable_dns_support
  enable_dns_hostnames  = var.enable_dns_hostnames
  public_subnets_cidrs  = var.public_subnets_cidrs
  availability_zones    = var.availability_zones
  private_subnets_cidrs = var.private_subnets_cidrs
}

# =============================================================================
# Security Group Module
# Reference: terraform/modules/security_group/
# Assignment: §69, §70, §73 (SSH restricted to home IP CIDRs)
# =============================================================================

module "finishline_sg" {
  source = "../../modules/security_group"

  project_name               = var.project_name
  vpc_id                     = module.finishline_vpc.vpc_id
  vpc_cidr                   = var.vpc_cidr
  environment                = var.environment
  manage_by                  = var.manage_by
  ingress_rules              = var.ingress_rules
  egress_rules               = var.egress_rules
  additional_tags            = var.additional_sg_tags
  security_group_name        = var.security_group_name
  security_group_description = var.security_group_description
}

# =============================================================================
# Key Pair Module
# Reference: terraform/modules/secret/key_pair/
# Assignment: §71, §73 (Terraform-managed SSH keypairs)
# =============================================================================

module "finishline_key_pair" {
  source = "../../modules/secret/key_pair"

  key_name              = var.key_name
  project_name          = var.project_name
  environment           = var.environment
  manage_by             = var.manage_by
  key_algorithm         = var.key_algorithm
  rsa_bits              = var.rsa_bits
  private_key_directory = var.private_key_directory
  private_key_filename  = var.private_key_filename
  file_permission       = var.file_permission
  additional_tags       = var.additional_tags

  # Pass computed local values from local.tf
  computed_private_key_filename = local.key_pair_private_key_filename
  computed_private_key_path     = local.key_pair_private_key_path
  computed_tags                 = local.key_pair_tags
}

# =============================================================================
# IAM Module (EKS Roles and OIDC)
# Reference: terraform/modules/secret/iam/
# Assignment: §83, §84, §87, §89 (EKS IAM/RBAC integration)
# =============================================================================

module "finishline_iam" {
  source = "../../modules/secret/iam"

  project_name                  = var.project_name
  aws_region                    = var.aws_region
  environment                   = var.environment
  manage_by                     = var.manage_by
  cluster_name                  = var.cluster_name
  is_eks_role_enabled           = var.is_eks_role_enabled
  is_eks_nodegroup_role_enabled = var.is_eks_nodegroup_role_enabled
  is_eks_cluster_enabled        = var.is_eks_cluster_enabled
  eks_oidc_url                  = var.eks_oidc_url
  oidc_thumbprint               = var.oidc_thumbprint
  s3_bucket_arn                 = var.s3_bucket_arn
  additional_tags               = var.iam_additional_tags
}

# =============================================================================
# Jumphost IAM Role (for EKS authentication via RBAC)
# Assignment: §83, §84, §87, §89 (IAM role for Jumphost with EKS access)
# =============================================================================

resource "aws_iam_role" "jumphost_role" {
  name = "${var.project_name}-${var.environment}-jumphost-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-jumphost-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }
}

# IAM policy for EKS cluster access (least-privilege - scoped to Finishline cluster only)
resource "aws_iam_role_policy" "jumphost_eks_access" {
  name = "${var.project_name}-${var.environment}-jumphost-eks-access"
  role = aws_iam_role.jumphost_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "arn:aws:eks:*:*:cluster/${var.cluster_name}"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jumphost_profile" {
  name = "${var.project_name}-${var.environment}-jumphost-profile"
  role = aws_iam_role.jumphost_role.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-jumphost-profile"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }
}

# =============================================================================
# Bootstrap (Jumphost) Module
# Reference: terraform/modules/bootstrap/
# Assignment: §69, §70, §73 (Amazon Linux 2023, SSH restricted, tool installation)
# =============================================================================

module "jumphost" {
  source = "../../modules/bootstrap"

  project_name              = var.project_name
  environment               = var.environment
  manage_by                 = var.manage_by
  availability_zone         = var.jumphost_availability_zone
  ami_id                    = var.jumphost_ami_id
  instance_type             = var.jumphost_instance_type
  root_volume_size          = var.jumphost_root_volume_size
  root_volume_iops          = var.jumphost_root_volume_iops
  public_subnet_ids         = module.finishline_vpc.public_subnet_ids
  security_group_id         = module.finishline_sg.security_group_id
  key_name                  = module.finishline_key_pair.key_name
  iam_instance_profile_name = aws_iam_instance_profile.jumphost_profile.name
  user_data_base64          = local.jumphost_user_data
  additional_tags           = var.jumphost_additional_tags
}

# =============================================================================
# ALB Module
# Reference: terraform/modules/alb/
# Assignment: §31, §62, §65 (Shared ALB with group-tag=finishline, IngressGroup)
# =============================================================================

module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  manage_by         = var.manage_by
  vpc_id            = module.finishline_vpc.vpc_id
  public_subnet_ids = module.finishline_vpc.public_subnet_ids
  cluster_name      = var.cluster_name
  ingress_group     = var.alb_ingress_group

  # SSL/TLS Configuration (optional - set certificate_arn for HTTPS)
  certificate_arn = var.alb_certificate_arn
  ssl_policy      = var.alb_ssl_policy

  # ALB Configuration
  deletion_protection    = var.alb_deletion_protection
  idle_timeout           = var.alb_idle_timeout
  desync_mitigation_mode = var.alb_desync_mitigation_mode

  # Access Logs (optional)
  enable_access_logs = var.alb_enable_access_logs
  access_logs_bucket = var.alb_access_logs_bucket
  access_logs_prefix = var.alb_access_logs_prefix

  # CloudWatch Alarms
  enable_5xx_alarm  = var.alb_enable_5xx_alarm
  alb_5xx_threshold = var.alb_5xx_threshold

  additional_tags = var.alb_additional_tags
}

# =============================================================================
# EKS Module
# Reference: terraform/modules/eks/
# Assignment: §74, §75, §76, §79 (2x t3.medium, Bottlerocket AMI)
# Note: Disabled by default. Set is_eks_module_enabled = true to deploy.
# =============================================================================

module "finishline_eks" {
  count  = var.is_eks_module_enabled ? 1 : 0
  source = "../../modules/eks"

  project_name    = var.project_name
  environment     = var.environment
  manage_by       = var.manage_by
  aws_region      = var.aws_region
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # IAM Roles (from secret/iam module)
  cluster_role_arn = module.finishline_iam.eks_cluster_role_arn
  node_role_arn    = module.finishline_iam.eks_nodegroup_role_arn

  # VPC Configuration
  subnet_ids         = module.finishline_vpc.private_subnet_ids
  security_group_ids = [module.finishline_sg.security_group_id]

  # Cluster Access
  authentication_mode                         = "CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true
  endpoint_private_access                     = var.endpoint_private_access
  endpoint_public_access                      = var.endpoint_public_access
  cluster_enabled_log_types                   = var.cluster_enabled_log_types

  # Node Group Configuration
  is_eks_node_group_enabled  = var.is_eks_node_group_enabled
  desired_capacity_on_demand = var.desired_capacity_on_demand
  min_capacity_on_demand     = var.min_capacity_on_demand
  max_capacity_on_demand     = var.max_capacity_on_demand
  ondemand_instance_types    = var.ondemand_instance_types
  desired_capacity_spot      = var.desired_capacity_spot
  min_capacity_spot          = var.min_capacity_spot
  max_capacity_spot          = var.max_capacity_spot
  spot_instance_types        = var.spot_instance_types

  # EKS Addons
  is_eks_addons_enabled = var.is_eks_addons_enabled
  addons                = var.addons

  additional_tags = var.eks_additional_tags

  # Ensure IAM module is deployed first
  depends_on = [module.finishline_iam]
}
