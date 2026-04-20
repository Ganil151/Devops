#==============================================================
# Bootstrap Module Outputs
#==============================================================

output "namespaces" {
  description = "List of namespaces created"
  value       = var.bootstrap_enabled ? kubernetes_namespace_v1.namespaces[*].id : []
}

output "namespace_names" {
  description = "List of namespace names"
  value       = var.bootstrap_enabled ? var.namespaces : []
}

output "helm_releases" {
  description = "Map of helm releases deployed"
  value       = var.bootstrap_enabled ? { for name, release in helm_release.charts : name => release.id } : {}
}

output "helm_release_names" {
  description = "List of helm release names"
  value       = var.bootstrap_enabled ? keys(var.helm_charts) : []
}

output "service_accounts" {
  description = "Map of service accounts created"
  value       = var.bootstrap_enabled ? { for name, sa in kubernetes_service_account_v1.sa : name => sa.id } : {}
}

output "bootstrap_status" {
  description = "Bootstrap status"
  value       = var.bootstrap_enabled ? "enabled" : "disabled"
}

output "cluster_config_map" {
  description = "Cluster config map ID"
  value       = var.bootstrap_enabled ? kubernetes_config_map_v1.cluster_config[0].id : null
}
