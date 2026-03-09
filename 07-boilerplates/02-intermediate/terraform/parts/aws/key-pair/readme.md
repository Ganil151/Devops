# AWS Key Pair Architectural Patterns

This directory contains 20 common AWS Key Pair patterns for EC2 SSH access using Terraform. Key pairs enable secure SSH authentication to EC2 instances without password-based login.

## 📂 Key Pair Types Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Basic Key Pair** | Simple key with hardcoded public key string. | `01-basic-key-pair.tf` |
| 2 | **File-Based Key** | Load public key from local SSH file. | `02-file-based-key.tf` |
| 3 | **Generated Key** | Auto-generate RSA key pair with TLS provider. | `03-generated-key.tf` |
| 4 | **ED25519 Key** | Modern elliptic curve algorithm for security. | `04-ed25519-key.tf` |
| 5 | **Environment Key** | Environment-specific naming (dev/staging/prod). | `05-environment-key.tf` |
| 6 | **Multi-Region Key** | Deploy same key across multiple AWS regions. | `06-multi-region-key.tf` |
| 7 | **Secrets Manager** | Store private key in AWS Secrets Manager. | `07-secrets-manager-key.tf` |
| 8 | **SSM Parameter** | Store private key in Systems Manager. | `08-ssm-parameter-key.tf` |
| 9 | **Team-Based Keys** | Multiple keys for different teams. | `09-team-based-keys.tf` |
| 10 | **Key Rotation** | Implement versioned key rotation pattern. | `10-rotation-key.tf` |
| 11 | **Bastion Key** | Dedicated key for bastion/jump hosts. | `11-bastion-key.tf` |
| 12 | **Conditional Key** | Create key only when condition is met. | `12-conditional-key.tf` |
| 13 | **Imported Key** | Import existing key into Terraform state. | `13-imported-key.tf` |
| 14 | **Data Source Key** | Reference existing key pair via data source. | `14-data-source-key.tf` |
| 15 | **Workspace Key** | Different keys per Terraform workspace. | `15-workspace-key.tf` |
| 16 | **Module Key** | Reusable module for key pair creation. | `16-module-key.tf` |
| 17 | **Lifecycle Key** | Prevent accidental deletion with lifecycle rules. | `17-lifecycle-key.tf` |
| 18 | **Output Key** | Comprehensive outputs for module integration. | `18-output-key.tf` |
| 19 | **Dynamic Keys** | Create multiple keys from a map variable. | `19-dynamic-keys.tf` |
| 20 | **Minimalist** | Bare minimum configuration. | `20-minimalist-key.tf` |

## 🚀 Technical Best Practices

1. **Never Commit Private Keys**: Always add `*.pem` and private key files to `.gitignore`.
2. **Use 4096-bit RSA**: Stronger than default 2048-bit for enhanced security.
3. **Consider ED25519**: Modern algorithm with better performance and security.
4. **Store Keys Securely**: Use AWS Secrets Manager or SSM Parameter Store for private keys.
5. **Implement Key Rotation**: Regularly rotate keys and version them appropriately.
6. **Tag Everything**: Use consistent tagging for key management and auditing.
7. **Restrict Permissions**: Set file permissions to `0400` for private key files.
8. **Multi-Region Strategy**: Deploy same key across regions for DR scenarios.
9. **Team Segregation**: Use separate keys for different teams/environments.
10. **Lifecycle Protection**: Enable `prevent_destroy` for production keys.

## 🔐 Security Considerations

- **Private Key Storage**: Never store private keys in version control or plain text.
- **Access Control**: Limit who can access private keys using IAM policies.
- **Audit Trail**: Enable CloudTrail to monitor key pair usage and modifications.
- **Expiration Policy**: Implement key expiration and rotation policies.
- **Backup Strategy**: Securely backup private keys in encrypted storage.

## 🛠 Prerequisites

These patterns require:
- Terraform >= 1.0
- AWS Provider >= 4.0
- TLS Provider (for generated keys)
- Local Provider (for file operations)

## 📝 Usage Example

```hcl
# Generate and deploy a key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "example" {
  key_name   = "my-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Use with EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.example.key_name
}
```

## 🔄 Key Rotation Strategy

1. Generate new key pair with versioned name
2. Deploy new key to all instances
3. Update instance configurations to use new key
4. Verify access with new key
5. Remove old key from instances
6. Delete old key pair from AWS

## 📊 Common Use Cases

- **Development**: Quick SSH access for developers
- **Production**: Secure, rotated keys with audit trails
- **Bastion Hosts**: Dedicated keys for jump servers
- **CI/CD**: Automated deployment keys
- **Multi-Tenant**: Separate keys per customer/tenant
- **Disaster Recovery**: Multi-region key deployment

---
*Part of the DevOps Showcase - Infrastructure as Code Module.*
