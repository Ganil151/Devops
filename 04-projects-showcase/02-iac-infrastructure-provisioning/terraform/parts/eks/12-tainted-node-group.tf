# 12. EKS with Tainted Node Group
# Isolating specific workloads (e.g., databases) using Kubernetes taints.

resource "aws_eks_node_group" "tainted_nodes" {
  cluster_name    = aws_eks_cluster.basic.name
  node_group_name = "special-workload-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  taint {
    key    = "dedicated"
    value  = "gpu"
    effect = "NO_SCHEDULE"
  }

  instance_types = ["p3.2xlarge"]
  
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 0
  }
}
# (Only pods with a matching toleration can run on these nodes)
