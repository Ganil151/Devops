#!/bin/bash
#===============================================================================
# DevSecOps Workstation Bootstrap - Unified Edition v4.0.0
# Cross-platform implementation for Linux/Bash (Fedora, Ubuntu, WSL2)
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONFIGURATION LOADING
#-------------------------------------------------------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/config.json"
readonly SCRIPT_NAME="DevSecOps-Bootstrap"
readonly SCRIPT_VERSION="4.0.0-UNIFIED"

# Load configuration (requires jq)
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required to parse config.json. Install with: sudo dnf install jq" >&2
    exit 1
fi

readonly CONFIG=$(cat "$CONFIG_FILE" | jq -c .)

# Parse global settings
readonly LOG_DIR_LINUX=$(echo "$CONFIG" | jq -r '.defaults.log_dir.linux' | sed "s|\$HOME|$HOME|g")
readonly TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
readonly LOG_PATH="${LOG_DIR_LINUX}/${SCRIPT_NAME}-${TIMESTAMP}.log"
readonly REPORT_CSV="${LOG_DIR_LINUX}/${SCRIPT_NAME}-Report-${TIMESTAMP}.csv"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m'

# Global state
declare -a INSTALL_RESULTS=()
FORCE_REINSTALL=false
SKIP_DOCKER=false
EXPORT_REPORT=false
USE_PIP=true

#-------------------------------------------------------------------------------
# ARGUMENT PARSING
#-------------------------------------------------------------------------------

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force) FORCE_REINSTALL=true ;;
            --no-docker) SKIP_DOCKER=true ;;
            --export) EXPORT_REPORT=true ;;
            --no-pip) USE_PIP=false ;;
            --help|-h) show_help; exit 0 ;;
            *) echo "Unknown option: $1"; show_help; exit 1 ;;
        esac
        shift
    done
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Unified DevSecOps Bootstrap for Linux/WSL2

OPTIONS:
    --force       Force reinstall all tools
    --no-docker   Skip Docker Engine installation
    --export      Export report to CSV
    --no-pip      Disable pip fallbacks
    --help, -h    Show this help

EXAMPLES:
    sudo ./devops-bootstrap.sh
    sudo ./devops-bootstrap.sh --force --export
EOF
}

#-------------------------------------------------------------------------------
# LOGGING
#-------------------------------------------------------------------------------

log() {
    local msg="$1"
    local level="${2:-Info}"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    local entry="[$ts] [$level] $msg"
    
    mkdir -p "$LOG_DIR_LINUX" 2>/dev/null || true
    echo "$entry" >> "$LOG_PATH" 2>/dev/null || true
    
    case "$level" in
        Info) echo -e "${CYAN}${entry}${NC}" ;;
        Success) echo -e "${GREEN}${entry}${NC}" ;;
        Warning) echo -e "${YELLOW}${entry}${NC}" ;;
        Error) echo -e "${RED}${entry}${NC}" ;;
        Debug) [[ "${DEBUG:-}" == "true" ]] && echo -e "${GRAY}${entry}${NC}" ;;
    esac
}

#-------------------------------------------------------------------------------
# SYSTEM UTILITIES
#-------------------------------------------------------------------------------

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_version() {
    local cmd="$1"
    local arg="$2"
    if command_exists "$cmd"; then
        $cmd $arg 2>&1 | head -1 | tr -d '\r' | xargs
    fi
}

set_env() {
    local name="$1"
    local value="$2"
    export "$name=$value"
    if ! grep -q "^export $name=" ~/.bashrc 2>/dev/null; then
        echo "export $name=\"$value\"" >> ~/.bashrc
    fi
    log "Set $name=$value" "Debug"
}

add_path() {
    local path_dir="$1"
    if [[ ":$PATH:" != *":$path_dir:"* ]]; then
        export PATH="$path_dir:$PATH"
        if ! grep -q "export PATH=.*$path_dir" ~/.bashrc 2>/dev/null; then
            echo "export PATH=\"$path_dir:\$PATH\"" >> ~/.bashrc
        fi
    fi
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        i386|i686) echo "386" ;;
        *) echo "unknown" ;;
    esac
}

download() {
    local url="$1"
    local dest="$2"
    if command_exists curl; then
        curl -fsSL -o "$dest" "$url"
    elif command_exists wget; then
        wget -q -O "$dest" "$url"
    else
        return 1
    fi
}

extract() {
    local archive="$1"
    local dest="$2"
    mkdir -p "$dest"
    case "$archive" in
        *.zip)
            if command_exists unzip; then
                unzip -q "$archive" -d "$dest"
            else
                return 1
            fi
            ;;
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$dest"
            ;;
        *.tar.xz)
            tar -xJf "$archive" -C "$dest"
            ;;
        *)
            return 1
            ;;
    esac
}

#-------------------------------------------------------------------------------
# PACKAGE MANAGER SETUP
#-------------------------------------------------------------------------------

setup_repos() {
    log "Configuring DNF repositories..." "Info"
    
    # RPM Fusion
    if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
        local ver
        ver=$(rpm -E %fedora)
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${ver}.noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${ver}.noarch.rpm" -q
    fi
    
    # HashiCorp
    if [[ ! -f /etc/yum.repos.d/hashicorp.repo ]]; then
        sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo -q
    fi
    
    # Kubernetes
    if [[ ! -f /etc/yum.repos.d/kubernetes.repo ]]; then
        cat << EOF | sudo tee /etc/yum.repos.d/kubernetes.repo >/dev/null
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
    fi
    
    # Docker (if needed)
    if [[ "$SKIP_DOCKER" != "true" && ! -f /etc/yum.repos.d/docker-ce.repo ]]; then
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo -q
    fi
    
    # Adoptium
    if [[ ! -f /etc/yum.repos.d/adoptium.repo ]]; then
        sudo rpm --import https://packages.adoptium.net/artifactory/api/gpg/key/public
        cat << EOF | sudo tee /etc/yum.repos.d/adoptium.repo >/dev/null
[Adoptium]
name=Adoptium
baseurl=https://packages.adoptium.net/artifactory/rpm/fedora/\$releasever/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
EOF
    fi
    
    sudo dnf makecache --refresh -q
    log "Repositories configured" "Success"
}

#-------------------------------------------------------------------------------
# INSTALLATION ENGINES
#-------------------------------------------------------------------------------

install_dnf() {
    local pkg="$1"
    local cmd="$2"
    local arg="$3"
    local name="$4"
    log "Installing $name via DNF: $pkg" "Info"
    if sudo dnf install -y "$pkg" -q; then
        local ver
        ver=$(get_version "$cmd" "$arg")
        log "$name installed: ${ver:-unknown}" "Success"
        echo "Success|${ver:-unknown}"
    else
        log "DNF install failed: $pkg" "Error"
        echo "Failed|N/A"
    fi
}

install_pip() {
    local pkg="$1"
    local cmd="$2"
    local arg="$3"
    local name="$4"
    if [[ "$USE_PIP" != "true" ]]; then
        log "Skipping pip for $name" "Warning"
        echo "Skipped|N/A"
        return 0
    fi
    
    log "Installing $name via pip: $pkg" "Info"
    if ! command_exists pip3; then
        log "pip3 not found. Installing python3-pip..." "Warning"
        sudo dnf install -y python3-pip -q
    fi
    if ! command_exists pip3; then
        log "pip3 not available" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    if pip3 install --user --quiet "$pkg"; then
        add_path "$HOME/.local/bin"
        local ver
        ver=$(get_version "$cmd" "$arg")
        log "$name installed via pip: ${ver:-unknown}" "Success"
        echo "Success|${ver:-unknown}"
    else
        log "pip install failed: $pkg" "Error"
        echo "Failed|N/A"
    fi
}

install_github_binary() {
    local repo="$1"
    local pattern="$2"
    local binary="$3"
    local cmd="$4"
    local arg="$5"
    local name="$6"
    local arch
    arch=$(detect_arch)
    pattern="${pattern//\{ARCH\}/$arch}"
    
    log "Fetching $name from GitHub: $repo" "Info"
    local json
    json=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null) || {
        log "Failed to fetch release info" "Error"
        echo "Failed|N/A"
        return 1
    }
    
    local url
    url=$(echo "$json" | jq -r ".assets[] | select(.name | test(\"$pattern\")) | .browser_download_url" | head -1)
    if [[ -z "$url" || "$url" == "null" ]]; then
        log "No matching binary found for pattern: $pattern" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    local tmp="/tmp/${binary}-$$"
    if ! download "$url" "$tmp"; then
        log "Download failed" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    # Validate ELF binary (for non-archive downloads)
    if [[ "$pattern" != *.zip && "$pattern" != *.tar* ]] && ! file "$tmp" | grep -q "ELF"; then
        log "Downloaded file is not a valid Linux binary" "Error"
        rm -f "$tmp"
        echo "Failed|N/A"
        return 1
    fi
    
    chmod +x "$tmp"
    sudo mv "$tmp" "/usr/local/bin/$binary"
    
    local ver
    ver=$(get_version "$cmd" "$arg")
    log "$name installed: ${ver:-unknown}" "Success"
    echo "Success|${ver:-unknown}"
}

install_github_archive() {
    local repo="$1"
    local pattern="$2"
    local binary="$3"
    local cmd="$4"
    local arg="$5"
    local name="$6"
    local arch
    arch=$(detect_arch)
    pattern="${pattern//\{ARCH\}/$arch}"
    
    log "Fetching $name archive from GitHub: $repo" "Info"
    local json
    json=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null) || {
        log "Failed to fetch release info" "Error"
        echo "Failed|N/A"
        return 1
    }
    
    local url
    url=$(echo "$json" | jq -r ".assets[] | select(.name | test(\"$pattern\")) | .browser_download_url" | head -1)
    if [[ -z "$url" || "$url" == "null" ]]; then
        log "No matching archive found" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    local tmp_dir="/tmp/${binary}-install-$$"
    local archive="$tmp_dir/archive"
    mkdir -p "$tmp_dir"
    
    if ! download "$url" "$archive"; then
        log "Download failed" "Error"
        echo "Failed|N/A"
        return 1
    fi
    if ! extract "$archive" "$tmp_dir"; then
        log "Extraction failed" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    # Find and install binary
    local found
    found=$(find "$tmp_dir" -type f -name "$binary" -executable | head -1)
    if [[ -z "$found" ]]; then
        log "Binary '$binary' not found in archive" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    sudo mv "$found" "/usr/local/bin/$binary"
    sudo chmod +x "/usr/local/bin/$binary"
    
    local ver
    ver=$(get_version "$cmd" "$arg")
    log "$name installed: ${ver:-unknown}" "Success"
    rm -rf "$tmp_dir"
    echo "Success|${ver:-unknown}"
}

install_direct_url() {
    local url="$1"
    local extract_to="$2"
    local bin_subdir="$3"
    local cmd="$4"
    local arg="$5"
    local name="$6"
    local env_name="$7"
    
    log "Installing $name from direct URL" "Info"
    local tmp_zip="/tmp/${name// /-}.zip"
    if ! download "$url" "$tmp_zip"; then
        log "Download failed" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    local tmp_extract="/tmp/${name// /-}-extract"
    if ! extract "$tmp_zip" "$tmp_extract"; then
        log "Extraction failed" "Error"
        echo "Failed|N/A"
        return 1
    fi
    
    local src_dir
    src_dir=$(find "$tmp_extract" -maxdepth 1 -type d -name "${name// /-}*" | head -1)
    [[ -z "$src_dir" ]] && src_dir=$(find "$tmp_extract" -type d | head -2 | tail -1)
    
    sudo mkdir -p "$extract_to"
    sudo rsync -a "$src_dir/" "$extract_to/" 2>/dev/null || sudo cp -r "$src_dir/." "$extract_to/"
    
    [[ -n "$bin_subdir" ]] && add_path "$extract_to/$bin_subdir"
    [[ -n "$env_name" ]] && set_env "$env_name" "$extract_to"
    
    local ver
    ver=$(get_version "$cmd" "$arg")
    log "$name installed: ${ver:-unknown}" "Success"
    rm -f "$tmp_zip"
    rm -rf "$tmp_extract"
    echo "Success|${ver:-unknown}"
}

#-------------------------------------------------------------------------------
# TOOL INSTALLERS
#-------------------------------------------------------------------------------

apply_env_vars() {
    local env_json="$1"
    echo "$env_json" | jq -r 'to_entries[] | "\(.key)=\(.value)"' 2>/dev/null | while read -r line; do
        local name="${line%%=*}"
        local value="${line#*=}"
        if [[ "$value" == "auto_detect" ]]; then
            case "$name" in
                JAVA_HOME) value=$(readlink -f /usr/bin/java 2>/dev/null | sed 's:bin/java::') ;;
                *) continue ;;
            esac
        fi
        if [[ -n "$value" && -d "$value" ]]; then
            set_env "$name" "$value"
        fi
    done
}

install_tool() {
    local tool_json="$1"
    
    local name cmd arg display category methods env_vars skip_flag
    name=$(echo "$tool_json" | jq -r '.name')
    cmd=$(echo "$tool_json" | jq -r '.command')
    arg=$(echo "$tool_json" | jq -r '.version_arg')
    display=$(echo "$tool_json" | jq -r '.display_name')
    category=$(echo "$tool_json" | jq -r '.category // "Unknown"')
    methods=$(echo "$tool_json" | jq -c '.install_methods.linux')
    env_vars=$(echo "$tool_json" | jq -r '.env_vars // {}')
    skip_flag=$(echo "$tool_json" | jq -r '.skip_flag // ""')
    
    # Check skip flags
    if [[ -n "$skip_flag" && "${!skip_flag:-}" == "true" ]]; then
        log "[$category] Skipping $display (--$skip_flag enabled)" "Info"
        INSTALL_RESULTS+=("$display|$category|Skipped|N/A")
        return 0
    fi
    
    # Idempotency check
    local existing
    existing=$(get_version "$cmd" "$arg")
    if [[ -n "$existing" && "$FORCE_REINSTALL" != "true" ]]; then
        log "[$category] $display already installed: $existing" "Success"
        INSTALL_RESULTS+=("$display|$category|Skipped|$existing")
        return 0
    fi
    
    log "[$category] Installing $display..." "Info"
    local result="Failed|N/A"
    
    # Try DNF first
    local dnf_pkg
    dnf_pkg=$(echo "$methods" | jq -r '.dnf // empty')
    if [[ -n "$dnf_pkg" ]]; then
        result=$(install_dnf "$dnf_pkg" "$cmd" "$arg" "$display")
        if [[ "$result" == Success* ]]; then
            apply_env_vars "$env_vars"
            INSTALL_RESULTS+=("$display|$category|$result")
            return 0
        fi
    fi
    
    # Try GitHub binary download
    local gh_bin
    gh_bin=$(echo "$methods" | jq -c '.github // empty')
    if [[ -n "$gh_bin" && "$(echo "$gh_bin" | jq -r '.extract // false')" == "false" ]]; then
        local repo pattern binary
        repo=$(echo "$gh_bin" | jq -r '.repo')
        pattern=$(echo "$gh_bin" | jq -r '.pattern')
        binary=$(echo "$gh_bin" | jq -r '.binary_name')
        result=$(install_github_binary "$repo" "$pattern" "$binary" "$cmd" "$arg" "$display")
        if [[ "$result" == Success* ]]; then
            apply_env_vars "$env_vars"
            INSTALL_RESULTS+=("$display|$category|$result")
            return 0
        fi
    fi
    
    # Try GitHub archive extraction
    if [[ -n "$gh_bin" && "$(echo "$gh_bin" | jq -r '.extract // false')" == "true" ]]; then
        local repo pattern binary
        repo=$(echo "$gh_bin" | jq -r '.repo')
        pattern=$(echo "$gh_bin" | jq -r '.pattern')
        binary=$(echo "$gh_bin" | jq -r '.binary_name')
        result=$(install_github_archive "$repo" "$pattern" "$binary" "$cmd" "$arg" "$display")
        if [[ "$result" == Success* ]]; then
            apply_env_vars "$env_vars"
            INSTALL_RESULTS+=("$display|$category|$result")
            return 0
        fi
    fi
    
    # Try direct URL installation
    local direct
    direct=$(echo "$methods" | jq -c '.direct // empty')
    if [[ -n "$direct" ]]; then
        local url extract_to bin_subdir env_name
        url=$(echo "$direct" | jq -r '.url')
        extract_to=$(echo "$direct" | jq -r '.extract_to')
        bin_subdir=$(echo "$direct" | jq -r '.bin_subdir // empty')
        env_name=$(echo "$tool_json" | jq -r '.env_vars // {} | to_entries[0].key // empty')
        result=$(install_direct_url "$url" "$extract_to" "$bin_subdir" "$cmd" "$arg" "$display" "$env_name")
        if [[ "$result" == Success* ]]; then
            INSTALL_RESULTS+=("$display|$category|$result")
            return 0
        fi
    fi
    
    # Try pip fallback
    local pip_pkg
    pip_pkg=$(echo "$methods" | jq -r '.pip // empty')
    if [[ -n "$pip_pkg" && "$USE_PIP" == "true" ]]; then
        result=$(install_pip "$pip_pkg" "$cmd" "$arg" "$display")
        if [[ "$result" == Success* ]]; then
            INSTALL_RESULTS+=("$display|$category|$result")
            return 0
        fi
    fi
    
    # All methods failed
    log "ERROR: Failed to install $display after all attempts" "Error"
    INSTALL_RESULTS+=("$display|$category|Failed|N/A")
    return 1
}

#-------------------------------------------------------------------------------
# REPORTING
#-------------------------------------------------------------------------------

write_report() {
    echo -e "\n${GRAY}======================================================================${NC}"
    echo -e "${CYAN}           DEVSECOPS PROVISIONING REPORT${NC}"
    echo -e "${GRAY}======================================================================${NC}\n"
    
    if [[ ${#INSTALL_RESULTS[@]} -eq 0 ]]; then
        log "No tools processed" "Warning"
        return
    fi
    
    printf "%-28s %-12s %-10s %s\n" "Tool" "Category" "Status" "Version"
    printf "%-28s %-12s %-10s %s\n" "----" "--------" "------" "-------"
    
    local success=0 skipped=0 failed=0
    for entry in "${INSTALL_RESULTS[@]}"; do
        IFS='|' read -r tool cat status ver <<< "$entry"
        local color="$NC"
        case "$status" in
            Success) color="$GREEN"; ((success++)) ;;
            Skipped) color="$YELLOW"; ((skipped++)) ;;
            Failed) color="$RED"; ((failed++)) ;;
        esac
        printf "${color}%-28s %-12s %-10s ${NC}%s\n" "$tool" "$cat" "$status" "$ver"
    done
    
    echo -e "\n${CYAN}Summary:${NC}"
    echo "  Total: ${#INSTALL_RESULTS[@]}"
    echo -e "${GREEN}  ✓ Success: $success${NC}"
    echo -e "${YELLOW}  ◌ Skipped: $skipped${NC}"
    if [[ $failed -gt 0 ]]; then
        echo -e "${RED}  ✗ Failed: $failed${NC}"
    else
        echo -e "${GREEN}  ✗ Failed: $failed${NC}"
    fi
    
    if [[ "$EXPORT_REPORT" == "true" ]]; then
        echo "Tool,Category,Status,Version" > "$REPORT_CSV"
        printf '%s\n' "${INSTALL_RESULTS[@]}" | tr '|' ',' >> "$REPORT_CSV"
        echo -e "${CYAN}  📄 Exported: $REPORT_CSV${NC}"
    fi
    
    echo -e "\n${CYAN}Log: $LOG_PATH${NC}"
    echo -e "${GRAY}======================================================================${NC}\n"
    
    if [[ $failed -gt 0 ]]; then
        log "Completed with $failed failure(s)" "Warning"
        exit 1
    fi
    log "Provisioning complete" "Success"
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

main() {
    parse_args "$@"
    mkdir -p "$LOG_DIR_LINUX"
    
    log "Starting $SCRIPT_NAME v$SCRIPT_VERSION (Linux)" "Info"
    log "Log: $LOG_PATH" "Info"
    
    # Pre-flight checks
    if [[ $EUID -ne 0 ]]; then
        log "Please run with sudo" "Error"
        exit 1
    fi
    if ! command_exists dnf; then
        log "DNF required (Fedora/RHEL)" "Error"
        exit 1
    fi
    
    setup_repos
    
    # Install tools from config
    while IFS= read -r tool; do
        local cat
        cat=$(echo "$tool" | jq -r '.category // "Unknown"')
        echo "$tool" | jq -c --arg cat "$cat" '. + {category: $cat}' | install_tool
    done < <(echo "$CONFIG" | jq -c '.tools.core[], .tools.build[], .tools.security[], .tools.utilities[]')
    
    write_report
}

main "$@"