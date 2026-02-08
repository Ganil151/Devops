# 01. Basic EKS Cluster
# The control plane for Amazon Elastic Kubernetes Service.

resource "aws_eks_cluster" "basic" {
  name     = "basic-eks-cluster"
  role_arn = var.eks_cluster_role_arn # See parts/iam/08-iam-role-eks-cluster.tf

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}
