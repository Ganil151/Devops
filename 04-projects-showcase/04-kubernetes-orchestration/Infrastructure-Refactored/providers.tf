# ============================================================================
# Provider Configuration
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Remote backend configuration
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Enable versioning on the S3 bucket!
    # aws s3api put-bucket-versioning --bucket my-terraform-state-bucket --versioning-configuration Status=Enabled
  }
}

# ============================================================================
# AWS Provider
# ============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "devops-mastery"
    }
  }
}

# ============================================================================
# Kubernetes Provider
# ============================================================================

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# ============================================================================
# Helm Provider
# ============================================================================

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# ============================================================================
# Kubectl Provider
# ============================================================================

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}
