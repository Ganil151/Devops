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
sudo yum install -y java-17-amazon-corretto-devel 

# Set JAVA_HOME environment variable
JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh


# Install Git
echo "Installing Git..."
sudo yum install -y git

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker

# Install Maven 
echo "Installing Maven..."
sudo yum install -y maven

# Install yq
echo "Installing yq..."
sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -O /usr/local/bin/yq &&\
sudo chmod +x /usr/bin/yq


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

# Install Maven
wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
sudo mkdir -p /opt/maven
sudo chown -R ec2-user:ec2-user /opt/maven
sudo cd /opt/maven
sudo tar -xzf apache-maven-3.9.6-bin.tar.gz -C /opt/maven --strip-components=1
sudo rm -f apache-maven-3.9.6-bin.tar.gz

# Configure Maven environment variables
echo "export M2_HOME=/opt/maven" | sudo tee -a /etc/profile.d/maven.sh
echo 'export PATH=$PATH:$M2_HOME/bin' | sudo tee -a /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

echo "export M2_HOME=/opt/maven" | sudo tee -a .bash_profile
echo 'export PATH=$PATH:$M2_HOME/bin' | sudo tee -a .bash_profile


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

# Verify Java installation
echo "Verifying Java installation..."
java -version

echo "Installing Maven..."
sudo yum install -y maven

echo "Verifying Maven installation..."
mvn -version

source /etc/profile.d/jdk.sh
source /etc/profile.d/maven.sh
source .bash_profile

