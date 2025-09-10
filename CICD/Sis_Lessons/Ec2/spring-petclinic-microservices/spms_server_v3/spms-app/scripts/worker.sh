#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "worker"

# Install amazon-linux-extras if not present
sudo yum install java-17-amazon-corretto -y git docker


# Set JAVA_HOME environment variable
sudo touch /etc/profile.d/jdk.sh
sudo touch /opt/jdk-17 
echo 'export JAVA_HOME=/opt/jdk-17' | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh

# Set Java in Bash Profile
echo 'JAVA_HOME=/opt/jdk-17' | sudo tee -a .bash_profile
echo 'PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a .bash_profile

# Configure Opts
sudo mkdir -p /opt/jenkins
sudo chown -R ec2-user:ec2-user /opt/jenkins
sudo chmod -R 755 /opt/jenkins

# Enable & start Docker
sudo mkdir -p /opt/docker
sudo chown -R ec2-user:ec2-user /opt/docker
sudo chmod -R 755 /opt/docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user



# Install Docker Compose v2 (plugin style)
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# Verify Docker & Compose
docker --version
docker compose version

# Set JAVA_HOME environment variable
echo "export JAVA_HOME=/opt/jdk-17" | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh

# Configure Maven
sudo mkdir -p /opt/maven
sudo chown -R ec2-user:ec2-user /opt/maven
sudo chmod -R 755 /opt/maven
echo "export M2_HOME=/opt/maven" | sudo tee -a  ~/.bash_profile
echo "export M2=/opt/maven/bin" | sudo tee -a  ~/.bash_profile
echo "JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64" | sudo tee -a ~/.bash_profile
echo "export PATH=\$PATH:\$M2:\$M2_HOME:\$JAVA_HOME/bin" | sudo tee -a  ~/.bash_profile

# Configure Maven in Jenkins
sudo echo "export M2_HOME=/opt/maven" >> .bash_profile
sudo echo "export M2=/opt/maven/bin" >> .bash_profile
sudo echo "JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64" >> .bash_profile
sudo echo "export PATH=\$PATH:\$M2:\$M2_HOME:\$JAVA_HOME/bin" >> .bash_profile



# Verify Java and Maven
java -version
mvn -version

