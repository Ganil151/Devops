# ArgoCD GitOps

Comprehensive guide to ArgoCD installation, configuration, and GitOps continuous delivery for Kubernetes.

## ArgoCD Overview

### What is ArgoCD?
ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes that follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state.

### Key Features
- **GitOps Workflow**: Git as single source of truth
- **Kubernetes Native**: Built specifically for Kubernetes
- **Multi-Cluster Support**: Manage multiple clusters
- **Web UI**: Rich graphical interface
- **CLI Tool**: Command-line management
- **RBAC**: Role-based access control
- **SSO Integration**: LDAP, OIDC, SAML support

## Directory Structure

```bash
ArgoCD/
├── Installation/           # Setup and configuration
├── Applications/          # Application management
├── Projects/              # Project organization
├── Repositories/          # Git repository integration
├── Clusters/              # Multi-cluster management
├── Security/              # RBAC and authentication
├── Monitoring/            # Observability and alerts
├── Sync-Policies/         # Synchronization strategies
├── Helm-Integration/      # Helm chart management
├── Best-Practices/        # Production guidelines
└── Troubleshooting/       # Common issues and solutions
```

## Quick Start

### Installation
```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Access ArgoCD UI
```bash
# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at https://localhost:8080
# Username: admin
# Password: <from previous step>
```

## Core Concepts

### Applications
- Kubernetes resources managed by ArgoCD
- Defined by source (Git repo) and destination (cluster/namespace)
- Continuous monitoring and synchronization

### Projects
- Logical grouping of applications
- Define source repositories and destination clusters
- RBAC boundaries

### Repositories
- Git repositories containing application manifests
- Support for public and private repositories
- Multiple authentication methods

This comprehensive ArgoCD guide provides enterprise-ready GitOps automation capabilities.