#!/bin/bash
set -euo pipefail

# Usage: run as ec2-user / any user with sudo privileges.
# This script is Amazon Linux 2023 compatible.

echo "=== k3s bootstrap (Amazon Linux 2023) ==="
SUDO="sudo"

# update system
$SUDO dnf -y update

# install basic tools
$SUDO dnf install -y curl tar gzip unzip iproute util-linux

# Install Docker (package provided in AL2023)
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing docker..."
  $SUDO dnf install -y docker
  $SUDO systemctl enable --now docker
else
  echo "Docker present"
fi

# Add ec2-user to docker group (may require re-login)
if id ec2-user &>/dev/null; then
  $SUDO usermod -aG docker ec2-user || true
fi

# Install kubectl (client)
if ! command -v kubectl >/dev/null 2>&1; then
  echo "Installing kubectl..."
  KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  ARCH=$(uname -m)
  if [[ "$ARCH" == "aarch64" ]]; then ARCH="arm64"; elif [[ "$ARCH" == "x86_64" ]]; then ARCH="amd64"; fi
  curl -fsSL -o /tmp/kubectl "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl"
  curl -fsSL -o /tmp/kubectl.sha256 "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl.sha256"
  echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check -
  $SUDO install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  rm -f /tmp/kubectl /tmp/kubectl.sha256
else
  echo "kubectl present"
fi

# Install k3s (server)
if ! systemctl is-active --quiet k3s; then
  echo "Installing k3s server..."
  # Set INSTALL_K3S_VERSION if you want a pinned version
  curl -sfL https://get.k3s.io | $SUDO sh -s - --write-kubeconfig-mode 644
  # Wait a bit for k3s to become active
  $SUDO systemctl enable --now k3s
  sleep 5
else
  echo "k3s already installed and running"
fi

# Ensure kubeconfig for ec2-user
KUBECONFIG_SRC=/etc/rancher/k3s/k3s.yaml
KUBECONFIG_DEST=/home/ec2-user/.kube/config
if [ -f "$KUBECONFIG_SRC" ]; then
  $SUDO mkdir -p /home/ec2-user/.kube
  $SUDO cp "$KUBECONFIG_SRC" "$KUBECONFIG_DEST"
  $SUDO chown ec2-user:ec2-user /home/ec2-user/.kube -R
  $SUDO chmod 644 "$KUBECONFIG_DEST"
  echo "KUBECONFIG copied to $KUBECONFIG_DEST"
else
  echo "WARN: $KUBECONFIG_SRC not found yet."
fi

echo "=== Bootstrap completed ==="
echo "Run as ec2-user: kubectl get nodes"

# Print join command for workers (to STDOUT)
if [ -f /var/lib/rancher/k3s/server/node-token ]; then
  echo "k3s token available at /var/lib/rancher/k3s/server/node-token"
  echo "To join worker nodes (example):"
  echo "  sudo curl -sfL https://get.k3s.io | K3S_URL=https://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):6443 K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token) sh -"
fi

