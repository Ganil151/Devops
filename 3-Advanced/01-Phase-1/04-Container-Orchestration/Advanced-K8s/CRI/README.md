# crictl - Container Runtime Interface CLI

## Overview

**crictl** is a command-line interface for CRI-compatible container runtimes. It provides a kubectl-like experience for interacting directly with container runtimes, making it essential for debugging and troubleshooting container issues at the runtime level.

## What is crictl?

crictl is:
- A CLI tool for Container Runtime Interface (CRI)
- Used for debugging container runtime and images
- Compatible with any CRI-compliant runtime
- Essential for low-level container troubleshooting

## Role in Kubernetes Architecture

### Primary Functions

1. **Container Management**
   - Inspect running containers
   - Debug container issues
   - Manage container lifecycle

2. **Image Management**
   - List and inspect images
   - Pull and remove images
   - Debug image-related issues

3. **Pod Sandbox Management**
   - Inspect pod sandboxes
   - Debug networking issues
   - Manage pod-level resources

## crictl Architecture

### Runtime Integration
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   crictl    │───►│ CRI Runtime │───►│ Containers  │
│             │    │ (containerd │    │   & Images  │
│             │    │  /CRI-O)    │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   ▼                   │
       │            ┌─────────────┐            │
       │            │ Pod         │            │
       │            │ Sandboxes   │            │
       │            └─────────────┘            │
       │                   │                   │
       │                   ▼                   │
       └────────────┌─────────────┐◄───────────┘
                    │ Runtime     │
                    │ Statistics  │
                    └─────────────┘
```

## Installation and Setup

### Installation Methods

#### 1. Package Managers
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y cri-tools

# CentOS/RHEL
sudo yum install -y cri-tools

# Fedora
sudo dnf install -y cri-tools
```

#### 2. Direct Download
```bash
# Download latest version
VERSION="v1.28.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz
```

#### 3. From Source
```bash
git clone https://github.com/kubernetes-sigs/cri-tools.git
cd cri-tools
make
sudo cp build/bin/linux/amd64/crictl /usr/local/bin/
```

### Configuration

#### Runtime Endpoint Configuration
```bash
# Set runtime endpoint
export CONTAINER_RUNTIME_ENDPOINT=unix:///var/run/containerd/containerd.sock

# Or for CRI-O
export CONTAINER_RUNTIME_ENDPOINT=unix:///var/run/crio/crio.sock

# Set image endpoint (usually same as runtime)
export IMAGE_SERVICE_ENDPOINT=unix:///var/run/containerd/containerd.sock
```

#### Configuration File
```yaml
# /etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
disable-pull-on-run: false
```

## Core Commands

### Container Operations

#### List Containers
```bash
# List all containers
crictl ps

# List all containers (including stopped)
crictl ps -a

# List with additional details
crictl ps -o wide

# Filter by state
crictl ps --state running
crictl ps --state exited
```

#### Inspect Containers
```bash
# Inspect container
crictl inspect <container-id>

# Get container stats
crictl stats <container-id>

# Get all container stats
crictl stats
```

#### Container Logs
```bash
# View container logs
crictl logs <container-id>

# Follow logs
crictl logs -f <container-id>

# Show timestamps
crictl logs -t <container-id>

# Tail specific number of lines
crictl logs --tail=50 <container-id>
```

#### Execute Commands
```bash
# Execute command in container
crictl exec <container-id> ls /app

# Interactive shell
crictl exec -it <container-id> /bin/bash

# Execute with specific user
crictl exec -u 1000 <container-id> whoami
```

#### Container Lifecycle
```bash
# Stop container
crictl stop <container-id>

# Remove container
crictl rm <container-id>

# Force remove container
crictl rm -f <container-id>

# Remove all stopped containers
crictl rm $(crictl ps -aq --state exited)
```

### Image Operations

#### List Images
```bash
# List all images
crictl images

# List with digests
crictl images --digests

# Filter by repository
crictl images nginx

# Show image sizes
crictl images -v
```

#### Pull Images
```bash
# Pull image
crictl pull nginx:latest

# Pull with authentication
crictl pull --creds username:password private-registry.com/image:tag

# Pull from specific registry
crictl pull registry.k8s.io/pause:3.7
```

#### Inspect Images
```bash
# Inspect image
crictl inspecti nginx:latest

# Get image info in JSON format
crictl inspecti --output json nginx:latest
```

#### Remove Images
```bash
# Remove image
crictl rmi nginx:latest

# Remove image by ID
crictl rmi <image-id>

# Remove unused images
crictl rmi --prune

# Force remove image
crictl rmi -f nginx:latest
```

### Pod Sandbox Operations

#### List Pod Sandboxes
```bash
# List all pod sandboxes
crictl pods

# List with additional details
crictl pods -o wide

# Filter by state
crictl pods --state ready
crictl pods --state notready

# Filter by namespace
crictl pods --namespace kube-system
```

#### Inspect Pod Sandboxes
```bash
# Inspect pod sandbox
crictl inspectp <pod-id>

# Get pod sandbox in JSON format
crictl inspectp --output json <pod-id>
```

#### Pod Sandbox Lifecycle
```bash
# Stop pod sandbox
crictl stopp <pod-id>

# Remove pod sandbox
crictl rmp <pod-id>

# Force remove pod sandbox
crictl rmp -f <pod-id>
```

## Advanced Operations

### Runtime Information

#### Runtime Version
```bash
# Get runtime version
crictl version

# Get detailed runtime info
crictl info
```

#### Runtime Status
```bash
# Get runtime status
crictl status

# Check runtime configuration
crictl config --get runtime-endpoint
```

### Debugging Commands

#### Container Debugging
```bash
# Attach to container
crictl attach <container-id>

# Port forward (if supported)
crictl port-forward <container-id> 8080:80

# Copy files from container
crictl cp <container-id>:/path/to/file /local/path

# Copy files to container
crictl cp /local/path <container-id>:/path/to/file
```

#### Network Debugging
```bash
# List pod network namespaces
crictl pods -o json | jq '.items[].metadata.uid'

# Inspect pod network configuration
crictl inspectp <pod-id> | jq '.status.network'
```

### Filtering and Output

#### Advanced Filtering
```bash
# Filter by label
crictl ps --label io.kubernetes.pod.name=nginx

# Filter by name pattern
crictl ps --name nginx

# Filter by pod
crictl ps --pod <pod-id>

# Multiple filters
crictl ps --state running --label app=nginx
```

#### Custom Output Formats
```bash
# JSON output
crictl ps -o json

# Table output with custom columns
crictl ps -o table --columns ID,IMAGE,STATE,NAME

# Go template output
crictl ps -o go-template --template '{{range .}}{{.Id}} {{.Image.Image}}{{"\n"}}{{end}}'
```

## Configuration Management

### Runtime Configuration

#### containerd Configuration
```toml
# /etc/containerd/config.toml
[grpc]
  address = "/var/run/containerd/containerd.sock"

[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.7"
  
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
  endpoint = ["https://registry-1.docker.io"]
```

#### CRI-O Configuration
```toml
# /etc/crio/crio.conf
[crio.api]
listen = "/var/run/crio/crio.sock"

[crio.runtime]
default_runtime = "runc"
pause_image = "registry.k8s.io/pause:3.7"

[crio.image]
default_transport = "docker://"
pause_image = "registry.k8s.io/pause:3.7"
```

### crictl Configuration Options
```yaml
# ~/.crictl/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: true
pull-image-on-create: true
disable-pull-on-run: false
```

## Troubleshooting

### Common Issues

#### 1. Connection Issues
```bash
# Check runtime socket
ls -la /var/run/containerd/containerd.sock
ls -la /var/run/crio/crio.sock

# Test connectivity
crictl version

# Check runtime status
systemctl status containerd
systemctl status crio
```

#### 2. Permission Issues
```bash
# Check socket permissions
ls -la /var/run/containerd/containerd.sock

# Add user to docker group (if applicable)
sudo usermod -aG docker $USER

# Run with sudo if needed
sudo crictl ps
```

#### 3. Runtime Not Responding
```bash
# Restart runtime service
sudo systemctl restart containerd
sudo systemctl restart crio

# Check runtime logs
journalctl -u containerd -f
journalctl -u crio -f

# Check system resources
df -h
free -h
```

### Debug Commands
```bash
# Enable debug mode
crictl --debug ps

# Verbose output
crictl -v 4 ps

# Check runtime configuration
crictl config --list

# Validate runtime endpoint
crictl config --get runtime-endpoint
```

## Performance Monitoring

### Container Statistics
```bash
# Real-time container stats
crictl stats

# Single container stats
crictl stats <container-id>

# Stats in JSON format
crictl stats --output json

# Historical stats (if available)
crictl stats --history
```

### Resource Usage
```bash
# Container resource usage
crictl inspect <container-id> | jq '.status.resources'

# Pod sandbox resource usage
crictl inspectp <pod-id> | jq '.status.resources'

# Image disk usage
crictl images --digests | awk '{sum+=$7} END {print "Total size:", sum/1024/1024 "MB"}'
```

## Integration with Kubernetes

### Kubernetes Pod Debugging
```bash
# Find containers for a Kubernetes pod
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[*].containerID}'

# Get container ID from pod
CONTAINER_ID=$(kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[0].containerID}' | sed 's/.*:\/\///')

# Debug container with crictl
crictl logs $CONTAINER_ID
crictl exec -it $CONTAINER_ID /bin/bash
```

### Runtime Comparison
```bash
# Compare kubectl and crictl output
kubectl get pods
crictl pods

# Cross-reference container information
kubectl describe pod <pod-name>
crictl inspect <container-id>
```

## Security Considerations

### Runtime Security
```bash
# Check container security context
crictl inspect <container-id> | jq '.info.config.linux.security_context'

# Verify image signatures (if configured)
crictl pull --signature-policy /etc/containers/policy.json image:tag

# Check runtime security features
crictl info | jq '.config.linux.seccomp'
```

### Access Control
```bash
# Limit crictl access with sudo
echo 'username ALL=(ALL) NOPASSWD: /usr/local/bin/crictl' >> /etc/sudoers.d/crictl

# Use specific runtime socket permissions
sudo chmod 660 /var/run/containerd/containerd.sock
sudo chown root:docker /var/run/containerd/containerd.sock
```

## Best Practices

### 1. Configuration Management
- Use configuration files instead of environment variables
- Set appropriate timeouts for operations
- Configure proper logging levels
- Use consistent runtime endpoints

### 2. Debugging Workflow
- Start with high-level kubectl commands
- Use crictl for runtime-specific issues
- Check container logs before exec
- Verify image availability before troubleshooting

### 3. Performance
- Use filters to limit output
- Avoid frequent polling operations
- Clean up unused containers and images
- Monitor runtime resource usage

### 4. Security
- Limit access to runtime sockets
- Use least privilege principles
- Regularly update crictl and runtimes
- Monitor container security contexts

## Comparison with kubectl

### When to Use crictl vs kubectl

#### Use crictl for:
- Container runtime debugging
- Low-level container inspection
- Image management issues
- Runtime-specific problems
- Direct container operations

#### Use kubectl for:
- Kubernetes resource management
- Application deployment
- Cluster-wide operations
- High-level troubleshooting
- Production operations

### Command Equivalents
```bash
# List pods/containers
kubectl get pods
crictl pods

# Container logs
kubectl logs <pod-name>
crictl logs <container-id>

# Execute in container
kubectl exec -it <pod-name> -- /bin/bash
crictl exec -it <container-id> /bin/bash

# Container inspection
kubectl describe pod <pod-name>
crictl inspect <container-id>
```

## Conclusion

crictl is essential for:
- Low-level container runtime debugging
- Image management and troubleshooting
- Container lifecycle operations
- Runtime-specific issue resolution
- Development and testing workflows

Understanding crictl complements kubectl knowledge and provides deeper insight into container runtime behavior in Kubernetes environments.