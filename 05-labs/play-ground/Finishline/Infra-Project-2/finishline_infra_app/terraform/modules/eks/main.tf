#==============================================================
# EKS Cluster Modules
#==============================================================

# KMS Key for EKS Secret Encryption
resource "aws_kms_key" "eks_secrets" {
  count                   = var.is_eks_cluster_enabled ? 1 : 0
  description             = "KMS key for EKS secret encryption - ${var.cluster_name}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-secrets-key"
  })
}

resource "aws_kms_alias" "eks_secrets" {
  count         = var.is_eks_cluster_enabled ? 1 : 0
  name          = "alias/${var.cluster_name}-secrets"
  target_key_id = aws_kms_key.eks_secrets[0].key_id
}

resource "aws_eks_cluster" "eks" {
  count    = var.is_eks_cluster_enabled ? 1 : 0
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.cluster_enabled_log_types

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets[0].arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = false
    public_access_cidrs     = []
    security_group_ids      = var.security_group_ids
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

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

  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]

  lifecycle {
    ignore_changes = [version]
  }
}

#==============================================================
# IAM Policy Attachments for EKS Cluster Role
#==============================================================
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count      = var.is_eks_cluster_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = split("/", var.cluster_role_arn)[1]
}

data "tls_certificate" "eks_cert" {
  count = var.is_eks_cluster_enabled ? 1 : 0
  url   = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}

#==============================================================
# Aws Eks Access Entry Role
#==============================================================
resource "aws_eks_access_entry" "node_role_access" {
  count = var.is_eks_cluster_enabled ? 1 : 0
  cluster_name = aws_eks_cluster.eks[0].name
  principal_arn = var.node_role_arn
  type = "EC2_LINUX"

  depends_on = [ aws_eks_cluster.eks ]
}


#==============================================================
# OIDC Identity Provider Modules
#==============================================================
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  count           = var.is_eks_cluster_enabled ? 1 : 0
  url             = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cert[0].certificates[0].sha1_fingerprint]

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })

  depends_on = [aws_eks_cluster.eks]
}

#==============================================================
# On-Demand Node Group Modules
#==============================================================
resource "aws_eks_node_group" "ondemand_nodes" {
  count           = var.is_eks_cluster_enabled && var.create_ondemand_nodegroup ? 1 : 0
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
  ami_type       = var.ami_type
  disk_size      = var.cluster_disk_size

  labels = {
    type     = "ondemand"
    capacity = "on-demand"
  }

  update_config {
    max_unavailable = 1
  }

  tags = local.tags

  depends_on = [aws_eks_cluster.eks]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_node_group" "spot_nodes" {
  count           = var.is_eks_cluster_enabled && var.desired_capacity_on_spot > 0 ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster_name}-spot-nodes"
  node_role_arn   = var.node_role_arn

  scaling_config {
    desired_size = var.desired_capacity_on_spot
    min_size     = var.min_capacity_on_spot
    max_size     = var.max_capacity_on_spot
  }

  subnet_ids     = var.subnet_ids
  instance_types = var.spot_instance_types
  capacity_type  = "SPOT"
  ami_type       = var.ami_type
  disk_size      = var.cluster_disk_size

  labels = {
    type      = "spot"
    lifecycle = "spot"
    capacity  = "spot"
  }

  update_config {
    max_unavailable = 1
  }

  tags = local.tags

  depends_on = [aws_eks_cluster.eks]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

