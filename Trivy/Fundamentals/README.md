# Trivy Fundamentals

Essential concepts and basic usage of Trivy security scanner.

## Contents

- **[trivy-fundamentals-guide.md](./trivy-fundamentals-guide.md)** - Complete fundamentals guide covering:
  - What is Trivy and core capabilities
  - Installation across different platforms
  - Basic commands and scanning types
  - Output formats and configuration
  - Essential examples for getting started

## Learning Objectives

After completing this section, you will understand:
- How to install and configure Trivy
- Basic scanning commands for different targets
- How to interpret scan results
- Configuration options and customization
- Output formats for different use cases

## Quick Start

```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Basic scans
trivy image nginx:latest          # Scan container image
trivy fs .                        # Scan filesystem
trivy repo https://github.com/user/repo  # Scan repository
```

## Next Steps

- Explore [Container Scanning](../Container-Scanning/) for Docker security
- Learn [Infrastructure Scanning](../Infrastructure-Scanning/) for IaC security
- Implement [CI/CD Integration](../CI-CD-Integration/) for automated scanning