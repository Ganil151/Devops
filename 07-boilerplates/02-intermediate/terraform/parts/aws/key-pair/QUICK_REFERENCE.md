# Key-Pair Quick Reference Guide

## 🚀 Quick Start

### Basic Usage
```bash
# Navigate to key-pair directory
cd /home/ganil/Documents/Devops/07-boilerplates/02-intermediate/terraform/parts/aws/key-pair

# View any pattern
cat 01-basic-key-pair.tf
```

## 📋 Pattern Selection Guide

### For Development
- **02-file-based-key.tf** - Quick setup with existing SSH keys
- **20-minimalist-key.tf** - Simplest possible configuration
- **05-environment-key.tf** - Separate dev/staging/prod keys

### For Production
- **07-secrets-manager-key.tf** - Secure private key storage
- **10-rotation-key.tf** - Implement key rotation
- **17-lifecycle-key.tf** - Prevent accidental deletion

### For Security
- **04-ed25519-key.tf** - Modern encryption algorithm
- **08-ssm-parameter-key.tf** - Centralized key management
- **11-bastion-key.tf** - Dedicated bastion host access

### For Scale
- **06-multi-region-key.tf** - Deploy across regions
- **09-team-based-keys.tf** - Multiple team keys
- **19-dynamic-keys.tf** - Generate multiple keys from map

### For Automation
- **03-generated-key.tf** - Auto-generate keys
- **12-conditional-key.tf** - Conditional creation
- **16-module-key.tf** - Reusable module pattern

### For Migration
- **13-imported-key.tf** - Import existing keys
- **14-data-source-key.tf** - Reference existing keys

## 🔧 Common Commands

### Generate SSH Key Locally
```bash
# RSA 4096-bit
ssh-keygen -t rsa -b 4096 -f ~/.ssh/my_key -C "user@example.com"

# ED25519 (modern)
ssh-keygen -t ed25519 -f ~/.ssh/my_key -C "user@example.com"
```

### Terraform Operations
```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply specific pattern
terraform apply -target=aws_key_pair.basic

# Import existing key
terraform import aws_key_pair.imported my-existing-key

# Show outputs
terraform output
```

### Verify Key Pair
```bash
# List AWS key pairs
aws ec2 describe-key-pairs

# Get specific key fingerprint
aws ec2 describe-key-pairs --key-names my-key
```

## 🔐 Security Checklist

- [ ] Never commit private keys to version control
- [ ] Add `*.pem` to `.gitignore`
- [ ] Set private key permissions to `0400`
- [ ] Use Secrets Manager or SSM for storage
- [ ] Implement key rotation policy
- [ ] Tag all keys appropriately
- [ ] Enable CloudTrail for audit
- [ ] Use separate keys per environment
- [ ] Document key ownership
- [ ] Backup keys securely

## 📊 Pattern Comparison

| Pattern | Complexity | Security | Use Case |
|---------|-----------|----------|----------|
| 01-basic | Low | Medium | Quick testing |
| 02-file-based | Low | Medium | Local development |
| 03-generated | Medium | High | Automated provisioning |
| 04-ed25519 | Medium | Very High | Modern security |
| 07-secrets-manager | High | Very High | Production |
| 10-rotation | High | Very High | Enterprise |
| 20-minimalist | Very Low | Low | Learning/POC |

## 🎯 Best Practices by Scenario

### Scenario: New Project
1. Start with `03-generated-key.tf`
2. Add `07-secrets-manager-key.tf` for storage
3. Implement `05-environment-key.tf` for multi-env

### Scenario: Existing Infrastructure
1. Use `13-imported-key.tf` to import
2. Reference with `14-data-source-key.tf`
3. Plan migration to `10-rotation-key.tf`

### Scenario: Multi-Team Organization
1. Deploy `09-team-based-keys.tf`
2. Add `11-bastion-key.tf` for jump hosts
3. Use `19-dynamic-keys.tf` for scale

### Scenario: High Security Requirements
1. Use `04-ed25519-key.tf` for algorithm
2. Store with `07-secrets-manager-key.tf`
3. Protect with `17-lifecycle-key.tf`
4. Rotate using `10-rotation-key.tf`

## 🔄 Key Rotation Workflow

```bash
# 1. Generate new key (v2)
terraform apply -var="key_version=v2"

# 2. Update instances to accept both keys
# (Add new key to authorized_keys)

# 3. Test access with new key
ssh -i new_key.pem ec2-user@instance

# 4. Remove old key from instances
# (Remove from authorized_keys)

# 5. Delete old key pair
terraform destroy -target=aws_key_pair.old_key
```

## 📞 Troubleshooting

### Issue: Permission Denied
```bash
# Fix permissions
chmod 400 my_key.pem

# Verify
ls -la my_key.pem
```

### Issue: Key Already Exists
```bash
# Import existing key
terraform import aws_key_pair.my_key existing-key-name

# Or use data source
# See: 14-data-source-key.tf
```

### Issue: Wrong Key Format
```bash
# Convert to OpenSSH format
ssh-keygen -i -f key.pub > openssh_key.pub
```

## 📚 Additional Resources

- [AWS Key Pairs Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)
- [SSH Key Best Practices](https://www.ssh.com/academy/ssh/keygen)
- [ED25519 vs RSA](https://security.stackexchange.com/questions/90077/ssh-key-ed25519-vs-rsa)

---
*Quick Reference for AWS Key-Pair Terraform Patterns*
