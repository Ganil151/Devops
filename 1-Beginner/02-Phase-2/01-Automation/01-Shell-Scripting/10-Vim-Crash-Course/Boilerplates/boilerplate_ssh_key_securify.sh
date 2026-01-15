#!/bin/bash

# boilerplate_ssh_key_securify.sh - Fix SSH key permissions for Ansible

set -euo pipefail

readonly SSH_DIR="$HOME/.ssh"
readonly KEY_FILES=("id_rsa" "ansible_key.pem" "*.pem")

for pattern in "${KEY_FILES[@]}"; do
    for key in $SSH_DIR/$pattern; do
        [ -f "$key" ] || continue
        
        current_perms=$(stat -c "%a" "$key" 2>/dev/null || stat -f "%Lp" "$key")
        
        if [ "$current_perms" != "600" ]; then
            chmod 600 "$key"
            echo "✓ Fixed: $key (was $current_perms, now 600)"
        else
            echo "✓ OK: $key"
        fi
    done
done

echo "SSH key permissions secured!"
