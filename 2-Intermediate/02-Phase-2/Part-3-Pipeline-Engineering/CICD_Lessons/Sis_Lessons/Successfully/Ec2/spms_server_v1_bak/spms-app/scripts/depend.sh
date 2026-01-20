#!/bin/bash
set -e

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "worker" && sudo /bin/bash

# Install amazon-linux-extras if not present
sudo yum install -y java-17-amazon-corretto-devel git

# Verify Java
java -version

# Increase tmp files
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

