#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "jenkins-master"

# Install dependencies
sudo yum install java-21-amazon-corretto-devel git  -y

# Verify Java
java -version

# Increase tmp files
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

