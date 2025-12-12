# Infrastructure as Code Security

Security scanning for infrastructure configurations and IaC templates.

## Contents

- **[iac-security-guide.md](./iac-security-guide.md)** - Complete IaC security guide covering:
  - Terraform security scanning
  - Kubernetes manifest analysis
  - Docker Compose security
  - CloudFormation template scanning
  - Custom policy development
  - Security best practices

## Supported Formats

- **Terraform**: `.tf`, `.tfvars` files
- **Kubernetes**: YAML manifests, Helm charts
- **Docker Compose**: `docker-compose.yml`
- **CloudFormation**: AWS templates
- **Azure ARM**: Resource Manager templates
- **Dockerfile**: Container build files

## Quick Examples

```bash
# Scan Terraform files
trivy config terraform/

# Scan Kubernetes manifests
trivy config k8s/

# Scan with custom policies
trivy config --policy custom-policy.rego .

# Compliance scanning
trivy config --compliance k8s-cis .
```

## Security Checks

- Misconfigurations detection
- Security best practices validation
- Compliance framework alignment
- Custom policy enforcement
- Secret detection in configs