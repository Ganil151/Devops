# 10. EKS with Spot Instances (Managed Node Group)
# leveraging cost-effective spot instances for Kubernetes nodes.

resource "aws_eks_node_group" "spot_nodes" {
  cluster_name    = aws_eks_cluster.basic.name
  node_group_name = "spot-workers"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = "SPOT"
  instance_types = ["c5.large", "m5.large"]

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 1
  }
}
