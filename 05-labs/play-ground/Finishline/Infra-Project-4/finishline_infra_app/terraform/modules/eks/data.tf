data "tls_certificate" "eks_cert" {
  count = var.is_eks_cluster_enabled ? 1 : 0
  url   = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}
