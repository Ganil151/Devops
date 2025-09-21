#!/bin/bash
set -e

echo "Changing Host Name..."
sudo hostnamectl set-hostname "ansible-server"

echo "Updating system..."
sudo yum -y update && sudo yum -y upgrade

# Install Ansible
echo "Installing Ansible..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 ansible git python3 net-tools bind-utils
echo "Ansible installed successfully!"

# Add New User
echo "Adding new user..."
sudo useradd -m -s /bin/bash ansadmin
echo "Enter password for ansadmin:"
sudo passwd ansadmin
echo "ansadmin user added successfully!"
echo "Adding ansadmin to sudoers..."
echo "ansadmin ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
echo "ansadmin added to sudoers successfully!"
echo "Adding ansadmin to wheel group..."
sudo usermod -aG wheel ansadmin
echo "ansadmin added to wheel group successfully!"
echo "Adding ansadmin to docker group..."

# Su into Ansible User
echo "Logging in as ansadmin..."
sudo su - ansadmin
echo "ansadmin logged in successfully!"
echo "Adding ansadmin to docker group..." 

# Install Docker /opt/docker 
cd /opt/docker 

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker installed successfully!"

# Configure Docker User
echo "Configuring Docker user..."
sudo usermod -aG docker ansadmin
sudo systemctl restart docker

