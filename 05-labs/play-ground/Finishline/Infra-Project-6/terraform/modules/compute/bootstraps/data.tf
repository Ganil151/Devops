#============================================================
#  Data Sources
#============================================================

# Get current AWS caller identity
data "aws_caller_identity" "current" {
  count = var.is_karpenter_enabled ? 1 : 0
}

# Get IAM policy document for node group role
data "aws_iam_policy" "eks_worker_node" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "eks_cni" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
