#!/bin/bash

set -e

# Change Host Name
echo "Changing Host Name..."
sudo hostnamectl set-hostname "docker-server"

# Install dependencies and update system
echo "Installing dependencies and updating system..."
sudo apt update -y
sudo apt upgrade -y

# Install prerequisite packages for Docker
echo "Installing prerequisite packages for Docker..."
sudo apt install -y ca-certificates curl

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
echo "Adding Docker repository to Apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update Apt packages and install Docker
echo "Updating Apt packages and installing Docker..."
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the current user to the docker group
echo "Adding user '$USER' to the 'docker' group..."
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"
echo "You must log out and log back in for the group changes to take effect."

# Configure Docker to start on boot
echo "Configuring Docker to start on boot..."
sudo systemctl enable docker
sudo systemctl start docker

# Increase /tmp file size persistently and remount
echo "Increasing /tmp file size to 1.5GB persistently..."
if ! grep -q "/tmp tmpfs" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
fi

echo "Remounting /tmp with the new size..."
if sudo mount -o remount /tmp; then
    echo "/tmp remounted successfully."
else
    echo "WARNING: Failed to remount /tmp immediately. A reboot is required for the change to take effect."
    exit 0 # Allow the script to complete, but with a warning.
fi

echo "Docker installation and configuration complete."
