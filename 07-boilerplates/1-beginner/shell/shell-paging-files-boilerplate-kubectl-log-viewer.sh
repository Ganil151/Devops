#!/bin/bash

# ==============================================================================
# Script: boilerplate_kubectl_log_viewer.sh
# Description: Pages through Kubernetes logs with color highlighting
# DevOps Context: K8s debugging and troubleshooting
# Requires: kubectl
# ==============================================================================

set -euo pipefail

readonly POD_NAME="${1:?Error: Pod name required}"
readonly NAMESPACE="${2:-default}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Check kubectl
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log "ERROR" "kubectl not found"
        exit 1
    fi
}

# View logs
view_logs() {
    log "INFO" "Viewing logs for pod: $POD_NAME (namespace: $NAMESPACE)"
    
    kubectl logs "$POD_NAME" -n "$NAMESPACE" --tail=500 | less -R +G
}

main() {
    check_kubectl
    view_logs
}

main "$@"
