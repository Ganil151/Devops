variable "cluster_name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "region" { type = string }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0" # Always pin versions!

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Enable OIDC for IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  # Karpenter requirements
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    primary = {
      min_size     = 1
      max_size     = 5 # For Capstone budget
      desired_size = 2

      instance_types = ["t3.medium"] # Keeping it cheap
      capacity_type  = "SPOT"        # 100% Spot per requirements

      # Labels for Node Affinity
      labels = {
        "role" = "general"
      }
    }
  }

  # Cluster API access
  authentication_mode = "API_AND_CONFIG_MAP"
}

# 🛠️ KARPENTER IAM ROLE (The Scaler)
# This allows Karpenter to provision EC2 nodes dynamically.
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  # Attach additional policies if needed
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

# 🛠️ AWS LOAD BALANCER CONTROLLER IAM ROLE
module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${var.cluster_name}-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# Outputs for ArgoCD / Kubeconfig
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "cluster_name" {
  value = module.eks.cluster_name
}
