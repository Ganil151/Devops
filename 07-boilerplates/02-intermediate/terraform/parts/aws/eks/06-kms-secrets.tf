# 06. EKS with KMS Secrets Encryption
# encrypting Kubernetes secrets at rest using AWS KMS.

resource "aws_eks_cluster" "encrypted_cluster" {
  name     = "secure-cluster"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn
    }
  }
}
