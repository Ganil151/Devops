#!/bin/bash
#===============================================================================
# SYNOPSIS
#      DevSecOps Workstation Bootstrap - Fedora 43 Edition v7.4.0
# DESCRIPTION
#      Enterprise-grade provisioning for VS Code, Docker, Terraform, K8s,
#      AWS, GitOps, Security Scanning, Note-Taking (Obsidian, Joplin),
#      and developer productivity tools.
#      FIXED: GitHub API URL construction + URL sanitization + robust fallbacks.
#===============================================================================

set -euo pipefail

#===============================================================================
# GLOBAL CONFIGURATION
#===============================================================================
readonly SCRIPT_VERSION="7.4.0"
readonly LOG_DIR="${HOME}/.devsecops-provisioner"
readonly LOG_PATH="${LOG_DIR}/install.log"
readonly CONFIG_DIR="${HOME}/.bashrc.d"
readonly ALIASES_FILE="${CONFIG_DIR}/devops-aliases.sh"
readonly COMPLETIONS_FILE="${CONFIG_DIR}/devops-completions.sh"
readonly TEMP_DIR=$(mktemp -d)

# Tool versions
: "${TERRAFORM_VERSION:=1.9.0}"
: "${KUBECTL_VERSION:=1.31.0}"
: "${HELM_VERSION:=3.15.0}"
: "${AWS_CLI_VERSION:=2.17.0}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Feature Toggles
: "${INSTALL_AWS_CLI:=1}"
: "${INSTALL_GITOPS_TOOLS:=1}"
: "${INSTALL_DEV_PRODUCTIVITY:=1}"
: "${INSTALL_SECURITY_ADVANCED:=1}"
: "${INSTALL_SHELL_ENHANCEMENTS:=1}"
: "${INSTALL_NOTE_TOOLS:=1}"

# Network settings
: "${CURL_TIMEOUT:=30}"
: "${CURL_RETRIES:=3}"
: "${CURL_RETRY_DELAY:=5}"

declare -a INSTALLED_TOOLS=()

#===============================================================================
# LOGGING & ERROR HANDLING
#===============================================================================
cleanup() {
    local exit_code=$?
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}✗ Script failed with exit code $exit_code${NC}" >&2
        echo -e "${YELLOW}Check logs at: ${LOG_PATH}${NC}" >&2
    fi
    exit $exit_code
}
trap cleanup EXIT INT TERM

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
    return 1
}

#===============================================================================
# USER & PRE-FLIGHT
#===============================================================================
detect_user() {
    if [[ -n "${SUDO_USER:-}" ]]; then echo "$SUDO_USER"; else echo "${USER:-$(whoami)}"; fi
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
    local retry=0
    while [[ $retry -lt $CURL_RETRIES ]]; do
        if curl -sL --connect-timeout 10 https://github.com > /dev/null 2>&1; then
            log "Network connectivity verified"
            return 0
        fi
        ((retry++)) || true
        warn "Network check failed (attempt $retry/$CURL_RETRIES), retrying in ${CURL_RETRY_DELAY}s..."
        sleep "$CURL_RETRY_DELAY"
    done
    warn "DNS resolution failed after $CURL_RETRIES attempts. Injecting temporary Google DNS (8.8.8.8)..."
    echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf > /dev/null
}

check_dnf_compatibility() {
    log "Checking DNF version for compatibility..."
    if dnf --version 2>/dev/null | grep -q "^5\."; then
        log "DNF5 detected - using manual repo file configuration"
        return 0
    fi
    log "DNF4 detected - standard repository management available"
}

check_conflicting_packages() {
    log "Checking for package conflicts..."
    if rpm -q "kubernetes*-client" >/dev/null 2>&1 && command -v kubectl >/dev/null 2>&1; then
        local existing_version
        existing_version=$(kubectl version --client --short 2>/dev/null | grep -oP 'Client Version: \K[0-9.]+' || echo "unknown")
        log "kubectl already installed via Fedora package (v${existing_version}) - skipping Kubernetes repo installation"
        return 0
    fi
    if rpm -q --whatprovides /usr/bin/kubectl >/dev/null 2>&1; then
        local provider
        provider=$(rpm -q --whatprovides /usr/bin/kubectl)
        log "/usr/bin/kubectl provided by ${provider} - using existing installation"
        return 0
    fi
    return 1
}

#===============================================================================
# NETWORK HELPERS (CRITICAL FIX: URL sanitization + GitHub API)
#===============================================================================
sanitize_url() {
    local url="$1"
    # Remove ALL whitespace, control characters, and trailing content
    echo "$url" | tr -d '[:space:]' | sed 's/[^a-zA-Z0-9:\/\.\_\-\?=&%#]//g'
}

curl_with_retry() {
    local url="$1"
    local output="$2"
    local retry=0
    
    # Sanitize URL - CRITICAL FIX
    url=$(sanitize_url "$url")
    
    local curl_opts=(-fsSL --connect-timeout "$CURL_TIMEOUT" --retry "$CURL_RETRIES" --retry-delay "$CURL_RETRY_DELAY" --retry-all-errors -L)
    
    while [[ $retry -lt $CURL_RETRIES ]]; do
        if curl "${curl_opts[@]}" "$url" -o "$output" 2>/dev/null; then
            return 0
        fi
        ((retry++)) || true
        warn "Download failed for $url (attempt $retry/$CURL_RETRIES)"
        [[ $retry -lt $CURL_RETRIES ]] && sleep "$CURL_RETRY_DELAY"
    done
    return 1
}

curl_get_json_field() {
    local url="$1"
    local field="$2"
    local result
    url=$(sanitize_url "$url")
    result=$(curl -fsSL --connect-timeout "$CURL_TIMEOUT" "$url" 2>/dev/null | jq -r "$field" 2>/dev/null) || return 1
    [[ -n "$result" && "$result" != "null" ]] && echo "$result" || return 1
}

get_github_latest_release() {
    local repo="$1"
    # FIXED: No spaces in URL construction
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    curl_get_json_field "$api_url" '.tag_name' | tr -d 'v'
}

get_github_asset_url() {
    local repo="$1"
    local pattern="$2"
    # FIXED: No spaces in URL construction
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    curl -fsSL --connect-timeout "$CURL_TIMEOUT" "$api_url" 2>/dev/null | \
        jq -r ".assets[] | select(.name | test(\"${pattern}\")) | .browser_download_url" 2>/dev/null | head -n1
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
    if dnf install -y "$pkg_name" -q >> "$LOG_PATH" 2>&1; then
        success "$pkg_name installed"
        return 0
    else
        error "Failed to install $pkg_name"
        return 1
    fi
}

install_package_skip_conflict() {
    local pkg_name="$1"
    if rpm -q "$pkg_name" >/dev/null 2>&1 || command -v "${pkg_name%%-*}" >/dev/null 2>&1; then
        log "$pkg_name or equivalent already installed - skipping"
        return 0
    fi
    log "Installing $pkg_name via dnf (with conflict handling)..."
    if dnf install -y "$pkg_name" -q --allowerasing >> "$LOG_PATH" 2>&1; then
        success "$pkg_name installed"
        return 0
    else
        warn "Failed to install $pkg_name via dnf - trying alternative method"
        return 1
    fi
}

extract_tarball() {
    local url="$1" binary_name="$2" install_path="${3:-/usr/local/bin}"
    local temp_file="${TEMP_DIR}/archive.tar.gz"
    log "Downloading and extracting $binary_name..."
    
    url=$(sanitize_url "$url")
    
    if ! curl_with_retry "$url" "$temp_file"; then
        warn "Failed to download $binary_name from $url"
        return 1
    fi
    
    if ! tar -xzf "$temp_file" -C "$TEMP_DIR" 2>/dev/null; then
        warn "Failed to extract archive for $binary_name"
        return 1
    fi
    
    local found_bin
    found_bin=$(find "$TEMP_DIR" -name "$binary_name" -type f -executable | head -n 1)
    
    if [[ -z "$found_bin" || ! -f "$found_bin" ]]; then
        found_bin=$(find "$TEMP_DIR" -name "$binary_name" -type f | head -n 1)
    fi
    
    if [[ -z "$found_bin" || ! -f "$found_bin" ]]; then
        warn "Binary '$binary_name' not found in archive"
        return 1
    fi
    
    chmod +x "$found_bin"
    mv "$found_bin" "${install_path}/${binary_name}"
    success "$binary_name installed"
}

install_rpm_from_url() {
    local rpm_url="$1"
    local rpm_name
    rpm_name=$(basename "$rpm_url")
    local temp_rpm="${TEMP_DIR}/${rpm_name}"
    
    log "Downloading RPM: $rpm_name"
    if ! curl_with_retry "$rpm_url" "$temp_rpm"; then
        warn "Failed to download $rpm_name"
        return 1
    fi
    
    if dnf install -y "$temp_rpm" -q --allowerasing >> "$LOG_PATH" 2>&1; then
        success "$rpm_name installed"
        return 0
    else
        warn "Failed to install $rpm_name via dnf"
        return 1
    fi
}

install_appimage() {
    local url="$1"
    local binary_name="$2"
    local install_path="${3:-/usr/local/bin}"
    local temp_file="${TEMP_DIR}/${binary_name}.AppImage"
    
    url=$(sanitize_url "$url")
    log "Downloading AppImage: $binary_name"
    
    if ! curl_with_retry "$url" "$temp_file"; then
        warn "Failed to download $binary_name AppImage"
        return 1
    fi
    
    chmod +x "$temp_file"
    mv "$temp_file" "${install_path}/${binary_name}"
    
    if [[ "$binary_name" != *" "* ]]; then
        cat > "${install_path}/${binary_name}.sh" << EOF
#!/bin/bash
exec "${install_path}/${binary_name}" "\$@"
EOF
        chmod +x "${install_path}/${binary_name}.sh"
    fi
    
    success "$binary_name AppImage installed"
}

#===============================================================================
# TOOL PROVISIONING
#===============================================================================

install_vscode() {
    if command -v code >/dev/null 2>&1; then success "VS Code exists"; return 0; fi
    log "Configuring VS Code repository..."
    
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
    
    local extensions=("ms-vscode.cpptools" "ms-python.python" "hashicorp.terraform" "ms-azuretools.vscode-docker" "redhat.vscode-yaml" "streetsidesoftware.code-spell-checker")
    for ext in "${extensions[@]}"; do
        sudo -u "$ACTUAL_USER" code --install-extension "$ext" --force >/dev/null 2>&1 || true
    done
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then success "Docker exists"; return 0; fi
    log "Configuring Docker repository..."
    
    cat <<EOF > /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
    
    dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin -q >> "$LOG_PATH" 2>&1
    systemctl enable --now docker
    usermod -aG docker "$ACTUAL_USER"
    success "Docker Suite installed"
}

install_terraform() {
    if command -v terraform >/dev/null 2>&1; then success "Terraform exists"; return 0; fi
    log "Configuring HashiCorp repository..."
    
    cat <<EOF > /etc/yum.repos.d/hashicorp.repo
[hashicorp]
name=HashiCorp Stable - \$basearch
baseurl=https://rpm.releases.hashicorp.com/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF
    
    dnf makecache --refresh -q 2>/dev/null || true
    
    if ! install_package "terraform"; then
        warn "Repo install failed, downloading binary directly..."
        local tf_url="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
        if curl_with_retry "$tf_url" "${TEMP_DIR}/tf.zip"; then
            unzip -q "${TEMP_DIR}/tf.zip" -d /usr/local/bin/
            chmod +x /usr/local/bin/terraform
            success "Terraform installed via binary"
        else
            error "Failed to download Terraform binary"
            return 1
        fi
    fi
}

install_kubernetes_tools() {
    log "Installing K8s tools (kubectl, helm, k9s, stern)..."
    
    if check_conflicting_packages; then
        success "kubectl already available - skipping repo installation"
    else
        local k8s_major_version="${KUBECTL_VERSION%.*}"
        cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v${k8s_major_version}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v${k8s_major_version}/rpm/repodata/repomd.xml.key
EOF
        
        install_package_skip_conflict "kubectl" || {
            warn "kubectl repo install failed, trying direct download..."
            if curl_with_retry "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" /usr/local/bin/kubectl; then
                chmod +x /usr/local/bin/kubectl
                success "kubectl installed via direct download"
            else
                error "All kubectl installation methods failed"
            fi
        }
    fi
    
    if ! command -v helm >/dev/null 2>&1; then
        log "Installing Helm..."
        if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >/dev/null 2>&1; then
            success "Helm installed"
        else
            warn "Helm installation failed"
        fi
    else
        success "Helm already installed"
    fi

    if [[ "$INSTALL_DEV_PRODUCTIVITY" == "1" ]]; then
        # k9s - use GitHub API for reliable asset URL
        local k9s_url
        k9s_url=$(get_github_asset_url "derailed/k9s" "k9s_Linux_amd64.tar.gz")
        if [[ -n "$k9s_url" ]]; then
            extract_tarball "$k9s_url" "k9s" || warn "k9s installation failed"
        else
            warn "Could not resolve k9s download URL via API, trying fallback..."
            local k9s_version
            k9s_version=$(get_github_latest_release "derailed/k9s")
            if [[ -n "$k9s_version" ]]; then
                extract_tarball "https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_amd64.tar.gz" "k9s" || warn "k9s fallback installation failed"
            fi
        fi
        
        # stern - FIXED: correct asset pattern + fallback
        local stern_url
        stern_url=$(get_github_asset_url "stern/stern" "stern_.*_linux_amd64.tar.gz")
        if [[ -n "$stern_url" ]]; then
            extract_tarball "$stern_url" "stern" || warn "stern installation failed"
        else
            warn "Could not resolve stern via API, trying fallback..."
            local stern_version
            stern_version=$(get_github_latest_release "stern/stern")
            if [[ -n "$stern_version" ]]; then
                extract_tarball "https://github.com/stern/stern/releases/download/v${stern_version}/stern_${stern_version}_linux_amd64.tar.gz" "stern" || warn "stern fallback installation failed"
            else
                warn "Could not resolve stern version - install manually: https://github.com/stern/stern/releases"
            fi
        fi
    fi
}

install_aws_cli() {
    if [[ "$INSTALL_AWS_CLI" == "1" ]] && ! command -v aws >/dev/null 2>&1; then
        log "Installing AWS CLI v2..."
        local aws_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
        
        if curl_with_retry "$aws_url" "${TEMP_DIR}/awscliv2.zip"; then
            unzip -q "${TEMP_DIR}/awscliv2.zip" -d "$TEMP_DIR"
            "${TEMP_DIR}/aws/install" --update -b /usr/local/bin >/dev/null 2>&1
            success "AWS CLI installed"
        else
            warn "Failed to download AWS CLI installer"
        fi
    elif command -v aws >/dev/null 2>&1; then
        success "AWS CLI already installed"
    fi
}

install_security_tools() {
    if [[ "$INSTALL_SECURITY_ADVANCED" != "1" ]]; then return 0; fi
    
    log "Configuring Security Tools (Trivy, Checkov)..."
    
    cat <<EOF > /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=0
enabled=1
EOF
    
    install_package "trivy" || warn "Trivy installation via repo failed"
    
    if ! command -v trivy >/dev/null 2>&1; then
        log "Installing Trivy via direct download..."
        local trivy_version="0.49.0"
        local trivy_url="https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_Linux-64bit.tar.gz"
        if curl_with_retry "$trivy_url" "${TEMP_DIR}/trivy.tar.gz"; then
            tar -xzf "${TEMP_DIR}/trivy.tar.gz" -C "$TEMP_DIR"
            mv "${TEMP_DIR}/trivy" /usr/local/bin/
            chmod +x /usr/local/bin/trivy
            success "Trivy installed via direct download"
        else
            warn "Trivy direct download failed"
        fi
    fi
    
    if command -v pip3 >/dev/null 2>&1; then
        sudo -u "$ACTUAL_USER" pip3 install --user --quiet checkov 2>/dev/null && success "Checkov installed" || warn "Checkov installation failed"
    fi
}

install_note_taking_tools() {
    if [[ "$INSTALL_NOTE_TOOLS" != "1" ]]; then 
        log "Note-taking tools installation disabled via INSTALL_NOTE_TOOLS=0"
        return 0
    fi
    
    log "Installing Note-Taking & Knowledge Management Tools..."
    
    # Obsidian - FIXED: GitHub API with proper URL + manual fallback instructions
    if ! command -v obsidian >/dev/null 2>&1 && ! rpm -q obsidian >/dev/null 2>&1; then
        log "Installing Obsidian..."
        local obsidian_url
        obsidian_url=$(get_github_asset_url "obsidianmd/obsidian-releases" "obsidian_.*_amd64.rpm")
        
        if [[ -n "$obsidian_url" ]]; then
            if install_rpm_from_url "$obsidian_url"; then
                success "Obsidian installed"
            else
                warn "Obsidian RPM installation failed"
            fi
        else
            warn "Could not resolve Obsidian via GitHub API"
            log "Installing Obsidian via direct known URL fallback..."
            # Fallback: try known stable version
            local obsidian_fallback="https://github.com/obsidianmd/obsidian-releases/releases/download/1.5.3/obsidian_1.5.3_amd64.rpm"
            if curl_with_retry "$obsidian_fallback" "${TEMP_DIR}/obsidian_fallback.rpm"; then
                if dnf install -y "${TEMP_DIR}/obsidian_fallback.rpm" -q --allowerasing >> "$LOG_PATH" 2>&1; then
                    success "Obsidian installed via fallback"
                else
                    warn "Obsidian fallback install failed"
                fi
            else
                warn "Obsidian download failed - please install manually:"
                warn "  1. Visit: https://obsidian.md/download"
                warn "  2. Download the Linux .rpm file"
                warn "  3. Run: sudo dnf install ./obsidian_*.rpm"
            fi
        fi
    else
        success "Obsidian already installed"
    fi
    
    # Joplin - AppImage only (not in Fedora repos)
    if ! command -v joplin >/dev/null 2>&1; then
        log "Installing Joplin via AppImage..."
        local joplin_version
        joplin_version=$(get_github_latest_release "laurent22/joplin")
        if [[ -n "$joplin_version" ]]; then
            local joplin_url="https://github.com/laurent22/joplin/releases/download/v${joplin_version}/Joplin-${joplin_version}.AppImage"
            if install_appimage "$joplin_url" "joplin"; then
                success "Joplin installed via AppImage"
            else
                warn "Joplin AppImage installation failed"
            fi
        else
            warn "Could not resolve Joplin version - trying stable fallback..."
            if install_appimage "https://github.com/laurent22/joplin/releases/download/v2.14.0/Joplin-2.14.0.AppImage" "joplin"; then
                success "Joplin installed via fallback"
            else
                warn "Joplin installation failed - manual: https://joplinapp.org"
            fi
        fi
    else
        success "Joplin already installed"
    fi
    
    # Mark Text
    if [[ ! -f /usr/local/bin/mark-text ]]; then
        log "Installing Mark Text (Markdown editor)..."
        local marktext_version
        marktext_version=$(get_github_latest_release "marktext/marktext")
        if [[ -n "$marktext_version" ]]; then
            local marktext_url="https://github.com/marktext/marktext/releases/download/v${marktext_version}/marktext-x86_64.AppImage"
            if install_appimage "$marktext_url" "mark-text"; then
                success "Mark Text installed"
            else
                warn "Mark Text installation failed"
            fi
        else
            warn "Could not resolve Mark Text version - trying fallback..."
            if install_appimage "https://github.com/marktext/marktext/releases/download/v0.17.1/marktext-x86_64.AppImage" "mark-text"; then
                success "Mark Text installed via fallback"
            else
                warn "Mark Text installation failed - manual: https://marktext.app"
            fi
        fi
    else
        success "Mark Text already installed"
    fi
    
    # Logseq - FIXED: Better URL handling + fallback
    if [[ "$INSTALL_DEV_PRODUCTIVITY" == "1" ]] && [[ ! -f /usr/local/bin/logseq ]]; then
        log "Installing Logseq (outliner-based knowledge base)..."
        local logseq_version
        logseq_version=$(get_github_latest_release "logseq/logseq")
        if [[ -n "$logseq_version" ]]; then
            local logseq_url="https://github.com/logseq/logseq/releases/download/v${logseq_version}/Logseq-linux-x86_64.AppImage"
            if install_appimage "$logseq_url" "logseq"; then
                success "Logseq installed"
            else
                warn "Logseq installation failed"
            fi
        else
            warn "Could not resolve Logseq version - trying fallback..."
            if install_appimage "https://github.com/logseq/logseq/releases/download/v0.10.9/Logseq-linux-x86_64.AppImage" "logseq"; then
                success "Logseq installed via fallback"
            else
                warn "Logseq installation failed - manual: https://logseq.com"
            fi
        fi
    fi
    
    # Setup Obsidian vault structure
    if command -v obsidian >/dev/null 2>&1 || [[ -f /usr/bin/obsidian ]] || rpm -q obsidian >/dev/null 2>&1; then
        log "Configuring Obsidian workspace..."
        local obsidian_vault="${USER_HOME}/Documents/Obsidian-Vault"
        mkdir -p "$obsidian_vault"/{.obsidian,attachments,templates,daily-notes}
        chown -R "$ACTUAL_USER:" "$obsidian_vault" 2>/dev/null || true
        success "Obsidian vault structure created at $obsidian_vault"
    fi
}

#===============================================================================
# ALIASES & SHELL
#===============================================================================
configure_shell() {
    log "Configuring shell, aliases, and completions..."
    mkdir -p "$CONFIG_DIR"
    
    cat << 'ALIASES_EOF' > "$ALIASES_FILE"
# >>> System & Navigation <<<
alias cls='clear'
alias reload='source ~/.bashrc 2>/dev/null && echo "✅ Config reloaded"'
alias path='printf "%s\n" "${PATH//:/$'\''\n'\''}"'
alias l='ls -lah --color=auto --group-directories-first 2>/dev/null || ls -lah'
alias ll='ls -alF --color=auto --group-directories-first 2>/dev/null || ls -alF'
alias la='ls -A --color=auto 2>/dev/null || ls -A'
alias lt='ls -lh --color=auto --sort=time 2>/dev/null || ls -lh -t'
alias mkdir='mkdir -p'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias h='history | grep -i --color=auto'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp 2>/dev/null || echo "⚠️  Port tools unavailable"'
alias myip='curl -sL https://ifconfig.me 2>/dev/null || curl -sL https://icanhazip.com 2>/dev/null || echo "⚠️  IP lookup unavailable"'
alias df='df -h --total 2>/dev/null || df -h'
alias du='du -h --max-depth=2 2>/dev/null || du -h -d 2'
alias free='free -h 2>/dev/null || free -m'
alias top='htop 2>/dev/null || top'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias timestamp='date "+%Y%m%d_%H%M%S"'

# >>> Git Mastery <<<
alias gs='git status -sb 2>/dev/null || echo "⚠️  Not a git repo"'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gc='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull --rebase'
alias gb='git branch -vv'
alias gba='git branch -a'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main 2>/dev/null || git checkout master'
alias gd='git diff --staged'
alias gds='git diff --staged --stat'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gloga='git log --all --graph --oneline --decorate'
alias gundo='git reset --soft HEAD~1'
alias gclean='git branch --merged 2>/dev/null | grep -v "\*\|main\|master\|develop" | xargs -r git branch -d 2>/dev/null'
alias gprune='git remote prune origin'
alias gamend='git commit --amend --no-edit'
alias gwho='git log -1 --pretty=format:"%an <%ae>"'
alias gtime='git log -1 --pretty=format:"%ai"'

gclone() {
    [[ -z "$1" ]] && echo "Usage: gclone <repo-url> [directory]" && return 1
    local target="${2:-$(basename "$1" .git)}"
    git clone --quiet "$1" "$target" && cd "$target" && echo "✅ Cloned: $target"
}

gswitch() {
    local branch
    branch=$(git branch -a 2>/dev/null | grep -v HEAD | sed 's/^..//' | cut -d' ' -f1 | grep -v '^remotes' | sort -u)
    [[ -z "$branch" ]] && echo "⚠️  No branches found" && return 1
    echo "$branch" | fzf --preview 'git log -10 --oneline {}' 2>/dev/null | xargs -r git checkout || echo "⚠️  fzf unavailable or cancelled"
}

gclean-merged() {
    local protected="main master develop"
    git branch --merged 2>/dev/null | grep -v "\*" | while read -r b; do
        [[ "$protected" != *"$b"* ]] && git branch -d "$b" 2>/dev/null && echo "✅ Deleted: $b"
    done
}

# >>> Docker <<<
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker ps'
alias dpa='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}" 2>/dev/null || docker ps -a'
alias dstats='docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "⚠️  docker stats unavailable"'
alias dstop='docker stop $(docker ps -q 2>/dev/null) 2>/dev/null || true'
alias dkill='docker rm -f $(docker ps -aq 2>/dev/null) 2>/dev/null || true'
alias dex='docker exec -it'
alias dimg='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" 2>/dev/null || docker images'
alias dprune='docker system prune -af --volumes'
alias dclean='docker rmi $(docker images -q -f dangling=true 2>/dev/null) 2>/dev/null || true'
alias dlogs='docker logs -f --tail=100'
alias dbuild='docker build --progress=plain -t'
alias dexec='docker exec -it'
alias dinspect='docker inspect --format="{{json .Config}}" | jq -C . 2>/dev/null || docker inspect'

if docker compose version &>/dev/null; then
    alias dco='docker compose'
elif command -v docker-compose &>/dev/null; then
    alias dco='docker-compose'
else
    alias dco='echo "⚠️  Docker Compose not installed"'
fi 2>/dev/null

alias dcup='dco up -d' 2>/dev/null || true
alias dcdn='dco down' 2>/dev/null || true
alias dcl='dco logs -f' 2>/dev/null || true
alias dcps='dco ps' 2>/dev/null || true

# >>> Kubernetes <<<
alias k='kubectl 2>/dev/null || echo "⚠️  kubectl not installed"'
alias kgp='kubectl get pods 2>/dev/null || true'
alias kgpw='kubectl get pods -o wide 2>/dev/null || true'
alias kgs='kubectl get svc 2>/dev/null || true'
alias kgd='kubectl get deployments 2>/dev/null || true'
alias kga='kubectl get all 2>/dev/null || true'
alias kd='kubectl describe' 2>/dev/null || true
alias kl='kubectl logs -f --tail=100' 2>/dev/null || true
alias kexec='kubectl exec -it' 2>/dev/null || true
alias kdelp='kubectl delete pod' 2>/dev/null || true
alias kw='watch -n 2 kubectl get pods 2>/dev/null || kubectl get pods --watch' 2>/dev/null || true
alias kaf='kubectl apply -f' 2>/dev/null || true
alias kdf='kubectl delete -f' 2>/dev/null || true

ksh() {
    [[ -z "$1" ]] && echo "Usage: ksh <pod-name> [-n namespace]" && return 1
    local ns="${3:-default}"
    kubectl exec -it "$1" -n "$ns" -- /bin/bash 2>/dev/null || \
    kubectl exec -it "$1" -n "$ns" -- /bin/sh 2>/dev/null || \
    echo "❌ Could not exec into $1 (try /bin/sh)"
}

klogs() {
    [[ -z "$1" ]] && echo "Usage: klogs <pod-name> [-n namespace]" && return 1
    local ns="${3:-default}"
    kubectl logs -f --tail=200 "$1" -n "$ns" 2>/dev/null || echo "❌ Logs unavailable"
}

kportf() {
    [[ -z "$1" || -z "$2" ]] && echo "Usage: kportf <pod> <local-port>[:<remote-port>] [-n namespace]" && return 1
    local ns="${4:-default}"
    kubectl port-forward "$1" "$2" -n "$ns" 2>/dev/null || echo "❌ Port-forward failed"
}

kctx() { kubectl config current-context 2>/dev/null || echo "⚠️  No context set"; }
kns() { kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "default"; }

# >>> Terraform <<<
alias tf='terraform 2>/dev/null || echo "⚠️  terraform not installed"'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tfo='terraform output'
alias tfw='terraform workspace'
alias tff='terraform fmt -recursive'
alias tfs='terraform state list'

tfinit() { terraform init -upgrade -reconfigure "$@"; }

tfplan() {
    terraform plan -out=tfplan "$@" && echo "✅ Plan saved to tfplan. Apply with: terraform apply tfplan"
}

tfapply() {
    [[ -f tfplan ]] && terraform apply tfplan "$@" || echo "⚠️  No tfplan file. Run 'tfplan' first."
}

# >>> Note-Taking & Knowledge Management <<<
alias obs='obsidian 2>/dev/null || echo "⚠️  Obsidian not installed"'
alias jop='joplin 2>/dev/null || echo "⚠️  Joplin not installed"'
alias mark='mark-text 2>/dev/null || echo "⚠️  Mark Text not installed"'
alias logseq='logseq 2>/dev/null || echo "⚠️  Logseq not installed"'
alias obs-vault='cd "${HOME}/Documents/Obsidian-Vault" 2>/dev/null || mkdir -p "${HOME}/Documents/Obsidian-Vault" && cd "${HOME}/Documents/Obsidian-Vault"'
alias notes='obs-vault'

# >>> Cloud Platforms <<<
alias aws-who='aws sts get-caller-identity 2>/dev/null || echo "⚠️  AWS CLI unavailable"'
alias aws-ls='aws s3 ls 2>/dev/null || true'
alias aws-logs='aws logs tail --follow 2>/dev/null || true'
alias aws-ec2='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,IP:PrivateIpAddress}" --output table 2>/dev/null || true'

asp() {
    [[ -z "$1" ]] && echo "Usage: asp <profile-name>" && return 1
    export AWS_PROFILE="$1"
    echo "✅ AWS Profile: $AWS_PROFILE"
}

ec2-connect() {
    [[ -z "$1" ]] && echo "Usage: ec2-connect <instance-id>" && return 1
    echo "🔐 Starting SSM Session for $1..."
    aws ssm start-session --target "$1" 2>/dev/null || echo "❌ SSM failed (check permissions/region)"
}

alias g-who='gcloud auth list 2>/dev/null || echo "⚠️  gcloud not installed"'
alias g-list='gcloud projects list 2>/dev/null || true'
alias g-compute='gcloud compute instances list 2>/dev/null || true'
alias g-ssh='gcloud compute ssh 2>/dev/null || echo "Usage: g-ssh <instance-name>"'

g-proj() {
    [[ -z "$1" ]] && echo "Usage: g-proj <project-id>" && return 1
    gcloud config set project "$1" 2>/dev/null && echo "✅ GCP Project: $1" || echo "❌ Failed to set project"
}

g-zone() {
    [[ -z "$1" ]] && echo "Usage: g-zone <zone>" && return 1
    gcloud config set compute/zone "$1" 2>/dev/null && echo "✅ GCP Zone: $1" || echo "❌ Failed to set zone"
}

alias az-who='az account show 2>/dev/null || echo "⚠️  Azure CLI not installed"'
alias az-login='az login --use-device-code 2>/dev/null || az login'
alias az-list='az account list --output table 2>/dev/null || true'
alias az-vm='az vm list --output table 2>/dev/null || true'

az-sub() {
    [[ -z "$1" ]] && echo "Usage: az-sub <subscription-name-or-id>" && return 1
    az account set --subscription "$1" 2>/dev/null && echo "✅ Azure Subscription: $1" || echo "❌ Failed to set subscription"
}

# >>> Utility Functions <<<
extract() {
    [[ -f "$1" ]] || { echo "❌ '\''$1'\'' is not a valid file"; return 1; }
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz)         tar xJf "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.rar)            unrar e -y "$1" 2>/dev/null || bsdtar x -f "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.zip)            unzip -q "$1" ;;
        *.7z)             7z x -y "$1" 2>/dev/null || echo "⚠️  7z not installed" ;;
        *.Z)              uncompress "$1" ;;
        *)                echo "❌ Unknown format: $1"; return 1 ;;
    esac && echo "✅ Extracted: $1"
}

mkcd() { mkdir -p "$1" && cd "$1" && pwd; }
findf() { find . -type f -iname "*$1*" 2>/dev/null | head -20; }
grepf() { grep -rIn --color=always "$@" . 2>/dev/null | head -50; }

serve() {
    local port="${1:-8080}"
    echo "🌐 Serving $(pwd) on http://localhost:${port}"
    python3 -m http.server "$port" 2>/dev/null || python -m http.server "$port" 2>/dev/null || echo "❌ Python not available"
}

jp() { jq -C . 2>/dev/null || python3 -m json.tool 2>/dev/null || cat; }
y2j() { yq -o=json . 2>/dev/null || python3 -c "import sys,yaml,json; print(json.dumps(yaml.safe_load(sys.stdin),indent=2))" 2>/dev/null || cat; }

alias sysinfo='echo "🖥️  $(uname -s) $(uname -r) | 🐧 $OSTYPE | 👤 $(whoami)@$(hostname)"'
alias disk='df -h / /home 2>/dev/null | tail -2'
alias mem='free -h 2>/dev/null | grep -i mem'
alias cpu='lscpu 2>/dev/null | grep -E "Model name|CPU\(s\)|Architecture" || echo "⚠️  CPU info unavailable"'

alias ping8='ping -c 8 8.8.8.8'
alias ping1='ping -c 1 1.1.1.1'
alias dns-test='nslookup google.com 2>/dev/null || dig google.com +short 2>/dev/null || echo "⚠️  DNS tools unavailable"'
alias http-test='curl -ILs https://httpbin.org/ip 2>/dev/null | head -5 || echo "⚠️  HTTP test failed"'

alias ssh-keys='ls -la ~/.ssh/*.pub 2>/dev/null || echo "⚠️  No SSH keys found"'
alias perms-check='find . -maxdepth 3 -perm /o+w -type f 2>/dev/null | head -10 || echo "✅ No world-writable files in current tree"'
alias env-check='env | grep -E "(AWS|AZURE|GCLOUD|KUBE|TF_|DOCKER)" | sort'
ALIASES_EOF

    chown "$ACTUAL_USER:" "$ALIASES_FILE" 2>/dev/null || true
    chmod 644 "$ALIASES_FILE"
    
    if ! grep -q '\.bashrc\.d' "${USER_HOME}/.bashrc" 2>/dev/null; then
        cat << 'BASHRC_EOF' >> "${USER_HOME}/.bashrc"

# DevOps config directory (auto-generated by provisioner)
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*.sh; do
        [ -f "$rc" ] && . "$rc"
    done
fi
BASHRC_EOF
        log "Added ~/.bashrc.d sourcing to .bashrc"
    fi
    
    success "Enhanced DevOps aliases created at $ALIASES_FILE"
    
    cat << 'COMPLETIONS_EOF' > "$COMPLETIONS_FILE"
if command -v kubectl >/dev/null 2>&1; then source <(kubectl completion bash) 2>/dev/null || true; fi
if command -v helm >/dev/null 2>&1; then source <(helm completion bash) 2>/dev/null || true; fi
if command -v docker >/dev/null 2>&1 && [[ -f /usr/share/bash-completion/completions/docker ]]; then source /usr/share/bash-completion/completions/docker; fi
if command -v terraform >/dev/null 2>&1 && [[ -n "${BASH_VERSION:-}" ]]; then eval "$(terraform -install-autocomplete)" 2>/dev/null || true; fi
if command -v aws >/dev/null 2>&1 && [[ -f /usr/share/bash-completion/completions/aws ]]; then source /usr/share/bash-completion/completions/aws 2>/dev/null || true; fi
COMPLETIONS_EOF

    chown -R "$ACTUAL_USER:" "$CONFIG_DIR" 2>/dev/null || true
    
    if [[ "$INSTALL_SHELL_ENHANCEMENTS" == "1" ]]; then
        log "Installing starship prompt..."
        if curl_with_retry "https://starship.rs/install.sh" "${TEMP_DIR}/starship_install.sh"; then
            if bash "${TEMP_DIR}/starship_install.sh" -y >/dev/null 2>&1; then
                grep -q 'starship init' "${USER_HOME}/.bashrc" 2>/dev/null || echo 'eval "$(starship init bash)"' >> "${USER_HOME}/.bashrc"
                success "Starship prompt configured"
            else
                warn "Starship installation script failed"
            fi
        else
            warn "Starship download failed - manual: curl -sS https://starship.rs/install.sh | sh"
        fi
    fi
    
    success "Shell completions configured at $COMPLETIONS_FILE"
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    check_root
    check_network
    check_dnf_compatibility
    log "Starting DevSecOps Suite v${SCRIPT_VERSION} on Fedora 43..."

    log "Installing base dependencies..."
    install_package "git" || true
    install_package "jq" || true
    install_package "yq" || true
    install_package "fzf" || true
    install_package "unzip" || true
    install_package "python3-pip" || true
    install_package "ansible" || true
    install_package "bash-completion" || true
    install_package "fuse" || true
    install_package "libfuse2" || true

    install_vscode
    install_docker
    install_terraform
    install_kubernetes_tools
    install_aws_cli
    install_security_tools
    install_note_taking_tools
    configure_shell

    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}   PROVISIONING COMPLETE SUCCESSFULLY!     ${NC}"
    echo -e "${GREEN}   Installed: ${#INSTALLED_TOOLS[@]} tools. Log: $LOG_PATH ${NC}"
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Run: source ~/.bashrc"
    echo -e "  2. Configure AWS: aws configure"
    echo -e "  3. Configure Docker: newgrp docker"
    echo -e "  4. Launch Obsidian: obs or obsidian"
    echo -e "  5. Create vault: notes"
    echo -e "${CYAN}Feature toggles:${NC}"
    echo -e "  INSTALL_NOTE_TOOLS=${INSTALL_NOTE_TOOLS}"
    echo -e "  INSTALL_AWS_CLI=${INSTALL_AWS_CLI}"
    echo -e "  INSTALL_SECURITY_ADVANCED=${INSTALL_SECURITY_ADVANCED}"
    echo -e "${YELLOW}If downloads failed:${NC}"
    echo -e "  - Check network/firewall"
    echo -e "  - Install manually from official sites"
    echo -e "  - Re-run script after fixing connectivity"
}

main "$@"