#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "master"


# Install amazon-linux-extras if not present
sudo yum install java-17-amazon-corretto -y git 


# Set JAVA_HOME environment variable
sudo touch /etc/profile.d/jdk.sh
sudo touch /opt/jdk-17 
echo 'export JAVA_HOME=/opt/jdk-17' | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh

# Set Java in Bash Profile
echo 'JAVA_HOME=/opt/jdk-17' | sudo tee -a .bash_profile
echo 'PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a .bash_profile


# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Set Java in Jenkins
sudo -u jenkins touch /var/lib/jenkins/.bash_profile
echo "JAVA_HOME=/opt/jdk-17" | sudo tee -a /var/lib/jenkins/.bash_profile
echo 'PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /var/lib/jenkins/.bash_profile


# Enable & start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager || true

# Create SSH Directory
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins chmod 700 /var/lib/jenkins/.ssh

# Generate SSH key as jenkins user
sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa

# Get public key
sudo -u jenkins cp -r /var/lib/jenkins/.ssh/id_rsa* > /var/lib/jenkins/.ssh/

# Create known_hosts file
sudo -u jenkins touch /var/lib/jenkins/.ssh/known_hosts

# Fix permissions
sudo mkdir -p /var/lib/jenkins/.ssh
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo -u jenkins chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Configure Git
sudo touch /var/lib/jenkins/.gitconfig
sudo chown jenkins:jenkins /var/lib/jenkins/.gitconfig
sudo chmod 644 /var/lib/jenkins/.gitconfig

# Increase Jenkins /tmp Directory
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

# Verify Java
java -version





