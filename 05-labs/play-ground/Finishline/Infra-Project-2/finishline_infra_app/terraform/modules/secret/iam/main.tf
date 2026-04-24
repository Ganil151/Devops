# =============================================================
# IAM Random Integer
# =============================================================
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

# =============================================================
# IAM EKS Cluster Role
# =============================================================
resource "aws_iam_role" "eks-cluster_role" {
  count = var.is_role_enabled ? 1 : 0  
  name = "${local.cluster_name}-cluster-role-${random_integer.random_suffix.result}"

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
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count = var.is_role_enabled ? 1 : 0  

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster_role[0].name
} 
  
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  count = var.is_role_enabled ? 1 : 0  

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster_role[0].name

}

resource "aws_iam_role" "eks-nodegroup-role" {
  count = var.is_role_enabled ? 1 : 0  
  name = "${local.cluster_name}-nodegroup-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
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

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  count           = var.is_eks_cluster_enabled ? 1 : 0
  url             = var.eks_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.oidc_thumbprint

  tags = local.iam_tags
}  

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.oidc_namespace}:${var.oidc_service_account}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider[0].arn]
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

resource "aws_iam_instance_profile" "eks_nodegroup_profile" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-nodegroup-profile"
  role  = aws_iam_role.eks-nodegroup-role[0].name
}

resource "aws_iam_role_policy_attachment" "eks-oidc-policy-attach" {
  count      = var.is_eks_cluster_enabled && var.eks_oidc_url != "" && var.s3_bucket_arn != "" ? 1 : 0
  role       = aws_iam_role.eks_oidc[0].name
  policy_arn = aws_iam_policy.eks-oidc-policy[0].arn
}

