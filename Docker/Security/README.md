# Docker Security

Comprehensive guide to container security best practices, hardening, and compliance.

## Security Fundamentals

### Container Security Model

- **Isolation**: Process and resource isolation
- **Least Privilege**: Minimal permissions and capabilities
- **Defense in Depth**: Multiple security layers
- **Immutable Infrastructure**: Read-only containers
- **Supply Chain Security**: Secure base images and dependencies

### Security Layers

```
Application Security     ← Code vulnerabilities, dependencies
Container Runtime       ← Docker daemon, containerd
Host OS Security       ← Kernel, system hardening
Network Security       ← Firewall, network policies
Infrastructure         ← Cloud security, physical security
```

## Image Security

### Secure Base Images

```dockerfile
# Use official, minimal images
FROM alpine:3.16                    # Minimal Linux distribution
FROM node:16-alpine                 # Official Node.js on Alpine
FROM gcr.io/distroless/java:11     # Distroless images

# Use specific versions, not latest
FROM nginx:1.21.6-alpine           # Specific version
FROM postgres:13.7                 # Avoid 'latest' tag

# Multi-stage builds for minimal attack surface
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER 1000:1000
CMD ["node", "server.js"]
```

### Image Scanning

```bash
# Docker Scout (built-in)
docker scout cves myapp:latest
docker scout recommendations myapp:latest

# Trivy scanner
trivy image myapp:latest
trivy image --severity HIGH,CRITICAL myapp:latest

# Snyk scanner
snyk container test myapp:latest

# Clair scanner
clairctl analyze myapp:latest
```

### Dockerfile Security

```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set proper ownership
COPY --chown=appuser:appgroup . /app

# Use non-root user
USER appuser

# Avoid running as root
# Never use USER root in production

# Remove unnecessary packages
RUN apk add --no-cache curl && \
    apk del build-dependencies

# Use COPY instead of ADD
COPY requirements.txt .            # Preferred
# ADD can extract archives and fetch URLs (security risk)

# Set proper file permissions
COPY --chmod=755 script.sh /usr/local/bin/
```

## Runtime Security

### Container Hardening

```bash
# Run with read-only filesystem
docker run --read-only nginx

# Drop all capabilities
docker run --cap-drop ALL nginx

# Add only required capabilities
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx

# Disable new privileges
docker run --security-opt no-new-privileges nginx

# Set resource limits
docker run --memory=512m --cpus="1" nginx

# Use security profiles
docker run --security-opt apparmor:nginx-profile nginx
docker run --security-opt seccomp:seccomp-profile.json nginx
```

### User and Permissions

```bash
# Run as non-root user
docker run --user 1000:1000 nginx

# Map user to host user
docker run --user $(id -u):$(id -g) nginx

# Set specific user in Dockerfile
FROM nginx:alpine
RUN adduser -D -s /bin/sh appuser
USER appuser
```

### Capability Management

```bash
# List default capabilities
docker run --rm alpine sh -c 'apk add --no-cache libcap && capsh --print'

# Drop dangerous capabilities
docker run --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --cap-add CHOWN \
  nginx

# Common capabilities to avoid:
# SYS_ADMIN, SYS_PTRACE, SYS_MODULE, DAC_OVERRIDE
```

## Network Security

### Network Isolation

```bash
# Create isolated networks
docker network create --internal backend-network

# No external connectivity
docker run --network backend-network alpine

# Custom bridge with isolation
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.enable_icc=false \
  isolated-network
```

### Firewall Configuration

```bash
# Docker and iptables
# Docker modifies iptables automatically
# Use DOCKER-USER chain for custom rules

# Block specific traffic
iptables -I DOCKER-USER -s 192.168.1.0/24 -j DROP

# Allow only specific ports
iptables -I DOCKER-USER -p tcp --dport 80 -j ACCEPT
iptables -I DOCKER-USER -p tcp --dport 443 -j ACCEPT
iptables -I DOCKER-USER -j DROP
```

### TLS and Encryption

```bash
# Enable Docker daemon TLS
dockerd \
  --tlsverify \
  --tlscacert=ca.pem \
  --tlscert=server-cert.pem \
  --tlskey=server-key.pem \
  -H=0.0.0.0:2376

# Client TLS configuration
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/path/to/certs
export DOCKER_HOST=tcp://docker-host:2376
```

## Secrets Management

### Docker Secrets (Swarm)

```bash
# Create secret
echo "mysecretpassword" | docker secret create db_password -

# Use secret in service
docker service create \
  --name webapp \
  --secret db_password \
  myapp:latest

# Access secret in container
# Available at /run/secrets/db_password
```

### External Secrets Management

```bash
# HashiCorp Vault integration
docker run -d \
  --name vault-agent \
  -v vault-secrets:/vault/secrets \
  vault:latest agent -config=/vault/config

# AWS Secrets Manager
docker run -d \
  --name app \
  -e AWS_REGION=us-west-2 \
  --env-file <(aws secretsmanager get-secret-value --secret-id prod/db --query SecretString --output text) \
  myapp:latest

# Kubernetes secrets
kubectl create secret generic db-secret --from-literal=password=secret
```

### Environment Variable Security

```bash
# Avoid secrets in environment variables
# BAD: docker run -e DB_PASSWORD=secret myapp
# GOOD: Use secrets management or files

# Use secret files instead
docker run -v /host/secrets:/secrets:ro myapp

# Runtime secret injection
docker run --env-file <(generate-secrets.sh) myapp
```

## Compliance and Auditing

### Security Benchmarks

```bash
# CIS Docker Benchmark
# Download and run CIS benchmark script
wget https://github.com/docker/docker-bench-security/archive/master.zip
unzip master.zip
cd docker-bench-security-master
sudo sh docker-bench-security.sh

# NIST guidelines compliance
# Implement NIST Cybersecurity Framework
# Regular security assessments
```

### Logging and Monitoring

```bash
# Enable audit logging
dockerd --log-driver=syslog --log-opt syslog-address=tcp://log-server:514

# Container logging
docker run --log-driver=fluentd --log-opt fluentd-address=localhost:24224 myapp

# Security event monitoring
docker events --filter event=start --filter event=stop
docker events --filter container=webapp --filter event=exec
```

### Vulnerability Management

```bash
# Regular image scanning
# Automated CI/CD pipeline scanning
# Vulnerability database updates

# Example CI/CD security pipeline
#!/bin/bash
# Build image
docker build -t myapp:$BUILD_ID .

# Scan for vulnerabilities
trivy image --exit-code 1 --severity HIGH,CRITICAL myapp:$BUILD_ID

# Security tests
docker run --rm -v $(pwd):/app myapp:$BUILD_ID npm audit

# Deploy only if secure
if [ $? -eq 0 ]; then
  docker push myapp:$BUILD_ID
fi
```

## Advanced Security

### AppArmor Profiles

```bash
# Create AppArmor profile
cat > nginx-profile << EOF
#include <tunables/global>

profile nginx-profile flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  
  capability setuid,
  capability setgid,
  capability net_bind_service,
  
  /usr/sbin/nginx mr,
  /etc/nginx/** r,
  /var/log/nginx/** w,
  /var/run/nginx.pid w,
  
  deny /proc/sys/** w,
  deny /sys/** w,
}
EOF

# Load profile
sudo apparmor_parser -r -W nginx-profile

# Use profile
docker run --security-opt apparmor:nginx-profile nginx
```

### SELinux Configuration

```bash
# SELinux labels for containers
docker run --security-opt label=type:container_t nginx

# Custom SELinux policy
# Create .te policy file
# Compile and load policy
# Apply to containers
```

### Seccomp Profiles

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": ["read", "write", "open", "close", "stat", "fstat"],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": ["chmod", "chown"],
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
```

```bash
# Use seccomp profile
docker run --security-opt seccomp:profile.json nginx
```

## Security Automation

### Automated Security Scanning

```yaml
# GitHub Actions security workflow
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build image
        run: docker build -t myapp .
        
      - name: Run Trivy scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp
          format: sarif
          output: trivy-results.sarif
          
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: trivy-results.sarif
```

### Runtime Security Monitoring

```bash
# Falco for runtime security
docker run -d \
  --name falco \
  --privileged \
  -v /var/run/docker.sock:/host/var/run/docker.sock \
  -v /dev:/host/dev \
  -v /proc:/host/proc:ro \
  -v /boot:/host/boot:ro \
  -v /lib/modules:/host/lib/modules:ro \
  -v /usr:/host/usr:ro \
  falcosecurity/falco:latest

# Custom Falco rules for container security
```

## Production Security

### Security Checklist

```bash
# Image Security
☐ Use minimal base images
☐ Scan images for vulnerabilities
☐ Use specific image tags
☐ Implement multi-stage builds
☐ Run as non-root user

# Runtime Security
☐ Enable read-only filesystem
☐ Drop unnecessary capabilities
☐ Set resource limits
☐ Use security profiles
☐ Enable audit logging

# Network Security
☐ Use custom networks
☐ Implement network segmentation
☐ Configure firewall rules
☐ Enable TLS encryption
☐ Monitor network traffic

# Secrets Management
☐ Use external secrets management
☐ Avoid secrets in environment variables
☐ Rotate secrets regularly
☐ Encrypt secrets at rest
☐ Audit secret access
```

### Incident Response

```bash
# Container forensics
docker diff <container>              # Show filesystem changes
docker logs <container>              # Check logs
docker exec <container> ps aux       # Check processes
docker inspect <container>           # Get detailed info

# Security incident containment
docker stop <compromised_container>
docker network disconnect <network> <container>
docker exec <container> netstat -tulpn

# Evidence collection
docker commit <container> evidence:$(date +%Y%m%d)
docker save evidence:$(date +%Y%m%d) > evidence.tar
```

## Security Tools Integration

### Popular Security Tools

```bash
# Anchore Engine
anchore-cli image add myapp:latest
anchore-cli image wait myapp:latest
anchore-cli image vuln myapp:latest all

# Clair
clairctl analyze myapp:latest
clairctl report myapp:latest

# Twistlock/Prisma Cloud
twistcli images scan myapp:latest

# Aqua Security
scannercli scan myapp:latest
```

### CI/CD Security Integration

```bash
# Jenkins pipeline security
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
            }
        }
        stage('Security Scan') {
            steps {
                sh 'trivy image --exit-code 1 myapp:${BUILD_NUMBER}'
                sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy myapp:${BUILD_NUMBER}'
            }
        }
        stage('Deploy') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh 'docker push myapp:${BUILD_NUMBER}'
            }
        }
    }
}
```