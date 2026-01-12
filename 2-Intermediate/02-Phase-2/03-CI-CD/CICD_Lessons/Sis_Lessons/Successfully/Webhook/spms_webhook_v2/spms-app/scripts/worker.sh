#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "worker" 

# Install amazon-linux-extras if not present
sudo yum install -y java-17-amazon-corretto-devel git docker

# Set JAVA_HOME environment variable
JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/jar"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile.d/jdk.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile.d/jdk.sh
# source /etc/profile.d/jdk.sh

JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/jar"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a .bash_profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a .bash_profile
# source .bash_profile

d

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

docker --version
docker compose version

# Increase tmp files
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

