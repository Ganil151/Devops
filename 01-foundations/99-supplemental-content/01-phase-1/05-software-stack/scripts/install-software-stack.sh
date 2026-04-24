#!/bin/bash

#############################################################################
# Script: install-software-stack.sh
# Description: Automated Linux Software Stack Installer (LAMP/LEMP/DevOps)
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   LINUX STACK INSTALLER${NC}"
echo -e "${CYAN}========================================${NC}"

# Detect OS
if [ -f /etc/debian_version ]; then
    OS="Debian"
    PKG_MGR="apt-get"
    UPDATE_CMD="apt-get update"
    INSTALL_CMD="apt-get install -y"
elif [ -f /etc/redhat-release ]; then
    OS="RedHat"
    PKG_MGR="dnf"
    UPDATE_CMD="dnf check-update"
    INSTALL_CMD="dnf install -y"
fi

echo "Detected $OS system."

# Update System
echo -e "\n${CYAN}[1/4] Updating System...${NC}"
$UPDATE_CMD

# Install Tools
echo -e "\n${CYAN}[2/4] Installing Core Tools (curl, git, vim, htop)...${NC}"
$INSTALL_CMD curl git vim htop wget unzip

# Install Stack Option
echo -e "\nSelect Stack to Install:"
echo "1) DevOps Base (Docker, Python, Node, Terraform)"
echo "2) LAMP (Apache, MySQL, PHP)"
echo "3) Minimal (Just tools)"
read -r -p "Selection [1]: " CHOICE
CHOICE=${CHOICE:-1}

if [ "$CHOICE" == "1" ]; then
    echo -e "\n${CYAN}[3/4] Installing DevOps Stack...${NC}"
    
    # Python
    $INSTALL_CMD python3 python3-pip
    
    # Docker
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com | sh
        usermod -aG docker $SUDO_USER
    fi
    
    # Terraform
    if ! command -v terraform &> /dev/null; then
        echo "Installing Terraform..."
        if [ "$OS" == "Debian" ]; then
            wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
            apt-get update && apt-get install terraform
        fi
    fi

elif [ "$CHOICE" == "2" ]; then
    echo -e "\n${CYAN}[3/4] Installing LAMP Stack...${NC}"
    $INSTALL_CMD apache2 mysql-server php libapache2-mod-php php-mysql
fi

echo -e "\n${CYAN}[4/4] Verifying Installation...${NC}"
if command -v git &> /dev/null; then echo -e "${GREEN}Git: $(git --version)${NC}"; fi
if command -v python3 &> /dev/null; then echo -e "${GREEN}Python: $(python3 --version)${NC}"; fi
if command -v docker &> /dev/null; then echo -e "${GREEN}Docker: $(docker --version)${NC}"; fi

echo -e "\n${GREEN}Installation Complete.${NC}"
