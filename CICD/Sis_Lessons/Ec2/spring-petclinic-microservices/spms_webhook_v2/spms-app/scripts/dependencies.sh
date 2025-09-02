#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Function to install updates and EPEL repository
install_updates() {
  echo "Updating system packages..."
  sudo yum update -y
  echo "Installing EPEL repository..."
  sudo yum install -y epel-release
}

# Function to change the hostname
hostname_change() {
  local new_hostname="worker"
  echo "Changing hostname to $new_hostname..."
  sudo hostnamectl set-hostname "$new_hostname"
}

# Function to install required dependencies
install_dependencies() {
  echo "Installing required packages..."
  sudo yum install -y java-17-amazon-corretto-devel git docker maven
  # Verify Java installation
  echo "Verifying Java installation..."
  java -version
}

# Function to increase /tmp directory size
configure_tmp() {
  echo "Increasing /tmp directory size..."
  echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
  sudo mount -o remount /tmp
}

# Function to configure Docker
configure_docker() {
  echo "Configuring Docker..."
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker ec2-user
  sudo usermod -aG docker jenkins
  sudo systemctl restart docker
}

# Function to install Docker Compose
install_docker_compose() {
  echo "Installing Docker Compose..."
  mkdir -p ~/.docker/cli-plugins/
  curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
    -o ~/.docker/cli-plugins/docker-compose
  chmod +x ~/.docker/cli-plugins/docker-compose

  echo "Verifying Docker and Docker Compose installation..."
  docker --version
  docker compose version
  sudo systemctl restart docker
}

# Function to configure Maven
configure_maven() {
  echo "Adding Apache Maven repository..."
  sudo tee /etc/yum.repos.d/apache-maven.repo > /dev/null << 'EOF'
[apache-maven]
name=Apache Maven
baseurl=https://repos.fedorapeople.org/repos/katello/6.0/epel-8/Everything/x86_64/os/
enabled=1
gpgcheck=0
EOF

  echo "Installing Maven..."
  sudo yum install -y maven

  echo "Verifying Maven installation..."
  mvn -version
}

# Main Execution
echo "Starting setup process..."
install_updates
hostname_change
install_dependencies
configure_tmp
configure_docker
install_docker_compose
configure_maven
echo "Setup completed successfully!"