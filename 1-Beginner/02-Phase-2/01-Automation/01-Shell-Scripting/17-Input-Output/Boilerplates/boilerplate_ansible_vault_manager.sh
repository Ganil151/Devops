#!/bin/bash

# boilerplate_ansible_vault_manager.sh - Secret rotation automation

set -euo pipefail

readonly VAULT_PASSWORD_FILE=".vault_pass"
readonly SECRET_FILE="secrets.yml"

# Encrypt secrets from stdin
encrypt_secret() {
    cat <<EOF | ansible-vault encrypt_string --vault-password-file="$VAULT_PASSWORD_FILE"
$1
EOF
}

# Decrypt and display
decrypt_secret() {
    ansible-vault decrypt --vault-password-file="$VAULT_PASSWORD_FILE" "$SECRET_FILE" --output=-
}

# Rotate secret
rotate_secret() {
    local key="$1"
    local new_value="$2"
    
    ansible-vault decrypt "$SECRET_FILE" --vault-password-file="$VAULT_PASSWORD_FILE" --output=temp.yml
    sed -i "s/${key}:.*/${key}: ${new_value}/" temp.yml
    ansible-vault encrypt temp.yml --vault-password-file="$VAULT_PASSWORD_FILE" --output="$SECRET_FILE"
    rm temp.yml
    
    echo "✓ Secret rotated: $key"
}

# Example
echo "Ansible Vault manager loaded"
echo "Functions: encrypt_secret, decrypt_secret, rotate_secret"
