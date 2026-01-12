#!/bin/bash

set -e

# Change Host Name
echo "Change Host Name"
sudo hostnamectl set-hostname "jenkins-server"

# Install dependencies and update system
echo "Install dependencies and update system"
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y openjdk-21-jdk git

# Install Jenkins
echo "Installing Jenkins"
# Add Jenkins repo key and source list
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list again with Jenkins repo
sudo apt update -y
sudo apt install -y fontconfig ca-certificates apt-transport-https jenkins

# Configure Java for Jenkins service
echo "Configuring Java for Jenkins service"
# Find the JAVA_HOME path
JAVA_HOME_PATH=$(update-alternatives --query java | grep '^Value:' | awk '{print $2}' | sed 's/\/bin\/java//')
if [ -z "$JAVA_HOME_PATH" ]; then
    echo "ERROR: Could not determine JAVA_HOME path."
    exit 1
fi
echo "JAVA_HOME found: $JAVA_HOME_PATH"

# Create a drop-in file to override Jenkins service configuration
sudo mkdir -p /etc/systemd/system/jenkins.service.d
echo "[Service]" | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
echo "Environment=\"JAVA_HOME=$JAVA_HOME_PATH\"" | sudo tee -a /etc/systemd/system/jenkins.service.d/override.conf
echo "Environment=\"JENKINS_HOME=/var/lib/jenkins\"" | sudo tee -a /etc/systemd/system/jenkins.service.d/override.conf
echo "Restart=on-failure" | sudo tee -a /etc/systemd/system/jenkins.service.d/override.conf

# Reload systemd and restart Jenkins
sudo systemctl daemon-reload
sudo systemctl restart jenkins

# Configure SSH for Jenkins user
echo "Generating SSH key for Jenkins..."
# Use an idempotent check to avoid recreating keys
if [ ! -f /var/lib/jenkins/.ssh/id_rsa ]; then
    sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
    sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa
fi

# Fix permissions and ownership
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh
sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub

# Create known_hosts file and fix permissions
sudo -u jenkins touch /var/lib/jenkins/.ssh/known_hosts
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Increase /tmp size and make persistent
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

echo "Script execution complete. Jenkins should be running."
