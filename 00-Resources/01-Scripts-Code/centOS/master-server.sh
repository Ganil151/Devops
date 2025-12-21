#!/bin/bash

set -e

# --- 1. System Setup and Dependencies ---

echo "--- 1. System Setup ---"
# Set Host Name
NEW_HOSTNAME="Master-Server"
echo "Setting Host Name to: ${NEW_HOSTNAME}"
sudo hostnamectl set-hostname "${NEW_HOSTNAME}"

# Install core dependencies and update system
echo "Installing core dependencies and updating system..."
sudo dnf update -y
sudo dnf install -y java-21-openjdk-devel git wget curl tar gzip maven device-mapper-persistent-data lvm2

# Verify Java installation
JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
if [ ! -d "$JAVA_HOME" ]; then
    echo "ERROR: Java 21 OpenJDK not found at $JAVA_HOME. Please verify installation."
    exit 1
fi

# --- 2. Maven Configuration ---

echo "--- 2. Maven Configuration ---"
# Verify Maven installation
if ! command -v mvn &> /dev/null; then
    echo "Maven is not installed. Installing Maven..."
    sudo dnf install -y maven
fi

M2_HOME="/usr/share/maven"
if [ ! -d "$M2_HOME" ]; then
    echo "WARNING: Could not confirm standard M2_HOME directory ($M2_HOME). Skipping M2_HOME export."
    M2_HOME="" # Clear if not found to prevent exporting an invalid path
fi

# Configure environment variables for the current user's profile
echo "Configuring environment variables (JAVA_HOME, M2_HOME) for current user..."
{
    echo "export JAVA_HOME=${JAVA_HOME}"
    if [ -n "$M2_HOME" ]; then
        echo "export M2_HOME=${M2_HOME}"
    fi
    echo "export PATH=\$PATH:\$HOME/bin:\$JAVA_HOME/bin"
    if [ -n "$M2_HOME" ]; then
        echo "export PATH=\$PATH:\$M2_HOME/bin"
    fi
} | sudo tee -a /etc/profile.d/jenkins_env.sh # Use a profile.d script for system-wide shell configuration

# Make the profile script executable
sudo chmod +x /etc/profile.d/jenkins_env.sh

# --- 3. Install and Start Jenkins ---

echo "--- 3. Install and Start Jenkins ---"
# Add Jenkins repo key and source list
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf upgrade -y

# Install Jenkins
sudo dnf install -y jenkins
sudo systemctl daemon-reload

# Start and enable Jenkins
echo "Starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins | grep Active

# --- 4. Configure Jenkins User Environment (Critical for builds) ---

echo "--- 4. Configure Jenkins User Environment Variables ---"
JENKINS_PROFILE="/var/lib/jenkins/.bashrc"
echo "Configuring Jenkins user's shell profile (${JENKINS_PROFILE})..."

# Ensure the file exists and is owned by jenkins
sudo touch "${JENKINS_PROFILE}"
sudo chown jenkins:jenkins "${JENKINS_PROFILE}"

{
    echo "# Jenkins user specific environment variables"
    echo "export JAVA_HOME=${JAVA_HOME}"
    if [ -n "$M2_HOME" ]; then
        echo "export M2_HOME=${M2_HOME}"
    fi
    echo "export PATH=\$PATH:\$JAVA_HOME/bin"
    if [ -n "$M2_HOME" ]; then
        echo "export PATH=\$PATH:\$M2_HOME/bin"
    fi
} | sudo tee -a "${JENKINS_PROFILE}"

# --- 5. SSH Configuration for Jenkins User ---

echo "--- 5. SSH Configuration for Jenkins User ---"
SSH_DIR="/var/lib/jenkins/.ssh"
echo "Generating SSH key for Jenkins in ${SSH_DIR}..."

# Use -p to create parent directories if they don't exist
sudo -u jenkins mkdir -p "${SSH_DIR}"
# Generate SSH keypair
sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f "${SSH_DIR}/id_rsa" -C "jenkins@${NEW_HOSTNAME}"

# Fix permissions
sudo chown -R jenkins:jenkins "${SSH_DIR}"
sudo chmod 700 "${SSH_DIR}"
sudo chmod 600 "${SSH_DIR}/id_rsa"
sudo chmod 644 "${SSH_DIR}/id_rsa.pub"

# Create or ensure known_hosts file exists with correct permissions
sudo touch "${SSH_DIR}/known_hosts"
sudo chmod 644 "${SSH_DIR}/known_hosts"
sudo chown jenkins:jenkins "${SSH_DIR}/known_hosts"

# --- 6. /tmp Filesystem Tuning ---

echo "--- 6. /tmp Filesystem Tuning ---"
if ! grep -q "/tmp tmpfs" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
fi

echo "Remounting /tmp with the new size..."
if sudo mount -o remount /tmp; then
    echo "/tmp remounted successfully with 1.5GB size."
else
    echo "WARNING: Failed to remount /tmp immediately. A system reboot is required for the change to take full effect."
fi

# --- 7. Final Output ---

echo "--- Script execution complete. ---"
echo "Jenkins is starting. Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "NOTE: Remember to add the contents of ${SSH_DIR}/id_rsa.pub to your GitHub deploy keys."