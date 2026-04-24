#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "master"

# Install required packages
sudo yum install -y java-17-amazon-corretto git wget

# Set JAVA_HOME environment variable
JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh

JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a .bash_profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a .bash_profile
source .bash_profile

JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /var/lib/jenkins/.bash_profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /var/lib/jenkins/.bash_profile
source /var/lib/jenkins/.bash_profile

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Set Java in Jenkins environment
sudo -u jenkins bash -c "echo 'JAVA_HOME=$JAVA_HOME' >> /var/lib/jenkins/.bash_profile"
sudo -u jenkins bash -c "echo 'PATH=\$PATH:\$JAVA_HOME/bin' >> /var/lib/jenkins/.bash_profile"

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager || true

# Create SSH directory for Jenkins user
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins chmod 700 /var/lib/jenkins/.ssh

# Generate SSH key as Jenkins user
sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa

# Create known_hosts file
sudo -u jenkins touch /var/lib/jenkins/.ssh/known_hosts
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Fix permissions for SSH files
sudo -u jenkins chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub

# Increase Jenkins /tmp directory size
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

# Verify Java installation
java -version