#==============================================================
# Bootstrap Module - Kubernetes Resources
#==============================================================

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
  }
}

#==============================================================
# Kubernetes Namespaces
#==============================================================
resource "kubernetes_namespace_v1" "namespaces" {
  count = var.bootstrap_enabled ? length(var.namespaces) : 0

  metadata {
    name = var.namespaces[count.index]

    labels = merge(local.common_tags, {
      name = var.namespaces[count.index]
    })
  }

  lifecycle {
    prevent_destroy = false
  }
}

#==============================================================
# Kubernetes Service Accounts (for IRSA)
#==============================================================
resource "kubernetes_service_account_v1" "sa" {
  for_each = var.bootstrap_enabled ? var.helm_charts : {}

  metadata {
    name      = each.key
    namespace = each.value.namespace

    labels = merge(local.common_tags, {
      "app.kubernetes.io/name" = each.key
    })

    annotations = {
      "eks.amazonaws.com/role-arn" = ""
    }
  }

  automount_service_account_token = true
}

#==============================================================
# Helm Releases
#==============================================================
resource "helm_release" "charts" {
  for_each = var.bootstrap_enabled ? var.helm_charts : {}

  name       = each.key
  repository = each.value.repository
  chart      = each.key
  version    = each.value.version
  namespace  = each.value.namespace

  create_namespace = true

  values = each.value.values

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    kubernetes_namespace_v1.namespaces
  ]
}

#==============================================================
# ConfigMap for Cluster Configuration
#==============================================================
resource "kubernetes_config_map_v1" "cluster_config" {
  count = var.bootstrap_enabled ? 1 : 0

  metadata {
    name      = "cluster-config"
    namespace = "kube-system"

    labels = merge(local.common_tags, {
      "app.kubernetes.io/name" = "cluster-config"
    })
  }

  data = {
    "cluster_name" = var.cluster_name
    "environment"  = var.environment
  }
}
