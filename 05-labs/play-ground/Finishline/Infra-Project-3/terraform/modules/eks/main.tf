# =============================================================================
# EKS Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §74, §75, §76, §79 - EKS with 2x t3.medium, Bottlerocket x86
# =============================================================================

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach required policies to cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "finishline_eks" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  enabled_cluster_log_types = var.cluster_enabled_log_types

  tags = merge(local.common_tags, {
    Name = var.cluster_name
    Type = "EKSCluster"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller_policy,
  ]
}

# EKS Managed Node Group IAM Role
resource "aws_iam_role" "eks_node_group_role" {
  name = "${local.project_name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach required policies to node group role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# EKS Managed Node Group
resource "aws_eks_node_group" "finishline_node_group" {
  cluster_name    = aws_eks_cluster.finishline_eks.name
  node_group_name = "${local.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  # Assignment requirement: exactly 2 nodes, fixed size
  instance_types = var.instance_types
  ami_type       = "BOTTLEROCKET_x86_64" # Bottlerocket x86 architecture

  # Fixed node group size per assignment §79
  capacity_type = "ON_DEMAND"
  disk_size     = 20

  scaling_config {
    desired_size = 2 # Fixed to 2 per assignment
    min_size     = 2 # Fixed to 2 per assignment
    max_size     = 2 # Fixed to 2 per assignment
  }

  # Ensure nodes have public IP for internet access
  node_repair_config {
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-node-group"
    Type = "EKSNodeGroup"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

# OIDC Provider for IAM roles for service accounts
data "tls_certificate" "eks" {
  url = aws_eks_cluster.finishline_eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.finishline_eks.identity[0].oidc[0].issuer

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-eks-oidc"
    Type = "OIDCProvider"
  })
}
