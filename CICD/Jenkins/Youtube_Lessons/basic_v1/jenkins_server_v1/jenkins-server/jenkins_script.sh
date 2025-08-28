#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, or pipe failures
exec > >(tee -a /var/log/jenkins-install.log) 2>&1  # Log everything

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Install Dependencies
install_dependencies() {
log "Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y fontconfig openjdk-17-jre git curl
java -version || { log "Java installation failed"; exit 1; }
}

# Add Jenkins Repository
add_jenkins_repo() {
    log "Adding Jenkins repository..."

    # Create keyrings directory if it doesn't exist
    sudo mkdir -p /etc/apt/keyrings
    sudo chmod a+r /etc/apt/keyrings

    # Download and add Jenkins repository GPG key
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
        sudo tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

    # Add Jenkins repository to APT sources
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
        sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
}

# Install Jenkins
install_jenkins() {
    log "Installing Jenkins..."

    # Update package lists again to include Jenkins repository
    sudo apt-get update -y

    # Install Jenkins
    sudo apt-get install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins

    # Verify Jenkins service status
    if ! sudo systemctl is-active --quiet jenkins; then
        log "Jenkins service failed to start."
        exit 1
    fi
    log "Jenkins service started successfully."
}

# Cleanup
cleanup() {
    log "Cleaning up unused packages..."
    sudo apt-get autoremove -y
    sudo apt-get clean
}

# Main Execution
install_dependencies
add_jenkins_repo
install_jenkins
cleanup

log "✅ Jenkins installation complete!"