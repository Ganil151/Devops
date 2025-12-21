# SSH Key Management

Complete guide to SSH key generation, distribution, rotation, and lifecycle management.

## Key Generation

### Key Types and Algorithms
```bash
# Ed25519 (recommended - fastest, most secure)
ssh-keygen -t ed25519 -C "user@example.com"

# RSA (traditional, widely supported)
ssh-keygen -t rsa -b 4096 -C "user@example.com"

# ECDSA (elliptic curve)
ssh-keygen -t ecdsa -b 521 -C "user@example.com"

# DSA (deprecated, avoid)
# ssh-keygen -t dsa
```

### Key Generation Best Practices
```bash
# Generate with specific filename and comment
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_prod -C "production-access-$(date +%Y%m%d)"

# Generate with passphrase (recommended for production)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_secure -N "strong-passphrase"

# Generate without passphrase (automation use)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_automation -N ""

# Generate with specific key format
ssh-keygen -t rsa -b 4096 -m PEM -f ~/.ssh/id_rsa_legacy
```

### Batch Key Generation
```bash
#!/bin/bash
# generate-keys.sh - Generate keys for multiple environments

ENVIRONMENTS=("production" "staging" "development")
KEY_TYPE="ed25519"
KEY_DIR="$HOME/.ssh"

for env in "${ENVIRONMENTS[@]}"; do
    key_file="$KEY_DIR/id_${KEY_TYPE}_${env}"
    
    if [[ ! -f "$key_file" ]]; then
        echo "Generating key for $env environment..."
        ssh-keygen -t $KEY_TYPE -f "$key_file" -C "${env}-access-$(whoami)@$(hostname)-$(date +%Y%m%d)" -N ""
        echo "Generated: $key_file"
    else
        echo "Key already exists: $key_file"
    fi
done
```

## Key Distribution

### Manual Distribution
```bash
# Copy public key to remote server
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@remote-host

# Copy to specific port
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 user@remote-host

# Copy to multiple servers
for server in web1 web2 web3; do
    ssh-copy-id -i ~/.ssh/id_ed25519.pub user@$server
done
```

### Automated Distribution
```bash
#!/bin/bash
# distribute-keys.sh - Automated key distribution

PUBLIC_KEY="$HOME/.ssh/id_ed25519.pub"
SERVERS_FILE="servers.txt"
SSH_USER="deploy"

# Validate inputs
if [[ ! -f "$PUBLIC_KEY" ]]; then
    echo "Error: Public key not found: $PUBLIC_KEY"
    exit 1
fi

if [[ ! -f "$SERVERS_FILE" ]]; then
    echo "Error: Servers file not found: $SERVERS_FILE"
    exit 1
fi

# Distribute keys
while IFS= read -r server; do
    [[ -z "$server" || "$server" =~ ^# ]] && continue
    
    echo "Distributing key to $server..."
    
    if ssh-copy-id -i "$PUBLIC_KEY" "$SSH_USER@$server" 2>/dev/null; then
        echo "✓ Success: $server"
    else
        echo "✗ Failed: $server"
    fi
done < "$SERVERS_FILE"
```

### Ansible Key Distribution
```yaml
# distribute-ssh-keys.yml
---
- name: Distribute SSH keys to servers
  hosts: all
  become: yes
  
  tasks:
    - name: Ensure .ssh directory exists
      file:
        path: "/home/{{ ansible_user }}/.ssh"
        state: directory
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0700'
    
    - name: Add SSH public key
      authorized_key:
        user: "{{ ansible_user }}"
        key: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"
        state: present
        exclusive: no
    
    - name: Set authorized_keys permissions
      file:
        path: "/home/{{ ansible_user }}/.ssh/authorized_keys"
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0600'
```

## Key Rotation

### Rotation Strategy
```bash
#!/bin/bash
# rotate-ssh-keys.sh - SSH key rotation script

OLD_KEY="$HOME/.ssh/id_ed25519_old"
NEW_KEY="$HOME/.ssh/id_ed25519"
SERVERS_FILE="servers.txt"
SSH_USER="deploy"

# Step 1: Generate new key pair
echo "Generating new SSH key pair..."
ssh-keygen -t ed25519 -f "${NEW_KEY}_new" -C "rotated-$(date +%Y%m%d)-$(whoami)@$(hostname)" -N ""

# Step 2: Distribute new public key
echo "Distributing new public key..."
while IFS= read -r server; do
    [[ -z "$server" || "$server" =~ ^# ]] && continue
    
    echo "Adding new key to $server..."
    ssh-copy-id -i "${NEW_KEY}_new.pub" "$SSH_USER@$server"
done < "$SERVERS_FILE"

# Step 3: Test new key
echo "Testing new key access..."
test_failed=false
while IFS= read -r server; do
    [[ -z "$server" || "$server" =~ ^# ]] && continue
    
    if ssh -i "${NEW_KEY}_new" -o ConnectTimeout=10 "$SSH_USER@$server" "echo 'Connection test successful'" 2>/dev/null; then
        echo "✓ New key works on $server"
    else
        echo "✗ New key failed on $server"
        test_failed=true
    fi
done < "$SERVERS_FILE"

if [[ "$test_failed" == "true" ]]; then
    echo "Key rotation failed. New key doesn't work on all servers."
    exit 1
fi

# Step 4: Backup old key and activate new key
echo "Activating new key..."
[[ -f "$NEW_KEY" ]] && mv "$NEW_KEY" "$OLD_KEY"
[[ -f "$NEW_KEY.pub" ]] && mv "$NEW_KEY.pub" "$OLD_KEY.pub"
mv "${NEW_KEY}_new" "$NEW_KEY"
mv "${NEW_KEY}_new.pub" "$NEW_KEY.pub"

# Step 5: Remove old public key from servers (optional)
read -p "Remove old key from servers? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    while IFS= read -r server; do
        [[ -z "$server" || "$server" =~ ^# ]] && continue
        
        echo "Removing old key from $server..."
        ssh -i "$NEW_KEY" "$SSH_USER@$server" "sed -i '/$(cat $OLD_KEY.pub | cut -d' ' -f2)/d' ~/.ssh/authorized_keys"
    done < "$SERVERS_FILE"
fi

echo "Key rotation completed successfully!"
```

### Automated Rotation with Cron
```bash
# Add to crontab for monthly rotation
0 2 1 * * /usr/local/bin/rotate-ssh-keys.sh >> /var/log/ssh-key-rotation.log 2>&1
```

## Key Lifecycle Management

### Key Inventory
```bash
#!/bin/bash
# ssh-key-inventory.sh - Generate SSH key inventory

SSH_DIR="$HOME/.ssh"
INVENTORY_FILE="ssh-key-inventory-$(date +%Y%m%d).csv"

echo "Filename,Type,Bits,Fingerprint,Comment,Created,LastUsed" > "$INVENTORY_FILE"

for key_file in "$SSH_DIR"/id_*; do
    [[ ! -f "$key_file" ]] && continue
    [[ "$key_file" == *.pub ]] && continue
    
    # Get key information
    key_type=$(ssh-keygen -l -f "$key_file" 2>/dev/null | awk '{print $4}' | tr -d '()')
    key_bits=$(ssh-keygen -l -f "$key_file" 2>/dev/null | awk '{print $1}')
    fingerprint=$(ssh-keygen -l -f "$key_file" 2>/dev/null | awk '{print $2}')
    comment=$(ssh-keygen -l -f "$key_file" 2>/dev/null | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/[()]//')
    created=$(stat -c %y "$key_file" 2>/dev/null | cut -d' ' -f1)
    last_used=$(stat -c %x "$key_file" 2>/dev/null | cut -d' ' -f1)
    
    echo "$(basename $key_file),$key_type,$key_bits,$fingerprint,$comment,$created,$last_used" >> "$INVENTORY_FILE"
done

echo "Key inventory saved to: $INVENTORY_FILE"
```

### Key Validation
```bash
#!/bin/bash
# validate-ssh-keys.sh - Validate SSH key integrity

SSH_DIR="$HOME/.ssh"
validation_failed=false

echo "Validating SSH keys in $SSH_DIR..."

for key_file in "$SSH_DIR"/id_*; do
    [[ ! -f "$key_file" ]] && continue
    [[ "$key_file" == *.pub ]] && continue
    
    echo -n "Validating $(basename $key_file)... "
    
    # Check private key format
    if ssh-keygen -y -f "$key_file" >/dev/null 2>&1; then
        echo "✓ Valid"
        
        # Check if public key exists and matches
        pub_file="${key_file}.pub"
        if [[ -f "$pub_file" ]]; then
            generated_pub=$(ssh-keygen -y -f "$key_file")
            stored_pub=$(cat "$pub_file")
            
            if [[ "$generated_pub" == "$stored_pub" ]]; then
                echo "  ✓ Public key matches"
            else
                echo "  ✗ Public key mismatch"
                validation_failed=true
            fi
        else
            echo "  ⚠ Public key file missing"
        fi
    else
        echo "✗ Invalid or corrupted"
        validation_failed=true
    fi
done

if [[ "$validation_failed" == "true" ]]; then
    echo "Key validation failed!"
    exit 1
else
    echo "All keys validated successfully!"
fi
```

## SSH Agent Management

### SSH Agent Operations
```bash
# Start SSH agent
eval $(ssh-agent)

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Add key with specific lifetime (1 hour)
ssh-add -t 3600 ~/.ssh/id_ed25519

# List loaded keys
ssh-add -l

# List loaded keys with fingerprints
ssh-add -L

# Remove specific key
ssh-add -d ~/.ssh/id_ed25519

# Remove all keys
ssh-add -D

# Kill SSH agent
ssh-agent -k
```

### Automated Agent Management
```bash
#!/bin/bash
# ssh-agent-manager.sh - Manage SSH agent lifecycle

AGENT_ENV="$HOME/.ssh/agent-environment"

start_agent() {
    echo "Starting SSH agent..."
    ssh-agent > "$AGENT_ENV"
    chmod 600 "$AGENT_ENV"
    source "$AGENT_ENV" > /dev/null
    
    # Add default keys
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
}

load_agent() {
    if [[ -f "$AGENT_ENV" ]]; then
        source "$AGENT_ENV" > /dev/null
        
        # Check if agent is running
        if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
            start_agent
        fi
    else
        start_agent
    fi
}

case "${1:-load}" in
    start)
        start_agent
        ;;
    load)
        load_agent
        ;;
    stop)
        if [[ -f "$AGENT_ENV" ]]; then
            source "$AGENT_ENV" > /dev/null
            ssh-agent -k
            rm -f "$AGENT_ENV"
        fi
        ;;
    status)
        if [[ -f "$AGENT_ENV" ]]; then
            source "$AGENT_ENV" > /dev/null
            if kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
                echo "SSH agent is running (PID: $SSH_AGENT_PID)"
                ssh-add -l
            else
                echo "SSH agent is not running"
            fi
        else
            echo "SSH agent environment not found"
        fi
        ;;
    *)
        echo "Usage: $0 {start|load|stop|status}"
        exit 1
        ;;
esac
```

## Key Security

### Secure Key Storage
```bash
# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/config

# Encrypt private keys with strong passphrase
ssh-keygen -p -f ~/.ssh/id_ed25519

# Use hardware security modules (HSM)
# PKCS#11 integration
ssh-keygen -D /usr/lib/pkcs11/opensc-pkcs11.so
```

### Key Backup and Recovery
```bash
#!/bin/bash
# backup-ssh-keys.sh - Secure SSH key backup

BACKUP_DIR="/secure/backup/ssh-keys"
DATE=$(date +%Y%m%d_%H%M%S)
SSH_DIR="$HOME/.ssh"

# Create encrypted backup
mkdir -p "$BACKUP_DIR"
tar -czf - -C "$HOME" .ssh | gpg --cipher-algo AES256 --compress-algo 1 --symmetric --output "$BACKUP_DIR/ssh-keys-backup-$DATE.tar.gz.gpg"

echo "SSH keys backed up to: $BACKUP_DIR/ssh-keys-backup-$DATE.tar.gz.gpg"

# Restore from backup
# gpg --decrypt ssh-keys-backup-DATE.tar.gz.gpg | tar -xzf - -C "$HOME"
```

This comprehensive key management guide ensures secure and efficient SSH key lifecycle management across all environments.