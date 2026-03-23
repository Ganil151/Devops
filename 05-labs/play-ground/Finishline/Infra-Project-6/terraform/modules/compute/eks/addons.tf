#============================================================
#  IAM Role for EKS Node Group
#============================================================
resource "aws_iam_role" "eks_nodegroup" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name  = "${var.cluster_name}-nodegroup-role"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Effect" = "Allow"
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
        }
        "Action" = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}
#============================================================
#  IAM Role Policy Attachments for Node Group
#============================================================
resource "aws_iam_role_policy_attachment" "eks_nodegroup_amazon_eks_worker_node_policy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  role       = aws_iam_role.eks_nodegroup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_amazon_ec2_container_registry_readonly" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  role       = aws_iam_role.eks_nodegroup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_amazon_eks_cni_policy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  role       = aws_iam_role.eks_nodegroup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_amazon_ssm_managed_instance_core" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  role       = aws_iam_role.eks_nodegroup[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
#============================================================
#  IAM Instance Profile for Node Group
#============================================================
resource "aws_iam_instance_profile" "eks_nodegroup" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name  = "${var.cluster_name}-nodegroup-profile"
  role  = var.node_group_role_arn != "" ? var.node_group_role_arn : (var.is_eks_cluster_enabled ? aws_iam_role.eks_nodegroup[0].name : null)

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_eks_node_group" "nodegroup" {
  subnet_ids      = var.node_group_subnets
  ami_type        = var.node_group_ami_type
  count           = var.is_eks_nodegroup_enabled ? 1 : 0
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_group_role_arn != "" ? var.node_group_role_arn : (var.is_eks_nodegroup_role_enabled ? aws_iam_role.eks_nodegroup[0].arn : null)
  instance_types  = var.node_group_instance_types
  capacity_type   = var.node_group_capacity_type
  disk_size       = var.node_group_disk_size

  scaling_config {
    desired_size = var.node_group_scaling_config != null ? var.node_group_scaling_config.desired_size : 1
    min_size     = var.node_group_scaling_config != null ? var.node_group_scaling_config.min_size : 1
    max_size     = var.node_group_scaling_config != null ? var.node_group_scaling_config.max_size : 1
  }
  dynamic "update_config" {
    for_each = var.node_group_update_config != null ? [var.node_group_update_config] : []

    content {
      max_unavailable = update_config.value.max_unavailable
    }
  }
  dynamic "launch_template" {
    for_each = var.node_group_launch_template_id != "" ? [1] : []

    content {
      id      = var.node_group_launch_template_id
      version = var.node_group_version != null ? var.node_group_version : "Latest"
    }
  }
  labels = var.node_group_labels

  tags = merge(local.tags, var.node_group_tags, {
    "Name" = "${var.node_group_name}-node"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config]
  }

  timeouts {
    create = var.node_group_timeouts.create
    update = var.node_group_timeouts.update
    delete = var.node_group_timeouts.delete
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodegroup_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_nodegroup_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.eks_nodegroup_amazon_ec2_container_registry_readonly
  ]
}
#============================================================
#  Bootstrap Addons (Core EKS Addons)
#============================================================
resource "aws_eks_addon" "node_addons" {
  for_each = var.is_node_addons_enabled ? local.effective_addons : {}

  cluster_name  = var.cluster_name
  addon_name    = each.key
  addon_version = try(each.value.version, null)

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = each.key == "vpc-cni" ? var.node_group_role_arn : null
  configuration_values     = try(each.value.configuration_values, null)

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-${each.key}-addon"
  })

  lifecycle {
    ignore_changes = [addon_version]
  }
}

#============================================================
#  Karpenter Resources 
#============================================================
