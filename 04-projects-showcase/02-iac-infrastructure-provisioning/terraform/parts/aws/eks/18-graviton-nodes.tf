# 18. EKS with Graviton (ARM) Nodes
# Using high-efficiency ARM-based instances for worker nodes.

resource "aws_eks_node_group" "graviton_nodes" {
  cluster_name    = aws_eks_cluster.basic.name
  node_group_name = "arm-graviton-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "AL2_ARM_64"
  instance_types = ["t4g.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
}
# (Note: Container images must support ARM64)
