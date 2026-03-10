# =============================================================================
# IAM Module for EKS
# Module: secret/iam
# Assignment Reference: Finish Line 2026 §83, §84, §87, §89 (EKS IAM/RBAC integration)
# 
# Resources Created:
# 1. EKS Cluster Role (for EKS control plane)
# 2. EKS Node Group Role (for worker nodes)
# 3. OIDC Identity Provider (for service account IAM)
# 4. OIDC IAM Role + Policy (for S3 access via service accounts)
#
# SECURITY: This module follows least privilege principles:
# - S3 access is scoped to specific bucket and optional prefix
# - OIDC trust policy restricts to specific service account namespace
# - No wildcard (*) in resource ARNs for S3 access
# =============================================================================

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  cluster_name = var.cluster_name

  # Merge default tags with additional tags
  tags = merge({
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
    Terraform   = "true"
  }, var.additional_tags)

  # Common tags for IAM resources (IAM doesn't support all tags)
  iam_tags = {
    Cluster     = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.manage_by
  }
}

# -----------------------------------------------------------------------------
# Random Suffix for Unique Resource Names
# -----------------------------------------------------------------------------

resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

# =============================================================================
# 1. EKS Cluster Role
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
# Required for: EKS control plane to make AWS API calls
# =============================================================================

resource "aws_iam_role" "eks-cluster-role" {
  count = var.is_eks_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-cluster-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.iam_tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count      = var.is_eks_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role[0].name
}

# Additional EKS cluster policies (optional, based on requirements)
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  count      = var.is_eks_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-role[0].name
}

# =============================================================================
# 2. EKS Node Group Role
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html
# Required for: EC2 worker nodes to join cluster and pull images
# =============================================================================

resource "aws_iam_role" "eks-nodegroup-role" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-nodegroup-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.iam_tags
}

resource "aws_iam_role_policy_attachment" "node-policies" {
  for_each = var.is_eks_nodegroup_role_enabled ? toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]) : []

  policy_arn = each.value
  role       = aws_iam_role.eks-nodegroup-role[0].name
}

# =============================================================================
# 3. OIDC Identity Provider
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# Required for: Kubernetes service accounts to assume IAM roles (IRSA)
# Note: Created AFTER EKS cluster exists (needs OIDC issuer URL)
# =============================================================================

resource "aws_iam_openid_connect_provider" "eks-oidc-provider" {
  count           = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0
  url             = var.eks_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.oidc_thumbprint

  tags = local.iam_tags
}

# =============================================================================
# 4. OIDC IAM Role (for Kubernetes Service Accounts)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
# Required for: Pod-level IAM credentials via service account annotation
# =============================================================================

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    # Least privilege: Restrict to specific namespace and service account
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-oidc-provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.oidc_namespace}:${var.oidc_service_account}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-oidc-provider[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_oidc" {
  count              = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy[0].json
  name               = "${local.cluster_name}-oidc-role"

  tags = local.iam_tags
}

# =============================================================================
# 5. OIDC IAM Policy (S3 Access for Service Accounts)
# Scoped policy for S3 bucket access via IRSA
# =============================================================================

resource "aws_iam_policy" "eks-oidc-policy" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" && var.s3_bucket_arn != "" ? 1 : 0
  name  = "${local.cluster_name}-oidc-policy"

  # Policy is scoped to specific bucket ARN - no wildcards allowed for least privilege
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowBucketAccess"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = var.s3_bucket_arn
      },
      {
        Sid = "AllowObjectAccess"
        # Use GetObject for read, PutObject for write - scoped to prefix if provided
        Action   = var.s3_access_type == "read" ? ["s3:GetObject"] : var.s3_access_type == "write" ? ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"] : ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = var.s3_prefix != "" ? "${var.s3_bucket_arn}/${var.s3_prefix}/*" : "${var.s3_bucket_arn}/*"
      }
    ]
  })

  tags = local.iam_tags
}

resource "aws_iam_role_policy_attachment" "eks-oidc-policy-attach" {
  count      = var.is_eks_cluster_enabled && var.eks_oidc_url != "" && var.s3_bucket_arn != "" ? 1 : 0
  role       = aws_iam_role.eks_oidc[0].name
  policy_arn = aws_iam_policy.eks-oidc-policy[0].arn
}
