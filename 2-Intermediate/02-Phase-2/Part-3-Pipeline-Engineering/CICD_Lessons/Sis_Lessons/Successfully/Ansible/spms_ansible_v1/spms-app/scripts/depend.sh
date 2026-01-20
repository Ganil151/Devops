#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "worker"

# Install dependencies: Java 17, Git, Docker, Maven
sudo yum install -y java-17-amazon-corretto-devel git docker maven

# Verify Java and Maven
java -version
mvn -version

# Increase tmp files (prevent duplicate entries)
grep -q "/tmp tmpfs" /etc/fstab || echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

# Enable & start Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

# Install Docker Compose v2 (plugin style)
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# Verify Docker & Compose
docker --version
docker compose version
