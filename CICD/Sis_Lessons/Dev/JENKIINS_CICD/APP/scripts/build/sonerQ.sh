#!/bin/bash set -e 
# Change Host Name echo "Change Host Name" 
sudo hostnamectl set-hostname "sonarQ-server" 

# Install dependencies echo "Install dependencies" 
sudo apt update -y && sudo apt upgrade -y 

# Then install Java JDk 
sudo apt install -y openjdk-21-jdk 

# Install MySQL 
echo "Installing MySQL" 
sudo apt install -y mysql-server 
sudo systemctl start mysql 
sudo systemctl enable mysql


# Set JAVA_HOME environment variable 
echo "Setting JAVA_HOME environment variable" 
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac)))) 
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile 
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME" | sudo tee -a /etc/profile 

# Install required packages 
sudo apt install -y unzip git 
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.9.0.112764.zip 
sudo unzip sonarqube-25.9.0.112764.zip 


# Change Owner of SonarQube directory 
sudo chown -R ubuntu:ubuntu /home/ubuntu/sonarqube-25.9.0.112764/temp 
sudo chown -R ubuntu:ubuntu /home/ubuntu/sonarqube-25.9.0.112764/bin/ 
sudo chown -R ubuntu:ubuntu /home/ubuntu/sonarqube-25.9.0.112764/ 
sudo chmod -R 755 /home/ubuntu/sonarqube-25.9.0.112764/temp 
sudo chmod -R 755 /home/ubuntu/sonarqube-25.9.0.112764/

# Change Permissions for sonar.sh 
sudo chmod +x sonar.sh 

# Start SonarQube 
echo "Starting SonarQube" 
sudo ./sonar.sh console 

# Increase /tmp file 
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab 
sudo mount -o remount /tmp