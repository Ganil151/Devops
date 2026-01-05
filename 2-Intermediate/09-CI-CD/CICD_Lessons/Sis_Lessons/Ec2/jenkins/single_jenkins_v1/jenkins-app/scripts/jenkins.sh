#!/bin/bash
set -e

# Function to install dependencies
install_dependencies(){
  sudo yum update -y
  sudo yum upgrade -y
  echo "Installing required packages..."
  sudo yum install -y java-17-amazon-corretto-devel git docker

  # Start and enable Docker service
  echo "Starting and enabling Docker service..."
  sudo systemctl start docker
  sudo systemctl enable docker

  # Add Jenkins and ec2-user to Docker group
  sudo usermod -aG docker jenkins
  sudo usermod -aG docker ec2-user
}

# Function to install Jenkins
install_jenkins() {
  echo "Adding Jenkins repository..."
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

  echo "Installing Jenkins..."
  sudo yum install -y jenkins

  echo "Starting and enabling Jenkins service..."
  sudo systemctl start jenkins
  sudo systemctl enable jenkins

  echo "Jenkins installed successfully. Access it at http://<your-server-ip>:8080"
  echo "Initial admin password can be found at: /var/lib/jenkins/secrets/initialAdminPassword"
}

# Function to increase /tmp filesystem size
increase_tmpfs_size(){
  echo "Increasing /tmp filesystem size..."
  sudo mount -o remount,size=1G /tmp
}

generate_ssh_key(){
  # Generate SSH key for Jenkins
  echo "Generating SSH key..."
  if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
  else
    echo "SSH key already exists. Skipping generation."
  fi
}

configure_ssh(){
  # Configure SSH for Jenkins
  echo "Configuring SSH..."
  mkdir -p /var/lib/jenkins/.ssh
  cp ~/.ssh/id_rsa* /var/lib/jenkins/.ssh/
  touch /var/lib/jenkins/.ssh/known_hosts
}

set_ssh_permissions(){
  # Set appropriate permissions
  chown -R jenkins:jenkins /var/lib/jenkins/.ssh
  chmod 700 /var/lib/jenkins/.ssh
  chmod 600 /var/lib/jenkins/.ssh/id_rsa
  chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub
  chmod 644 /var/lib/jenkins/.ssh/known_hosts
}

# Execute the functions
install_dependencies
install_jenkins
increase_tmpfs_size
generate_ssh_key
configure_ssh
set_ssh_permissions

# Check Jenkins initialization
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  echo "Jenkins is already initialized."
else
  echo "Jenkins is not initialized. Initializing..."
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
fi

# Install Jenkins plugins
echo "Installing Jenkins plugins..."
sudo -u jenkins java -jar /var/lib/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin git docker-workflow blueocean
sudo systemctl restart jenkins


# Install terraform
echo "Installing Terraform..."
if [ -f "scripts/terraform/terraform.sh" ]; then
  echo "Terraform installation script found."
  bash scripts/terraform/terraform.sh
else
  echo "Terraform installation script not found."
fi