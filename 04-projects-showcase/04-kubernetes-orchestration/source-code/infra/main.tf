data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

terraform {
  required_version = ">= 1.0.0"

  # For local testing, we use local state. In production, use S3 backend.
  # backend "s3" { ... }
}

module "networking" {
  source = "../../../2-Intermediate/02-Phase-2/01-Infrastructure-Automation/03-Cloud-Platforms/Terraform/modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}

module "eks" {
  source = "../../../2-Intermediate/02-Phase-2/01-Infrastructure-Automation/03-Cloud-Platforms/Terraform/modules/eks"

  project_name    = var.project_name
  cluster_version = var.eks_cluster_version
  subnet_ids      = module.networking.private_subnet_ids
  instance_types  = ["t3.medium"]
  desired_size    = 2
  max_size        = 4
  min_size        = 1
}
