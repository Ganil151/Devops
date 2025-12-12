# Ansible Vault

Complete guide to Ansible Vault for encrypting sensitive data, managing secrets, and implementing secure automation workflows.

## Vault Basics

### What is Ansible Vault?

Ansible Vault is a feature that allows you to encrypt sensitive data such as passwords, keys, and other secrets within Ansible files. It provides a way to keep sensitive information secure while still allowing it to be used in playbooks and roles.

### Key Features
- **Encryption**: AES256 encryption for sensitive data
- **Integration**: Seamless integration with playbooks and roles
- **Flexibility**: Encrypt entire files or individual variables
- **Multiple Passwords**: Support for multiple vault passwords
- **Version Control**: Encrypted files can be safely stored in version control

## Basic Vault Operations

### Creating Encrypted Files
```bash
# Create new encrypted file
ansible-vault create secrets.yml

# Create with specific vault ID
ansible-vault create --vault-id prod@prompt secrets.yml

# Create with password file
ansible-vault create --vault-password-file ~/.vault_pass secrets.yml
```

### Editing Encrypted Files
```bash
# Edit encrypted file
ansible-vault edit secrets.yml

# Edit with specific vault ID
ansible-vault edit --vault-id prod@prompt secrets.yml

# Edit with password file
ansible-vault edit --vault-password-file ~/.vault_pass secrets.yml
```

### Viewing Encrypted Files
```bash
# View encrypted file content
ansible-vault view secrets.yml

# View with specific vault ID
ansible-vault view --vault-id prod@prompt secrets.yml

# View with password file
ansible-vault view --vault-password-file ~/.vault_pass secrets.yml
```

### Encrypting Existing Files
```bash
# Encrypt existing file
ansible-vault encrypt vars.yml

# Encrypt multiple files
ansible-vault encrypt vars.yml secrets.yml config.yml

# Encrypt with specific vault ID
ansible-vault encrypt --vault-id prod@prompt vars.yml

# Encrypt in-place
ansible-vault encrypt_string 'secret_password' --name 'db_password'
```

### Decrypting Files
```bash
# Decrypt file (removes encryption)
ansible-vault decrypt secrets.yml

# Decrypt to stdout (keeps file encrypted)
ansible-vault decrypt --output=- secrets.yml

# Decrypt with specific vault ID
ansible-vault decrypt --vault-id prod@prompt secrets.yml
```

### Changing Vault Passwords
```bash
# Change vault password
ansible-vault rekey secrets.yml

# Change with specific vault IDs
ansible-vault rekey --vault-id old@prompt --new-vault-id new@prompt secrets.yml

# Change using password files
ansible-vault rekey --vault-password-file old_pass --new-vault-password-file new_pass secrets.yml
```

## Vault File Examples

### Complete Encrypted File
```yaml
# secrets.yml (encrypted)
$ANSIBLE_VAULT;1.1;AES256
66386439653762391081743274974402374729374927394729374927394729374927
39472937492739472937492739472937492739472937492739472937492739472937
...

# When decrypted, contains:
---
database_password: supersecret123
api_key: abc123def456ghi789
ssl_private_key: |
  -----BEGIN PRIVATE KEY-----
  MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...
  -----END PRIVATE KEY-----
admin_users:
  - username: admin
    password: admin_secret_pass
  - username: operator
    password: operator_secret_pass
```

### Mixed Encrypted/Unencrypted Variables
```yaml
# group_vars/production/main.yml
---
# Unencrypted variables
app_name: myapp
app_version: 1.0.0
environment: production
debug_mode: false

# Reference to encrypted variables
database_host: db.production.example.com
database_user: myapp_user
database_password: "{{ vault_database_password }}"
api_key: "{{ vault_api_key }}"

# group_vars/production/vault.yml (encrypted)
---
vault_database_password: supersecret123
vault_api_key: abc123def456ghi789
vault_ssl_certificate: |
  -----BEGIN CERTIFICATE-----
  MIIDXTCCAkWgAwIBAgIJAKoK/heBjcOuMA0GCSqGSIb3DQEBBQUAMEUxCzAJBgNV
  ...
  -----END CERTIFICATE-----
```

### Inline Encrypted Strings
```yaml
# playbook.yml with inline encrypted strings
---
- name: Deploy application with secrets
  hosts: webservers
  vars:
    database_password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      66386439653762391081743274974402374729374927394729374927394729374927
      39472937492739472937492739472937492739472937492739472937492739472937
    
    api_key: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      33386439653762391081743274974402374729374927394729374927394729374927
      29472937492739472937492739472937492739472937492739472937492739472937
  
  tasks:
    - name: Configure database connection
      template:
        src: database.conf.j2
        dest: /etc/myapp/database.conf
      vars:
        db_password: "{{ database_password }}"
```

## Vault Password Management

### Password Files
```bash
# Create password file
echo 'my_vault_password' > ~/.vault_pass
chmod 600 ~/.vault_pass

# Use password file
ansible-playbook --vault-password-file ~/.vault_pass playbook.yml

# Environment variable for password file
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
ansible-playbook playbook.yml
```

### Password Scripts
```bash
#!/bin/bash
# vault_pass.sh - Dynamic password retrieval
# Retrieve password from external system (AWS Secrets Manager, HashiCorp Vault, etc.)

# Example: Get from environment variable
echo "${VAULT_PASSWORD}"

# Example: Get from AWS Secrets Manager
# aws secretsmanager get-secret-value --secret-id ansible-vault-password --query SecretString --output text

# Example: Get from HashiCorp Vault
# vault kv get -field=password secret/ansible/vault

# Make executable
chmod +x vault_pass.sh

# Use script
ansible-playbook --vault-password-file ./vault_pass.sh playbook.yml
```

### Multiple Vault IDs
```bash
# Create files with different vault IDs
ansible-vault create --vault-id prod@prompt production_secrets.yml
ansible-vault create --vault-id staging@prompt staging_secrets.yml
ansible-vault create --vault-id dev@prompt development_secrets.yml

# Use multiple vault IDs in playbook
ansible-playbook --vault-id prod@prompt --vault-id staging@prompt playbook.yml

# Vault ID with password files
ansible-vault create --vault-id prod@~/.vault_pass_prod secrets.yml
ansible-vault create --vault-id staging@~/.vault_pass_staging secrets.yml
```

## Integration with Playbooks

### Using Encrypted Variables
```yaml
# playbook.yml
---
- name: Deploy secure application
  hosts: webservers
  become: yes
  vars_files:
    - vars/main.yml
    - vars/vault.yml  # Encrypted file
  
  tasks:
    - name: Create database user
      mysql_user:
        name: "{{ db_user }}"
        password: "{{ vault_db_password }}"  # From encrypted file
        priv: "{{ db_name }}.*:ALL"
        state: present
        login_user: root
        login_password: "{{ vault_mysql_root_password }}"
      no_log: true  # Prevent password logging
    
    - name: Configure API credentials
      template:
        src: api_config.j2
        dest: /etc/myapp/api.conf
        owner: myapp
        group: myapp
        mode: '0600'
      vars:
        api_key: "{{ vault_api_key }}"
        api_secret: "{{ vault_api_secret }}"
```

### Running Playbooks with Vault
```bash
# Prompt for vault password
ansible-playbook --ask-vault-pass playbook.yml

# Use password file
ansible-playbook --vault-password-file ~/.vault_pass playbook.yml

# Use multiple vault IDs
ansible-playbook --vault-id prod@prompt --vault-id staging@~/.vault_pass_staging playbook.yml

# Environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
ansible-playbook playbook.yml
```

## Advanced Vault Features

### Vault IDs and Labels
```yaml
# Different vault IDs for different environments
# production_secrets.yml (encrypted with prod vault ID)
$ANSIBLE_VAULT;1.2;AES256;prod
66386439653762391081743274974402374729374927394729374927394729374927
...

# staging_secrets.yml (encrypted with staging vault ID)
$ANSIBLE_VAULT;1.2;AES256;staging
33386439653762391081743274974402374729374927394729374927394729374927
...

# Use in playbook
- name: Load environment-specific secrets
  include_vars: "{{ environment }}_secrets.yml"
```

### Conditional Vault Loading
```yaml
# Load different vault files based on environment
- name: Load production secrets
  include_vars: vault_production.yml
  when: environment == "production"

- name: Load staging secrets
  include_vars: vault_staging.yml
  when: environment == "staging"

- name: Load development secrets
  include_vars: vault_development.yml
  when: environment == "development"
```

### Vault in Roles
```yaml
# roles/database/defaults/main.yml
---
db_host: localhost
db_port: 3306
db_name: myapp
db_user: myapp_user
# Password will come from vault

# roles/database/vars/main.yml (encrypted)
---
vault_db_password: encrypted_password_here
vault_db_root_password: encrypted_root_password_here

# roles/database/tasks/main.yml
---
- name: Create database
  mysql_db:
    name: "{{ db_name }}"
    state: present
    login_user: root
    login_password: "{{ vault_db_root_password }}"

- name: Create database user
  mysql_user:
    name: "{{ db_user }}"
    password: "{{ vault_db_password }}"
    priv: "{{ db_name }}.*:ALL"
    state: present
    login_user: root
    login_password: "{{ vault_db_root_password }}"
  no_log: true
```

## Security Best Practices

### Password Management
```bash
# Use strong, unique passwords for each vault
# Store vault passwords securely (password managers, HSMs, etc.)
# Rotate vault passwords regularly
# Use different vault IDs for different environments

# Example: Generate strong password
openssl rand -base64 32

# Example: Store in password manager
# 1password get item "Ansible Vault Production" --fields password
```

### File Permissions
```bash
# Secure vault password files
chmod 600 ~/.vault_pass
chown $(whoami):$(whoami) ~/.vault_pass

# Secure vault files themselves
chmod 640 vault_secrets.yml
chown ansible:ansible vault_secrets.yml

# Secure directories
chmod 750 group_vars/production/
chmod 750 host_vars/
```

### Version Control
```bash
# .gitignore - Never commit unencrypted secrets
*.vault_pass
*_password
secrets.txt
.vault_password

# Commit encrypted files safely
git add group_vars/production/vault.yml  # This is encrypted, safe to commit
git add vars/secrets.yml                 # This is encrypted, safe to commit

# Verify files are encrypted before committing
ansible-vault view group_vars/production/vault.yml
```

### Logging and Auditing
```yaml
# Prevent sensitive data in logs
- name: Configure database
  mysql_user:
    name: "{{ db_user }}"
    password: "{{ vault_db_password }}"
    state: present
  no_log: true  # Prevents password from appearing in logs

# Conditional logging
- name: Debug non-sensitive information
  debug:
    msg: "Configuring database {{ db_name }} for user {{ db_user }}"
  # Don't log the password

# Audit vault access
- name: Log vault access
  lineinfile:
    path: /var/log/ansible-vault-access.log
    line: "{{ ansible_date_time.iso8601 }} - {{ ansible_user_id }} accessed vault on {{ inventory_hostname }}"
    create: yes
  delegate_to: localhost
  run_once: true
```

## Integration with External Systems

### AWS Secrets Manager
```python
#!/usr/bin/env python3
# aws_secrets_vault_pass.py
import boto3
import json
import sys

def get_secret(secret_name, region_name="us-east-1"):
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        secret = get_secret_value_response['SecretString']
        return json.loads(secret)['password']
    except Exception as e:
        print(f"Error retrieving secret: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    secret_name = "ansible-vault-password"
    password = get_secret(secret_name)
    print(password)
```

### HashiCorp Vault
```bash
#!/bin/bash
# vault_password_script.sh
# Retrieve Ansible Vault password from HashiCorp Vault

# Authenticate with HashiCorp Vault (example using token)
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="$(cat ~/.vault-token)"

# Retrieve password
vault kv get -field=password secret/ansible/vault-password

# Alternative: Use vault agent for authentication
# vault auth -method=aws
# vault kv get -field=password secret/ansible/vault-password
```

### Azure Key Vault
```python
#!/usr/bin/env python3
# azure_keyvault_pass.py
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
import sys

def get_vault_password():
    try:
        # Use default Azure credentials
        credential = DefaultAzureCredential()
        
        # Key Vault URL
        vault_url = "https://your-keyvault.vault.azure.net/"
        
        # Create client
        client = SecretClient(vault_url=vault_url, credential=credential)
        
        # Retrieve secret
        secret = client.get_secret("ansible-vault-password")
        return secret.value
    
    except Exception as e:
        print(f"Error retrieving secret from Azure Key Vault: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    password = get_vault_password()
    print(password)
```

## Automation and CI/CD Integration

### Jenkins Pipeline
```groovy
pipeline {
    agent any
    
    environment {
        ANSIBLE_VAULT_PASSWORD_FILE = credentials('ansible-vault-password-file')
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    // Run Ansible playbook with vault
                    sh '''
                        ansible-playbook \
                            -i inventory/production \
                            --vault-password-file ${ANSIBLE_VAULT_PASSWORD_FILE} \
                            deploy.yml
                    '''
                }
            }
        }
    }
}
```

### GitLab CI
```yaml
# .gitlab-ci.yml
deploy:
  stage: deploy
  image: ansible/ansible-runner:latest
  before_script:
    - echo "$VAULT_PASSWORD" > .vault_pass
    - chmod 600 .vault_pass
  script:
    - ansible-playbook --vault-password-file .vault_pass -i inventory/production deploy.yml
  after_script:
    - rm -f .vault_pass
  only:
    - main
  variables:
    VAULT_PASSWORD: $ANSIBLE_VAULT_PASSWORD  # Set in GitLab CI/CD variables
```

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy with Ansible Vault
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Ansible
        run: |
          pip install ansible
      
      - name: Create vault password file
        run: |
          echo "${{ secrets.ANSIBLE_VAULT_PASSWORD }}" > .vault_pass
          chmod 600 .vault_pass
      
      - name: Run Ansible playbook
        run: |
          ansible-playbook \
            --vault-password-file .vault_pass \
            -i inventory/production \
            deploy.yml
      
      - name: Cleanup
        if: always()
        run: |
          rm -f .vault_pass
```

## Troubleshooting

### Common Issues
```bash
# Issue: "Decryption failed"
# Solution: Check password and vault ID
ansible-vault view --vault-id prod@prompt secrets.yml

# Issue: "Vault format unhashable type"
# Solution: Check YAML syntax in encrypted file
ansible-vault edit secrets.yml

# Issue: "No vault secrets found"
# Solution: Verify file is actually encrypted
file secrets.yml  # Should show "data" not "ASCII text"

# Issue: "Wrong vault password"
# Solution: Try different vault IDs or password files
ansible-vault view --vault-id staging@prompt secrets.yml
```

### Debugging Vault Issues
```bash
# Verbose output for vault operations
ansible-playbook -vvv --ask-vault-pass playbook.yml

# Check vault file format
head -1 secrets.yml  # Should start with $ANSIBLE_VAULT

# Verify vault password
echo "test_password" | ansible-vault encrypt_string --stdin-name test_var

# Test vault access
ansible-vault view secrets.yml --vault-password-file ~/.vault_pass
```

This comprehensive Vault guide covers all aspects of secure secret management in Ansible automation workflows.