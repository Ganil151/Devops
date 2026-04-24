# =============================================================================
# Outputs: staging Environment
# Finish Line 2026 Infrastructure
# =============================================================================

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.main_vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.main_public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.main_private_subnet_ids
}

# ALB Outputs
output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "EKS node group name"
  value       = module.eks.node_group_name
}

# Jumphost Outputs
output "jumphost_public_ip" {
  description = "Jumphost public IP"
  value       = module.jumphost.jumphost_public_ip
}

output "jumphost_ssh_command" {
  description = "SSH command to connect to jumphost"
  value       = module.jumphost.ssh_command
}

# IAM Outputs
output "jumphost_role_name" {
  description = "Jumphost IAM role name"
  value       = module.iam.jumphost_role_name
}
