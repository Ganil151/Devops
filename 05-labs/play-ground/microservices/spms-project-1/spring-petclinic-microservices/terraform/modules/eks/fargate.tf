resource "aws_eks_fargate_profile" "this" {
  count                  = var.enable_fargate ? 1 : 0
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "${var.environment}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "fargate"
  }

  tags = var.tags
}

resource "aws_iam_role" "fargate" {
  count = var.enable_fargate ? 1 : 0
  name  = "${var.environment}-eks-fargate-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_AmazonEKSFargatePodExecutionRolePolicy" {
  count      = var.enable_fargate ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}
