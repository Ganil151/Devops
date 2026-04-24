# =============================================================================
# EKS Module - Elastic Kubernetes Service
# Module: eks
# Assignment Reference: Finish Line 2026 §74, §75, §76, §79
# - EKS Cluster with Managed Node Groups
# - Exactly 2x t3.medium on-demand nodes
# - Bottlerocket AMI for nodes
# - OIDC Identity Provider for IRSA
# =============================================================================

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Merge default tags with additional tags
  tags = merge({
    Name        = var.cluster_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.manage_by
    Terraform   = "true"
  }, var.additional_tags)

  # Node group common tags
  node_group_tags = merge(local.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

# =============================================================================
# Data Source: TLS Certificate for OIDC Provider
# Reference: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate
# =============================================================================

data "tls_certificate" "eks_cert" {
  count = var.is_eks_cluster_enabled ? 1 : 0
  url   = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}

# =============================================================================
# EKS Cluster
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/clusters.html
# Assignment: §74, §75 (EKS Cluster with managed node groups)
# =============================================================================

resource "aws_eks_cluster" "eks" {
  count    = var.is_eks_cluster_enabled ? 1 : 0
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = var.security_group_ids
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  # Explicitly disable EKS Auto Mode — using managed node groups instead.
  # Required with AWS provider ≥ 6.x which may default to Auto Mode.
  compute_config {
    enabled = false
  }

  storage_config {
    block_storage {
      enabled = false
    }
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = false
    }
  }

  tags = local.tags

  lifecycle {
    # Ignore version changes to allow Kubernetes upgrades
    ignore_changes = [version]
  }
}

# =============================================================================
# OIDC Identity Provider
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# Assignment: §87, §89 (OIDC for IRSA - IAM Roles for Service Accounts)
# =============================================================================

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  count           = var.is_eks_cluster_enabled ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cert[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })

  lifecycle {
    ignore_changes = [thumbprint_list]
  }

  depends_on = [aws_eks_cluster.eks]
}

# =============================================================================
# On-Demand Node Group
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
# Assignment: §74, §75, §76, §79 (Exactly 2x t3.medium nodes)
# =============================================================================

resource "aws_eks_node_group" "ondemand_node" {
  count           = (var.is_eks_cluster_enabled && var.is_eks_node_group_enabled) ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-ondemand-nodes"
  node_role_arn   = var.node_role_arn

  scaling_config {
    desired_size = var.desired_capacity_on_demand
    min_size     = var.min_capacity_on_demand
    max_size     = var.max_capacity_on_demand
  }

  subnet_ids     = var.subnet_ids
  instance_types = var.ondemand_instance_types
  capacity_type  = "ON_DEMAND"

  # AMI Type: Bottlerocket (assignment requirement §79)
  ami_type             = "BOTTLEROCKET_x86_64"
  disk_size            = 20
  force_update_version = false

  labels = {
    type     = "ondemand"
    capacity = "on-demand"
  }

  update_config {
    max_unavailable = 1
  }

  # Taints (optional - for special workload isolation)
  dynamic "taint" {
    for_each = var.ondemand_taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = local.node_group_tags

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_openid_connect_provider.eks_oidc_provider,
  ]

  lifecycle {
    # Ignore scaling config changes to allow manual adjustments
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# =============================================================================
# Spot Node Group (Optional)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
# =============================================================================

resource "aws_eks_node_group" "spot_node" {
  count           = (var.is_eks_cluster_enabled && var.is_eks_node_group_enabled && var.desired_capacity_spot > 0) ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-spot-nodes"
  node_role_arn   = var.node_role_arn

  scaling_config {
    desired_size = var.desired_capacity_spot
    min_size     = var.min_capacity_spot
    max_size     = var.max_capacity_spot
  }

  subnet_ids     = var.subnet_ids
  instance_types = var.spot_instance_types
  capacity_type  = "SPOT"

  # AMI Type: Bottlerocket
  ami_type             = "BOTTLEROCKET_x86_64"
  disk_size            = 30
  force_update_version = false

  labels = {
    type      = "spot"
    lifecycle = "spot"
    capacity  = "spot"
  }

  update_config {
    max_unavailable = 1
  }

  # Taints for spot nodes (to prevent critical workloads)
  dynamic "taint" {
    for_each = var.spot_taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = local.node_group_tags

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_openid_connect_provider.eks_oidc_provider,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# =============================================================================
# EKS Access Entry (for node role)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html
# Required for EKS clusters v1.30+ with CONFIG_MAP authentication mode
# =============================================================================

resource "aws_eks_access_entry" "node_role" {
  count         = var.is_eks_cluster_enabled ? 1 : 0
  cluster_name  = aws_eks_cluster.eks[0].name
  principal_arn = var.node_role_arn
  type          = "EC2_LINUX"

  tags = local.tags

  depends_on = [aws_eks_cluster.eks]
}

# =============================================================================
# EKS Access Entry (for cluster admin role - optional)
# =============================================================================

resource "aws_eks_access_entry" "admin_role" {
  count         = var.is_eks_cluster_enabled && var.admin_role_arn != "" ? 1 : 0
  cluster_name  = aws_eks_cluster.eks[0].name
  principal_arn = var.admin_role_arn
  type          = "STANDARD"

  tags = local.tags

  depends_on = [aws_eks_cluster.eks]
}

# =============================================================================
# EKS Access Policy Association (for admin role)
# =============================================================================

resource "aws_eks_access_policy_association" "admin_cluster_admin" {
  count        = var.is_eks_cluster_enabled && var.admin_role_arn != "" ? 1 : 0
  cluster_name = aws_eks_cluster.eks[0].name

  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.admin_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin_role]
}
