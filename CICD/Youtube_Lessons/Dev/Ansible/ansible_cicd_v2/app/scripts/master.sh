#!/bin/bash

set -e 

# Change Host Name
echo "Changing Host Name..."
sudo hostnamectl set-hostname "master"

# Install dependencies
echo "Installing dependencies..."
sudo yum update -y
sudo yum -y upgrade --releasever=2023.8.20250908
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 ansible git python3 net-tools bind-utils

# Install Terraform 
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Verfiy Terraform installation
if ! command -v terraform &> /dev/null; then
    echo "Terraform installation failed."
    exit 1
fi