#!/bin/bash
set -e

# Install Maven
MAVEN_VERSION="3.9.11"
MAVEN_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"

# Update and install required packages
install_dependencies() {
    echo "Installing Java, Git, and other dependencies..."
    sudo dnf install -y java-17-amazon-corretto-devel git
    java -version || { echo "Java installation failed"; exit 1; }
}

install_Maven() {
    wget "$MAVEN_URL"
    tar -xzf "$MAVEN_ARCHIVE"
    sudo mv "apache-maven-${MAVEN_VERSION}" /opt/maven
    sudo ln -sf /opt/maven/bin/mvn /usr/bin/mvn
    rm -f "$MAVEN_ARCHIVE"
}


# Persist Maven environment variables
configure_maven(){
    echo 'export M2_HOME=/opt/maven' | sudo tee -a /etc/profile.d/maven.sh
    echo 'export PATH=$M2_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/maven.sh
    source /etc/profile.d/maven.sh
}


# Increase Jenkins /tmp Directory
increase_tmp_size() {
    echo "Increasing /tmp directory size for Jenkins..."
    echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
    sudo mount -o remount /tmp
}

install_docker() {
    echo "Installing Docker..."
    sudo dnf install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
}

install_docker_compose() {
    echo "Installing Docker Compose..."
    sudo mkdir -p /usr/libexec/docker/cli-plugins
    sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
}

add_ec2-user_to_docker_group() {
    echo "Adding ec2-user user to Docker group..."
    sudo usermod -aG docker ec2-user
    sudo systemctl restart docker
}


# Main Execution
install_dependencies
install_Maven
configure_maven
increase_tmp_size
install_docker
install_docker_compose
add_ec2-user_to_docker_group