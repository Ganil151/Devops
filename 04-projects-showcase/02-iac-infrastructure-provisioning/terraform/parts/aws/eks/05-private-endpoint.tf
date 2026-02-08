# 05. EKS with Public Endpoint Disabled
# Hardened cluster where the API server is only accessible within the VPC.

resource "aws_eks_cluster" "private_eks" {
  name     = "private-cluster"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = false
    endpoint_private_access = true
  }
}
