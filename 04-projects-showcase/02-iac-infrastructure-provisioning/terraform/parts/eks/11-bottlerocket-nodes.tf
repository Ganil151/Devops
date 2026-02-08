# 11. EKS with Bottlerocket OS Nodes
# Using AWS's container-optimized operating system for nodes.

resource "aws_eks_node_group" "bottlerocket" {
  cluster_name    = aws_eks_cluster.basic.name
  node_group_name = "bottlerocket-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "BOTTLEROCKET_x86_64"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
}
