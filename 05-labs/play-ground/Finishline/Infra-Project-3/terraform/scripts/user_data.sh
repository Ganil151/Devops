#!/bin/bash
# =============================================================================
# Jumphost User Data Script - Tool Installation
# Finish Line 2026 Infrastructure
# Assignment: §F - Install mysql-client, kubectl, aws-cli v2, helm, kustomize
# =============================================================================

set -xe



# Log start
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== User Data Script Started at $(date) ==="

# =============================================================================
# Install AWS CLI v2
# =============================================================================
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install --update
rm -rf aws awscliv2.zip

AWS_VERSION=$(aws --version 2>&1 | head -n1)
echo "AWS CLI installed: $AWS_VERSION"

# =============================================================================
# Install kubectl
# =============================================================================
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl

KUBECTL_VERSION=$(kubectl version --client --output=yaml | grep gitVersion | head -n1)
echo "Kubectl installed: $KUBECTL_VERSION"

# =============================================================================
# Install Helm (latest)
# =============================================================================
echo "Installing Helm..."
HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"
tar -xzf "helm-${HELM_VERSION}-linux-amd64.tar.gz"
mv linux-amd64/helm /usr/local/bin/helm
rm -rf "helm-${HELM_VERSION}-linux-amd64.tar.gz" linux-amd64

HELM_VER=$(helm version --short)
echo "Helm installed: $HELM_VER"

# =============================================================================
# Install Kustomize (latest)
# =============================================================================
echo "Installing Kustomize..."
KUSTOMIZE_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -LO "https://github.com/kubernetes-sigs/kustomize/releases/download/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz"
tar -xzf "kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz"
mv kustomize /usr/local/bin/kustomize
chmod +x /usr/local/bin/kustomize
rm -rf "kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz"

KUSTOMIZE_VER=$(kustomize version --short)
echo "Kustomize installed: $KUSTOMIZE_VER"

# =============================================================================
# Install MySQL Client
# =============================================================================
echo "Installing MySQL client..."
dnf install -y mysql

MYSQL_VER=$(mysql --version)
echo "MySQL client installed: $MYSQL_VER"

# =============================================================================
# Install additional utilities
# =============================================================================
echo "Installing additional utilities..."
dnf install -y \
    jq \
    git \
    vim \
    telnet \
    net-tools \
    bind-utils

# =============================================================================
# Configure kubeconfig directory
# =============================================================================
echo "Configuring kubeconfig directory..."
mkdir -p /home/ec2-user/.kube
chown ec2-user:ec2-user /home/ec2-user/.kube
chmod 700 /home/ec2-user/.kube

# =============================================================================
# Create verification script
# =============================================================================
cat > /home/ec2-user/verify-tools.sh << 'VERIFY'
#!/bin/bash
echo "=== Tool Verification Checklist ==="
echo ""
echo "1. AWS CLI v2:"
aws --version
echo ""
echo "2. Kubectl:"
kubectl version --client --output=yaml | grep gitVersion
echo ""
echo "3. Helm:"
helm version --short
echo ""
echo "4. Kustomize:"
kustomize version --short
echo ""
echo "5. MySQL Client:"
mysql --version
echo ""
echo "=== All tools verified ==="
VERIFY

chmod +x /home/ec2-user/verify-tools.sh
chown ec2-user:ec2-user /home/ec2-user/verify-tools.sh

# =============================================================================
# Log completion
# =============================================================================
echo "=== User Data Script Completed at $(date) ==="
echo "=== All tools installed successfully ==="
touch /var/log/user-data.complete
