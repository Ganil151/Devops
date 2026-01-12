# Cloud DevOps Security

Complete guide to securing DevOps pipelines, infrastructure as code, and cloud deployments.

## Pipeline Security
```bash
# Secure CI/CD Pipelines
# Secret management
# Code scanning and vulnerability assessment

# GitHub Actions Security
name: Secure Pipeline
on: [push]
jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
      - name: SAST Scan
        uses: github/codeql-action/analyze@v1
```

## Infrastructure Security
```bash
# Secure Infrastructure as Code
# Policy as Code
# Compliance automation

# Terraform Security Scanning
# tfsec integration
resource "aws_s3_bucket" "example" {
  bucket = "my-secure-bucket"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  
  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Checkov Policy Scanning
checkov -f main.tf --framework terraform
```

## Container Security
```bash
# Container image scanning
# Runtime security
# Kubernetes security policies

# Docker Security Scanning
docker scan myapp:latest

# Kubernetes Security Policies
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

## Secret Management
```bash
# Centralized secret management
# Encryption at rest and in transit
# Secret rotation

# AWS Secrets Manager
aws secretsmanager create-secret \
    --name prod/myapp/db \
    --description "Database credentials for MyApp" \
    --secret-string '{"username":"admin","password":"mypassword"}'

# HashiCorp Vault Integration
vault kv put secret/myapp/db \
    username=admin \
    password=mypassword

# Kubernetes Secrets
kubectl create secret generic db-secret \
    --from-literal=username=admin \
    --from-literal=password=mypassword
```