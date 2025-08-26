#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Install amazon-linux-extras if not present
sudo yum install -y java-17-amazon-corretto-devel git

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

# SSH KEYGEN
sudo ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa

# Create Known Hosts
sudo touch /var/lib/jenkins/.ssh/known_hosts

# Change Owner
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh

# Change Permissions
sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa.pub
sudo chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Install Docker
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose
sudo mkdir -p /usr/libexec/docker/cli-plugins
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Add Jenkins to Docker group
sudo usermod -aG docker jenkins

# Restart Docker
sudo systemctl restart docker


