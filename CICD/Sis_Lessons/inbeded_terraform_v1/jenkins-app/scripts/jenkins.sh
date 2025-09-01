#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "master"

# Install amazon-linux-extras if not present
sudo yum install -y java-17-amazon-corretto-devel git yum-utils

# Verify Java
java -version

# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo    
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key    

# Install Jenkins
sudo yum install -y jenkins

echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "Jenkins installed successfully. Access it at http://<your-server-ip>:8080"
echo "Initial admin password can be found at: /var/lib/jenkins/secrets/initialAdminPassword"

# Function to increase /tmp filesystem size
echo "Increasing /tmp filesystem size..."
sudo mount -o remount,size=1G /tmp

# Generate SSH key for Jenkins
echo "Generating SSH key..."
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
else
  echo "SSH key already exists. Skipping generation."
fi

# Configure SSH for Jenkins
echo "Configuring SSH..."
mkdir -p /var/lib/jenkins/.ssh
cp ~/.ssh/id_rsa* /var/lib/jenkins/.ssh/
touch /var/lib/jenkins/.ssh/known_hosts

# Set appropriate permissions
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
chmod 700 /var/lib/jenkins/.ssh
chmod 600 /var/lib/jenkins/.ssh/id_rsa
chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub
chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Check Jenkins initialization
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  echo "Jenkins is already initialized."
else
  echo "Jenkins is not initialized. Initializing..."
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
fi

# Install Jenkins plugins
echo "Installing Jenkins plugins..."
sudo -u jenkins java -jar /var/lib/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin git docker-workflow blueocean
sudo systemctl restart jenkins

# Install Terraform
echo "Installing Terraform..."
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform
