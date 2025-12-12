# Docker Installation Guide

Complete installation guide for Docker Engine across different operating systems.

## Ubuntu/Debian Installation

### Method 1: Convenience Script (Recommended)
```bash
# Download and run installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (optional)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker run hello-world
```

### Method 2: Repository Installation
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
sudo docker run hello-world
```

## CentOS/RHEL Installation

### Repository Installation
```bash
# Install required packages
sudo dnf -y install dnf-plugins-core

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
sudo systemctl enable --now docker

# Verify installation
sudo docker run hello-world

# Add user to docker group
sudo usermod -aG docker $USER
```

### Package Installation
```bash
# Download RPM package from https://download.docker.com/linux/centos/
# Install package
sudo dnf install /path/to/docker-ce-package.rpm

# Start Docker
sudo systemctl enable --now docker
```

## macOS Installation

### Docker Desktop (Recommended)
1. Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Install the `.dmg` file
3. Start Docker Desktop from Applications
4. Verify installation:
```bash
docker --version
docker run hello-world
```

### Homebrew Installation
```bash
# Install Docker
brew install --cask docker

# Start Docker Desktop
open /Applications/Docker.app

# Verify installation
docker --version
```

## Windows Installation

### Docker Desktop for Windows
1. Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Run the installer
3. Enable WSL 2 backend (recommended)
4. Restart computer if required
5. Start Docker Desktop
6. Verify installation:
```powershell
docker --version
docker run hello-world
```

### WSL 2 Backend Setup
```bash
# Enable WSL 2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Download and install WSL 2 kernel update
# Set WSL 2 as default
wsl --set-default-version 2

# Install Ubuntu from Microsoft Store
# Configure Docker Desktop to use WSL 2 backend
```

## Post-Installation Setup

### Configure Docker as Non-Root User (Linux)
```bash
# Create docker group (usually exists)
sudo groupadd docker

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Verify non-root access
docker run hello-world
```

### Configure Docker to Start on Boot
```bash
# Enable Docker service (systemd)
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Start Docker service
sudo systemctl start docker

# Check status
sudo systemctl status docker
```

### Configure Docker Daemon
```bash
# Create daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart Docker
sudo systemctl restart docker
```

## Verification and Testing

### Basic Verification
```bash
# Check Docker version
docker --version
docker version

# Check Docker info
docker info

# Run test container
docker run hello-world

# Run interactive container
docker run -it ubuntu bash
```

### Advanced Testing
```bash
# Test networking
docker run --rm nginx:alpine

# Test volume mounting
docker run --rm -v $(pwd):/data alpine ls /data

# Test port mapping
docker run -d -p 8080:80 nginx:alpine
curl http://localhost:8080

# Clean up
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

## Docker Compose Installation

### Linux Installation
```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Alternative Installation (pip)
```bash
# Install via pip
pip install docker-compose

# Verify installation
docker-compose --version
```

## Troubleshooting Installation

### Common Issues

#### Permission Denied
```bash
# Error: permission denied while trying to connect to Docker daemon
# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Docker Daemon Not Running
```bash
# Error: Cannot connect to the Docker daemon
# Solution: Start Docker service
sudo systemctl start docker

# Check status
sudo systemctl status docker
```

#### Storage Driver Issues
```bash
# Error: storage driver issues
# Solution: Configure storage driver
sudo tee /etc/docker/daemon.json <<EOF
{
  "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker
```

#### Network Issues
```bash
# Error: network connectivity issues
# Solution: Configure DNS
sudo tee /etc/docker/daemon.json <<EOF
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

sudo systemctl restart docker
```

### Diagnostic Commands
```bash
# Check Docker logs
sudo journalctl -u docker.service

# Check system resources
df -h
free -h

# Check Docker disk usage
docker system df

# Clean up Docker resources
docker system prune -a
```

## Uninstallation

### Ubuntu/Debian
```bash
# Remove Docker packages
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Remove Docker data
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Remove Docker group
sudo groupdel docker
```

### CentOS/RHEL
```bash
# Remove Docker packages
sudo dnf remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Remove Docker data
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

### macOS/Windows
1. Uninstall Docker Desktop from Applications
2. Remove Docker data directories if needed

## Security Considerations

### Rootless Docker (Advanced)
```bash
# Install rootless Docker
curl -fsSL https://get.docker.com/rootless | sh

# Configure environment
export PATH=/home/$USER/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# Start rootless Docker
systemctl --user start docker
systemctl --user enable docker
```

### Docker Bench Security
```bash
# Run security benchmark
docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /usr/bin/containerd:/usr/bin/containerd:ro \
    -v /usr/bin/runc:/usr/bin/runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --label docker_bench_security \
    docker/docker-bench-security
```

This completes the comprehensive Docker installation guide covering all major platforms and post-installation configuration.