#!/bin/bash

set -e

# Change Host Name
echo "Change Host Name"
sudo hostnamectl set-hostname "master-server"

# Install dependencies
echo "Install dependencies"
sudo yum update -y

# Then install Java JDk
sudo yum install -y java-21-amazon-corretto-devel git

# Configure Java
echo "Configure Java"
JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a ~/.bashrc
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME" | sudo tee -a ~/.bashrc


# Install Jenkins 
echo "Install Jenkins"
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

#Then Import Key:
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

# Now Install Jenkins
sudo yum install -y jenkins

# Configure Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Configure Java in Jenkins
echo "Configure Java"
sudo touch /var/lib/jenkins/.bash_profile
sudo chown -R jenkins:jenkins /var/lib/jenkins/.bash_profile
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /var/lib/jenkins/.bash_profile
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME" | sudo tee -a /var/lib/jenkins/.bash_profile
source /var/lib/jenkins/.bash_profile

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

# Increase /tmp file
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp