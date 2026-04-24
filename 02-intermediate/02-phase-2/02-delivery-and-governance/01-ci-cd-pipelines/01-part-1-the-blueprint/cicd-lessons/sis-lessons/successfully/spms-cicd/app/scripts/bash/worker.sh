#!/bin/bash

set -e

# Change Host Name
echo "Change Host Name"
sudo hostnamectl set-hostname "worker-server"

# Install dependencies
echo "Install dependencies"
sudo yum update -y

# Then install Java JDk
sudo yum install -y java-21-amazon-corretto-devel git docker

# Configure Java
echo "Configure Java"
JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a ~/.bashrc
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME" | sudo tee -a ~/.bashrc

# Function to configure Docker
echo "Configuring Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Install yq
echo "Installing yq..."
sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -O /usr/local/bin/yq && \
sudo chmod +x /usr/local/bin/yq

# Function to install Docker Compose
echo "Installing Docker Compose..."
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

echo "Verifying Docker and Docker Compose installation..."
docker --version
docker compose version

# Increase /tmp file
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp