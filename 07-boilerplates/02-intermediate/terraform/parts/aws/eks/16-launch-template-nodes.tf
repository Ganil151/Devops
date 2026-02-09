# 16. EKS with Launch Template for Node Group
# Customizing nodes with specific disk volumes and security settings.

resource "aws_eks_node_group" "custom_nodes" {
  cluster_name    = aws_eks_cluster.basic.name
  node_group_name = "custom-template-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  launch_template {
    name    = aws_launch_template.eks_nodes.name
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
}

resource "aws_launch_template" "eks_nodes" {
  name = "eks-node-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Custom-EKS-Node"
    }
  }
}
