#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, or pipe failures
exec > >(tee -a /var/log/jenkins-install.log) 2>&1  # Log everything

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Install Base Dependencies
install_base_dependencies() {
    log "Updating package lists..."
    if ! sudo apt-get update -y; then
        log "Failed to update package lists. Exiting..."
        exit 1
    fi

    log "Installing base dependencies..."
    sudo apt-get install -y fontconfig git curl wget
}

# Install Java
install_java_dependency() {
    log "Installing Java..."
    sudo apt-get install -y openjdk-17-jre

    # Verify Java installation
    if ! command -v java &> /dev/null; then
        log "Java is not installed or not in PATH."
        exit 1
    fi

    java -version || { log "Java installation failed"; exit 1; }
}

# Cleanup Unused Packages
cleanup() {
    log "Cleaning up unused packages..."
    sudo apt-get autoremove -y
    sudo apt-get clean
}

# Main Execution
install_base_dependencies
install_java_dependency
cleanup

log "Java installation complete😎"