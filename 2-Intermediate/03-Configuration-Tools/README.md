# 🔧 Configuration Management Tools

This directory contains all configuration management and Infrastructure as Code (IaC) tools for the Intermediate level.

---

## 📂 Tools Overview

### 🏗️ Infrastructure as Code
- **[01-Terraform](./01-Terraform/README.md)**: Infrastructure provisioning and lifecycle management
- **[05-Cloud-Init](./05-Cloud-Init/)**: Cloud instance initialization and configuration
- **[09-Packer](./09-Packer/README.md)**: Automated machine image building
- **[11-Pulumi](./11-Pulumi/README.md)**: Modern IaC with programming languages

### ⚙️ Configuration Management  
- **[02-Ansible](./02-Ansible/README.md)**: Agentless configuration management and automation
- **[03-Chef](./03-Chef/README.md)**: Infrastructure automation with Ruby DSL
- **[07-Puppet](./07-Puppet/README.md)**: Enterprise configuration management platform
- **[08-SaltStack](./08-SaltStack/README.md)**: Event-driven infrastructure automation

### 📦 Container & Application Configuration
- **[04-Helm](./04-Helm/README.md)**: Kubernetes package manager and templating
- **[06-Kustomize](Kustomize.md)**: Kubernetes native configuration management

### 🏠 Development Environment Management
- **[10-Vagrant](./10-Vagrant/README.md)**: Development environment automation

---

## 🎯 Learning Path
1. **Terraform** - Learn infrastructure provisioning fundamentals
2. **Ansible** - Master agentless configuration management  
3. **Chef** - Enterprise-grade automation patterns
4. **Helm** - Package Kubernetes applications
5. **Cloud-Init** - Cloud-native initialization
6. **Kustomize** - Kubernetes-native configuration
7. **Puppet** - Enterprise configuration management
8. **SaltStack** - Event-driven automation
9. **Packer** - Automated image building
10. **Vagrant** - Development environment consistency
11. **Pulumi** - Modern IaC with programming languages

---

## 🔄 Tool Integration Matrix

| Use Case | Primary Tool | Secondary Tool | Integration Pattern |
|----------|--------------|----------------|--------------------|
| **Infrastructure + Config** | Terraform | Ansible | Terraform provisions → Ansible configures |
| **Container Apps** | Helm | Kustomize | Helm for packaging → Kustomize for customization |
| **Image Building** | Packer | Ansible/Chef | Packer builds → Config tools provision |
| **Development** | Vagrant | Docker | Vagrant for VMs → Docker for containers |
| **Enterprise Config** | Puppet/Chef | SaltStack | Traditional config → Event-driven automation |
| **Modern IaC** | Pulumi | Terraform | Programming languages → HCL migration |

---

**Return to**: [Intermediate Level](../README.md)