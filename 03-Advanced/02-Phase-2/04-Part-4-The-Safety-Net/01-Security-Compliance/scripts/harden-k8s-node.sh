#!/bin/bash
# Description: Hardens a Kubernetes Node for Production
# Scope: CIS Benchmarks implementation for Ubuntu/CentOS nodes.
# Usage: sudo ./harden-k8s-node.sh

set -e
LOG="/var/log/k8s_hardening.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [K8S-HARDEN] $1" | tee -a "$LOG"
}

# 1. Kubelet Security
harden_kubelet() {
    log "Hardening Kubelet Config..."
    KUBE_CONFIG="/var/lib/kubelet/config.yaml"
    if [ -f "$KUBE_CONFIG" ]; then
        # Disable Anonymous Auth
        sed -i 's/anonymous: .*/anonymous:\n    enabled: false/' "$KUBE_CONFIG"
        # Enable Authorization
        sed -i 's/mode: AlwaysAllow/mode: Webhook/' "$KUBE_CONFIG"
        systemctl restart kubelet
    else
        log "Warning: Kubelet config not found at $KUBE_CONFIG"
    fi
}

# 2. Kernel/Network Hardening
harden_sysctl() {
    log "Applying Secure Sysctl Params..."
    cat <<EOF > /etc/sysctl.d/99-k8s-hardening.conf
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
EOF
    sysctl --system
}

# 3. Permission Checks
check_permissions() {
    log "Verifying K8s File Permissions..."
    chmod 644 /etc/kubernetes/manifests/*.yaml
    chmod 600 /etc/kubernetes/admin.conf
    log "Permissions reset to CIS standard."
}

main() {
    if [[ $EUID -ne 0 ]]; then
        echo "Root required"
        exit 1
    fi
    log "Starting K8s Node Hardening..."
    harden_kubelet
    harden_sysctl
    check_permissions
    log "Hardening Complete."
}

main
