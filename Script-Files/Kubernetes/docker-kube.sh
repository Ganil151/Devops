#!/bin/bash

set -e

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Add Docker's official GPG key:
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker packages
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
sudo systemctl start docker

# Install Kubernetes
sudo apt update

# Download kubectl binary
KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
ARCH=$(uname -m)

if [[ "$ARCH" == "aarch64" ]]; then
  ARCH="arm64"
elif [[ "$ARCH" == "x86_64" ]]; then
  ARCH="amd64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

curl -LO "https://dl.k8s.io/release/$KUBE_VERSION/bin/linux/$ARCH/kubectl"
curl -LO "https://dl.k8s.io/release/$KUBE_VERSION/bin/linux/$ARCH/kubectl.sha256"

# Verify the kubectl binary
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Clean up downloaded files
rm kubectl kubectl.sha256

# Verify installation
kubectl version --client