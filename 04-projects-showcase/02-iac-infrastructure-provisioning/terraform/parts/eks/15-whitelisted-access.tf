# 15. EKS with Private Access Control
# Limiting API server access to specific public IP CIDRs.

resource "aws_eks_cluster" "whitelisted_eks" {
  name     = "whitelisted-cluster"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    public_access_cidrs     = ["203.0.113.0/24"] # Only corporate IP
  }
}
