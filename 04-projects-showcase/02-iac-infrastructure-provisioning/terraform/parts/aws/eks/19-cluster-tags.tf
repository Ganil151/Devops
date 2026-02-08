# 19. EKS Cluster Tags for Automation
# tagging the cluster for discovery by controllers (like ALB Controller).

resource "aws_eks_cluster" "tagged_cluster" {
  name     = "discovery-cluster"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = {
    "kubernetes.io/cluster/discovery-cluster" = "shared"
    "Environment"                             = "Staging"
  }
}
