#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "master"

# Install amazon-linux-extras if not present
sudo yum install -y java-17-amazon-corretto-devel git docker

# Set JAVA_HOME environment variable
JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/jar"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh

JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/jar"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a .bash_profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a .bash_profile

JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/jar"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /var/lib/jenkins/.bash_profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /var/lib/jenkins/.bash_profile

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
sudo systemctl status jenkins 

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
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo -u jenkins chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub
sudo -u jenkins chmod 644 /var/lib/jenkins/.ssh/known_hosts

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

docker --version
docker compose version

# Increase Jenkins /tmp Directory
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp









