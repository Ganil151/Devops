# ArgoCD Applications

Application management, deployment patterns, and lifecycle management in ArgoCD.

## Application Basics

### Creating Applications
```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/user/myapp
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### CLI Application Management
```bash
# Create application
argocd app create myapp \
  --repo https://github.com/user/myapp \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace production

# Sync application
argocd app sync myapp

# Get application status
argocd app get myapp

# Delete application
argocd app delete myapp
```

## Sync Strategies

### Manual Sync
```yaml
spec:
  syncPolicy: {}  # No automated sync
```

### Automated Sync
```yaml
spec:
  syncPolicy:
    automated:
      prune: true      # Delete resources not in Git
      selfHeal: true   # Revert manual changes
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
```

### Sync Windows
```yaml
spec:
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
    automated:
      prune: true
      selfHeal: true
    syncWindows:
    - kind: allow
      schedule: "0 9 * * 1-5"  # Weekdays 9 AM
      duration: 8h
      applications:
      - myapp
```

## Multi-Source Applications
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-source-app
spec:
  sources:
  - repoURL: https://github.com/user/app-config
    path: overlays/production
    targetRevision: HEAD
  - repoURL: https://github.com/user/app-manifests
    path: base
    targetRevision: v1.0.0
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

This guide covers comprehensive ArgoCD application management and deployment strategies.