#============================================================
# Random Suffix (only used when deterministic naming is disabled)
#============================================================
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

#============================================================
#  IAM ROLE - EKS Cluster
#============================================================
resource "aws_iam_role" "eks-cluster-role" {
  count = var.is_eks_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-cluster-role${local.name_suffix}"

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
#  IAM ROLE POLICIES ATTACHMENT - EKS Cluster
#============================================================
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count      = var.is_eks_role_enabled ? 1 : 0
  role       = aws_iam_role.eks-cluster-role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  count      = var.is_eks_role_enabled ? 1 : 0
  role       = aws_iam_role.eks-cluster-role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

#============================================================
#  IAM NODEGROUP ROLE
#============================================================
resource "aws_iam_role" "eks-nodegroup-role" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-nodegroup-role${local.name_suffix}"

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
#  OIDC IAM Provider
#============================================================
resource "aws_iam_openid_connect_provider" "eks-oidc-provider" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = var.eks_oidc_url

  tags = local.iam_tags
}

#============================================================
#  OIDC IAM Role (Generic workload role)
#============================================================
resource "aws_iam_role" "eks_oidc_role" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  name               = "${local.cluster_name}-oidc-role${local.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy[0].json

  tags = local.iam_tags

  depends_on = [aws_iam_openid_connect_provider.eks-oidc-provider]
}

#============================================================
#  S3 OIDC Policy
#============================================================
resource "aws_iam_policy" "eks_oidc_policy" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" && var.s3_bucket_arn != "" ? 1 : 0
  name  = "${local.cluster_name}-oidc-policy${local.name_suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ObjectAccess"
        Effect = "Allow"
        Action = (
          var.s3_access_type == "read" ? ["s3:GetObject"] :
          var.s3_access_type == "write" ? ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"] :
          ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
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

  depends_on = [aws_iam_role.eks_oidc_role]
}

#============================================================
#  KARPENTER CONTROLLER ROLE (IRSA)
#============================================================
resource "aws_iam_role" "karpenter-controller-role" {
  count = var.is_karpenter_enabled && var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  name               = "${local.karpenter_cluster_name}-karpenter-controller-role${local.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy[0].json

  tags = merge(local.iam_tags, {
    "karpenter.sh/discovery" = local.karpenter_cluster_name
  })
}

#============================================================
#  KARPENTER CONTROLLER POLICY
#============================================================
resource "aws_iam_policy" "karpenter-controller-policy" {
  count = var.is_karpenter_enabled && var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  name        = "${local.karpenter_cluster_name}-karpenter-controller-policy${local.name_suffix}"
  description = "IAM policy for Karpenter controller to provision EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2InstanceOperations"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeImages",
          "ec2:DescribeCapacityReservations",
          "ec2:DescribeAvailabilityZones",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEC2Tagging"
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:network-interface/*",
          "arn:aws:ec2:*:*:launch-template/*",
          "arn:aws:ec2:*:*:spot-instances-request/*"
        ]
      },
      {
        Sid    = "AllowEC2Termination"
        Effect = "Allow"
        Action = [
          "ec2:TerminateInstances"
        ]
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/karpenter.sh/discovery" = local.karpenter_cluster_name
          }
        }
      },
      {
        Sid    = "AllowIAMPassRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = var.is_eks_nodegroup_role_enabled ? [
          aws_iam_role.eks-nodegroup-role[0].arn,
          try(aws_iam_role.karpenter-node-role[0].arn, "*")
          ] : [
          try(aws_iam_role.karpenter-node-role[0].arn, "*")
        ]
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      },
      {
        Sid    = "AllowSSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/aws/service/*"
      },
      {
        Sid    = "AllowPricingDataAccess"
        Effect = "Allow"
        Action = [
          "pricing:GetProducts"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEKSClusterAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "arn:aws:eks:*:*:cluster/${local.karpenter_cluster_name}"
      },
      {
        Sid    = "AllowInstanceProfileOperations"
        Effect = "Allow"
        Action = [
          "iam:GetInstanceProfile"
        ]
        Resource = var.karpenter_node_instance_profile_name != "" ? "arn:aws:iam::*:instance-profile/${var.karpenter_node_instance_profile_name}" : "*"
      }
    ]
  })

  tags = local.iam_tags
}

resource "aws_iam_role_policy_attachment" "karpenter-controller-policy-attachment" {
  count = var.is_karpenter_enabled && var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  policy_arn = aws_iam_policy.karpenter-controller-policy[0].arn
  role       = aws_iam_role.karpenter-controller-role[0].name
}

#============================================================
#  KARPENTER NODE ROLE
#============================================================
resource "aws_iam_role" "karpenter-node-role" {
  count = var.is_karpenter_enabled ? 1 : 0

  name               = "${local.karpenter_cluster_name}-karpenter-node-role${local.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume_role_policy[0].json

  tags = merge(local.iam_tags, {
    "karpenter.sh/discovery" = local.karpenter_cluster_name
  })
}

#============================================================
#  KARPENTER NODE ROLE POLICIES ATTACHMENT
#============================================================
resource "aws_iam_role_policy_attachment" "karpenter-node-policies" {
  for_each = var.is_karpenter_enabled ? toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.karpenter-node-role[0].name
}

#============================================================
#  KARPENTER NODE INSTANCE PROFILE
#============================================================
resource "aws_iam_instance_profile" "karpenter-node-profile" {
  count = var.is_karpenter_enabled ? 1 : 0

  name = "${local.karpenter_cluster_name}-karpenter-node-profile${local.name_suffix}"
  role = aws_iam_role.karpenter-node-role[0].name

  tags = local.iam_tags
}
