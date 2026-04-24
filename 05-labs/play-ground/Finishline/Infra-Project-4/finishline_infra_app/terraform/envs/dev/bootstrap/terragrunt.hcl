#============================================================
#  Bootstrap Module - Development Environment
#============================================================

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//bootstrap"
}

inputs = {
  project_name    = "finishline-infra"
  environment     = "development"
  manage_by      = true
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # EKS Cluster Configuration
  cluster_name             = "finishline-eks-cluster"
  cluster_endpoint        = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate  = dependency.eks.outputs.cluster_certificate_authority

  # Bootstrap Configuration
  bootstrap_enabled = true

  # Namespaces to create
  namespaces = ["dev", "staging", "prod"]

  # Helm Charts to deploy (example)
  helm_charts = {
    # Add your helm charts here
    # Example:
    # "aws-load-balancer-controller" = {
    #   repository = "https://aws.github.io/eks-charts"
    #   version    = "1.6.0"
    #   namespace  = "kube-system"
    # }
  }
}

dependency "eks" {
  config_path   = "../eks"
  skip_outputs  = true

  mock_outputs = {
    cluster_endpoint               = "https://mock-eks-cluster.us-east-1.eks.amazonaws.com"
    cluster_certificate_authority   = "mock-certificate"
  }
}

dependencies {
  paths = ["../eks"]
}
