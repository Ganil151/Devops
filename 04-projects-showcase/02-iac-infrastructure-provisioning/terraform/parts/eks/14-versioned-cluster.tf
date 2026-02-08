# 14. EKS Cluster with Specific Version
# Pinning the Kubernetes version for stability.

resource "aws_eks_cluster" "pinnned_version" {
  name     = "v1-28-cluster"
  version  = "1.28" # Explicitly set version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}
