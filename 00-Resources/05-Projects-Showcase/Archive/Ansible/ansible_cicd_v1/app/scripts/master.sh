#!/bin/bash

set -e 

# Change Host Name
echo "Changing Host Name..."
sudo hostnamectl set-hostname "master"

# Install dependencies
echo "Installing dependencies..."
sudo yum update -y

# Install Terraform 
echo "Installing Terraform..."
sudo yum-config-manger --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Verfiy Terraform installation
if ! command -v terraform &> /dev/null; then
    echo "Terraform installation failed."
    exit 1
fi