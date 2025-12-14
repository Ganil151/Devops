# ArgoCD Fundamentals

Complete introduction to ArgoCD, GitOps principles, and continuous deployment concepts.

## What is ArgoCD?

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state.

### Key Features
- **Declarative GitOps**: Git as single source of truth
- **Application Management**: Deploy and manage applications
- **Multi-Cluster Support**: Manage multiple Kubernetes clusters
- **Web UI & CLI**: Rich interfaces for management
- **RBAC Integration**: Role-based access control
- **SSO Integration**: Single sign-on support

## GitOps Principles

### Core Concepts
```yaml
# GitOps Workflow
Source Code → Git Repository → ArgoCD → Kubernetes Cluster

# Key Principles:
# 1. Declarative - System state described declaratively
# 2. Versioned - All changes tracked in Git
# 3. Immutable - No direct cluster modifications
# 4. Pulled - ArgoCD pulls changes from Git
```

### Benefits of GitOps
- **Version Control**: All changes tracked and auditable
- **Rollback Capability**: Easy rollback to previous states
- **Consistency**: Same deployment process across environments
- **Security**: No direct cluster access needed
- **Collaboration**: Git-based workflow for teams

## ArgoCD Architecture

### Core Components
```
┌─────────────────────────────────────────────────────────┐
│                    ArgoCD Architecture                   │
│                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │   Git Repo  │    │   ArgoCD    │    │ Kubernetes  │ │
│  │             │◄───│   Server    │───►│   Cluster   │ │
│  │ - Manifests │    │             │    │             │ │
│  │ - Helm      │    │ - API       │    │ - Apps      │ │
│  │ - Kustomize │    │ - UI        │    │ - Resources │ │
│  └─────────────┘    │ - Controller│    └─────────────┘ │
│                     └─────────────┘                    │
│                                                         │
│  ┌─────────────┐    ┌─────────────┐                    │
│  │   ArgoCD    │    │  Repository │                    │
│  │    CLI      │    │   Server    │                    │
│  │             │    │             │                    │
│  └─────────────┘    └─────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

### Component Details

#### ArgoCD Server
- **API Server**: REST API for all operations
- **Web UI**: Browser-based management interface
- **gRPC Server**: CLI and UI communication
- **Authentication**: User authentication and RBAC

#### Application Controller
- **Sync Engine**: Monitors Git and applies changes
- **Health Assessment**: Checks application health
- **Drift Detection**: Identifies configuration drift
- **Reconciliation**: Ensures desired state

#### Repository Server
- **Git Integration**: Clones and monitors repositories
- **Manifest Generation**: Processes Helm, Kustomize, etc.
- **Caching**: Caches repository data for performance
- **Credential Management**: Handles repository access

## Application Lifecycle

### Application States
```yaml
# Application Sync Status
Synced:     # Git matches cluster state
OutOfSync:  # Git differs from cluster state
Unknown:    # Cannot determine sync status

# Application Health Status
Healthy:    # All resources running correctly
Progressing: # Deployment in progress
Degraded:   # Some resources unhealthy
Suspended:  # Application suspended
Missing:    # Resources not found
Unknown:    # Cannot determine health
```

### Sync Strategies
```yaml
# Manual Sync
sync_policy:
  automated: false
  # Requires manual intervention to sync

# Automatic Sync
sync_policy:
  automated:
    prune: true      # Delete resources not in Git
    selfHeal: true   # Correct drift automatically
    allowEmpty: false # Prevent empty sync
```

## Basic Concepts

### Applications
```yaml
# ArgoCD Application Definition
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/app-config
    targetRevision: HEAD
    path: k8s-manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Projects
```yaml
# ArgoCD Project Definition
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: my-project
  namespace: argocd
spec:
  description: "My Application Project"
  sourceRepos:
  - 'https://github.com/company/*'
  destinations:
  - namespace: 'my-app-*'
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  namespaceResourceWhitelist:
  - group: 'apps'
    kind: Deployment
  - group: ''
    kind: Service
```

### Repositories
```yaml
# Repository Configuration
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/company/private-repo
  password: my-password
  username: my-username
```

## Deployment Patterns

### Basic Deployment Flow
```bash
# 1. Developer commits code changes
git add .
git commit -m "Update application version"
git push origin main

# 2. ArgoCD detects changes
# 3. ArgoCD syncs changes to cluster
# 4. Application is updated automatically
```

### Multi-Environment Pattern
```
Repository Structure:
├── environments/
│   ├── dev/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   └── production/
│       ├── kustomization.yaml
│       └── patches/
└── base/
    ├── deployment.yaml
    ├── service.yaml
    └── kustomization.yaml
```

## Getting Started Workflow

### 1. Prepare Git Repository
```bash
# Create application manifests
mkdir my-app-config
cd my-app-config

# Create basic Kubernetes manifests
cat > deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:1.20
        ports:
        - containerPort: 80
EOF

# Commit to Git
git init
git add .
git commit -m "Initial application manifests"
git remote add origin https://github.com/username/my-app-config
git push -u origin main
```

### 2. Create ArgoCD Application
```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/username/my-app-config
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### 3. Deploy Application
```bash
# Apply application to ArgoCD
kubectl apply -f application.yaml

# Check application status
argocd app get my-app

# Sync application manually (if not automated)
argocd app sync my-app
```

## Common Use Cases

### Continuous Deployment
```yaml
# Automated deployment pipeline
Developer → Git Push → ArgoCD Sync → Kubernetes Deploy

# Benefits:
# - Automatic deployments
# - Consistent environments
# - Audit trail in Git
# - Easy rollbacks
```

### Configuration Management
```yaml
# Centralized configuration
# - All configs in Git
# - Environment-specific values
# - Secret management
# - Policy enforcement
```

### Multi-Cluster Management
```yaml
# Single ArgoCD managing multiple clusters
# - Development cluster
# - Staging cluster  
# - Production cluster
# - DR cluster
```

## Best Practices for Beginners

### Repository Organization
```bash
# Recommended structure
app-config/
├── README.md
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── helm-charts/
    └── my-app/
```

### Application Naming
```yaml
# Use consistent naming conventions
# Format: <app-name>-<environment>
# Examples:
# - web-app-dev
# - api-service-prod
# - database-staging
```

### Sync Policies
```yaml
# Start with manual sync for learning
syncPolicy:
  automated: false

# Progress to automated sync
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

This comprehensive guide provides the foundation for understanding ArgoCD and GitOps principles essential for continuous deployment workflows.