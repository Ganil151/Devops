# 17. EKS with OIDC Identity Provider Config
# integrating external OIDC providers (like Okta or Google) with Kubernetes RBAC.

resource "aws_eks_identity_provider_config" "okta" {
  cluster_name = aws_eks_cluster.basic.name

  oidc {
    client_id                     = "okta-client-id"
    identity_provider_config_name = "okta-auth"
    issuer_url                    = "https://okta.example.com"
  }
}
