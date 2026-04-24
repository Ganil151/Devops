#============================================================
#  Data Sources
#============================================================

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# Get TLS certificate for EKS cluster OIDC provider
data "tls_certificate" "eks_cert" {
  count = var.is_eks_cluster_enabled ? 1 : 0
  url   = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}

data "aws_iam_policy" "eks_worker_node" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "eks_cni" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
