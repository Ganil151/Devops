#!/bin/bash
# ==============================================================================
# Script Name: Optimize-IntelGPU.sh
# Target: Fedora 43 (Workstation/Server)
# Function: Installs Intel Media Drivers, enables GuC/HuC, and sets performance flags.
# ==============================================================================

LOG_FILE="/var/log/intel_gpu_opt.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

# 1. Update and Install Core Drivers
log "Installing Intel Media Drivers and Toolkits via DNF5..."
dnf5 install -y intel-media-driver intel-gpu-tools libva-utils \
                mesa-dri-drivers gstreamer1-vaapi libva-intel-driver

# 2. Enable RPM Fusion for non-free codecs (Required for full VA-API support)
log "Enabling RPM Fusion repositories for hardware codecs..."
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 config-manager setopt fedora-cisco-openh264.enabled=1
dnf5 install -y intel-media-driver --allowerasing

# 3. Kernel Parameter Optimization (GuC/HuC & FBC)
# Note: GuC (Graphics MicroController) improves scheduling and power management.
log "Applying kernel optimizations for i915/Xe drivers..."
cat <<EOF > /etc/modprobe.d/i915-intel.conf
options i915 enable_guc=3
options i915 enable_fbc=1
options i915 fastboot=1
EOF

# 4. Set Environment Variables for VA-API
if ! grep -q "LIBVA_DRIVER_NAME=iHD" /etc/environment; then
    echo "LIBVA_DRIVER_NAME=iHD" >> /etc/environment
    log "Environment variable iHD set for VA-API."
fi

# 5. Refresh Initramfs
log "Regenerating initramfs..."
dracut --force

log "Optimization complete. Please REBOOT to apply kernel changes."
