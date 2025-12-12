# Trivy Fundamentals Guide

## Table of Contents
1. [What is Trivy](#what-is-trivy)
2. [Installation](#installation)
3. [Basic Commands](#basic-commands)
4. [Scanning Types](#scanning-types)
5. [Output Formats](#output-formats)
6. [Configuration](#configuration)

## What is Trivy

Trivy is a comprehensive security scanner for containers, infrastructure, and code repositories.

### Key Features
- **Multi-target scanning**: Images, filesystems, repositories, Kubernetes
- **Multi-format support**: Docker, OCI, Tar archives
- **Vulnerability detection**: OS packages, language dependencies
- **Misconfiguration detection**: IaC, Kubernetes, Docker
- **Secret detection**: API keys, passwords, tokens
- **SBOM support**: Generate and analyze Software Bill of Materials

## Installation

### Linux/macOS
```bash
# Install script
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Homebrew
brew install trivy

# APT (Debian/Ubuntu)
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

### Docker
```bash
# Run Trivy in Docker
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy:latest image nginx

# Scan local directory
docker run --rm -v "$PWD":/workspace aquasec/trivy:latest fs /workspace
```

## Basic Commands

### Image Scanning
```bash
# Scan Docker image
trivy image nginx:latest

# Scan with specific severity
trivy image --severity HIGH,CRITICAL nginx:latest

# Scan and exit with error on vulnerabilities
trivy image --exit-code 1 nginx:latest

# Scan private registry
trivy image --username user --password pass registry.example.com/image:tag
```

### Filesystem Scanning
```bash
# Scan current directory
trivy fs .

# Scan specific directory
trivy fs /path/to/project

# Skip specific directories
trivy fs --skip-dirs node_modules,vendor .
```

### Repository Scanning
```bash
# Scan remote repository
trivy repo https://github.com/user/repo

# Scan local repository
trivy repo .

# Scan specific branch
trivy repo --branch main https://github.com/user/repo
```

## Scanning Types

### Vulnerability Scanning
```bash
# OS packages only
trivy image --vuln-type os nginx:latest

# Language libraries only
trivy image --vuln-type library nginx:latest

# Both OS and libraries
trivy image --vuln-type os,library nginx:latest
```

### Configuration Scanning
```bash
# Scan IaC files
trivy config .

# Scan Kubernetes manifests
trivy config k8s-manifests/

# Scan Terraform files
trivy config terraform/

# Scan Dockerfile
trivy config --file-patterns dockerfile:Dockerfile .
```

### Secret Scanning
```bash
# Enable secret detection
trivy fs --scanners secret .

# Combine vulnerability and secret scanning
trivy fs --scanners vuln,secret .

# Custom secret patterns
trivy fs --secret-config secret-config.yaml .
```

## Output Formats

### JSON Output
```bash
# JSON format
trivy image --format json nginx:latest

# Save to file
trivy image --format json --output result.json nginx:latest

# Pretty JSON
trivy image --format json nginx:latest | jq .
```

### SARIF Output
```bash
# SARIF format for GitHub
trivy image --format sarif --output trivy-results.sarif nginx:latest
```

### Template Output
```bash
# HTML report
trivy image --format template --template "@contrib/html.tpl" --output report.html nginx:latest

# Custom template
trivy image --format template --template "@custom.tpl" nginx:latest
```

## Configuration

### Configuration File
```yaml
# trivy.yaml
format: json
output: trivy-results.json
severity:
  - HIGH
  - CRITICAL
vulnerability:
  type:
    - os
    - library
secret:
  config: secret-config.yaml
```

### Environment Variables
```bash
# Cache directory
export TRIVY_CACHE_DIR=/tmp/trivy

# Skip database update
export TRIVY_SKIP_UPDATE=true

# Timeout
export TRIVY_TIMEOUT=10m

# Debug mode
export TRIVY_DEBUG=true
```

### Ignore Files
```bash
# .trivyignore
CVE-2019-1234
CVE-2020-5678

# Ignore specific paths
/path/to/ignore/**
*.test.js
```

## Basic Examples

### CI/CD Pipeline Check
```bash
#!/bin/bash
# Basic security check script

echo "Scanning Docker image..."
trivy image --exit-code 1 --severity HIGH,CRITICAL myapp:latest

echo "Scanning source code..."
trivy fs --exit-code 1 --severity HIGH,CRITICAL .

echo "Scanning infrastructure..."
trivy config --exit-code 1 .

echo "Security scan completed successfully!"
```

### Multi-format Report
```bash
#!/bin/bash
# Generate multiple report formats

IMAGE="nginx:latest"

# JSON report
trivy image --format json --output vulnerability-report.json $IMAGE

# SARIF for GitHub
trivy image --format sarif --output trivy-results.sarif $IMAGE

# HTML report
trivy image --format template --template "@contrib/html.tpl" --output security-report.html $IMAGE

echo "Reports generated: vulnerability-report.json, trivy-results.sarif, security-report.html"
```