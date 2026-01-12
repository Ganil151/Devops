#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "master"

# Install required packages
sudo yum install -y java-17-amazon-corretto-devel git jenkins python3.11 jq python3-pip

# Enable amazon-linux-extras
sudo amazon-linux-extras enable java-openjdk11

# Install Ansible
sudo pip3 install ansible

# Verify installations
java -version
ansible --version

# Increase Jenkins /tmp Directory
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Enable & start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins 

# Create SSH Directory
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins chmod 700 /var/lib/jenkins/.ssh

# Generate SSH key as jenkins user
sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa

# Create known_hosts file
sudo -u jenkins touch /var/lib/jenkins/.ssh/known_hosts

# Fix permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo -u jenkins chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/known_hosts

# === AUTO FETCH WORKER IP AND CONFIGURE SSH ===

# Method 1: If worker is in same VPC, get it from AWS metadata or predefined list
echo "Attempting to auto-discover worker IP..."

# Option A: Get worker IP from AWS EC2 tags (if using consistent tagging)
WORKER_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*worker*" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text 2>/dev/null || echo "")

# Option B: If you know the worker name pattern, use it
if [ -z "$WORKER_IP" ] || [ "$WORKER_IP" = "None" ]; then
    WORKER_IP=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=*slave*" "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text 2>/dev/null || echo "")
fi

# Option C: Get from Terraform output (if available)
if [ -z "$WORKER_IP" ] || [ "$WORKER_IP" = "None" ]; then
    if [ -f "/tmp/terraform-output.json" ]; then
        WORKER_IP=$(jq -r '.worker_public_ip.value' /tmp/terraform-output.json 2>/dev/null || echo "")
    fi
fi

# Option D: Fallback - get from environment variable (set by Terraform/user data)
if [ -z "$WORKER_IP" ] || [ "$WORKER_IP" = "None" ]; then
    WORKER_IP="${WORKER_IP_ADDRESS}"  # Set this in Terraform user_data
fi

# Validate IP address
if [ -n "$WORKER_IP" ] && [ "$WORKER_IP" != "None" ] && [[ $WORKER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Found worker IP: $WORKER_IP"
    
    # Add worker to known_hosts
    sudo -u jenkins ssh-keyscan -H "$WORKER_IP" | sudo -u jenkins tee -a /var/lib/jenkins/.ssh/known_hosts > /dev/null
    
    # Optional: Create inventory file for Ansible
    cat > /tmp/inventory.ini << EOF
[jenkins-workers]
worker ansible_host=$WORKER_IP ansible_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
    
    echo "Worker IP configured successfully"
else
    echo "WARNING: Could not auto-detect worker IP. Please configure manually."
    echo "You can add worker IP later using:"
    echo "sudo -u jenkins ssh-keyscan -H <WORKER_IP> | sudo -u jenkins tee -a /var/lib/jenkins/.ssh/known_hosts > /dev/null"
fi

# Display Jenkins public key for manual worker configuration
echo "=== JENKINS PUBLIC KEY ==="
sudo cat /var/lib/jenkins/.ssh/id_rsa.pub
echo "========================="

echo "Jenkins Master setup completed!"