#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "worker" && sudo /bin/bash

# Install amazon-linux-extras if not present
sudo yum install -y java-17-amazon-corretto-devel git docker

# Verify Java
java -version

# Increase tmp files
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

docker --version
docker compose version

