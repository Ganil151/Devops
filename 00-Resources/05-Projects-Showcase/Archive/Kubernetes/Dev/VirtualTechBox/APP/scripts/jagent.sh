#!/bin/bash

set -e 

# Install Dependencies 
sudo apt-get update
sudo apt-get upgrade -y

# Change Hostname 
sudo hostnamectl set-hostname "Jenkins-Agent"

# Install git wget
sudo apt install git wget -y

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

# Install Docker 
sudo install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER