# ============================================================================
# Outputs: EKS Infrastructure
# ============================================================================

# ----------------------------------------------------------------------------
# VPC Outputs
# ----------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC identifier"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "Elastic IPs of NAT Gateways"
  value       = module.networking.nat_gateway_ips
}

# ----------------------------------------------------------------------------
# EKS Cluster Outputs
# ----------------------------------------------------------------------------

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
  sensitive   = false
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster authentication"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the cluster (for IRSA)"
  value       = module.eks.cluster_oidc_issuer_url
}

# ----------------------------------------------------------------------------
# Node Group Outputs
# ----------------------------------------------------------------------------

output "node_group_id" {
  description = "EKS node group ID"
  value       = module.eks.node_group_id
}

output "node_group_arn" {
  description = "EKS node group ARN"
  value       = module.eks.node_group_arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = module.eks.node_group_status
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = module.eks.node_iam_role_arn
}

# ----------------------------------------------------------------------------
# Service Mesh Outputs
# ----------------------------------------------------------------------------

output "istio_ingress_gateway_hostname" {
  description = "Hostname of Istio ingress gateway LoadBalancer"
  value       = var.enable_service_mesh ? module.service_mesh[0].ingress_gateway_hostname : null
}

output "istio_ingress_gateway_ip" {
  description = "IP address of Istio ingress gateway LoadBalancer"
  value       = var.enable_service_mesh ? module.service_mesh[0].ingress_gateway_ip : null
}

output "kiali_url" {
  description = "URL to access Kiali dashboard"
  value       = var.enable_service_mesh && var.enable_kiali ? module.service_mesh[0].kiali_url : null
}

output "jaeger_url" {
  description = "URL to access Jaeger UI"
  value       = var.enable_service_mesh && var.enable_jaeger ? module.service_mesh[0].jaeger_url : null
}

# ----------------------------------------------------------------------------
# Monitoring Outputs
# ----------------------------------------------------------------------------

output "prometheus_endpoint" {
  description = "Prometheus server endpoint"
  value       = var.enable_monitoring ? module.monitoring[0].prometheus_endpoint : null
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = var.enable_monitoring && var.enable_grafana ? module.monitoring[0].grafana_url : null
}

output "grafana_admin_user" {
  description = "Grafana admin username"
  value       = var.enable_monitoring && var.enable_grafana ? module.monitoring[0].grafana_admin_user : null
}

# ----------------------------------------------------------------------------
# GitOps Outputs
# ----------------------------------------------------------------------------

output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = var.enable_gitops ? module.gitops[0].argocd_server_url : null
}

output "argocd_admin_password" {
  description = "ArgoCD admin password (retrieve from Kubernetes secret)"
  value       = var.enable_gitops ? module.gitops[0].argocd_admin_password : null
  sensitive   = true
}

# ----------------------------------------------------------------------------
# Connection Information
# ----------------------------------------------------------------------------

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "cluster_access_instructions" {
  description = "Instructions to access the cluster"
  value = <<-EOT
    # Configure kubectl
    aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}
    
    # Verify connection
    kubectl get nodes
    
    # Access Istio Ingress Gateway
    ${var.enable_service_mesh ? "kubectl get svc -n istio-ingress" : "Service mesh not enabled"}
    
    # Access ArgoCD
    ${var.enable_gitops ? "kubectl get svc -n ${var.argocd_namespace}" : "GitOps not enabled"}
    
    # Access Grafana
    ${var.enable_monitoring && var.enable_grafana ? "kubectl port-forward -n monitoring svc/grafana 3000:80" : "Monitoring not enabled"}
  EOT
}

# ----------------------------------------------------------------------------
# Resource Tags
# ----------------------------------------------------------------------------

output "common_tags" {
  description = "Common tags applied to all resources"
  value = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
