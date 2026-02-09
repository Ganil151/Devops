# 13. EKS with Remote Access (SSH)
# enabling SSH access for troubleshooting nodes in a managed node group.

resource "aws_eks_node_group" "ssh_enabled" {
  cluster_name    = aws_eks_cluster.basic.name
  node_group_name = "debuggable-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  remote_access {
    ec2_ssh_key               = var.key_pair_name
    source_security_group_ids = [var.bastion_sg_id]
  }

  instance_types = ["t3.micro"]
  
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}
