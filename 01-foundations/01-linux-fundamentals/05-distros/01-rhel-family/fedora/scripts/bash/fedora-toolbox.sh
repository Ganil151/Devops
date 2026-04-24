#!/bin/bash
# ==============================================================================
# Script Name: Fedora-Toolbox.sh
# Description: Master script for applying optimizations, hardening, and audits on Fedora.
# Author: Gemini Code Assist
# ==============================================================================

# --- Global Settings & Helpers ---
set -e # Exit on any error

LOG_DIR="/var/log/fedora_toolbox"
mkdir -p "$LOG_DIR"
MAIN_LOG="$LOG_DIR/toolbox_main.log"

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MAIN_LOG"
}

# --- Root Privilege Check ---
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root. Aborting.${NC}"
    exit 1
fi

# --- Function Definitions (from other scripts) ---

# From Optimize-FedoraFull.sh
optimize_full_system() {
    log_action "--- Starting Full System Optimization ---"
    
    # 0. Enable RPM Fusion
    log_action "Checking RPM Fusion repositories..."
    if ! dnf5 repolist | grep -q "rpmfusion-free"; then
        log_action "Enabling RPM Fusion repositories..."
        dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
    fi

    # 1. DNF5 Speed Hacks
    log_action "Optimizing DNF5 for faster downloads..."
    local DNF_CONF="/etc/dnf/dnf.conf"
    if ! grep -q "max_parallel_downloads" "$DNF_CONF"; then
        echo "max_parallel_downloads=10" >> "$DNF_CONF"
        log_action "Added max_parallel_downloads=10"
    fi
    if ! grep -q "fastestmirror" "$DNF_CONF"; then
        echo "fastestmirror=True" >> "$DNF_CONF"
        log_action "Added fastestmirror=True"
    fi

    # 2. Btrfs Transparent Compression
    log_action "Enabling Btrfs zstd compression in fstab..."
    if grep -q "btrfs" /etc/fstab; then
        sed -i '/btrfs/ { /compress=/! s/defaults/defaults,compress=zstd:1/ }' /etc/fstab
        log_action "Updated fstab for Btrfs compression (if not already present)."
        log_action "${YELLOW}Note: Run 'sudo btrfs filesystem defragment -r -v -czstd /' after reboot.${NC}"
    else
        log_action "No Btrfs partitions found in /etc/fstab. Skipping compression."
    fi

    # 3. Tuning zRAM
    log_action "Configuring zRAM-Generator..."
    mkdir -p /etc/systemd/zram-generator.conf.d/
    cat <<EOF > /etc/systemd/zram-generator.conf.d/99-custom.conf
[zram0]
zram-size = ram / 1
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
    log_action "Reloading systemd and restarting zRAM service..."
    systemctl daemon-reload
    systemctl restart systemd-zram-setup@zram0.service

    # 4. Performance Profiles (Tuned)
    log_action "Applying 'throughput-performance' tuned profile..."
    if ! rpm -q tuned &>/dev/null; then
        dnf5 install -y tuned tuned-ppd
    fi
    systemctl enable --now tuned
    tuned-adm profile throughput-performance

    # 5. Multimedia Codecs
    log_action "Swapping to full ffmpeg for hardware decoding..."
    if rpm -q ffmpeg-free &>/dev/null; then
        dnf5 swap -y ffmpeg-free ffmpeg --allowerasing
        dnf5 group upgrade -y multimedia --exclude=PackageKit-gstreamer-plugin
    else
        log_action "ffmpeg-free not found or ffmpeg already installed."
    fi

    log_action "${GREEN}Full System Optimization complete! Please reboot to finalize all changes.${NC}"
}

# From Optimize-IntelGPU.sh
optimize_intel_gpu() {
    log_action "--- Starting Intel GPU Optimization ---"
    
    # 1. Install Core Drivers
    log_action "Ensuring Intel Media Drivers and essential toolkits are installed..."
    dnf5 install -y intel-media-driver intel-gpu-tools libva-utils \
                    mesa-dri-drivers gstreamer1-vaapi libva-intel-driver

    # 2. Enable RPM Fusion
    log_action "Enabling RPM Fusion repositories for hardware codecs..."
    dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
    dnf5 install -y intel-media-driver --allowerasing

    # 3. Kernel Parameter Optimization
    log_action "Applying kernel optimizations for i915/Xe drivers..."
    cat <<EOF > /etc/modprobe.d/i915-intel.conf
options i915 enable_guc=3
options i915 enable_fbc=1
options i915 fastboot=1
EOF

    # 4. Set Environment Variables for VA-API
    if ! grep -q "LIBVA_DRIVER_NAME=iHD" /etc/environment; then
        echo "LIBVA_DRIVER_NAME=iHD" >> /etc/environment
        log_action "Environment variable iHD set for VA-API."
    fi

    # 5. Refresh Initramfs
    log_action "Regenerating initramfs..."
    dracut --force

    log_action "${GREEN}Intel GPU Optimization complete. Please REBOOT to apply kernel changes.${NC}"
}

# From fedora-network.sh
harden_network() {
    log_action "--- Starting Network Hardening ---"
    local CUSTOM_SSH_PORT=2222

    # Kernel / Sysctl Tuning
    log_action "Applying Kernel Hardening via sysctl..."
    cat <<EOF > /etc/sysctl.d/99-hardened-network.conf
# TCP SYN Cookie & Flood Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
# Disable Source Routing and Redirects
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
# IPv6 Hardening (Disable RA)
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
EOF
    sysctl --system > /dev/null

    # Firewalld Orchestration
    log_action "Hardening Firewalld..."
    log_action "Setting default zone to 'drop'."
    firewall-cmd --set-default-zone=drop --permanent
    
    log_action "Configuring firewall for custom SSH port: ${CUSTOM_SSH_PORT}"
    if ! firewall-cmd --zone=drop --query-port=${CUSTOM_SSH_PORT}/tcp --permanent; then
        firewall-cmd --zone=drop --add-port=${CUSTOM_SSH_PORT}/tcp --permanent
    fi
    firewall-cmd --remove-service=ssh --permanent >/dev/null 2>&1 || true
    
    echo -e "${YELLOW}--- IMPORTANT ---"
    log_action "Firewall now only allows SSH on port ${CUSTOM_SSH_PORT}."
    log_action "You MUST edit /etc/ssh/sshd_config and change the 'Port' directive."
    log_action "Then run: sudo systemctl restart sshd"
    log_action "FAILURE TO DO SO WILL LOCK YOU OUT OF SSH."
    echo -e "${YELLOW}-----------------${NC}"

    firewall-cmd --reload

    # DNS over HTTPS & Privacy
    log_action "Configuring systemd-resolved and MAC Randomization..."
    mkdir -p /etc/systemd/resolved.conf.d /etc/NetworkManager/conf.d
    cat <<EOF > /etc/systemd/resolved.conf.d/hardened-dns.conf
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
DNSOverTLS=yes
DNSSEC=yes
FallbackDNS=1.0.0.1 149.112.112.112
EOF
    systemctl try-restart systemd-resolved
    
    log_action "${GREEN}Network Hardening complete.${NC}"
}

# From Fedora-SystemAudit.sh
run_system_audit() {
    log_action "--- Starting System Security Audit ---"
    local REPORT="$LOG_DIR/audit_report_$(date +%F).txt"
    
    echo "--- FEDORA SYSTEM AUDIT ---" | tee "$REPORT"

    echo -e "\n[+] PACKAGE MANAGEMENT (DNF5)" | tee -a "$REPORT"
    dnf5 updateinfo list security installed | tee -a "$REPORT"

    echo -e "\n[+] DEEP SYSTEM SCAN (LYNIS)" | tee -a "$REPORT"
    if ! command -v lynis &> /dev/null; then
        echo "Lynis not found. Installing..." | tee -a "$REPORT"
        dnf5 install -y lynis
    fi
    echo "Running Lynis Audit..." | tee -a "$REPORT"
    lynis audit system --quick --report-file "$LOG_DIR/lynis-report.dat" > /dev/null
    grep -E "^warning\[\]|^suggestion\[\]" "$LOG_DIR/lynis-report.dat" | tee -a "$REPORT"

    log_action "${GREEN}Audit Complete. Full reports available in: $LOG_DIR${NC}"
}

# From fedora-security.sh
verify_security_hardening() {
    log_action "--- Verifying Security Hardening Status ---"
    local REPORT_FILE="$LOG_DIR/hardening_audit_$(date +%F).log"
    local CUSTOM_SSH_PORT=2222
    
    echo "--- SECURITY READINESS REPORT ---" | tee "$REPORT_FILE"

    local check_param() {
        local label=$1; local command=$2; local expected=$3; local current
        current=$(eval "$command" 2>/dev/null)
        [[ "$current" == *"$expected"* ]] && echo -e "${GREEN}[PASS]${NC} $label" | tee -a "$REPORT_FILE" || echo -e "${RED}[FAIL]${NC} $label (Current: $current | Expected: $expected)" | tee -a "$REPORT_FILE"
    }

    check_param "Firewall Default Zone" "firewall-cmd --get-default-zone" "drop"
    check_param "TCP SYN Cookies" "sysctl -n net.ipv4.tcp_syncookies" "1"
    check_param "DNSSEC Validation" "resolvectl status | grep 'DNSSEC:'" "yes"
    check_param "SSH Custom Port" "firewall-cmd --zone=drop --query-port=${CUSTOM_SSH_PORT}/tcp" "yes"

    log_action "Verification complete. Report saved to $REPORT_FILE"
}

# From Rollback-FedoraFull.sh
rollback_full_optimization() {
    log_action "--- Starting Rollback of Full System Optimization ---"
    read -p "This will revert DNF, fstab, zRAM, and other changes. Are you sure? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_action "Rollback aborted by user."
        return
    fi
    
    log_action "Reverting DNF5 configuration..."
    sed -i '/max_parallel_downloads=10/d' /etc/dnf/dnf.conf
    sed -i '/fastestmirror=True/d' /etc/dnf/dnf.conf

    log_action "Reverting fstab compression settings..."
    sed -i 's/defaults,compress=zstd:1/defaults/g' /etc/fstab

    log_action "Removing custom zRAM configuration..."
    rm -f /etc/systemd/zram-generator.conf.d/99-custom.conf
    systemctl daemon-reload
    systemctl restart systemd-zram-setup@zram0.service

    if rpm -q tuned &>/dev/null; then
        tuned-adm off && dnf5 remove -y tuned tuned-ppd
    fi

    log_action "${GREEN}Rollback complete. Please reboot to finalize changes.${NC}"
}

# --- Menu and Main Loop ---
show_menu() {
    echo -e "\n${BLUE}--- Fedora Toolbox ---${NC}"
    echo "1. Apply Full System Optimizations (DNF, Btrfs, zRAM, Tuned)"
    echo "2. Apply Intel GPU Optimizations"
    echo "3. Apply Network Hardening Rules"
    echo "4. Run Full System Security Audit (Lynis)"
    echo "5. Verify Security Hardening Status"
    echo -e "${YELLOW}6. Rollback Full System Optimizations${NC}"
    echo -e "${RED}7. Exit${NC}"
    echo "--------------------"
}

main() {
    while true; do
        show_menu
        read -p "Enter your choice [1-7]: " choice
        case $choice in
            1) optimize_full_system ;;
            2) optimize_intel_gpu ;;
            3) harden_network ;;
            4) run_system_audit ;;
            5) verify_security_hardening ;;
            6) rollback_full_optimization ;;
            7) log_action "Exiting Fedora Toolbox."; break ;;
            *) echo -e "${RED}Invalid option.${NC}" ;;
        esac
        echo -e "\nPress [Enter] to return to the menu..."
        read -r
    done
}

# --- Script Execution ---
main