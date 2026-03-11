#!/bin/bash
# =============================================================================
# Jumphost User Data Script
# Project: Finish Line 2026 Infrastructure
# Assignment Reference: Finish Line 2026 §69, §70, §73, §92
# Purpose: Install required tools on Amazon Linux 2023 jumphost
# Tools: aws-cli v2, kubectl, helm, kustomize, mysql-client
# =============================================================================

set -e

echo "=== Starting Jumphost Initialization ==="
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# -----------------------------------------------------------------------------
# System Update
# -----------------------------------------------------------------------------
echo "=== Updating System Packages ==="
dnf update -y

# -----------------------------------------------------------------------------
# Install AWS CLI v2
# Reference: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# -----------------------------------------------------------------------------
echo "=== Installing AWS CLI v2 ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
rm -rf /tmp/aws /tmp/awscliv2.zip
echo "AWS CLI installed: $(aws --version)"

# -----------------------------------------------------------------------------
# Install kubectl
# Reference: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# -----------------------------------------------------------------------------
echo "=== Installing kubectl ==="
K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
echo "Kubernetes stable version: ${K8S_VERSION}"
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
rm -f kubectl
echo "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

# -----------------------------------------------------------------------------
# Install Helm
# Reference: https://helm.sh/docs/intro/install/
# -----------------------------------------------------------------------------
echo "=== Installing Helm ==="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
echo "Helm installed: $(helm version --short)"

# -----------------------------------------------------------------------------
# Install Kustomize
# Reference: https://kubectl.docs.kubernetes.io/installation/kustomize/
# -----------------------------------------------------------------------------
echo "=== Installing Kustomize ==="
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
mv kustomize /usr/local/bin/
echo "Kustomize installed: $(kustomize version)"

# -----------------------------------------------------------------------------
# Install MySQL Client
# -----------------------------------------------------------------------------
echo "=== Installing MySQL Client ==="
dnf install -y mysql
echo "MySQL client installed: $(mysql --version)"

# -----------------------------------------------------------------------------
# Install Additional Useful Tools
# -----------------------------------------------------------------------------
echo "=== Installing Additional Tools ==="

# Install jq for JSON processing
dnf install -y jq
echo "jq installed: $(jq --version)"

# Install unzip (required for various operations)
dnf install -y unzip

# Install git for version control
dnf install -y git
echo "git installed: $(git --version)"

# -----------------------------------------------------------------------------
# Configure Shell Environment
# -----------------------------------------------------------------------------
echo "=== Configuring Shell Environment ==="

# Add kubectl completion to bashrc
cat >> /home/ec2-user/.bashrc <<'EOF'

# Kubernetes aliases and completions
alias k=kubectl
complete -o default -F __start_kubectl k

# Helm completions
source <(helm completion bash)

# Useful aliases
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgs='kubectl get services'
EOF

# Apply the changes
su - ec2-user -c "source /home/ec2-user/.bashrc"

# -----------------------------------------------------------------------------
# Verification
# -----------------------------------------------------------------------------
echo ""
echo "=== Installation Summary ==="
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""
echo "Tool Versions:"
echo "  - AWS CLI:      $(aws --version 2>&1 | head -1)"
echo "  - kubectl:      $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>&1 | head -1)"
echo "  - Helm:         $(helm version --short)"
echo "  - Kustomize:    $(kustomize version 2>&1 | head -1)"
echo "  - MySQL:        $(mysql --version)"
echo "  - jq:           $(jq --version)"
echo "  - git:          $(git --version)"
echo ""
echo "=== Jumphost Setup Complete ==="
