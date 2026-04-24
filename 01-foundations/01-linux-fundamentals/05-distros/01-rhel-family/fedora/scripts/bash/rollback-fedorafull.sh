#!/bin/bash
# ==============================================================================
# Script Name: Rollback-FedoraFull.sh
# Description: Reverts changes made by Optimize-FedoraFull.sh
# ==============================================================================

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Exit immediately if a command exits with a non-zero status.
set -e

LOG="/var/log/system_optimization_rollback.log"
log_action() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

# 1. Revert DNF5 Configuration
log_action "Reverting DNF5 configuration..."
sed -i '/max_parallel_downloads=10/d' /etc/dnf/dnf.conf
sed -i '/fastestmirror=True/d' /etc/dnf/dnf.conf

# 2. Revert fstab (Btrfs compression)
log_action "Reverting fstab compression settings..."
if grep -q "defaults,compress=zstd:1" /etc/fstab; then
    sed -i 's/defaults,compress=zstd:1/defaults/g' /etc/fstab
    log_action "Removed compress=zstd:1 from fstab."
fi

# 3. Revert zRAM
log_action "Removing custom zRAM configuration..."
if [[ -f /etc/systemd/zram-generator.conf.d/99-custom.conf ]]; then
    rm -f /etc/systemd/zram-generator.conf.d/99-custom.conf
    log_action "Reloading systemd and restarting zRAM service to apply default settings..."
    systemctl daemon-reload
    systemctl restart systemd-zram-setup@zram0.service
else
    log_action "No custom zRAM config found."
fi

# 4. Revert Tuned Profile (Optional - if installed by optimization script)
if rpm -q tuned &>/dev/null; then
    log_action "Removing Tuned..."
    tuned-adm off
    dnf5 remove -y tuned tuned-ppd
fi

# 5. Revert Multimedia Codecs (Optional - if swapped)
if rpm -q ffmpeg &>/dev/null; then
    log_action "Swapping back to ffmpeg-free..."
    log_action "WARNING: This will also remove the RPM Fusion repositories."
    dnf5 swap -y ffmpeg ffmpeg-free --allowerasing
    dnf5 remove -y rpmfusion-free-release rpmfusion-nonfree-release --noautoremove
fi

log_action "Rollback complete. Please reboot to finalize filesystem and memory changes."