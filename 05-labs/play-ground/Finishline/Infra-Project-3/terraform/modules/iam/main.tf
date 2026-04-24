# =============================================================================
# IAM Module - Main Configuration
# Finish Line 2026 Infrastructure
# Assignment: §83, §84, §87, §89 - Instance roles, EKS access mapping
# =============================================================================

# Jumphost IAM Role for EKS Authentication
resource "aws_iam_role" "jumphost_role" {
  name = "${local.project_name}-jumphost-role"

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

# Attach policies for EKS authentication (least privilege)
resource "aws_iam_role_policy_attachment" "jumphost_eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.jumphost_role.name
}

# Custom policy for EKS describe actions (read-only)
resource "aws_iam_role_policy" "jumphost_eks_readonly" {
  name = "${local.project_name}-jumphost-eks-readonly"
  role = aws_iam_role.jumphost_role.id

  # Least-privilege: Scope permissions to specific Finishline cluster only
  # ARN format: arn:aws:eks:REGION:ACCOUNT_ID:cluster/CLUSTER_NAME
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:AccessKubernetesApi"
        ]
        Resource = "arn:aws:eks:*:*:cluster/${var.cluster_name}"
      }
    ]
  })
}

# EKS Access Entry for jumphost role (EKS 1.30+)
resource "aws_eks_access_entry" "jumphost_access" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.jumphost_role.arn
  type          = "STANDARD"

  tags = local.common_tags
}

# EKS Access Policy Association for admin access
resource "aws_eks_access_policy_association" "jumphost_admin" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.jumphost_role.arn

  access_scope {
    type = "cluster"
  }
}
