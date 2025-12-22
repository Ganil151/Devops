resource "aws_eks_addons" "pod-identity" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "eks-pod-identity-agent"
  addon_version = "latest"
}