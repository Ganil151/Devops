# SonarQube Installation Methods

Choose the installation method that best fits your environment and requirements.

## Available Installation Methods

### 1. Native Installation
- **[Ubuntu Installation Guide](./Native/ubuntu-installation-guide.md)** - Complete native installation on Ubuntu 24.04
- **[Original Install Guide](./Native/install-sonarQube.md)** - Step-by-step installation instructions
- **[SystemD Service](./Native/systemd-service-config.md)** - Service configuration for system management

**Best for:**
- Production environments requiring maximum performance
- Organizations with specific OS requirements
- Custom security and compliance needs

### 2. Docker Installation
- **[Docker Installation Guide](./Docker/docker-installation-guide.md)** - Comprehensive Docker setup with PostgreSQL
- **[Docker Quick Start](./Docker/docker-quick-start.md)** - Fast Docker deployment
- **[Container Notes](./Docker/docker-container-notes.md)** - Docker-specific configurations

**Best for:**
- Development and testing environments
- Quick proof-of-concept deployments
- Containerized infrastructure

### 3. Kubernetes Installation
- **[Kubernetes Deployment Guide](./Kubernetes/kubernetes-deployment-guide.md)** - Production-ready Kubernetes deployment

**Best for:**
- Cloud-native environments
- High availability requirements
- Scalable enterprise deployments

## Quick Comparison

| Method | Complexity | Performance | Scalability | Maintenance |
|--------|------------|-------------|-------------|-------------|
| Native | Medium | Excellent | Good | Medium |
| Docker | Low | Good | Good | Low |
| Kubernetes | High | Excellent | Excellent | High |

## Prerequisites by Method

### Native Installation
- Ubuntu 24.04 LTS (or compatible Linux)
- OpenJDK 17
- PostgreSQL 12+
- 4GB+ RAM, 2+ CPU cores

### Docker Installation
- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB+ RAM available to Docker

### Kubernetes Installation
- Kubernetes 1.20+
- Helm 3.x (recommended)
- StorageClass for persistent volumes
- 8GB+ RAM per pod

## Getting Started

1. **Choose your installation method** based on your requirements
2. **Review prerequisites** for your chosen method  
3. **Follow the detailed guide** for step-by-step instructions
4. **Configure security** and performance settings
5. **Set up monitoring** and backup procedures

## Next Steps

After installation:
- Configure [Database](../Configuration/Database/) settings
- Set up [Security](../Configuration/Security/) and authentication
- Optimize [Performance](../../../../../3-Advanced/01-Phase-1/03-Linux/Performance) settings
- Integrate with [CI/CD](../CI-CD-Integration/) pipelines