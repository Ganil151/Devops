#!/bin/bash
set -e

# Update and install required packages
sudo yum update -y
sudo yum install -y git java-17-amazon-corretto-devel

# Install Maven
MAVEN_VERSION="3.9.11"
MAVEN_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"

wget "$MAVEN_URL"
tar -xzf "$MAVEN_ARCHIVE"
sudo mv "apache-maven-${MAVEN_VERSION}" /opt/maven
sudo ln -sf /opt/maven/bin/mvn /usr/bin/mvn
rm -f "$MAVEN_ARCHIVE"

# Persist Maven environment variables
echo 'export M2_HOME=/opt/maven' | sudo tee -a /etc/profile.d/maven.sh
echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Install Docker (needed for microservices deployment)
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo mkdir -p /usr/libexec/docker/cli-plugins
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose


