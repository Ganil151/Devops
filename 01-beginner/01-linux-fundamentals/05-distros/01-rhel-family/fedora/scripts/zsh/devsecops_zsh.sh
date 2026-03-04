#!/bin/bash
#===============================================================================
# SYNOPSIS
#      DevSecOps Workstation Bootstrap - Fedora 43 Edition v8.2.0 (Zsh Edition)
# DESCRIPTION
#      Enterprise-grade provisioning with Oh My Zsh, robust error handling,
#      pre-installation checks, URL validation, and multi-source fallbacks.
#      TARGET SHELL: Zsh (.zshrc) with Oh My Zsh framework support.
#      ENHANCED: Complete Oh My Zsh plugin management with proper .zshrc configuration
#      FEATURES: Check installed status + Validate URLs + Alternative sources + Graceful degradation
#===============================================================================

set -euo pipefail

#===============================================================================
# GLOBAL CONFIGURATION
#===============================================================================
readonly SCRIPT_VERSION="8.2.0"
readonly LOG_DIR="${HOME}/.devsecops-provisioner"
readonly LOG_PATH="${LOG_DIR}/install.log"
readonly CONFIG_DIR="${HOME}/.zshrc.d"
readonly ALIASES_FILE="${CONFIG_DIR}/devops-aliases.zsh"
readonly COMPLETIONS_FILE="${CONFIG_DIR}/devops-completions.zsh"
readonly TEMP_DIR=$(mktemp -d)

# Tool versions (can be overridden via env vars)
: "${TERRAFORM_VERSION:=1.9.0}"
: "${KUBECTL_VERSION:=1.31.0}"
: "${HELM_VERSION:=3.15.0}"
: "${AWS_CLI_VERSION:=2.17.0}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Feature Toggles
: "${INSTALL_AWS_CLI:=1}"
: "${INSTALL_GITOPS_TOOLS:=1}"
: "${INSTALL_DEV_PRODUCTIVITY:=1}"
: "${INSTALL_SECURITY_ADVANCED:=1}"
: "${INSTALL_SHELL_ENHANCEMENTS:=1}"
: "${INSTALL_NOTE_TOOLS:=1}"
: "${INSTALL_OH_MY_ZSH:=1}"

# Oh My Zsh Configuration
: "${OMZ_THEME:=robbyrussell}"
: "${OMZ_PLUGINS:=(git docker docker-compose kubectl helm terraform aws zsh-autosuggestions zsh-syntax-highlighting)}"

# Network settings
: "${CURL_TIMEOUT:=30}"
: "${CURL_RETRIES:=3}"
: "${CURL_RETRY_DELAY:=5}"

# Track installation status
declare -A INSTALLED_STATUS=()
declare -a INSTALL_LOG=()

#===============================================================================
# LOGGING & ERROR HANDLING
#===============================================================================
cleanup() {
    local exit_code=$?
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}✗ Script completed with exit code $exit_code${NC}" >&2
        echo -e "${YELLOW}Check detailed logs at: ${LOG_PATH}${NC}" >&2
        print_install_summary
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
    local tool="$1"
    local msg="[OK] $tool: $2"
    echo -e "${GREEN}${msg}${NC}"
    echo "$msg" >> "$LOG_PATH"
    INSTALLED_STATUS["$tool"]="installed"
    INSTALL_LOG+=("✓ $tool")
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
    INSTALL_LOG+=("✗ ${2:-unknown}: $1")
    return 1
}

info() {
    local msg="[INFO] $1"
    echo -e "${BLUE}${msg}${NC}"
    echo "$msg" >> "$LOG_PATH"
}

print_install_summary() {
    echo -e "\n${CYAN}=== Installation Summary ===${NC}"
    for entry in "${INSTALL_LOG[@]}"; do
        echo -e "  $entry"
    done
    echo -e "${CYAN}==========================${NC}\n"
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
    local hosts=("github.com" "api.github.com" "raw.githubusercontent.com" "packages.microsoft.com")
    local reachable=0
    
    for host in "${hosts[@]}"; do
        if curl -sL --connect-timeout 10 "https://${host}" > /dev/null 2>&1; then
            ((reachable++)) || true
        fi
    done
    
    if [[ $reachable -lt 2 ]]; then
        warn "Limited network connectivity detected. Injecting Google DNS..."
        echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf > /dev/null
        echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf > /dev/null
    else
        log "Network connectivity verified (${reachable}/${#hosts[@]} hosts reachable)"
    fi
}

check_dnf_compatibility() {
    log "Checking DNF version for compatibility..."
    if dnf --version 2>/dev/null | grep -q "^5\."; then
        log "DNF5 detected - using manual repo file configuration"
        return 0
    fi
    log "DNF4 detected - standard repository management available"
}

check_zsh_available() {
    if ! command -v zsh >/dev/null 2>&1; then
        warn "Zsh is not installed. Installing now..."
        install_package "zsh" || {
            error "Zsh installation failed - cannot proceed with Zsh configuration" "zsh"
            return 1
        }
    fi
    info "Zsh is available at: $(command -v zsh)"
    return 0
}

#===============================================================================
# PRE-INSTALLATION CHECKS
#===============================================================================
is_command_available() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

is_rpm_installed() {
    local pkg="$1"
    rpm -q "$pkg" >/dev/null 2>&1
}

is_file_executable() {
    local path="$1"
    [[ -x "$path" && -f "$path" ]]
}

check_tool_installed() {
    local tool_name="$1"
    shift
    local checks=("$@")
    
    for check in "${checks[@]}"; do
        case "$check" in
            command:*)
                local cmd="${check#command:}"
                if is_command_available "$cmd"; then
                    info "${tool_name} already installed (command: ${cmd})"
                    return 0
                fi
                ;;
            rpm:*)
                local pkg="${check#rpm:}"
                if is_rpm_installed "$pkg"; then
                    info "${tool_name} already installed (rpm: ${pkg})"
                    return 0
                fi
                ;;
            file:*)
                local fpath="${check#file:}"
                if is_file_executable "$fpath"; then
                    info "${tool_name} already installed (file: ${fpath})"
                    return 0
                fi
                ;;
        esac
    done
    return 1
}

#===============================================================================
# URL VALIDATION & DOWNLOAD HELPERS
#===============================================================================
sanitize_url() {
    local url="$1"
    echo "$url" | tr -d '[:space:]\r\n\t' | sed 's/[^a-zA-Z0-9:\/\.\_\-\?=&%#]//g'
}

validate_url() {
    local url="$1"
    url=$(sanitize_url "$url")
    
    if curl -sI --connect-timeout 10 "$url" 2>/dev/null | grep -q "HTTP/[0-9.]* 200"; then
        return 0
    fi
    if curl -sL --connect-timeout 10 -r 0-1023 "$url" -o /dev/null 2>/dev/null; then
        return 0
    fi
    return 1
}

curl_with_retry() {
    local url="$1"
    local output="$2"
    local retry=0
    
    url=$(sanitize_url "$url")
    
    if ! validate_url "$url"; then
        warn "URL validation failed: $url"
        return 1
    fi
    
    local curl_opts=(-fsSL --connect-timeout "$CURL_TIMEOUT" --retry "$CURL_RETRIES" --retry-delay "$CURL_RETRY_DELAY" --retry-all-errors -L)
    
    while [[ $retry -lt $CURL_RETRIES ]]; do
        if curl "${curl_opts[@]}" "$url" -o "$output" 2>/dev/null; then
            if [[ -s "$output" ]]; then
                return 0
            fi
        fi
        ((retry++)) || true
        warn "Download attempt $retry/$CURL_RETRIES failed for: $url"
        [[ $retry -lt $CURL_RETRIES ]] && sleep "$CURL_RETRY_DELAY"
    done
    return 1
}

download_with_fallbacks() {
    local output="$1"
    shift
    local sources=("$@")
    
    for source in "${sources[@]}"; do
        source=$(sanitize_url "$source")
        info "Trying download source: $source"
        
        if validate_url "$source" && curl_with_retry "$source" "$output"; then
            if [[ -s "$output" ]]; then
                info "Successfully downloaded from: $source"
                return 0
            fi
        fi
        warn "Failed to download from: $source"
    done
    
    error "All download sources failed" "download"
    return 1
}

curl_get_json_field() {
    local url="$1"
    local field="$2"
    local result
    
    url=$(sanitize_url "$url")
    
    if ! validate_url "$url"; then
        warn "GitHub API URL not reachable: $url"
        return 1
    fi
    
    result=$(curl -fsSL --connect-timeout "$CURL_TIMEOUT" "$url" 2>/dev/null | jq -r "$field" 2>/dev/null) || return 1
    
    if [[ -n "$result" && "$result" != "null" ]]; then
        echo "$result"
        return 0
    fi
    return 1
}

get_github_latest_release() {
    local repo="$1"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    curl_get_json_field "$api_url" '.tag_name' | tr -d 'v'
}

get_github_asset_url() {
    local repo="$1"
    local pattern="$2"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    
    if ! validate_url "$api_url"; then
        warn "GitHub API not reachable for: $repo"
        return 1
    fi
    
    curl -fsSL --connect-timeout "$CURL_TIMEOUT" "$api_url" 2>/dev/null | \
        jq -r ".assets[] | select(.name | test(\"${pattern}\")) | .browser_download_url" 2>/dev/null | head -n1
}

#===============================================================================
# INSTALLATION HELPERS
#===============================================================================
install_package() {
    local pkg_name="$1"
    
    if rpm -q "$pkg_name" >/dev/null 2>&1; then
        info "$pkg_name is already installed via RPM"
        return 0
    fi
    
    log "Installing $pkg_name via dnf..."
    if dnf install -y "$pkg_name" -q >> "$LOG_PATH" 2>&1; then
        return 0
    else
        warn "DNF install failed for $pkg_name"
        return 1
    fi
}

install_package_skip_conflict() {
    local pkg_name="$1"
    
    if rpm -q "$pkg_name" >/dev/null 2>&1 || command -v "${pkg_name%%-*}" >/dev/null 2>&1; then
        info "$pkg_name or equivalent already installed - skipping"
        return 0
    fi
    
    log "Installing $pkg_name via dnf (with conflict handling)..."
    if dnf install -y "$pkg_name" -q --allowerasing >> "$LOG_PATH" 2>&1; then
        return 0
    else
        warn "DNF install failed for $pkg_name"
        return 1
    fi
}

extract_tarball() {
    local url="$1" binary_name="$2" install_path="${3:-/usr/local/bin}"
    local temp_file="${TEMP_DIR}/archive.tar.gz"
    
    if ! download_with_fallbacks "$temp_file" "$url"; then
        warn "Failed to download archive for $binary_name"
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
        warn "Binary '$binary_name' not found in archive. Contents:"
        tar -tzf "$temp_file" 2>/dev/null | head -20 >> "$LOG_PATH"
        return 1
    fi
    
    chmod +x "$found_bin"
    mv "$found_bin" "${install_path}/${binary_name}"
    return 0
}

install_rpm_from_url() {
    local rpm_url="$1"
    local rpm_name
    rpm_name=$(basename "$rpm_url")
    local temp_rpm="${TEMP_DIR}/${rpm_name}"
    
    if ! download_with_fallbacks "$temp_rpm" "$rpm_url"; then
        warn "Failed to download RPM: $rpm_name"
        return 1
    fi
    
    if dnf install -y "$temp_rpm" -q --allowerasing >> "$LOG_PATH" 2>&1; then
        return 0
    else
        warn "Failed to install RPM: $rpm_name"
        return 1
    fi
}

install_appimage() {
    local url="$1"
    local binary_name="$2"
    local install_path="${3:-/usr/local/bin}"
    local temp_file="${TEMP_DIR}/${binary_name}.AppImage"
    
    if ! download_with_fallbacks "$temp_file" "$url"; then
        warn "Failed to download AppImage: $binary_name"
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
    
    return 0
}

#===============================================================================
# OH MY ZSH INSTALLATION (WITH ROBUST ERROR HANDLING)
#===============================================================================
install_oh_my_zsh() {
    if [[ "$INSTALL_OH_MY_ZSH" != "1" ]]; then
        info "Oh My Zsh installation disabled via INSTALL_OH_MY_ZSH=0"
        return 0
    fi
    
    log "Installing Oh My Zsh..."
    
    # Check if Oh My Zsh is already installed
    if [[ -d "${USER_HOME}/.oh-my-zsh" ]]; then
        success "Oh My Zsh" "already installed at ~/.oh-my-zsh"
        return 0
    fi
    
    # Ensure Zsh is available
    if ! check_zsh_available; then
        error "Zsh not available - cannot install Oh My Zsh" "oh-my-zsh"
        return 1
    fi
    
    # Method 1: Official unattended install script
    local omz_script="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    
    if validate_url "$omz_script"; then
        info "Downloading Oh My Zsh install script..."
        if curl -fsSL "$omz_script" -o "${TEMP_DIR}/install_oh_my_zsh.sh" 2>/dev/null; then
            # Run with unattended flag, keep .zshrc backup handling
            if RUNZSH=no CHSH=no bash "${TEMP_DIR}/install_oh_my_zsh.sh" >> "$LOG_PATH" 2>&1; then
                if [[ -d "${USER_HOME}/.oh-my-zsh" ]]; then
                    success "Oh My Zsh" "installed via official script"
                    return 0
                fi
            fi
        fi
        warn "Oh My Zsh official script installation failed"
    else
        warn "Oh My Zsh script URL not reachable"
    fi
    
    # Method 2: Git clone fallback
    info "Trying Git clone fallback for Oh My Zsh..."
    local omz_repo="https://github.com/ohmyzsh/ohmyzsh.git"
    
    if command -v git >/dev/null 2>&1; then
        if git clone --depth=1 "$omz_repo" "${USER_HOME}/.oh-my-zsh" >> "$LOG_PATH" 2>&1; then
            # Copy default zshrc template
            if [[ -f "${USER_HOME}/.oh-my-zsh/templates/zshrc.zsh-template" ]]; then
                if [[ ! -f "${USER_HOME}/.zshrc" ]]; then
                    cp "${USER_HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "${USER_HOME}/.zshrc"
                fi
            fi
            success "Oh My Zsh" "installed via Git clone"
            return 0
        fi
        warn "Oh My Zsh Git clone failed"
    else
        warn "Git not available for Oh My Zsh fallback"
    fi
    
    # Method 3: Manual tarball download
    info "Trying tarball download fallback for Oh My Zsh..."
    local omz_tarball="https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    
    if download_with_fallbacks "${TEMP_DIR}/ohmyzsh.tar.gz" "$omz_tarball"; then
        mkdir -p "${USER_HOME}/.oh-my-zsh"
        if tar -xzf "${TEMP_DIR}/ohmyzsh.tar.gz" -C "${USER_HOME}/.oh-my-zsh" --strip-components=1 >> "$LOG_PATH" 2>&1; then
            if [[ ! -f "${USER_HOME}/.zshrc" ]] && [[ -f "${USER_HOME}/.oh-my-zsh/templates/zshrc.zsh-template" ]]; then
                cp "${USER_HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "${USER_HOME}/.zshrc"
            fi
            success "Oh My Zsh" "installed via tarball"
            return 0
        fi
        warn "Oh My Zsh tarball extraction failed"
    fi
    
    # All methods failed
    error "Oh My Zsh installation failed - manual: https://ohmyz.sh/#install" "oh-my-zsh"
    warn "You can install manually by running:"
    warn "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
    return 1
}

#===============================================================================
# OH MY ZSH PLUGIN INSTALLATION (ENHANCED)
#===============================================================================
install_omz_plugin() {
    local plugin_name="$1"
    local plugin_repo="$2"
    local plugin_path="${USER_HOME}/.oh-my-zsh/custom/plugins/${plugin_name}"
    
    if [[ -d "$plugin_path" ]]; then
        info "Plugin ${plugin_name} already installed"
        return 0
    fi
    
    log "Installing Oh My Zsh plugin: ${plugin_name}..."
    
    if command -v git >/dev/null 2>&1; then
        if git clone --depth=1 "$plugin_repo" "$plugin_path" >> "$LOG_PATH" 2>&1; then
            success "Plugin" "${plugin_name} installed"
            return 0
        else
            warn "Failed to clone plugin: ${plugin_name}"
            return 1
        fi
    else
        warn "Git not available for plugin installation"
        return 1
    fi
}

install_zsh_plugins() {
    if [[ "$INSTALL_OH_MY_ZSH" != "1" ]] || [[ ! -d "${USER_HOME}/.oh-my-zsh" ]]; then
        info "Oh My Zsh not installed - skipping plugin installation"
        return 0
    fi
    
    log "Installing recommended Zsh plugins..."
    
    # Ensure custom plugins directory exists
    mkdir -p "${USER_HOME}/.oh-my-zsh/custom/plugins"
    
    # zsh-autosuggestions (essential for productivity)
    install_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    
    # zsh-syntax-highlighting (essential for productivity)
    install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
    
    # zsh-completions (additional completions)
    install_omz_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions"
    
    # Optional: kubectl plugin for Oh My Zsh (if not using built-in)
    if [[ ! -d "${USER_HOME}/.oh-my-zsh/plugins/kubectl" ]]; then
        install_omz_plugin "kubectl" "https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl" 2>/dev/null || \
            info "kubectl plugin available in Oh My Zsh core"
    fi
    
    # Optional: docker plugin (if not using built-in)
    if [[ ! -d "${USER_HOME}/.oh-my-zsh/plugins/docker" ]]; then
        info "docker plugin available in Oh My Zsh core"
    fi
    
    # Optional: terraform plugin (if not using built-in)
    if [[ ! -d "${USER_HOME}/.oh-my-zsh/plugins/terraform" ]]; then
        info "terraform plugin available in Oh My Zsh core"
    fi
    
    # Optional: aws plugin (if not using built-in)
    if [[ ! -d "${USER_HOME}/.oh-my-zsh/plugins/aws" ]]; then
        info "aws plugin available in Oh My Zsh core"
    fi
    
    success "Zsh plugins" "configured"
}

#===============================================================================
# .ZSHRC PLUGIN CONFIGURATION (CRITICAL FIX)
#===============================================================================
configure_omz_plugins_in_zshrc() {
    if [[ "$INSTALL_OH_MY_ZSH" != "1" ]] || [[ ! -d "${USER_HOME}/.oh-my-zsh" ]]; then
        return 0
    fi
    
    log "Configuring Oh My Zsh plugins in .zshrc..."
    
    local zshrc_file="${USER_HOME}/.zshrc"
    
    # Ensure .zshrc exists
    if [[ ! -f "$zshrc_file" ]]; then
        if [[ -f "${USER_HOME}/.oh-my-zsh/templates/zshrc.zsh-template" ]]; then
            cp "${USER_HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "$zshrc_file"
            info "Created .zshrc from Oh My Zsh template"
        else
            touch "$zshrc_file"
            info "Created empty .zshrc"
        fi
    fi
    
    # Define the plugins we want
    local desired_plugins="git docker docker-compose kubectl helm terraform aws zsh-autosuggestions zsh-syntax-highlighting zsh-completions"
    
    # Check if plugins line exists in .zshrc
    if grep -q "^plugins=" "$zshrc_file" 2>/dev/null; then
        # Plugins line exists - update it
        info "Updating existing plugins configuration in .zshrc..."
        
        # Create backup
        cp "$zshrc_file" "${zshrc_file}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Replace plugins line with our desired plugins
        sed -i "s/^plugins=(.*)/plugins=(${desired_plugins})/" "$zshrc_file" 2>/dev/null || {
            # If sed fails, use alternative method
            warn "sed update failed, using alternative method..."
            grep -v "^plugins=" "$zshrc_file" > "${zshrc_file}.tmp" 2>/dev/null || true
            echo "plugins=(${desired_plugins})" >> "${zshrc_file}.tmp"
            mv "${zshrc_file}.tmp" "$zshrc_file"
        }
        
        success "plugins" "updated in .zshrc"
    else
        # Plugins line doesn't exist - add it after ZSH_THEME or at beginning
        info "Adding plugins configuration to .zshrc..."
        
        # Find ZSH_THEME line and add plugins after it
        if grep -q "^ZSH_THEME=" "$zshrc_file" 2>/dev/null; then
            sed -i "/^ZSH_THEME=/a plugins=(${desired_plugins})" "$zshrc_file" 2>/dev/null || {
                # Alternative: append to file
                echo "plugins=(${desired_plugins})" >> "$zshrc_file"
            }
        else
            # No ZSH_THEME found, add at beginning
            echo "plugins=(${desired_plugins})" >> "$zshrc_file"
        fi
        
        success "plugins" "added to .zshrc"
    fi
    
    # Verify plugins configuration
    if grep -q "^plugins=" "$zshrc_file" 2>/dev/null; then
        local current_plugins
        current_plugins=$(grep "^plugins=" "$zshrc_file" | head -1)
        info "Current plugins configuration: ${current_plugins}"
    else
        warn "Could not verify plugins configuration in .zshrc"
    fi
    
    # Ensure Oh My Zsh is sourced in .zshrc
    if ! grep -q "oh-my-zsh.sh" "$zshrc_file" 2>/dev/null; then
        info "Adding Oh My Zsh source to .zshrc..."
        echo 'export ZSH="${HOME}/.oh-my-zsh"' >> "$zshrc_file"
        echo 'source "$ZSH/oh-my-zsh.sh"' >> "$zshrc_file"
        success "Oh My Zsh" "source added to .zshrc"
    fi
    
    # Add plugin loading for custom plugins (zsh-autosuggestions, zsh-syntax-highlighting must load after oh-my-zsh.sh)
    if ! grep -q "zsh-autosuggestions" "$zshrc_file" 2>/dev/null; then
        cat >> "$zshrc_file" << 'PLUGIN_LOAD_EOF'

# Load custom Oh My Zsh plugins (must be after oh-my-zsh.sh source)
if [[ -d "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    source "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -d "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    source "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if [[ -d "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-completions" ]]; then
    fpath=("${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-completions/src" $fpath)
    autoload -Uz compinit && compinit
fi
PLUGIN_LOAD_EOF
        success "Custom plugins" "loading configured in .zshrc"
    fi
    
    chown "$ACTUAL_USER:" "$zshrc_file" 2>/dev/null || true
    chmod 644 "$zshrc_file"
}

#===============================================================================
# TOOL PROVISIONING WITH ROBUST CHECKS
#===============================================================================

install_vscode() {
    if check_tool_installed "VS Code" "command:code"; then
        success "VS Code" "already installed"
        return 0
    fi
    
    log "Configuring VS Code repository..."
    
    local ms_key="https://packages.microsoft.com/keys/microsoft.asc"
    if ! validate_url "$ms_key"; then
        warn "Microsoft GPG key URL not reachable, trying alternative..."
        ms_key="https://packages.microsoft.com/keys/microsoft.asc.gpg"
    fi
    
    rpm --import "$ms_key" 2>/dev/null || warn "Failed to import Microsoft GPG key"
    
    cat <<EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    
    if install_package "code"; then
        success "VS Code" "installed via DNF"
        
        local extensions=("ms-vscode.cpptools" "ms-python.python" "hashicorp.terraform" "ms-azuretools.vscode-docker" "redhat.vscode-yaml" "streetsidesoftware.code-spell-checker")
        for ext in "${extensions[@]}"; do
            sudo -u "$ACTUAL_USER" code --install-extension "$ext" --force >/dev/null 2>&1 || true
        done
        return 0
    fi
    
    warn "DNF install failed, trying direct RPM download..."
    local vs_rpm="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    if download_with_fallbacks "${TEMP_DIR}/vscode.rpm" "$vs_rpm"; then
        if dnf install -y "${TEMP_DIR}/vscode.rpm" -q --allowerasing >> "$LOG_PATH" 2>&1; then
            success "VS Code" "installed via direct RPM"
            return 0
        fi
    fi
    
    error "VS Code installation failed - please install manually from https://code.visualstudio.com" "vscode"
    return 1
}

install_docker() {
    if check_tool_installed "Docker" "command:docker"; then
        success "Docker" "already installed"
        return 0
    fi
    
    log "Configuring Docker repository..."
    
    cat <<EOF > /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
    
    if install_package "docker-ce" && install_package "docker-ce-cli" && install_package "containerd.io"; then
        systemctl enable --now docker 2>/dev/null || true
        usermod -aG docker "$ACTUAL_USER" 2>/dev/null || true
        success "Docker" "installed and configured"
        return 0
    fi
    
    warn "Docker CE repo install failed, trying Fedora packages..."
    if install_package "docker" && install_package "docker-compose"; then
        systemctl enable --now docker 2>/dev/null || true
        usermod -aG docker "$ACTUAL_USER" 2>/dev/null || true
        success "Docker" "installed via Fedora repos"
        return 0
    fi
    
    error "Docker installation failed - please install manually" "docker"
    return 1
}

install_terraform() {
    if check_tool_installed "Terraform" "command:terraform"; then
        success "Terraform" "already installed"
        return 0
    fi
    
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
    
    if install_package "terraform"; then
        success "Terraform" "installed via DNF repo"
        return 0
    fi
    
    warn "Repo install failed, trying direct binary download..."
    local tf_sources=(
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
    )
    
    if download_with_fallbacks "${TEMP_DIR}/tf.zip" "${tf_sources[@]}"; then
        unzip -q "${TEMP_DIR}/tf.zip" -d /usr/local/bin/
        chmod +x /usr/local/bin/terraform
        success "Terraform" "installed via direct binary"
        return 0
    fi
    
    warn "Direct download failed, trying Fedora package..."
    if install_package "terraform"; then
        success "Terraform" "installed via Fedora repos (may be older version)"
        return 0
    fi
    
    error "Terraform installation failed - manual: https://developer.hashicorp.com/terraform/install" "terraform"
    return 1
}

install_kubernetes_tools() {
    log "Installing K8s tools (kubectl, helm, k9s, stern)..."
    
    if check_conflicting_packages || check_tool_installed "kubectl" "command:kubectl"; then
        success "kubectl" "already available"
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
        
        if install_package_skip_conflict "kubectl"; then
            success "kubectl" "installed via Kubernetes repo"
        else
            warn "kubectl repo install failed, trying direct download..."
            local kubectl_sources=(
                "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
                "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
            )
            
            if download_with_fallbacks /usr/local/bin/kubectl "${kubectl_sources[@]}"; then
                chmod +x /usr/local/bin/kubectl
                success "kubectl" "installed via direct download"
            else
                if install_package "kubernetes-client"; then
                    success "kubectl" "installed via Fedora kubernetes-client"
                else
                    error "kubectl installation failed" "kubectl"
                fi
            fi
        fi
    fi
    
    if check_tool_installed "Helm" "command:helm"; then
        success "Helm" "already installed"
    else
        log "Installing Helm..."
        local helm_script="https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
        
        if validate_url "$helm_script" && curl -fsSL "$helm_script" | bash >/dev/null 2>&1; then
            success "Helm" "installed via official script"
        else
            warn "Helm script failed, trying direct binary..."
            local helm_version="${HELM_VERSION}"
            local helm_sources=(
                "https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz"
                "https://github.com/helm/helm/releases/download/v${helm_version}/helm-v${helm_version}-linux-amd64.tar.gz"
            )
            
            if download_with_fallbacks "${TEMP_DIR}/helm.tar.gz" "${helm_sources[@]}"; then
                tar -xzf "${TEMP_DIR}/helm.tar.gz" -C "$TEMP_DIR"
                mv "${TEMP_DIR}/linux-amd64/helm" /usr/local/bin/ 2>/dev/null || \
                find "$TEMP_DIR" -name "helm" -type f -executable -exec mv {} /usr/local/bin/ \;
                chmod +x /usr/local/bin/helm 2>/dev/null || true
                success "Helm" "installed via direct binary"
            else
                error "Helm installation failed" "helm"
            fi
        fi
    fi

    if [[ "$INSTALL_DEV_PRODUCTIVITY" == "1" ]]; then
        if ! check_tool_installed "k9s" "command:k9s"; then
            local k9s_url
            k9s_url=$(get_github_asset_url "derailed/k9s" "k9s_Linux_amd64.tar.gz")
            
            if [[ -n "$k9s_url" ]] && extract_tarball "$k9s_url" "k9s"; then
                success "k9s" "installed via GitHub API"
            else
                warn "k9s GitHub API failed, trying version fallback..."
                local k9s_version
                k9s_version=$(get_github_latest_release "derailed/k9s")
                if [[ -n "$k9s_version" ]]; then
                    local k9s_fallback="https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_amd64.tar.gz"
                    if extract_tarball "$k9s_fallback" "k9s"; then
                        success "k9s" "installed via version fallback"
                    else
                        warn "k9s installation failed - manual: https://github.com/derailed/k9s/releases"
                    fi
                fi
            fi
        else
            success "k9s" "already installed"
        fi
        
        if ! check_tool_installed "stern" "command:stern"; then
            local stern_url
            stern_url=$(get_github_asset_url "stern/stern" "stern_.*_linux_amd64.tar.gz")
            
            if [[ -n "$stern_url" ]] && extract_tarball "$stern_url" "stern"; then
                success "stern" "installed via GitHub API"
            else
                warn "stern GitHub API failed, trying version fallback..."
                local stern_version
                stern_version=$(get_github_latest_release "stern/stern")
                if [[ -n "$stern_version" ]]; then
                    local stern_fallback="https://github.com/stern/stern/releases/download/v${stern_version}/stern_${stern_version}_linux_amd64.tar.gz"
                    if extract_tarball "$stern_fallback" "stern"; then
                        success "stern" "installed via version fallback"
                    else
                        warn "stern installation failed - manual: https://github.com/stern/stern/releases"
                    fi
                fi
            fi
        else
            success "stern" "already installed"
        fi
    fi
}

install_aws_cli() {
    if [[ "$INSTALL_AWS_CLI" != "1" ]]; then
        info "AWS CLI installation disabled via INSTALL_AWS_CLI=0"
        return 0
    fi
    
    if check_tool_installed "AWS CLI" "command:aws"; then
        success "AWS CLI" "already installed"
        return 0
    fi
    
    log "Installing AWS CLI v2..."
    
    local aws_sources=(
        "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    )
    
    if download_with_fallbacks "${TEMP_DIR}/awscliv2.zip" "${aws_sources[@]}"; then
        unzip -q "${TEMP_DIR}/awscliv2.zip" -d "$TEMP_DIR"
        if "${TEMP_DIR}/aws/install" --update -b /usr/local/bin >/dev/null 2>&1; then
            success "AWS CLI" "installed"
            return 0
        fi
    fi
    
    warn "AWS CLI direct install failed, trying Fedora package..."
    if install_package "awscli"; then
        success "AWS CLI" "installed via Fedora repos (v1)"
        return 0
    fi
    
    error "AWS CLI installation failed - manual: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" "aws-cli"
    return 1
}

install_security_tools() {
    if [[ "$INSTALL_SECURITY_ADVANCED" != "1" ]]; then return 0; fi
    
    log "Configuring Security Tools (Trivy, Checkov)..."
    
    if check_tool_installed "Trivy" "command:trivy"; then
        success "Trivy" "already installed"
    else
        cat <<EOF > /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=0
enabled=1
EOF
        
        if install_package "trivy"; then
            success "Trivy" "installed via repo"
        else
            warn "Trivy repo install failed, trying direct download..."
            local trivy_version="0.49.0"
            local trivy_sources=(
                "https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_Linux-64bit.tar.gz"
                "https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.tar.gz"
            )
            
            if download_with_fallbacks "${TEMP_DIR}/trivy.tar.gz" "${trivy_sources[@]}"; then
                tar -xzf "${TEMP_DIR}/trivy.tar.gz" -C "$TEMP_DIR"
                mv "${TEMP_DIR}/trivy" /usr/local/bin/
                chmod +x /usr/local/bin/trivy
                success "Trivy" "installed via direct download"
            else
                warn "Trivy installation failed - manual: https://aquasecurity.github.io/trivy/latest/installation/"
            fi
        fi
    fi
    
    if check_tool_installed "Checkov" "command:checkov"; then
        success "Checkov" "already installed"
    elif command -v pip3 >/dev/null 2>&1; then
        if sudo -u "$ACTUAL_USER" pip3 install --user --quiet checkov 2>/dev/null; then
            success "Checkov" "installed via pip"
        else
            warn "Checkov pip install failed"
        fi
    fi
}

install_note_taking_tools() {
    if [[ "$INSTALL_NOTE_TOOLS" != "1" ]]; then 
        info "Note-taking tools disabled via INSTALL_NOTE_TOOLS=0"
        return 0
    fi
    
    log "Installing Note-Taking & Knowledge Management Tools..."
    
    if check_tool_installed "Obsidian" "command:obsidian" "rpm:obsidian"; then
        success "Obsidian" "already installed"
    else
        log "Installing Obsidian..."
        local obsidian_url
        obsidian_url=$(get_github_asset_url "obsidianmd/obsidian-releases" "obsidian_.*_amd64.rpm")
        
        if [[ -n "$obsidian_url" ]] && install_rpm_from_url "$obsidian_url"; then
            success "Obsidian" "installed via GitHub RPM"
        else
            warn "Obsidian GitHub API failed, trying known versions..."
            local obsidian_fallbacks=(
                "https://github.com/obsidianmd/obsidian-releases/releases/download/1.5.3/obsidian_1.5.3_amd64.rpm"
                "https://github.com/obsidianmd/obsidian-releases/releases/download/1.4.16/obsidian_1.4.16_amd64.rpm"
            )
            
            local installed=0
            for fallback in "${obsidian_fallbacks[@]}"; do
                if validate_url "$fallback" && install_rpm_from_url "$fallback"; then
                    success "Obsidian" "installed via fallback RPM"
                    installed=1
                    break
                fi
            done
            
            if [[ $installed -eq 0 ]]; then
                warn "Obsidian installation failed - please install manually:"
                warn "  1. Visit: https://obsidian.md/download"
                warn "  2. Download Linux .rpm"
                warn "  3. Run: sudo dnf install ./obsidian_*.rpm"
            fi
        fi
    fi
    
    if check_tool_installed "Joplin" "command:joplin"; then
        success "Joplin" "already installed"
    else
        log "Installing Joplin via AppImage..."
        local joplin_version
        joplin_version=$(get_github_latest_release "laurent22/joplin")
        
        if [[ -n "$joplin_version" ]]; then
            local joplin_url="https://github.com/laurent22/joplin/releases/download/v${joplin_version}/Joplin-${joplin_version}.AppImage"
            if install_appimage "$joplin_url" "joplin"; then
                success "Joplin" "installed via AppImage"
            else
                if install_appimage "https://github.com/laurent22/joplin/releases/download/v2.14.0/Joplin-2.14.0.AppImage" "joplin"; then
                    success "Joplin" "installed via fallback AppImage"
                else
                    warn "Joplin installation failed - manual: https://joplinapp.org"
                fi
            fi
        else
            warn "Could not resolve Joplin version - trying direct fallback..."
            if install_appimage "https://github.com/laurent22/joplin/releases/download/v2.14.0/Joplin-2.14.0.AppImage" "joplin"; then
                success "Joplin" "installed via direct fallback"
            else
                warn "Joplin installation failed"
            fi
        fi
    fi
    
    if check_tool_installed "Mark Text" "file:/usr/local/bin/mark-text"; then
        success "Mark Text" "already installed"
    else
        log "Installing Mark Text..."
        local marktext_version
        marktext_version=$(get_github_latest_release "marktext/marktext")
        
        if [[ -n "$marktext_version" ]]; then
            local marktext_url="https://github.com/marktext/marktext/releases/download/v${marktext_version}/marktext-x86_64.AppImage"
            if install_appimage "$marktext_url" "mark-text"; then
                success "Mark Text" "installed"
            else
                if install_appimage "https://github.com/marktext/marktext/releases/download/v0.17.1/marktext-x86_64.AppImage" "mark-text"; then
                    success "Mark Text" "installed via fallback"
                else
                    warn "Mark Text installation failed - manual: https://marktext.app"
                fi
            fi
        fi
    fi
    
    if [[ "$INSTALL_DEV_PRODUCTIVITY" == "1" ]] && ! check_tool_installed "Logseq" "file:/usr/local/bin/logseq"; then
        log "Installing Logseq..."
        local logseq_version
        logseq_version=$(get_github_latest_release "logseq/logseq")
        
        if [[ -n "$logseq_version" ]]; then
            local logseq_url="https://github.com/logseq/logseq/releases/download/v${logseq_version}/Logseq-linux-x86_64.AppImage"
            if install_appimage "$logseq_url" "logseq"; then
                success "Logseq" "installed"
            else
                if install_appimage "https://github.com/logseq/logseq/releases/download/v0.10.9/Logseq-linux-x86_64.AppImage" "logseq"; then
                    success "Logseq" "installed via fallback"
                else
                    warn "Logseq installation failed - manual: https://logseq.com"
                fi
            fi
        fi
    fi
    
    if is_command_available obsidian || is_rpm_installed obsidian || [[ -f /usr/bin/obsidian ]]; then
        log "Configuring Obsidian workspace..."
        local obsidian_vault="${USER_HOME}/Documents/Obsidian-Vault"
        mkdir -p "$obsidian_vault"/{.obsidian,attachments,templates,daily-notes}
        chown -R "$ACTUAL_USER:" "$obsidian_vault" 2>/dev/null || true
        success "Obsidian" "vault structure created"
    fi
}

check_conflicting_packages() {
    if rpm -q "kubernetes*-client" >/dev/null 2>&1 && command -v kubectl >/dev/null 2>&1; then
        info "kubectl already provided by Fedora kubernetes-client package"
        return 0
    fi
    if rpm -q --whatprovides /usr/bin/kubectl >/dev/null 2>&1; then
        local provider
        provider=$(rpm -q --whatprovides /usr/bin/kubectl)
        info "/usr/bin/kubectl provided by ${provider}"
        return 0
    fi
    return 1
}

#===============================================================================
# ZSH CONFIGURATION (.zshrc.d)
#===============================================================================
configure_zsh() {
    log "Configuring Zsh, aliases, and completions..."
    mkdir -p "$CONFIG_DIR"
    
    # Zsh aliases file
    cat << 'ALIASES_EOF' > "$ALIASES_FILE"
# >>> System & Navigation <<<
alias cls='clear'
alias reload='source ~/.zshrc 2>/dev/null && echo "✅ Config reloaded"'
alias path='print -l ${PATH//:/\\n}'
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
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp 2>/dev/null'
alias myip='curl -sL https://ifconfig.me 2>/dev/null || curl -sL https://icanhazip.com 2>/dev/null'
alias df='df -h --total 2>/dev/null || df -h'
alias du='du -h --max-depth=2 2>/dev/null || du -h -d 2'
alias free='free -h 2>/dev/null || free -m'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias timestamp='date "+%Y%m%d_%H%M%S"'

# >>> Git <<<
alias gs='git status -sb 2>/dev/null'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull --rebase'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glog="git log --graph --oneline --decorate"

# >>> Docker <<<
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker ps'
alias dpa='docker ps -a'
alias dlogs='docker logs -f --tail=100'
alias dprune='docker system prune -af --volumes'
if docker compose version &>/dev/null; then alias dco='docker compose'; elif command -v docker-compose &>/dev/null; then alias dco='docker-compose'; fi
alias dcup='dco up -d' 2>/dev/null || true
alias dcdn='dco down' 2>/dev/null || true

# >>> Kubernetes <<<
alias k='kubectl 2>/dev/null || echo "kubectl not installed"'
alias kgp='kubectl get pods 2>/dev/null'
alias kgs='kubectl get svc 2>/dev/null'
alias kgd='kubectl get deployments 2>/dev/null'
alias kl='kubectl logs -f --tail=100' 2>/dev/null
alias kaf='kubectl apply -f' 2>/dev/null

# >>> Terraform <<<
alias tf='terraform 2>/dev/null || echo "terraform not installed"'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'

# >>> Note-Taking <<<
alias obs='obsidian 2>/dev/null || echo "Obsidian not installed"'
alias jop='joplin 2>/dev/null || echo "Joplin not installed"'
alias notes='cd "${HOME}/Documents/Obsidian-Vault" 2>/dev/null || mkdir -p "${HOME}/Documents/Obsidian-Vault" && cd "${HOME}/Documents/Obsidian-Vault"'

# >>> Cloud <<<
alias aws-who='aws sts get-caller-identity 2>/dev/null'
asp() { [[ -n "$1" ]] && export AWS_PROFILE="$1" && echo "✅ AWS Profile: $AWS_PROFILE"; }

# >>> Utilities <<<
extract() { [[ -f "$1" ]] && case "$1" in *.tar.gz|*.tgz) tar xzf "$1";; *.zip) unzip -q "$1";; *.tar) tar xf "$1";; *) echo "Unknown format";; esac; }
mkcd() { mkdir -p "$1" && cd "$1" && pwd; }
serve() { python3 -m http.server "${1:-8080}" 2>/dev/null || python -m http.server "${1:-8080}"; }
jp() { jq -C . 2>/dev/null || python3 -m json.tool 2>/dev/null || cat; }
ALIASES_EOF

    chown "$ACTUAL_USER:" "$ALIASES_FILE" 2>/dev/null || true
    chmod 644 "$ALIASES_FILE"
    
    # Zsh completions file
    cat << 'COMPLETIONS_EOF' > "$COMPLETIONS_FILE"
# Zsh completions for DevOps tools
# Kubernetes
if (( ${+commands[kubectl]} )); then
    source <(kubectl completion zsh) 2>/dev/null || true
fi

# Helm
if (( ${+commands[helm]} )); then
    source <(helm completion zsh) 2>/dev/null || true
fi

# Docker (if bash-completion is available)
if [[ -f /usr/share/bash-completion/completions/docker ]]; then
    autoload -Uz bashcompinit && bashcompinit 2>/dev/null
    source /usr/share/bash-completion/completions/docker 2>/dev/null || true
fi

# Terraform
if (( ${+commands[terraform]} )); then
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        eval "\$(terraform -install-autocomplete)" 2>/dev/null || true
    fi
fi

# AWS CLI
if (( ${+commands[aws]} )) && [[ -f /usr/share/zsh/site-functions/_aws ]]; then
    source /usr/share/zsh/site-functions/_aws 2>/dev/null || true
fi
COMPLETIONS_EOF

    chown -R "$ACTUAL_USER:" "$CONFIG_DIR" 2>/dev/null || true
    
    # Update .zshrc to source our config directory
    if ! grep -q '\.zshrc\.d' "${USER_HOME}/.zshrc" 2>/dev/null; then
        cat << 'ZSHRC_EOF' >> "${USER_HOME}/.zshrc"

# DevOps config directory (auto-generated by provisioner)
if [[ -d ~/.zshrc.d ]]; then
    for rc_file in ~/.zshrc.d/*.zsh; do
        [[ -f "$rc_file" ]] && source "$rc_file"
    done
fi
ZSHRC_EOF
        log "Added ~/.zshrc.d sourcing to .zshrc"
    fi
    
    success "aliases" "configured at $ALIASES_FILE"
    success "completions" "configured at $COMPLETIONS_FILE"
    
    # Configure Oh My Zsh plugins in .zshrc (CRITICAL - must run after .zshrc.d setup)
    configure_omz_plugins_in_zshrc
    
    # Starship prompt for Zsh
    if [[ "$INSTALL_SHELL_ENHANCEMENTS" == "1" ]]; then
        if curl_with_retry "https://starship.rs/install.sh" "${TEMP_DIR}/starship.sh" && \
           bash "${TEMP_DIR}/starship.sh" -y >/dev/null 2>&1; then
            if ! grep -q 'starship init zsh' "${USER_HOME}/.zshrc" 2>/dev/null; then
                echo 'eval "$(starship init zsh)"' >> "${USER_HOME}/.zshrc"
            fi
            success "starship" "prompt configured for Zsh"
        else
            warn "Starship installation failed - manual: curl -sS https://starship.rs/install.sh | sh"
        fi
    fi
    
    # Set Zsh as default shell if not already
    if [[ "$SHELL" != *"zsh" ]]; then
        if grep -q "/zsh$" /etc/shells 2>/dev/null; then
            chsh -s "$(command -v zsh)" "$ACTUAL_USER" 2>/dev/null && \
                info "Zsh set as default shell for $ACTUAL_USER" || \
                warn "Could not set Zsh as default shell - run: chsh -s \$(which zsh)"
        fi
    fi
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================
main() {
    check_root
    check_network
    check_dnf_compatibility
    
    log "Starting DevSecOps Suite v${SCRIPT_VERSION} (Zsh Edition) on Fedora 43..."
    log "User: $ACTUAL_USER | Home: $USER_HOME | Shell: ${SHELL:-unknown}"
    
    # Base dependencies
    log "Installing base dependencies..."
    for pkg in git jq yq fzf unzip python3-pip ansible bash-completion zsh fuse libfuse2; do
        install_package "$pkg" || warn "Failed to install $pkg (non-critical)"
    done
    
    # Oh My Zsh installation (before other shell config)
    install_oh_my_zsh
    install_zsh_plugins
    
    # Core tools
    install_vscode
    install_docker
    install_terraform
    install_kubernetes_tools
    install_aws_cli
    install_security_tools
    install_note_taking_tools
    
    # Zsh configuration (last, after tools are available for completions)
    configure_zsh
    
    # Final summary
    echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ PROVISIONING COMPLETE!            ║${NC}"
    echo -e "${GREEN}║   Zsh Edition with Oh My Zsh           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Installed tools: ${#INSTALLED_STATUS[@]}${NC}"
    echo -e "${CYAN}Log file: $LOG_PATH${NC}"
    
    print_install_summary
    
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "  1. Reload Zsh: source ~/.zshrc  (or start new terminal)"
    echo -e "  2. Docker access: newgrp docker (or logout/login)"
    echo -e "  3. AWS config: aws configure"
    echo -e "  4. Launch Obsidian: obs or obsidian"
    echo -e "  5. Create notes vault: notes"
    echo -e "  6. If Zsh isn't your default: chsh -s \$(which zsh)"
    
    echo -e "\n${CYAN}🔧 Feature Toggles Used:${NC}"
    echo -e "  INSTALL_OH_MY_ZSH=${INSTALL_OH_MY_ZSH}"
    echo -e "  INSTALL_NOTE_TOOLS=${INSTALL_NOTE_TOOLS}"
    echo -e "  INSTALL_AWS_CLI=${INSTALL_AWS_CLI}"
    echo -e "  INSTALL_SECURITY_ADVANCED=${INSTALL_SECURITY_ADVANCED}"
    echo -e "  INSTALL_SHELL_ENHANCEMENTS=${INSTALL_SHELL_ENHANCEMENTS}"
    
    echo -e "\n${YELLOW}⚠️  If any tool failed to install:${NC}"
    echo -e "  • Check logs: cat $LOG_PATH"
    echo -e "  • Verify network/firewall settings"
    echo -e "  • Install manually from official websites"
    echo -e "  • Re-run script after fixing issues (already-installed tools will be skipped)"
    
    echo -e "\n${BLUE}🎨 Oh My Zsh Tips:${NC}"
    echo -e "  • Change theme: edit ZSH_THEME in ~/.zshrc"
    echo -e "  • Update OMZ: omz update"
    echo -e "  • List plugins: ls ~/.oh-my-zsh/plugins"
    echo -e "  • List custom plugins: ls ~/.oh-my-zsh/custom/plugins"
    echo -e "  • Reload config: source ~/.zshrc"
    echo -e "  • Current plugins: grep '^plugins=' ~/.zshrc"
    
    echo -e "\n${MAGENTA}🔌 Installed Oh My Zsh Plugins:${NC}"
    if [[ -d "${USER_HOME}/.oh-my-zsh/custom/plugins" ]]; then
        ls -1 "${USER_HOME}/.oh-my-zsh/custom/plugins" 2>/dev/null | while read plugin; do
            echo -e "  ✓ ${plugin}"
        done
    fi
    echo -e "  Core plugins: git, docker, docker-compose, kubectl, helm, terraform, aws"
}

main "$@"