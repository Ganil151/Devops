#!/bin/bash
set -e 

# Function to install updates and EPEL repository
echo "Updating system packages..."
sudo yum update -y


# Function to change the hostname
echo "Changing hostname to worker..."
sudo hostnamectl set-hostname "worker"


# Function to install required dependencies
echo "Installing required packages..."
sudo yum install -y java-17-amazon-corretto-devel git docker maven

# Verify Java installation
echo "Verifying Java installation..."
java -version


# Function to increase /tmp directory size
echo "Increasing /tmp directory size..."
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp


# Function to configure Docker
echo "Configuring Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
sudo systemctl restart docker


# Function to install Docker Compose
echo "Installing Docker Compose..."
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

echo "Verifying Docker and Docker Compose installation..."
docker --version
docker compose version
sudo systemctl restart docker


# Function to configure Maven
echo "Adding Apache Maven repository..."
sudo tee /etc/yum.repos.d/apache-maven.repo > /dev/null << 'EOF'
  [apache-maven]
  name=Apache Maven
  baseurl=https://repos.fedorapeople.org/repos/katello/6.0/epel-8/Everything/x86_64/os/
  enabled=1
  gpgcheck=0
EOF

echo "Installing Maven..."
sudo yum install -y maven

echo "Verifying Maven installation..."
mvn -version


