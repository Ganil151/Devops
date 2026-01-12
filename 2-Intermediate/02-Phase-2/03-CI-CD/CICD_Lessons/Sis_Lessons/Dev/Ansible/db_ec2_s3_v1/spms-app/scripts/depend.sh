#!/bin/bash
set -e
set -x

# Update packages
sudo yum update -y

# Change the hostname
sudo hostnamectl set-hostname "jenkins-server"

# Increase tmp files size
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

# Install dependencies
sudo yum install java-21-amazon-corretto-devel git docker -y

# Verify Java
java -version || { echo "Java installation failed"; exit 1; }

# Configure Git
sudo chown -R jenkins:jenkins /usr/bin/git
sudo chmod 755 /usr/bin/git


# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Enable & start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager || true

# Create SSH Directory
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins chmod 700 /var/lib/jenkins/.ssh

# Configure Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user
sudo systemctl restart jenkins

# Configure Maven
wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz
sudo tar -xvf apache-maven-3.9.11-bin.tar.gz -C /opt/
sudo ln -s /opt/apache-maven-3.9.11/bin/mvn /usr/local/bin/mvn
rm apache-maven-3.9.11-bin.tar.gz

sudo ln -s /opt/apache-maven-3.9.11 /opt/maven

# Configure environment variables for Jenkins and ec2-user
echo 'export M2_HOME=/opt/maven' | sudo tee -a /var/lib/jenkins/.bash_profile
echo 'export M2=/opt/maven/bin' | sudo tee -a /var/lib/jenkins/.bash_profile
echo 'export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java' | sudo tee -a /var/lib/jenkins/.bash_profile
echo 'export PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2' | sudo tee -a /var/lib/jenkins/.bash_profile

echo 'export M2_HOME=/opt/maven' | sudo tee -a /home/ec2-user/.bash_profile
echo 'export M2=/opt/maven/bin' | sudo tee -a /home/ec2-user/.bash_profile
echo 'export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java' | sudo tee -a /home/ec2-user/.bash_profile
echo 'export PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2' | sudo tee -a /home/ec2-user/.bash_profile

sudo chmod -R 755 /usr/lib/jvm/java-21-amazon-corretto.x86_64
sudo chmod -R 755 /opt/maven
sudo chmod -R 755 /opt/apache-maven-3.9.11


# Verify Maven installation
mvn -v || { echo "Maven installation failed"; exit 1; }