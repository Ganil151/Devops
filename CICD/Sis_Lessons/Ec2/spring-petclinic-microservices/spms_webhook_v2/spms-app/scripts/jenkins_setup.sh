#!/bin/bash
set -e

## ------------------- Functions -------------------

install_updates() {
  sudo yum update -y
  # Install EPEL repository
  sudo yum install -y epel-release
}

# Change the hostname
hostname_change() {
  local new_hostname="master"
  sudo hostnamectl set-hostname "$new_hostname"
}

# Install required packages
install_dependencies(){
  sudo yum install -y java-17-amazon-corretto-devel git docker
  # Verify Java
  java -version
}

# Increase Jenkins /tmp Directory
configure_tmp(){
  echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
  sudo mount -o remount /tmp
}

# Add Jenkins repo & install
install_jenkins(){
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo  
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key  
  sudo yum install -y jenkins
}

# Enable & start Jenkins
configure_jenkins(){
  sudo systemctl enable jenkins
  sudo systemctl start jenkins
  sudo systemctl status jenkins
}

# Configure SSH for Jenkins user
configure_ssh(){
  echo "Generating SSH key for Jenkins..."
  sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
  if [ ! -f /var/lib/jenkins/.ssh/id_rsa ]; then
    sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa
  fi

  # Fix permissions
  sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
  sudo chmod 700 /var/lib/jenkins/.ssh
  sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
  sudo chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub

  # Create known_hosts file
  sudo touch /var/lib/jenkins/.ssh/known_hosts
  sudo chmod 644 /var/lib/jenkins/.ssh/known_hosts
}

# Add Worker Known Hosts
add_worker_known_hosts(){
  WORKER_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=spms_app-worker-v1" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text
  )
  echo "Adding worker ($WORKER_IP) to Jenkins known_hosts...."
  sudo -u jenkins ssh-keyscan -H $WORKER_IP | sudo tee -a /var/lib/jenkins/.ssh/known_hosts > /dev/null
}

# Install Jenkins plugins
install_plugins(){
  echo "Installing Jenkins plugins..."
  sudo -u jenkins java -jar /var/lib/jenkins/war/WEB-INF/jenkins-cli.jar \
    -s http://localhost:8080/ install-plugin git docker-workflow blueocean
  sudo systemctl restart jenkins
}

# Configure Docker
configure_docker(){
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker ec2-user
  sudo usermod -aG docker jenkins
  sudo systemctl restart jenkins
}

# Install Docker Compose
install_docker_compose(){
  mkdir -p ~/.docker/cli-plugins/
  curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
    -o ~/.docker/cli-plugins/docker-compose
  chmod +x ~/.docker/cli-plugins/docker-compose

  docker --version
  docker compose version
  sudo systemctl restart docker
}

# Check Jenkins initialization
check_jenkins_init(){
  if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "Jenkins is already initialized."
  else
    echo "Jenkins is not initialized. Initializing..."
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  fi
}

## ------------------- Main Execution -------------------

install_updates
install_dependencies
hostname_change
configure_tmp
install_jenkins 
configure_jenkins
configure_ssh
check_jenkins_init
install_plugins
configure_docker
install_docker_compose
add_worker_known_hosts
