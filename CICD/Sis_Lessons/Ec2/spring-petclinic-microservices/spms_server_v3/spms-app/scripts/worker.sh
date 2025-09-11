#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "worker"

# Install required packages
sudo yum install -y java-17-amazon-corretto git docker wget

# Set JAVA_HOME environment variable
JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh

# Enable & start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add ec2-user to the docker group
sudo usermod -aG docker ec2-user
echo "You must log out and log back in for Docker group changes to take effect."

# Install Docker Compose v2 (system-wide)
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify Docker & Compose
docker --version
docker compose version

# Install Maven
wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
sudo mkdir -p /opt/maven
sudo chown -R ec2-user:ec2-user /opt/maven
sudo cd /opt/maven
sudo tar -xzf /tmp/maven.tar.gz -C /opt/maven --strip-components=1
sudo rm -f /tmp/maven.tar.gz

# Configure Maven environment variables
echo "export M2_HOME=/opt/maven" | sudo tee -a /etc/profile.d/maven.sh
echo 'export PATH=$PATH:$M2_HOME/bin' | sudo tee -a /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Verify Java and Maven
java -version
mvn -version