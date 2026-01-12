############################################################
# OIDC Certificate and Policy Documents
############################################################

# 1. Fetch the TLS certificate for the EKS cluster's OIDC provider
# This only runs if the cluster is enabled
data "tls_certificate" "eks-certificate" {
  count = var.is_eks_cluster_enabled ? 1 : 0
  url   = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}

# 2. The Trust Policy for the OIDC Role
# FIX: Added count here to prevent "Empty Tuple" error
data "aws_iam_policy_document" "eks-oidc-assume-role-policy" {
  count = var.is_eks_cluster_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      # This reference is safe now because count ensures this block only 
      # evaluates when the provider exists.
      variable = "${replace(aws_iam_openid_connect_provider.eks-oidc-provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-oidc-provider[0].arn]
      type        = "Federated"
    }
  }
}