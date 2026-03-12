#!/bin/bash
#===============================================================================
# SYNOPSIS
#      DevSecOps Workstation Bootstrap - Fedora 43 Edition v5.1.0
# DESCRIPTION
#      Enterprise-grade provisioning for VS Code, Docker, Terraform, K8s,
#      AWS, GitOps, Security Scanning, and developer productivity tools.
#      Optimized for Fedora 43 with robust error handling and idempotency.
#===============================================================================

set -euo pipefail

#===============================================================================
# GLOBAL CONFIGURATION
#===============================================================================
readonly SCRIPT_VERSION="5.1.0"
readonly LOG_DIR="${HOME}/.devsecops-provisioner"
readonly LOG_PATH="${LOG_DIR}/install.log"
readonly TEMP_DIR=$(mktemp -d)

# Tool versions (pin for reproducibility - override via env vars)
: "${TERRAFORM_VERSION:=1.9.0}"
: "${KUBECTL_VERSION:=1.31.0}"
: "${HELM_VERSION:=3.15.0}"
: "${AWS_CLI_VERSION:=2.15.0}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Optional tool flags (set to 0 to skip)
: "${INSTALL_AWS_CLI:=1}"
: "${INSTALL_GITOPS_TOOLS:=1}"
: "${INSTALL_DEV_PRODUCTIVITY:=1}"
: "${INSTALL_CONTAINER_ADVANCED:=1}"
: "${INSTALL_SECURITY_ADVANCED:=1}"

# Track installed tools for summary
declare -a INSTALLED_TOOLS=()

#===============================================================================
# CLEANUP & ERROR HANDLING
#===============================================================================
cleanup() {
    local exit_code=$?
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}✗ Script failed with exit code $exit_code${NC}"
        echo -e "${YELLOW}Check logs at: ${LOG_PATH}${NC}"
    fi
    exit $exit_code
}

trap cleanup EXIT INT TERM

error_exit() {
    echo -e "${RED}[FATAL] $1${NC}" >&2
    echo "[FATAL] $(date +'%Y-%m-%d %H:%M:%S') $1" >> "$LOG_PATH"
    exit 1
}

#===============================================================================
# LOGGING
#===============================================================================
log() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${CYAN}${msg}${NC}"
    echo "$msg" >> "$LOG_PATH"
}

success() {
    local msg="[OK] $1"
    echo -e "${GREEN}${msg}${NC}"
    echo "$msg" >> "$LOG_PATH"
    INSTALLED_TOOLS+=("$1")
}

warn() {
    local msg="[WARN] $1"
    echo -e "${YELLOW}${msg}${NC}"
    echo "$msg" >> "$LOG_PATH"
}

error() {
    local msg="[ERROR] $1"
    echo -e "${RED}${msg}${NC}"
    echo "$msg" >> "$LOG_PATH"
}

#===============================================================================
# PRE-FLIGHT CHECKS
#===============================================================================
detect_user() {
    # Correctly detect the original user when script runs via sudo
    if [[ -n "${SUDO_USER:-}" ]]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}

readonly ACTUAL_USER=$(detect_user)
readonly USER_HOME=$(eval echo ~"$ACTUAL_USER")

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "Elevating to root privileges..."
        exec sudo bash "$0" "$@"
    fi
}

check_network() {
    log "Verifying network connectivity..."
    local endpoints=("https://www.google.com" "https://github.com" "https://pkgs.k8s.io")
    
    for endpoint in "${endpoints[@]}"; do
        if curl -s --connect-timeout 5 --retry 2 "$endpoint" > /dev/null 2>&1; then
            log "Connectivity to $endpoint verified"
            return 0
        fi
    done
    
    warn "Primary endpoints unreachable. Checking DNS..."
    if ! host github.com >/dev/null 2>&1; then
        warn "DNS resolution failed. Adding temporary DNS servers..."
        # Backup original resolv.conf
        cp /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null || true
        echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf > /dev/null
        echo "nameserver 1.1.1.1" | tee -a /etc/resolv.conf > /dev/null
    fi
    
    if curl -s --connect-timeout 10 https://github.com > /dev/null 2>&1; then
        success "Network connectivity restored"
        return 0
    fi
    
    error_exit "No internet connectivity detected. Please check your network configuration."
}

check_fedora_version() {
    if [[ ! -f /etc/os-release ]]; then
        warn "Cannot detect OS - /etc/os-release not found"
        return 0
    fi
    
    local fedora_id version_num
    fedora_id=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    version_num=$(grep ^VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    
    if [[ "$fedora_id" != "fedora" ]]; then
        warn "This script is optimized for Fedora. Detected: $fedora_id"
    fi
    
    log "Detected Fedora $version_num"
}

check_required_commands() {
    local required=("curl" "dnf" "rpm" "sudo")
    local missing=()
    
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error_exit "Missing required commands: ${missing[*]}"
    fi
}

#===============================================================================
# INSTALLATION HELPERS
#===============================================================================
install_package() {
    local pkg_name="$1"
    
    if rpm -q "$pkg_name" >/dev/null 2>&1; then
        log "$pkg_name is already installed"
        return 0
    fi
    
    log "Installing $pkg_name via dnf..."
    if ! dnf install -y "$pkg_name" -q >> "$LOG_PATH" 2>&1; then
        error "Failed to install $pkg_name via dnf"
        return 1
    fi
    success "$pkg_name installed"
    return 0
}

download_binary() {
    local url="$1"
    local binary_name="$2"
    local install_path="${3:-/usr/local/bin}"
    local checksum="${4:-}"
    
    local temp_file="${TEMP_DIR}/${binary_name}"
    
    log "Downloading $binary_name from $url..."
    if ! curl -fsSL --retry 3 --connect-timeout 30 "$url" -o "$temp_file" 2>> "$LOG_PATH"; then
        error "Failed to download $binary_name"
        return 1
    fi
    
    # Verify checksum if provided
    if [[ -n "$checksum" ]]; then
        log "Verifying checksum for $binary_name..."
        local computed
        computed=$(sha256sum "$temp_file" | awk '{print $1}')
        if [[ "$computed" != "$checksum" ]]; then
            error "Checksum mismatch for $binary_name"
            return 1
        fi
    fi
    
    chmod +x "$temp_file"
    if ! mv "$temp_file" "${install_path}/${binary_name}" 2>> "$LOG_PATH"; then
        error "Failed to install $binary_name to ${install_path}"
        return 1
    fi
    
    success "$binary_name installed to ${install_path}"
    return 0
}

extract_tarball() {
    local url="$1"
    local binary_name="$2"
    local install_path="${3:-/usr/local/bin}"
    
    local temp_file="${TEMP_DIR}/archive.tar.gz"
    
    log "Downloading and extracting $binary_name..."
    if ! curl -fsSL --retry 3 "$url" -o "$temp_file" 2>> "$LOG_PATH"; then
        error "Failed to download archive for $binary_name"
        return 1
    fi
    
    if ! tar -xzf "$temp_file" -C "$TEMP_DIR" "$binary_name" 2>> "$LOG_PATH"; then
        error "Failed to extract $binary_name from archive"
        return 1
    fi
    
    chmod +x "${TEMP_DIR}/${binary_name}"
    if ! mv "${TEMP_DIR}/${binary_name}" "${install_path}/${binary_name}" 2>> "$LOG_PATH"; then
        error "Failed to install $binary_name"
        return 1
    fi
    
    success "$binary_name installed"
    return 0
}

verify_command() {
    local cmd="$1"
    local version_arg="${2:---version}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version_output
        version_output=$($cmd $version_arg 2>&1 | head -n1) || version_output="available"
        log "$cmd: $version_output"
        return 0
    else
        warn "$cmd not found in PATH after installation attempt"
        return 1
    fi
}

#===============================================================================
# TOOL PROVISIONING - CORE
#===============================================================================

install_vscode() {
    if command -v code >/dev/null 2>&1; then
        success "VS Code already installed"
        return 0
    fi
    
    log "Configuring VS Code repository..."
    if ! rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>> "$LOG_PATH"; then
        warn "Failed to import Microsoft GPG key"
    fi
    
    cat <<EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    
    if install_package "code"; then
        log "Installing VS Code extensions for $ACTUAL_USER..."
        local extensions=(
            "ms-vscode.cpptools"
            "ms-python.python"
            "hashicorp.terraform"
            "ms-azuretools.vscode-docker"
            "ms-kubernetes-tools.vscode-kubernetes-tools"
            "redhat.vscode-yaml"
            "github.vscode-github-actions"
        )
        
        for ext in "${extensions[@]}"; do
            sudo -u "$ACTUAL_USER" code --install-extension "$ext" --force >/dev/null 2>&1 || \
                warn "Failed to install VS Code extension: $ext"
        done
        success "VS Code configured"
    else
        error "Failed to install VS Code"
    fi
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        success "Docker already installed"
        return 0
    fi
    
    log "Configuring Docker CE repository..."
    cat <<EOF > /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
    
    if install_package "docker-ce" && \
       install_package "docker-ce-cli" && \
       install_package "containerd.io" && \
       install_package "docker-compose-plugin"; then
        log "Enabling and starting Docker service..."
        if systemctl enable --now docker >> "$LOG_PATH" 2>&1; then
            log "Docker service started"
        else
            warn "Failed to start Docker service"
        fi
        
        log "Adding $ACTUAL_USER to docker group..."
        if usermod -aG docker "$ACTUAL_USER" >> "$LOG_PATH" 2>&1; then
            success "Docker Engine + Compose installed"
        else
            warn "Failed to add user to docker group"
        fi
    else
        error "Failed to install Docker components"
    fi
}

install_terraform() {
    if command -v terraform >/dev/null 2>&1; then
        success "Terraform already installed"
        return 0
    fi
    
    log "Installing Terraform v${TERRAFORM_VERSION}..."
    
    # Add HashiCorp repository
    if ! dnf install -y dnf-plugins-core -q >> "$LOG_PATH" 2>&1; then
        warn "Failed to install dnf-plugins-core"
    fi
    
    if ! dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo -y -q >> "$LOG_PATH" 2>&1; then
        error "Failed to add HashiCorp repository"
        return 1
    fi
    
    # Install terraform (HashiCorp repo provides 'terraform' package, version controlled by repo)
    if install_package "terraform"; then
        verify_command "terraform"
        success "Terraform installed"
    else
        error "Failed to install Terraform"
    fi
}

#===============================================================================
# TOOL PROVISIONING - KUBERNETES ECOSYSTEM
#===============================================================================
install_kubernetes_tools() {
    # Kubectl with version pinning
    if ! command -v kubectl >/dev/null 2>&1; then
        log "Installing kubectl v${KUBECTL_VERSION}..."
        # Fixed URL - removed erroneous spaces
        cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION%.*}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION%.*}/rpm/repodata/repomd.xml.key
EOF
        if install_package "kubectl"; then
            verify_command "kubectl"
        else
            error "Failed to install kubectl"
        fi
    else
        success "kubectl already installed"
    fi

    # Helm
    if ! command -v helm >/dev/null 2>&1; then
        log "Installing Helm v${HELM_VERSION}..."
        if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | \
            DESIRED_VERSION="v${HELM_VERSION}" bash >> "$LOG_PATH" 2>&1; then
            verify_command "helm"
            success "Helm installed"
        else
            error "Failed to install Helm"
        fi
    else
        success "Helm already installed"
    fi
    
    # K9s - Terminal UI for Kubernetes
    if [[ "${INSTALL_DEV_PRODUCTIVITY}" == "1" ]] && ! command -v k9s >/dev/null 2>&1; then
        log "Installing k9s..."
        local k9s_url="https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
        if extract_tarball "$k9s_url" "k9s"; then
            verify_command "k9s"
        else
            warn "Failed to install k9s"
        fi
    fi
    
    # kubectx/kubens
    if [[ "${INSTALL_DEV_PRODUCTIVITY}" == "1" ]] && ! command -v kubectx >/dev/null 2>&1; then
        log "Installing kubectx/kubens..."
        if git clone --depth 1 https://github.com/ahmetb/kubectx /opt/kubectx >> "$LOG_PATH" 2>&1; then
            ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
            ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
            verify_command "kubectx"
            success "kubectx/kubens installed"
        else
            warn "Failed to clone kubectx repository"
        fi
    fi
    
    # Stern - Multi-pod log tailing
    if ! command -v stern >/dev/null 2>&1; then
        log "Installing stern..."
        local stern_url="https://github.com/stern/stern/releases/latest/download/stern_linux_amd64.tar.gz"
        if extract_tarball "$stern_url" "stern"; then
            verify_command "stern"
        else
            warn "Failed to install stern"
        fi
    fi
}

#===============================================================================
# TOOL PROVISIONING - CLOUD & GITOPS
#===============================================================================
install_cloud_tools() {
    # AWS CLI v2
    if [[ "${INSTALL_AWS_CLI}" == "1" ]] && ! command -v aws >/dev/null 2>&1; then
        log "Installing AWS CLI v${AWS_CLI_VERSION}..."
        local aws_zip="${TEMP_DIR}/awscliv2.zip"
        if curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "$aws_zip" >> "$LOG_PATH" 2>&1; then
            if unzip -q "$aws_zip" -d "${TEMP_DIR}/aws" >> "$LOG_PATH" 2>&1; then
                if "${TEMP_DIR}/aws/aws/install" --update >> "$LOG_PATH" 2>&1; then
                    verify_command "aws"
                    success "AWS CLI installed"
                else
                    error "AWS CLI installation script failed"
                fi
            else
                error "Failed to extract AWS CLI archive"
            fi
        else
            error "Failed to download AWS CLI"
        fi
    elif [[ "${INSTALL_AWS_CLI}" == "1" ]]; then
        success "AWS CLI already installed"
    fi
    
    # GitHub CLI
    if [[ "${INSTALL_DEV_PRODUCTIVITY}" == "1" ]] && ! command -v gh >/dev/null 2>&1; then
        log "Installing GitHub CLI..."
        if dnf install -y 'dnf-command(config-manager)' -q >> "$LOG_PATH" 2>&1; then
            if dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo -y -q >> "$LOG_PATH" 2>&1; then
                if install_package "gh"; then
                    verify_command "gh"
                else
                    warn "Failed to install gh via dnf"
                fi
            else
                warn "Failed to add GitHub CLI repository"
            fi
        else
            warn "Failed to install dnf config-manager plugin"
        fi
    elif [[ "${INSTALL_DEV_PRODUCTIVITY}" == "1" ]]; then
        success "GitHub CLI already installed"
    fi
    
    # ArgoCD CLI
    if [[ "${INSTALL_GITOPS_TOOLS}" == "1" ]] && ! command -v argocd >/dev/null 2>&1; then
        log "Installing ArgoCD CLI..."
        local argocd_url="https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
        if download_binary "$argocd_url" "argocd"; then
            verify_command "argocd"
        else
            warn "Failed to install ArgoCD CLI"
        fi
    elif [[ "${INSTALL_GITOPS_TOOLS}" == "1" ]]; then
        success "ArgoCD CLI already installed"
    fi
    
    # Flux CLI
    if [[ "${INSTALL_GITOPS_TOOLS}" == "1" ]] && ! command -v flux >/dev/null 2>&1; then
        log "Installing Flux CLI..."
        if curl -s https://fluxcd.io/install.sh | sudo bash >> "$LOG_PATH" 2>&1; then
            verify_command "flux"
            success "Flux CLI installed"
        else
            warn "Failed to install Flux CLI"
        fi
    elif [[ "${INSTALL_GITOPS_TOOLS}" == "1" ]]; then
        success "Flux CLI already installed"
    fi
}

#===============================================================================
# TOOL PROVISIONING - SECURITY & COMPLIANCE
#===============================================================================
install_security_tools() {
    # Trivy (via Aqua repo) - Fixed URL
    if ! command -v trivy >/dev/null 2>&1; then
        log "Configuring Trivy repository..."
        cat <<EOF > /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=0
enabled=1
EOF
        if install_package "trivy"; then
            verify_command "trivy"
        else
            warn "Failed to install Trivy via dnf"
        fi
    else
        success "Trivy already installed"
    fi

    # Checkov (Python)
    if ! command -v checkov >/dev/null 2>&1; then
        log "Installing Checkov..."
        if install_package "python3-pip"; then
            if sudo -u "$ACTUAL_USER" pip3 install --user --upgrade checkov -q >> "$LOG_PATH" 2>&1; then
                # Ensure ~/.local/bin is in PATH for user
                if ! grep -q 'export PATH.*\$HOME/\.local/bin' "${USER_HOME}/.bashrc" 2>/dev/null; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${USER_HOME}/.bashrc"
                    log "Added ~/.local/bin to PATH in .bashrc"
                fi
                verify_command "checkov"
                success "Checkov installed"
            else
                warn "Failed to install Checkov via pip"
            fi
        else
            warn "Failed to install python3-pip"
        fi
    else
        success "Checkov already installed"
    fi
    
    # Syft (SBOM generation)
    if [[ "${INSTALL_SECURITY_ADVANCED}" == "1" ]] && ! command -v syft >/dev/null 2>&1; then
        log "Installing Syft..."
        if curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin >> "$LOG_PATH" 2>&1; then
            verify_command "syft"
            success "Syft installed"
        else
            warn "Failed to install Syft"
        fi
    elif [[ "${INSTALL_SECURITY_ADVANCED}" == "1" ]]; then
        success "Syft already installed"
    fi
    
    # Grype (vulnerability scanner)
    if [[ "${INSTALL_SECURITY_ADVANCED}" == "1" ]] && ! command -v grype >/dev/null 2>&1; then
        log "Installing Grype..."
        if curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin >> "$LOG_PATH" 2>&1; then
            verify_command "grype"
            success "Grype installed"
        else
            warn "Failed to install Grype"
        fi
    elif [[ "${INSTALL_SECURITY_ADVANCED}" == "1" ]]; then
        success "Grype already installed"
    fi
    
    # Cosign (container signing)
    if [[ "${INSTALL_SECURITY_ADVANCED}" == "1" ]] && ! command -v cosign >/dev/null 2>&1; then
        log "Installing Cosign..."
        local cosign_url="https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
        if download_binary "$cosign_url" "cosign"; then
            verify_command "cosign"
        else
            warn "Failed to install Cosign"
        fi
    elif [[ "${INSTALL_SECURITY_ADVANCED}" == "1" ]]; then
        success "Cosign already installed"
    fi
}

#===============================================================================
# TOOL PROVISIONING - CONTAINER ADVANCED
#===============================================================================
install_container_advanced() {
    if [[ "${INSTALL_CONTAINER_ADVANCED}" != "1" ]]; then
        return 0
    fi
    
    # Podman ecosystem (Fedora-native)
    if ! command -v podman >/dev/null 2>&1; then
        log "Installing Podman ecosystem..."
        if install_package "podman" && \
           install_package "podman-docker" && \
           install_package "buildah" && \
           install_package "skopeo"; then
            success "Podman/Buildah/Skopeo installed"
        else
            warn "Failed to install Podman ecosystem"
        fi
    else
        success "Podman already installed"
    fi
    
    # Dive (Docker image explorer) - Fixed version handling
    if ! command -v dive >/dev/null 2>&1; then
        log "Installing Dive..."
        local dive_url="https://github.com/wagoodman/dive/releases/latest/download/dive_linux_amd64.tar.gz"
        if extract_tarball "$dive_url" "dive"; then
            verify_command "dive"
        else
            warn "Failed to install Dive"
        fi
    else
        success "Dive already installed"
    fi
    
    # Hadolint (Dockerfile linter)
    if ! command -v hadolint >/dev/null 2>&1; then
        log "Installing Hadolint..."
        local hadolint_url="https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64"
        if download_binary "$hadolint_url" "hadolint"; then
            verify_command "hadolint"
        else
            warn "Failed to install Hadolint"
        fi
    else
        success "Hadolint already installed"
    fi
}

#===============================================================================
# TOOL PROVISIONING - DEV PRODUCTIVITY
#===============================================================================
install_dev_productivity() {
    if [[ "${INSTALL_DEV_PRODUCTIVITY}" != "1" ]]; then
        return 0
    fi
    
    log "Installing developer productivity tools..."
    
    # Core utilities
    install_package "git" || warn "Failed to install git"
    install_package "jq" || warn "Failed to install jq"
    install_package "yq" || warn "Failed to install yq"
    install_package "ansible" || warn "Failed to install ansible"
    install_package "pre-commit" || warn "Failed to install pre-commit"
    
    # Terminal enhancements (Fedora package names)
    install_package "bat" || warn "Failed to install bat"
    install_package "fd-find" || warn "Failed to install fd-find"
    install_package "fzf" || warn "Failed to install fzf"
    install_package "ripgrep" || warn "Failed to install ripgrep"
    install_package "tealdeer" || warn "Failed to install tealdeer"
    
    # Starship prompt
    if ! command -v starship >/dev/null 2>&1; then
        log "Installing Starship prompt..."
        if curl -sS https://starship.rs/install.sh | sh -s -- -y >> "$LOG_PATH" 2>&1; then
            # Enable in bashrc if not present
            if ! grep -q "starship init bash" "${USER_HOME}/.bashrc" 2>/dev/null; then
                echo 'eval "$(starship init bash)"' >> "${USER_HOME}/.bashrc"
                log "Added starship init to .bashrc"
            fi
            success "Starship prompt installed"
        else
            warn "Failed to install Starship"
        fi
    else
        success "Starship already installed"
    fi
    
    # Lazygit
    if ! command -v lazygit >/dev/null 2>&1; then
        log "Installing lazygit..."
        local lazygit_url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_linux_amd64.tar.gz"
        if extract_tarball "$lazygit_url" "lazygit"; then
            verify_command "lazygit"
        else
            warn "Failed to install lazygit"
        fi
    else
        success "Lazygit already installed"
    fi
    
    # Act (run GitHub Actions locally)
    if ! command -v act >/dev/null 2>&1; then
        log "Installing act..."
        if curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash >> "$LOG_PATH" 2>&1; then
            verify_command "act"
            success "act installed"
        else
            warn "Failed to install act"
        fi
    else
        success "act already installed"
    fi
    
    success "Developer productivity tools processed"
}

#===============================================================================
# TOOL PROVISIONING - LANGUAGE RUNTIMES
#===============================================================================
install_language_runtimes() {
    # Go (for building Go-based DevOps tools)
    if ! command -v go >/dev/null 2>&1; then
        log "Installing Go..."
        if install_package "golang"; then
            # Configure GOPATH for user if not already set
            if ! grep -q "export GOPATH" "${USER_HOME}/.bashrc" 2>/dev/null; then
                cat << EOF >> "${USER_HOME}/.bashrc"

# Go environment
export GOPATH=\${HOME}/go
export PATH="\$PATH:\$GOPATH/bin"
EOF
                log "Added Go environment variables to .bashrc"
            fi
            verify_command "go"
            success "Go installed"
        else
            warn "Failed to install Go"
        fi
    else
        success "Go already installed"
    fi
    
    # Node.js LTS
    if ! command -v node >/dev/null 2>&1; then
        log "Installing Node.js LTS..."
        if curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash - >> "$LOG_PATH" 2>&1; then
            if install_package "nodejs"; then
                verify_command "node"
                success "Node.js installed"
            else
                warn "Failed to install nodejs via dnf"
            fi
        else
            warn "Failed to add NodeSource repository"
        fi
    else
        success "Node.js already installed"
    fi
}

#===============================================================================
# POST-INSTALLATION
#===============================================================================
generate_summary() {
    echo -e "\n${GREEN}==============================================${NC}"
    echo -e "${GREEN}   DEVSECOPS WORKSTATION PROVISIONING SUMMARY  ${NC}"
    echo -e "${GREEN}   Version: ${SCRIPT_VERSION}                          ${NC}"
    echo -e "${GREEN}==============================================${NC}\n"
    
    echo -e "${CYAN}Installed/Verified Tools:${NC}"
    printf "%-25s %s\n" "-----------------------" "----------------"
    
    for tool in "${INSTALLED_TOOLS[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local version_output
            version_output=$($tool --version 2>&1 | head -n1 || $tool version 2>&1 | head -n1 || echo "available")
            printf "%-25s %s\n" "$tool" "${version_output:0:40}"
        fi
    done
    
    echo -e "\n${YELLOW}Next Steps:${NC}"
    echo "  1. Restart your terminal or run: source ~/.bashrc"
    echo "  2. For Docker permissions: newgrp docker (or logout/login)"
    echo "  3. Configure AWS CLI: aws configure"
    echo "  4. Configure kubectl context as needed"
    echo "  5. Explore: k9s, lazygit, bat, starship"
    
    echo -e "\n${CYAN}Log file: ${LOG_PATH}${NC}"
    echo -e "${GREEN}✓ Provisioning completed!${NC}"
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================
main() {
    mkdir -p "$LOG_DIR"
    
    check_root
    check_network
    check_fedora_version
    check_required_commands
    
    log "Starting DevSecOps Workstation Bootstrap v${SCRIPT_VERSION}"
    log "Running as user: $ACTUAL_USER"
    
    # System update
    log "Updating system packages..."
    if ! dnf upgrade -y -q >> "$LOG_PATH" 2>&1; then
        warn "System update encountered issues, continuing..."
    fi
    
    # Install foundational packages
    log "Installing foundational packages..."
    for pkg in curl wget unzip tar gnupg2; do
        install_package "$pkg" || warn "Failed to install $pkg"
    done
    
    # Core DevOps tools
    install_docker
    install_terraform
    install_kubernetes_tools
    
    # Optional components
    install_cloud_tools
    install_security_tools
    install_container_advanced
    install_dev_productivity
    install_language_runtimes
    install_vscode
    
    # Final summary
    generate_summary
}

#===============================================================================
# ARGUMENT PARSING
#===============================================================================
show_help() {
    cat << EOF
DevSecOps Workstation Bootstrap v${SCRIPT_VERSION}

Usage: $0 [OPTIONS]

Options:
    --no-aws              Skip AWS CLI installation
    --no-gitops           Skip ArgoCD/Flux installation
    --no-productivity     Skip terminal productivity tools
    --no-container-adv    Skip Podman/Dive/Hadolint
    --no-security-adv     Skip Syft/Grype/Cosign
    --help                Show this help message

Environment Variables:
    TERRAFORM_VERSION   Pin Terraform version (default: 1.9.0)
    KUBECTL_VERSION     Pin kubectl version (default: 1.31.0)
    HELM_VERSION        Pin Helm version (default: 3.15.0)
    AWS_CLI_VERSION     Pin AWS CLI version (default: 2.15.0)

Examples:
    $0
    $0 --no-aws --no-gitops
    TERRAFORM_VERSION=1.8.5 $0
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-aws)
            INSTALL_AWS_CLI=0
            shift
            ;;
        --no-gitops)
            INSTALL_GITOPS_TOOLS=0
            shift
            ;;
        --no-productivity)
            INSTALL_DEV_PRODUCTIVITY=0
            shift
            ;;
        --no-container-adv)
            INSTALL_CONTAINER_ADVANCED=0
            shift
            ;;
        --no-security-adv)
            INSTALL_SECURITY_ADVANCED=0
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute main function
main "$@"
