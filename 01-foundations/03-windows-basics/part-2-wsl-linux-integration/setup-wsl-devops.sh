#!/bin/bash

# ==============================================================================
# Script Name: setup-wsl-devops.sh
# Description: Installs Docker, Docker Compose, Java 21, Terraform, Minikube, 
#              and Ansible on WSL Ubuntu 25.04.
# Author: Gsmash ganilbatistyan@gmail.com
# ==============================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Starting WSL DevOps Environment Setup...${NC}"

# 1. Update and Upgrade System
echo -e "${GREEN}>>> Updating and Upgrading System Packages...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Install common dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common wget

# 2. Install Docker & Docker Compose
echo -e "${GREEN}>>> Installing Docker & Docker Compose...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Setup docker group (optional but recommended)
sudo usermod -aG docker $USER

# 3. Install Java 21
echo -e "${GREEN}>>> Installing Java 21 (OpenJDK)...${NC}"
sudo apt install -y openjdk-21-jdk

# 4. Install Terraform
echo -e "${GREEN}>>> Installing Terraform...${NC}"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg --yes
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# 5. Install Minikube
echo -e "${GREEN}>>> Installing Minikube...${NC}"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# 6. Install Ansible
echo -e "${GREEN}>>> Installing Ansible...${NC}"
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Final Upgrade to ensure everything is latest
echo -e "${GREEN}>>> Final system upgrade...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${BLUE}>>> All tools installed successfully!${NC}"
echo -e "${BLUE}>>> Note: You may need to logout and login again for Docker group changes to take effect.${NC}"
echo -e "${BLUE}>>> Docker Version: $(docker --version)"
echo -e "${BLUE}>>> Java Version: $(java -version 2>&1 | head -n 1)"
echo -e "${BLUE}>>> Terraform Version: $(terraform --version | head -n 1)"
echo -e "${BLUE}>>> Minikube Version: $(minikube version | head -n 1)"
echo -e "${BLUE}>>> Ansible Version: $(ansible --version | head -n 1)"
