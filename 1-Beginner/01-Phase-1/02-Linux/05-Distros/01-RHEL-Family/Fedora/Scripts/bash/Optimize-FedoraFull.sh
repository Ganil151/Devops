#!/bin/bash
# ==============================================================================
# Script Name: Optimize-FedoraFull.sh
# Target: Fedora 43 (Workstation/Server)
# Role: Storage (Btrfs), Memory (zRAM), DNF5, and Power Optimization
# ==============================================================================

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then 
    echo "This script must be run as root."
    exit 1
fi

LOG="/var/log/system_optimization.log"
log_action() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

# Exit immediately if a command exits with a non-zero status.
set -e

# 0. Enable RPM Fusion (Prerequisite for Multimedia Codecs)
log_action "Checking RPM Fusion repositories..."
if ! dnf5 repolist | grep -q "rpmfusion-free"; then
    log_action "Enabling RPM Fusion repositories..."
    dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
fi

# 1. DNF5 Speed Hacks
log_action "Optimizing DNF5 for faster downloads..."
DNF_CONF="/etc/dnf/dnf.conf"
if ! grep -q "max_parallel_downloads" "$DNF_CONF"; then
    echo "max_parallel_downloads=10" >> "$DNF_CONF"
    log_action "Added max_parallel_downloads=10"
fi
if ! grep -q "fastestmirror" "$DNF_CONF"; then
    echo "fastestmirror=True" >> "$DNF_CONF"
    log_action "Added fastestmirror=True"
fi

# 2. Btrfs Transparent Compression (zstd:1)
# High performance, low latency compression for SSDs
log_action "Enabling Btrfs zstd compression in fstab..."
# Only apply to btrfs lines, and only if 'compress' is not already present
if grep -q "btrfs" /etc/fstab; then
    sed -i '/btrfs/ { /compress=/! s/defaults/defaults,compress=zstd:1/ }' /etc/fstab
    log_action "Updated fstab for Btrfs compression (if not already present)."
    log_action "Note: Run 'sudo btrfs filesystem defragment -r -v -czstd /' after reboot."
else
    log_action "No Btrfs partitions found in /etc/fstab. Skipping compression."
fi

# 3. Tuning zRAM (Compressed RAM Swap)
# Increasing priority and size for high-load workloads
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
# 'throughput-performance' is a good general-purpose server profile.
# For laptops, 'balanced' or 'powersave' might be more suitable.
log_action "Applying 'throughput-performance' tuned profile..."
if ! rpm -q tuned &>/dev/null; then
    dnf5 install -y tuned tuned-ppd
fi
systemctl enable --now tuned
tuned-adm profile throughput-performance

# 5. Multimedia Codecs (Hardware Acceleration Support)
log_action "Swapping to full ffmpeg for hardware decoding..."
if rpm -q ffmpeg-free &>/dev/null; then
    dnf5 swap -y ffmpeg-free ffmpeg --allowerasing
    dnf5 group upgrade -y multimedia --exclude=PackageKit-gstreamer-plugin
else
    log_action "ffmpeg-free not found or ffmpeg already installed."
fi

log_action "Optimization complete! Please reboot to initialize Btrfs and zRAM changes."