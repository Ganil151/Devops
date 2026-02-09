# 20. Minimalist EKS Cluster
# The absolute barebones code for an EKS control plane.

resource "aws_eks_cluster" "minimal" {
  name     = "baseline-eks"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}
# (Requires IAM role and subnets to be functional)
