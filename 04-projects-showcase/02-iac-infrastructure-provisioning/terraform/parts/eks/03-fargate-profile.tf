# 03. EKS with Fargate Profiles
# Run Kubernetes pods without managing EC2 instances.

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.basic.name
  fargate_profile_name   = "default-profile"
  pod_execution_role_arn = var.fargate_pod_role_arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system"
  }
}
# (Pods matching the selector will automatically run on Fargate)
