# IAM Roles (Separate from Module)
# This file is for demonstrating separation, but the terraform-aws-modules/eks/aws handles most IAM creation.
# If you have custom roles, define them here.

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])

  policy_arn = each.value
  role       = module.eks.eks_managed_node_groups["general"].iam_role_name
}
