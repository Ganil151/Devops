#!/bin/bash

# Update package lists
sudo apt-get update -y

# Install dependencies and Java (Jenkins requires Java 17+)
sudo apt-get install -y fontconfig openjdk-21-jre

# Verify Java installation
java -version

# Create keyrings directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

# Download and add Jenkins repository GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository to APT sources
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists again to include Jenkins repository
sudo apt-get update -y

# Install Jenkins
sudo apt-get install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins
