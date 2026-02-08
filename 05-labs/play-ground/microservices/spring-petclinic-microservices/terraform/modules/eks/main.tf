module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access = true

  enable_irsa = true

  eks_managed_node_groups = {
    general = {
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      instance_types = var.instance_types
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
