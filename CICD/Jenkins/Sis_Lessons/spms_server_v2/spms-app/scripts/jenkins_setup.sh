#!/bin/bash
set -e  # Exit on error
exec > >(tee -a setup.log) 2>&1  # Log all output

# Variables
JENKINS_HOME="/var/lib/jenkins"
SSH_DIR="$JENKINS_HOME/.ssh"

# Functions
install_dependencies() {
    echo "Installing Java, Git, and other dependencies..."
    sudo yum install -y java-17-amazon-corretto-devel git
    java -version || { echo "Java installation failed"; exit 1; }
}

install_jenkins() {
    echo "Adding Jenkins repository..."
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    echo "Installing Jenkins..."
    sudo yum install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo systemctl status jenkins --no-pager || true
}

configure_ssh() {
    echo "Configuring SSH for Jenkins user..."
    sudo -u jenkins mkdir -p "$SSH_DIR"
    sudo -u jenkins chmod 700 "$SSH_DIR"
    sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f "$SSH_DIR/id_rsa"
    sudo -u jenkins touch "$SSH_DIR/known_hosts"
    sudo chown -R jenkins:jenkins "$SSH_DIR"
    sudo -u jenkins chmod 600 "$SSH_DIR/id_rsa"
    sudo -u jenkins chmod 644 "$SSH_DIR/id_rsa.pub"
    sudo -u jenkins chmod 644 "$SSH_DIR/known_hosts"
}

increase_tmp_size() {
    echo "Increasing /tmp directory size for Jenkins..."
    echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
    sudo mount -o remount /tmp
}

install_docker() {
    echo "Installing Docker..."
    sudo yum install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
}

install_docker_compose() {
    echo "Installing Docker Compose..."
    sudo mkdir -p /usr/libexec/docker/cli-plugins
    sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
}

add_jenkins_to_docker_group() {
    echo "Adding Jenkins user to Docker group..."
    sudo usermod -aG docker jenkins
    sudo systemctl restart docker
}

# Main Execution
install_dependencies
install_jenkins
configure_ssh
increase_tmp_size
install_docker
install_docker_compose
add_jenkins_to_docker_group

echo "Setup complete!"