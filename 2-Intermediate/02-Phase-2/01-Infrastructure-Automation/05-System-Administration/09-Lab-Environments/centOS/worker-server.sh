#!/bin/bash

set -e

# --- 1. System Setup and Host Name Configuration ---

echo "--- 1. Changing Host Name ---"
# Set Host Name
NEW_HOSTNAME="Worker-Server"
echo "Changing Host Name to: ${NEW_HOSTNAME}"
sudo hostnamectl set-hostname "${NEW_HOSTNAME}"

# Update system packages
echo "--- Updating system packages ---"
sudo dnf update -y

# --- 2. Install Java and Configure Environment Variables ---

echo "--- 2. Installing Java ---"
# Install Java 21 OpenJDK
sudo dnf install -y java-21-openjdk-devel git wget curl tar gzip maven

# Verify Java installation
JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
if [ ! -d "$JAVA_HOME" ]; then
    echo "ERROR: Java 21 OpenJDK not found at $JAVA_HOME. Please verify installation."
    exit 1
fi

# Configure Java environment variables
echo "--- Configuring Java environment variables ---"
{
    echo "export JAVA_HOME=${JAVA_HOME}"
    echo "export PATH=\$PATH:\$HOME/bin:\$JAVA_HOME/bin"
} | sudo tee -a /etc/profile.d/java_env.sh

# Make the profile script executable
sudo chmod +x /etc/profile.d/java_env.sh

# Source the profile script to apply changes immediately
source /etc/profile.d/java_env.sh

# --- 3. Maven Configuration ---

echo "--- 3. Verifying Maven Installation ---"
M2_HOME="/usr/share/maven"
if [ ! -d "$M2_HOME" ]; then
    echo "WARNING: Could not confirm standard M2_HOME directory ($M2_HOME). Skipping M2_HOME export."
    M2_HOME="" # Clear if not found to prevent exporting an invalid path
fi

# Configure Maven environment variables
echo "--- Configuring Maven environment variables ---"
{
    echo "export M2_HOME=${M2_HOME}"
    echo "export PATH=\$PATH:\$M2_HOME/bin"
} | sudo tee -a /etc/profile.d/maven_env.sh

# Make the profile script executable
sudo chmod +x /etc/profile.d/maven_env.sh

# Source the profile script to apply changes immediately
source /etc/profile.d/maven_env.sh

# --- 4. Install Docker ---

echo "--- 4. Installing Docker ---"
# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo dnf install -y docker git

# Start and enable Docker service
echo "--- Starting and enabling Docker service ---"
sudo systemctl enable docker
sudo systemctl start docker

# Add the current user to the docker group
echo "--- Adding the current user to the docker group ---"
sudo usermod -aG docker $(whoami)
echo "You may need to log out and log back in for the group change to take effect."

# --- 5. Install Docker Compose ---

echo "--- 5. Installing Docker Compose ---"
COMPOSE_VERSION="v2.40.1" # Update this to the latest version if needed
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
PLUGINS_DIR="$DOCKER_CONFIG/cli-plugins"

# Create the plugins directory if it doesn't exist
mkdir -p "$PLUGINS_DIR"

# Download Docker Compose binary
echo "--- Downloading Docker Compose binary ---"
curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
     -o "$PLUGINS_DIR/docker-compose"

# Make the binary executable
chmod +x "$PLUGINS_DIR/docker-compose"

# Verify Docker Compose installation
if docker compose version; then
    echo "--- Docker Compose installed successfully ---"
else
    echo "--- ERROR: Docker Compose verification failed ---"
    exit 1
fi

# --- 6. Install YQ for YAML Processing ---

echo "--- 6. Installing YQ ---"
if ! command -v yq &> /dev/null; then
    echo "--- Installing yq ---"
    sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

# Verify YQ installation
if command -v yq &> /dev/null; then
    echo "--- YQ installed successfully ---"
else
    echo "--- ERROR: YQ installation failed ---"
    exit 1
fi

# --- 7. Install Ansible ---

echo "--- 7. Installing Ansible ---"
sudo dnf install -y ansible

# Verify Ansible installation
if command -v ansible &> /dev/null; then
    echo "--- Ansible installed successfully ---"
    ansible --version
else
    echo "--- ERROR: Ansible installation failed ---"
    exit 1
fi

# --- 8. Increase /tmp File Size Persistently ---

echo "--- 8. Increasing /tmp file size to 1.5GB persistently ---"
if ! grep -q "/tmp tmpfs" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
fi

echo "--- Remounting /tmp with the new size ---"
if sudo mount -o remount /tmp; then
    echo "--- /tmp remounted successfully with 1.5GB size ---"
else
    echo "--- WARNING: Failed to remount /tmp immediately. A reboot is required for the change to take effect ---"
    exit 0
fi

# --- Final Output ---

echo "--- Script execution complete. ---"
echo "Docker, Docker Compose, Java, Maven, Ansible, and other dependencies have been installed and configured successfully."