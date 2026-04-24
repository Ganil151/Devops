#============================================================
#  OIDC IAM ROLE DATA
#============================================================
data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  count = var.is_eks_cluster_enabled && var.eks_oidc_url != "" ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks-oidc-provider[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-oidc-provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.eks_oidc_namespace}:${var.eks_oidc_service_account_name}"]
    }
  }
}