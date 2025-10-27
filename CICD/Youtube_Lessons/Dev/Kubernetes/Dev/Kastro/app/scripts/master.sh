#!/bin/bash

set -e

# Install Dependencies 
sudo apt-get update
sudo apt-get upgrade -y

# Change Hostname 
sudo hostnamectl set-hostname "Master-Jenkins"

# Install git wget
sudo apt install git wget maven -y

# Install Java (OpenJDK 21)
sudo apt install openjdk-21-jdk -y

# Configure Java Environment Variables
# Find the Java installation path (usually /usr/lib/jvm/java-21-openjdk-amd64)
JAVA_HOME_PATH=$(readlink -f /usr/bin/java | sed "s:bin/java::")
# Export JAVA_HOME, JRE_HOME, and add Java's bin directory to PATH
export JAVA_HOME=$JAVA_HOME_PATH
export JRE_HOME=$JAVA_HOME_PATH/jre
export PATH=$PATH:$JAVA_HOME/bin

# Add exports to .bashrc to make them persistent for the current user
echo "" >> ~/.bashrc
echo "# Java Environment Variables" >> ~/.bashrc
echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.bashrc
echo "export JRE_HOME=$JAVA_HOME_PATH/jre" >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc

# Add Jenkins repository key and repository (using the stable repository key)
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo \
  "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update apt package index again to include Jenkins
sudo apt-get update

# Install Jenkins
sudo apt-get install -y jenkins

# Start and enable Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check if Jenkins service is active
if sudo systemctl is-active --quiet jenkins; then
  echo "Jenkins service started successfully."
  echo "Initial admin password is located at: /var/lib/jenkins/secrets/initialAdminPassword"
  echo "You can get it by running: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
else
  echo "Jenkins service failed to start."
  exit 1
fi

# Configure SSH for Jenkins user
echo "Generating SSH key for Jenkins..."
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa

# Fix permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh
sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub

# Create known_hosts file
sudo touch /var/lib/jenkins/.ssh/known_hosts
sudo chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Increase /tmp file size persistently and remount
echo "Increasing /tmp file size to 1.5GB persistently..."
if ! grep -q "/tmp tmpfs" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
fi

echo "Remounting /tmp with the new size..."
if sudo mount -o remount /tmp; then
    echo "/tmp remounted successfully."
else
    echo "WARNING: Failed to remount /tmp immediately. A reboot is required for the change to take effect."
    exit 0 
fi

echo "Script execution complete. Jenkins should be running."
