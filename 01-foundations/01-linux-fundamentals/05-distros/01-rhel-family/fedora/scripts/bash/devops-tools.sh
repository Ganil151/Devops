#!/bin/bash
#===============================================================================
# SYNOPSIS
#      DevSecOps Workstation Bootstrap - Fedora 43 Edition v4.4.0
# DESCRIPTION
#      Enterprise-grade provisioning for VS Code, Docker, Terraform, and more.
#      Optimized for Fedora 43 with robust network/DNS error handling.
#===============================================================================

set -euo pipefail

#===============================================================================
# GLOBAL CONFIGURATION
#===============================================================================
readonly LOG_DIR="${HOME}/.devsecops-provisioner"
readonly LOG_PATH="${LOG_DIR}/install.log"
mkdir -p "$LOG_DIR"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

#===============================================================================
# LOGGING & DIAGNOSTICS
#===============================================================================
log() { echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[OK] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

#===============================================================================
# PRE-FLIGHT CHECKS
#===============================================================================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "Elevating to root privileges..."
        exec sudo "$0" "$@"
    fi
}

check_network() {
    log "Verifying network connectivity..."
    # Attempt to fetch a single byte from Google as a connectivity test
    if ! curl -s --connect-timeout 5 https://www.google.com > /dev/null; then
        warn "Primary connectivity check failed. Checking DNS..."
        if ! host github.com >/dev/null 2>&1; then
            warn "DNS resolution failed. Adding temporary Google DNS (8.8.8.8)..."
            echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf > /dev/null
        fi
        # Re-check after DNS fix
        if ! curl -s --connect-timeout 5 https://www.google.com > /dev/null; then
            error "No internet connectivity detected. Please check your network."
            exit 1
        fi
    fi
    success "Network connectivity verified."
}

#===============================================================================
# INSTALLATION HELPERS
#===============================================================================
install_package() {
    local pkg_name=$1
    if rpm -q "$pkg_name" >/dev/null 2>&1; then
        success "$pkg_name is already installed."
    else
        log "Installing $pkg_name..."
        dnf install -y "$pkg_name" -q
        success "$pkg_name installed."
    fi
}

#===============================================================================
# TOOL PROVISIONING
#===============================================================================

install_vscode() {
    if command -v code >/dev/null 2>&1; then
        success "VS Code is already installed."
    else
        log "Configuring VS Code Repository..."
        rpm --import https://packages.microsoft.com/keys/microsoft.asc
        cat <<EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
        install_package "code"
        
        # Extensions for the non-root user
        log "Installing VS Code extensions..."
        sudo -u "${SUDO_USER:-$USER}" code --install-extension ms-vscode.cpptools --force >/dev/null 2>&1 || true
        sudo -u "${SUDO_USER:-$USER}" code --install-extension ms-python.python --force >/dev/null 2>&1 || true
        sudo -u "${SUDO_USER:-$USER}" code --install-extension hashicorp.terraform --force >/dev/null 2>&1 || true
    fi
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        success "Docker is already installed."
    else
        log "Configuring Docker Repository..."
        cat <<EOF > /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
        install_package "docker-ce"
        install_package "docker-ce-cli"
        install_package "containerd.io"
        systemctl enable --now docker
        usermod -aG docker "${SUDO_USER:-$USER}"
    fi
}

install_terraform() {
    if command -v terraform >/dev/null 2>&1; then
        success "Terraform is already installed."
    else
        log "Configuring HashiCorp Repository..."
        cat <<EOF > /etc/yum.repos.d/hashicorp.repo
[hashicorp]
name=HashiCorp Stable - \$basearch
baseurl=https://rpm.releases.hashicorp.com/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF
        install_package "terraform"
    fi
}

install_kubernetes_tools() {
    # Kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        log "Installing kubectl..."
        cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
EOF
        install_package "kubectl"
    fi

    # Helm
    if ! command -v helm >/dev/null 2>&1; then
        log "Installing Helm..."
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
}

install_security_tools() {
    # Trivy Repository (Avoids GitHub download errors)
    if ! command -v trivy >/dev/null 2>&1; then
        log "Configuring Trivy Repository..."
        cat <<EOF > /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=0
enabled=1
EOF
        install_package "trivy"
    fi

    # Checkov
    if ! command -v checkov >/dev/null 2>&1; then
        log "Installing Checkov..."
        install_package "python3-pip"
        sudo -u "${SUDO_USER:-$USER}" pip3 install --user checkov -q
    fi
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================
main() {
    check_root
    check_network
    
    log "Starting DevSecOps Workstation Bootstrap for Fedora 43..."
    
    # Core system update
    dnf upgrade -y -q
    
    # Utility Tools
    install_package "git"
    install_package "jq"
    install_package "yq"
    install_package "ansible"
    
    # Major Components
    install_docker
    install_terraform
    install_kubernetes_tools
    install_security_tools
    install_vscode
    
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}   SUCCESS: PROVISIONING COMPLETE          ${NC}"
    echo -e "${GREEN}   Please restart your shell or logout/in  ${NC}"
    echo -e "${GREEN}   to enable Docker group permissions.     ${NC}"
    echo -e "${GREEN}===========================================${NC}"
}

main
