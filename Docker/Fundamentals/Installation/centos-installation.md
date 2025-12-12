# Docker Installation on CentOS

Complete guide for installing Docker Engine on CentOS/RHEL systems.

## Installation Methods

You can install Docker Engine in different ways, depending on your needs:

- **Repository installation** - Recommended approach for ease of installation and upgrade
- **RPM package** - Manual installation for air-gapped systems
- **Convenience script** - Automated installation for development environments

## Repository Installation (Recommended)

### Prerequisites

```bash
# Update system packages
sudo dnf update -y

# Remove old Docker versions
sudo dnf remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-engine
```

### Set up Repository

```bash
# Install required packages
sudo dnf -y install dnf-plugins-core

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### Install Docker Engine

```bash
# Install Docker packages
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Note: If prompted to accept the GPG key, verify fingerprint:
# 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35
```

### Start and Enable Docker

```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify installation
sudo docker run hello-world
```

### Post-Installation Setup

```bash
# Add user to docker group (optional)
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
# Or use: newgrp docker

# Verify non-root access
docker run hello-world
```

## RPM Package Installation

### Download Packages

1. Go to https://download.docker.com/linux/centos/
2. Choose your CentOS version
3. Browse to `x86_64/stable/Packages/`
4. Download the required `.rpm` files:
   - `docker-ce-<version>.rpm`
   - `docker-ce-cli-<version>.rpm`
   - `containerd.io-<version>.rpm`
   - `docker-buildx-plugin-<version>.rpm`
   - `docker-compose-plugin-<version>.rpm`

### Install Packages

```bash
# Install Docker Engine
sudo dnf install /path/to/docker-ce.rpm \
  /path/to/docker-ce-cli.rpm \
  /path/to/containerd.io.rpm \
  /path/to/docker-buildx-plugin.rpm \
  /path/to/docker-compose-plugin.rpm

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
sudo docker run hello-world
```

## Convenience Script Installation

### Download and Run Script

```bash
# Download installation script
curl -fsSL https://get.docker.com -o get-docker.sh

# Review script (recommended)
cat get-docker.sh

# Run installation script
sudo sh get-docker.sh

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### Script Considerations

**Advantages:**
- Quick and easy installation
- Handles repository setup automatically
- Installs latest stable version

**Disadvantages:**
- Less control over installation process
- May install unwanted packages
- Not recommended for production

## Configuration

### Docker Daemon Configuration

```bash
# Create daemon configuration file
sudo mkdir -p /etc/docker

# Configure Docker daemon
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# Restart Docker to apply changes
sudo systemctl restart docker
```

### Firewall Configuration

```bash
# Allow Docker through firewall
sudo firewall-cmd --permanent --zone=public --add-masquerade
sudo firewall-cmd --permanent --zone=public --add-port=2376/tcp
sudo firewall-cmd --reload

# For Docker Swarm (if needed)
sudo firewall-cmd --permanent --add-port=2377/tcp
sudo firewall-cmd --permanent --add-port=7946/tcp
sudo firewall-cmd --permanent --add-port=7946/udp
sudo firewall-cmd --permanent --add-port=4789/udp
sudo firewall-cmd --reload
```

## Verification

### Test Installation

```bash
# Check Docker version
docker --version
docker version

# Check Docker info
docker info

# Run test container
docker run hello-world

# Check Docker Compose
docker compose version
```

### System Integration

```bash
# Check service status
sudo systemctl status docker

# View Docker logs
sudo journalctl -u docker.service

# Check Docker socket
ls -la /var/run/docker.sock
```

## Troubleshooting

### Common Issues

#### Permission Denied

```bash
# Error: permission denied while trying to connect to Docker daemon
# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Service Won't Start

```bash
# Check service status
sudo systemctl status docker

# Check logs
sudo journalctl -u docker.service

# Common fixes:
sudo systemctl daemon-reload
sudo systemctl restart docker
```

#### Storage Issues

```bash
# Check disk space
df -h /var/lib/docker

# Clean up Docker resources
docker system prune -a

# Change Docker root directory (if needed)
sudo systemctl stop docker
sudo mv /var/lib/docker /new/path/docker
sudo ln -s /new/path/docker /var/lib/docker
sudo systemctl start docker
```

## Security Hardening

### Secure Docker Daemon

```bash
# Configure TLS for Docker daemon
sudo mkdir -p /etc/docker/certs.d

# Generate certificates (example)
# In production, use proper CA-signed certificates

# Configure daemon with TLS
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "hosts": ["tcp://0.0.0.0:2376", "unix:///var/run/docker.sock"],
  "tls": true,
  "tlscert": "/etc/docker/certs.d/server-cert.pem",
  "tlskey": "/etc/docker/certs.d/server-key.pem",
  "tlsverify": true,
  "tlscacert": "/etc/docker/certs.d/ca.pem"
}
EOF
```

### User Namespace Mapping

```bash
# Enable user namespace mapping
sudo tee -a /etc/docker/daemon.json > /dev/null <<EOF
{
  "userns-remap": "default"
}
EOF

sudo systemctl restart docker
```

## Upgrade Docker

### Repository Upgrade

```bash
# Update package list
sudo dnf check-update

# Upgrade Docker packages
sudo dnf update docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Restart Docker service
sudo systemctl restart docker
```

### Manual Upgrade

```bash
# Download new RPM packages
# Install using dnf upgrade instead of install
sudo dnf upgrade /path/to/new-docker-packages.rpm
```

## Uninstall Docker

### Complete Removal

```bash
# Stop Docker service
sudo systemctl stop docker

# Remove Docker packages
sudo dnf remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# Remove Docker data (WARNING: This deletes all containers, images, volumes)
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Remove Docker configuration
sudo rm -rf /etc/docker

# Remove Docker group
sudo groupdel docker
```

## Production Considerations

### System Requirements

- **CPU**: 64-bit processor
- **Memory**: 4GB+ RAM recommended
- **Storage**: 20GB+ free space
- **OS**: CentOS 7+, RHEL 7+, Fedora 28+

### Performance Tuning

```bash
# Optimize for production
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  },
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
EOF

# Restart Docker
sudo systemctl restart docker
```

### Monitoring Setup

```bash
# Enable Docker metrics
sudo tee -a /etc/docker/daemon.json > /dev/null <<EOF
{
  "metrics-addr": "127.0.0.1:9323",
  "experimental": true
}
EOF

sudo systemctl restart docker
```

## Additional Resources

- [Docker Official Documentation](https://docs.docker.com/engine/install/centos/)
- [CentOS Docker Installation Guide](https://docs.docker.com/engine/install/centos/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Docker Production Deployment](https://docs.docker.com/engine/install/linux-postinstall/)