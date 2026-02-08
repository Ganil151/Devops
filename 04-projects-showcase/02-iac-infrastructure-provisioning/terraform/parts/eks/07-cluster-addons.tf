# 07. EKS with Add-ons (VPC-CNI)
# managing cluster software components via AWS APIs.

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.basic.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.basic.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.basic.name
  addon_name   = "kube-proxy"
}
