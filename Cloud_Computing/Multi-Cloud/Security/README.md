# Multi-Cloud Security

Complete guide to securing multi-cloud environments, identity management, and compliance.

## Identity and Access Management
```bash
# Federated Identity Management
# Single Sign-On (SSO) across clouds
# Centralized user management

# Azure AD Federation with AWS
aws iam create-saml-provider \
    --name AzureADProvider \
    --saml-metadata-document file://azure-ad-metadata.xml

# Google Cloud Identity Federation
gcloud iam workload-identity-pools create azure-pool \
    --location="global" \
    --description="Azure AD integration"
```

## Security Policies
```bash
# Consistent security policies
# Cross-cloud compliance
# Automated policy enforcement

# Open Policy Agent (OPA)
package multicloud.security

deny[msg] {
    input.cloud_provider == "aws"
    input.resource_type == "s3_bucket"
    not input.encryption_enabled
    msg := "S3 buckets must have encryption enabled"
}

deny[msg] {
    input.cloud_provider == "azure"
    input.resource_type == "storage_account"
    not input.https_only
    msg := "Azure Storage accounts must enforce HTTPS"
}
```

## Network Security
```bash
# Cross-cloud networking
# VPN connections
# Security groups alignment

# AWS to Azure VPN
aws ec2 create-vpn-connection \
    --type ipsec.1 \
    --customer-gateway-id cgw-12345678 \
    --vpn-gateway-id vgw-12345678

# Multi-cloud firewall rules
# Consistent across providers
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
    azurerm = { source = "hashicorp/azurerm" }
    google = { source = "hashicorp/google" }
  }
}
```

## Compliance Management
```bash
# Multi-cloud compliance frameworks
# Automated compliance checking
# Audit trail management

Frameworks:
- SOC 2 Type II
- ISO 27001
- PCI DSS
- GDPR
- HIPAA
- FedRAMP
```