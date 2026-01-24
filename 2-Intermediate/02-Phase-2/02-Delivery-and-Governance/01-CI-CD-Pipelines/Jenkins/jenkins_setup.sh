#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Install amazon-linux-extras if not present
sudo yum install -y java-17-amazon-corretto-devel

# Verify Java
java -version

# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Enable & start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager || true

# Install Docker
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker

# Add Jenkins to Docker group
sudo usermod -aG docker jenkins

# Restart Docker
sudo systemctl restart docker

# Reboot to apply group changes
sudo reboot
