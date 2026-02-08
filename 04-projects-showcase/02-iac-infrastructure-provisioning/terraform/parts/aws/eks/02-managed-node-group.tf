# 02. EKS with Managed Node Groups
# AWS-managed EC2 instances that join the Kubernetes cluster.

resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.basic.name
  node_group_name = "standard-nodes"
  node_role_arn   = var.eks_node_role_arn # See parts/iam/09-iam-role-eks-nodes.tf
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  update_config {
    max_unavailable = 1
  }
}
