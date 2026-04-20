#============================================================
# Random Suffix
#============================================================
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}
#============================================================
#  IAM ROLE 
#============================================================
resource "aws_iam_role" "eks-cluster-role" {
  count = var.is_eks_role_enabled ? 1 : 0
  name = "${local.cluster_name}-cluster-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.iam_tags  
}

#============================================================
#  IAM ROLE POLICIES ATTACHMENT
#============================================================
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count = var.is_eks_role_enabled ? 1 : 0
  role       = aws_iam_role.eks-cluster-role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  count = var.is_eks_role_enabled ? 1 : 0
  role       = aws_iam_role.eks-cluster-role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

#============================================================
#  IAM NODEGROUP ROLE 
#============================================================
resource "aws_iam_role" "eks-nodegroup-role" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name = "${local.cluster_name}-nodegroup-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.iam_tags
}

#============================================================
#  IAM NODEGROUP ROLE POLICIES ATTACHMENT
#============================================================
resource "aws_iam_role_policy_attachment" "node-policies" {
  for_each = var.is_eks_nodegroup_role_enabled ? toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.eks-nodegroup-role[0].name
}

#============================================================
#  OIDC IAM Role  
#============================================================
resource "aws_iam_openid_connect_provider" "eks-oidc-provider" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = var.eks_oidc_url

  tags = local.iam_tags
}

resource "aws_iam_role" "eks_oidc_role" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  name               = "${local.cluster_name}-oidc-role-${random_integer.random_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy[0].json

  tags = local.iam_tags
}

#============================================================
#  S3 OIDC Policy
#============================================================
resource "aws_iam_policy" "eks_oidc_policy" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" && var.s3_bucket_arn != "" ? 1 : 0
  name  = "${local.cluster_name}-oidc-policy-${random_integer.random_suffix.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ObjectAccess"
        Effect = "Allow"
        Action = (
          var.s3_access_type == "read" ? ["s3:GetObject"] :
          var.s3_access_type == "write" ? ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"] :
          ["s3:GetObject", "s3:PutObject"]
        )
        Resource = var.s3_prefix != "" ? "${var.s3_bucket_arn}/${var.s3_prefix}*" : "${var.s3_bucket_arn}/*"
      }
    ]
  })

  tags = local.iam_tags
}

resource "aws_iam_role_policy_attachment" "eks-oidc-policy-attachment" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" && var.s3_bucket_arn != "" ? 1 : 0

  policy_arn = aws_iam_policy.eks_oidc_policy[0].arn
  role       = aws_iam_role.eks_oidc_role[0].name
}