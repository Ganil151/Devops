# 🔒 Secrets Management Reference

> **"If your secrets are in Git, they're not secrets anymore. They're public knowledge waiting to be discovered."**

## 🎯 The Golden Rules

1. **Never commit secrets to version control**
2. **Encrypt secrets at rest and in transit**
3. **Use IAM roles over access keys**
4. **Rotate secrets regularly**
5. **Audit secret access**

---

## 🛠️ Tool Comparison

| Tool | Best For | Pros | Cons |
| :--- | :------- | :--- | :--- |
| **Ansible Vault** | Ansible-only workflows | Simple, built-in | Limited to Ansible |
| **AWS Secrets Manager** | AWS-native apps | Automatic rotation, IAM integration | AWS-only, cost |
| **HashiCorp Vault** | Multi-cloud, enterprise | Feature-rich, dynamic secrets | Complex setup |
| **SOPS** | GitOps workflows | Git-friendly, KMS integration | Requires KMS setup |
| **AWS Parameter Store** | Simple key-value | Free tier, simple | No automatic rotation |

---

## 🔐 Ansible Vault

### Basic Operations

```bash
# Create encrypted file
ansible-vault create secrets.yml

# Encrypt existing file
ansible-vault encrypt vars/passwords.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Decrypt file
ansible-vault decrypt secrets.yml

# View encrypted file
ansible-vault view secrets.yml

# Rekey (change password)
ansible-vault rekey secrets.yml
```

### Usage in Playbooks

```yaml
# vars/vault.yml (encrypted)
vault_db_password: SuperSecret123
vault_api_key: abc-xyz-789

# playbook.yml
- hosts: all
  vars_files:
    - vars/vault.yml
  tasks:
    - name: Configure database
      mysql_db:
        login_password: "{{ vault_db_password }}"
```

### CI/CD Integration

```yaml
# .gitlab-ci.yml
deploy:
  script:
    - echo "$VAULT_PASSWORD" > .vault_pass
    - ansible-playbook site.yml --vault-password-file .vault_pass
    - rm .vault_pass
```

---

## ☁️ AWS Secrets Manager

### Store Secret

```bash
aws secretsmanager create-secret \
  --name prod/db/password \
  --secret-string "SuperSecret123"
```

### Retrieve in Ansible

```yaml
- name: Get DB password
  set_fact:
    db_password: "{{ lookup('aws_secret', 'prod/db/password') }}"

- name: Configure database
  mysql_db:
    login_password: "{{ db_password }}"
```

### Retrieve in Terraform

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

### Automatic Rotation

```python
# Lambda rotation function
import boto3

def lambda_handler(event, context):
    secret_id = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']
    
    if step == "createSecret":
        # Generate new password
        new_password = generate_password()
        # Store pending secret
        client.put_secret_value(
            SecretId=secret_id,
            ClientRequestToken=token,
            SecretString=new_password,
            VersionStages=['AWSPENDING']
        )
```

---

## 🏛️ HashiCorp Vault

### Setup

```bash
# Start Vault server
vault server -dev

# Set environment
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root-token'

# Enable secrets engine
vault secrets enable -path=secret kv-v2
```

### Store and Retrieve

```bash
# Store secret
vault kv put secret/db password=SuperSecret123

# Retrieve secret
vault kv get secret/db

# Retrieve specific field
vault kv get -field=password secret/db
```

### Dynamic Secrets (Database)

```bash
# Enable database engine
vault secrets enable database

# Configure database connection
vault write database/config/mysql \
  plugin_name=mysql-database-plugin \
  connection_url="{{username}}:{{password}}@tcp(127.0.0.1:3306)/" \
  allowed_roles="readonly" \
  username="root" \
  password="rootpass"

# Create role
vault write database/roles/readonly \
  db_name=mysql \
  creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';" \
  default_ttl="1h" \
  max_ttl="24h"

# Generate credentials
vault read database/creds/readonly
```

### Ansible Integration

```yaml
- name: Get secret from Vault
  set_fact:
    db_password: "{{ lookup('hashi_vault', 'secret=secret/db:password') }}"
```

---

## 🔑 SOPS (Secrets OPerationS)

### Setup

```bash
# Install
brew install sops

# Configure KMS key
export SOPS_KMS_ARN="arn:aws:kms:us-east-1:123456789:key/abc-123"
```

### Encrypt File

```bash
# Create encrypted file
sops secrets.yaml

# Edit encrypted file
sops secrets.yaml

# Decrypt to stdout
sops -d secrets.yaml
```

### GitOps Workflow

```yaml
# secrets.yaml (encrypted with SOPS)
database:
  password: ENC[AES256_GCM,data:abc123...]
  
# .sops.yaml (configuration)
creation_rules:
  - path_regex: \.yaml$
    kms: 'arn:aws:kms:us-east-1:123456789:key/abc-123'
```

### Ansible Integration

```yaml
- name: Decrypt SOPS file
  shell: sops -d secrets.yaml
  register: secrets_content

- name: Parse secrets
  set_fact:
    secrets: "{{ secrets_content.stdout | from_yaml }}"
```

---

## 🔐 AWS Parameter Store

### Store Parameter

```bash
# String parameter
aws ssm put-parameter \
  --name /prod/db/host \
  --value "db.example.com" \
  --type String

# Secure string (encrypted)
aws ssm put-parameter \
  --name /prod/db/password \
  --value "SuperSecret123" \
  --type SecureString
```

### Retrieve in Scripts

```bash
#!/bin/bash
DB_PASSWORD=$(aws ssm get-parameter \
  --name /prod/db/password \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text)
```

### Terraform Integration

```hcl
data "aws_ssm_parameter" "db_password" {
  name = "/prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_ssm_parameter.db_password.value
}
```

---

## 🎯 Best Practices

### 1. Naming Conventions

```
# Good structure
/environment/service/secret-type
/prod/api/db-password
/staging/web/api-key
/dev/cache/redis-password

# Bad structure
/password1
/secret
/db_pass
```

### 2. Access Control

```hcl
# IAM policy for least privilege
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "secretsmanager:GetSecretValue"
    ],
    "Resource": "arn:aws:secretsmanager:*:*:secret:/prod/api/*"
  }]
}
```

### 3. Rotation Strategy

| Secret Type | Rotation Frequency | Method |
| :---------- | :----------------- | :----- |
| Database passwords | 90 days | Automatic (Secrets Manager) |
| API keys | 180 days | Manual with notification |
| SSH keys | 365 days | Automated with Ansible |
| Certificates | Before expiry | Let's Encrypt automation |

### 4. Audit Logging

```bash
# CloudTrail for Secrets Manager
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=prod/db/password

# Vault audit log
vault audit enable file file_path=/var/log/vault_audit.log
```

---

## 🚨 Common Mistakes

### ❌ Don't Do This

```yaml
# Hardcoded in playbook
- name: Configure app
  template:
    src: config.j2
    dest: /etc/app/config.yml
  vars:
    api_key: "abc123xyz"  # NEVER!
```

```hcl
# Hardcoded in Terraform
resource "aws_db_instance" "main" {
  password = "SuperSecret123"  # NEVER!
}
```

```bash
# Secrets in environment variables (visible in ps)
export DB_PASSWORD="SuperSecret123"  # RISKY!
```

### ✅ Do This Instead

```yaml
# Ansible Vault
- name: Configure app
  template:
    src: config.j2
    dest: /etc/app/config.yml
  vars:
    api_key: "{{ vault_api_key }}"
```

```hcl
# Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

```bash
# Fetch at runtime
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id prod/db/password \
  --query SecretString \
  --output text)
```

---

## 🔍 Troubleshooting

### Issue: Vault Password Prompt in CI/CD

```bash
# Solution: Use password file
echo "$VAULT_PASSWORD" > .vault_pass
ansible-playbook site.yml --vault-password-file .vault_pass
rm .vault_pass
```

### Issue: AWS Secrets Manager Access Denied

```bash
# Check IAM permissions
aws iam get-role-policy \
  --role-name MyRole \
  --policy-name SecretsAccess

# Verify secret exists
aws secretsmanager describe-secret \
  --secret-id prod/db/password
```

### Issue: Vault Token Expired

```bash
# Renew token
vault token renew

# Check token info
vault token lookup
```

---

[⬅️ Back to Reference Hub](./readme.md)
