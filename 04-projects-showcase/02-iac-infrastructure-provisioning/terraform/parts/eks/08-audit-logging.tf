# 08. EKS with Audit Logging
# enabling control plane logging for auditing and troubleshooting.

resource "aws_eks_cluster" "logged_cluster" {
  name     = "audited-cluster"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
