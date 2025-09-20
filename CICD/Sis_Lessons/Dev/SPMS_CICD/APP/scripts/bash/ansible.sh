#!/bin/bash
set -e

echo "Changing Host Name..."
sudo hostnamectl set-hostname "ansible-server"

echo "Updating system..."
sudo yum -y update && sudo yum -y upgrade

echo "Installing Ansible..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 ansible git python3 net-tools bind-utils
echo "Ansible installed successfully!"
