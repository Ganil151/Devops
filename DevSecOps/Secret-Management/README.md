# Secret Management

Complete guide to secure secret management in DevSecOps environments.

## Secret Management Fundamentals

### Secret Types
```bash
# API Keys and Tokens
- Database passwords
- API authentication tokens
- SSL/TLS certificates
- SSH private keys
- Cloud service credentials
- Third-party service keys
```

### Secret Scanning
```bash
# TruffleHog
trufflehog git https://github.com/user/repo.git

# GitLeaks
gitleaks detect --source . --verbose

# detect-secrets
detect-secrets scan --all-files .
detect-secrets audit .secrets.baseline
```

## Secret Management Tools

### HashiCorp Vault
```bash
# Vault Setup
vault server -dev
export VAULT_ADDR='http://127.0.0.1:8200'

# Store secrets
vault kv put secret/myapp/db \
  username=admin \
  password=supersecret

# Retrieve secrets
vault kv get secret/myapp/db
vault kv get -field=password secret/myapp/db

# Dynamic secrets
vault write database/config/my-mysql-database \
  plugin_name=mysql-database-plugin \
  connection_url="{{username}}:{{password}}@tcp(localhost:3306)/" \
  allowed_roles="my-role" \
  username="root" \
  password="mysql"
```

### AWS Secrets Manager
```bash
# Create secret
aws secretsmanager create-secret \
  --name prod/myapp/db \
  --description "Database credentials" \
  --secret-string '{"username":"admin","password":"secret"}'

# Retrieve secret
aws secretsmanager get-secret-value \
  --secret-id prod/myapp/db \
  --query SecretString --output text

# Rotate secret
aws secretsmanager rotate-secret \
  --secret-id prod/myapp/db \
  --rotation-lambda-arn arn:aws:lambda:region:account:function:rotate-secret
```

### Kubernetes Secrets
```yaml
# Secret creation
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: c2VjcmV0  # base64 encoded

---
# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "myapp"
```

## Secret Injection Patterns

### Environment Variables
```bash
# Docker secret injection
docker run -e DB_PASSWORD="$(vault kv get -field=password secret/db)" myapp

# Kubernetes secret mounting
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: myapp
    image: myapp:latest
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

### File-based Secrets
```yaml
# Volume mount secrets
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: myapp
    image: myapp:latest
    volumeMounts:
    - name: secret-volume
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
```

### Init Container Pattern
```yaml
apiVersion: v1
kind: Pod
spec:
  initContainers:
  - name: secret-fetcher
    image: vault:latest
    command: ['sh', '-c', 'vault kv get -field=password secret/db > /shared/password']
    volumeMounts:
    - name: shared-data
      mountPath: /shared
  containers:
  - name: myapp
    image: myapp:latest
    volumeMounts:
    - name: shared-data
      mountPath: /secrets
```

## Secret Rotation

### Automated Rotation
```python
# Secret rotation script
import boto3
import json
from datetime import datetime, timedelta

def rotate_database_password():
    secrets_client = boto3.client('secretsmanager')
    rds_client = boto3.client('rds')
    
    # Get current secret
    current_secret = secrets_client.get_secret_value(SecretId='prod/db/master')
    secret_data = json.loads(current_secret['SecretString'])
    
    # Generate new password
    new_password = generate_secure_password()
    
    # Update database
    rds_client.modify_db_instance(
        DBInstanceIdentifier='prod-db',
        MasterUserPassword=new_password,
        ApplyImmediately=True
    )
    
    # Update secret
    secret_data['password'] = new_password
    secrets_client.update_secret(
        SecretId='prod/db/master',
        SecretString=json.dumps(secret_data)
    )
    
    return True

def generate_secure_password(length=32):
    import secrets
    import string
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))
```

### Rotation Policies
```bash
# Vault rotation policy
vault write auth/aws/config/rotate \
  access_key=AKIAIOSFODNN7EXAMPLE \
  secret_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
  region=us-east-1

# Automatic rotation schedule
vault write database/config/my-mysql-database \
  plugin_name=mysql-database-plugin \
  connection_url="{{username}}:{{password}}@tcp(localhost:3306)/" \
  allowed_roles="my-role" \
  username="root" \
  password="mysql" \
  password_policy="my-policy"
```

## CI/CD Secret Management

### GitHub Actions Secrets
```yaml
name: Deploy with Secrets
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy application
        run: |
          DB_PASSWORD=$(aws secretsmanager get-secret-value \
            --secret-id prod/db/password \
            --query SecretString --output text)
          ./deploy.sh
```

### Jenkins Credentials
```groovy
pipeline {
    agent any
    
    environment {
        DB_CREDENTIALS = credentials('database-credentials')
    }
    
    stages {
        stage('Deploy') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'database-credentials',
                        usernameVariable: 'DB_USER',
                        passwordVariable: 'DB_PASS'
                    )
                ]) {
                    sh './deploy.sh'
                }
            }
        }
    }
}
```

## Secret Security Best Practices

### Encryption and Access Control
```bash
# Vault encryption in transit and at rest
vault write sys/config/encryption \
  type="aes256-gcm96"

# Access policies
vault policy write myapp-policy - <<EOF
path "secret/data/myapp/*" {
  capabilities = ["read"]
}
path "database/creds/myapp-role" {
  capabilities = ["read"]
}
EOF

# Role-based access
vault write auth/kubernetes/role/myapp \
  bound_service_account_names=myapp \
  bound_service_account_namespaces=production \
  policies=myapp-policy \
  ttl=1h
```

### Audit and Monitoring
```bash
# Vault audit logging
vault audit enable file file_path=/vault/logs/audit.log

# Secret access monitoring
vault read sys/internal/counters/requests

# AWS CloudTrail for Secrets Manager
aws logs create-log-group --log-group-name /aws/secretsmanager/audit

# Kubernetes audit policy
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets"]
```