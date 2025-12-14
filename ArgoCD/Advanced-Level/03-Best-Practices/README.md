# ArgoCD Best Practices

Production-ready guidelines, patterns, and optimization strategies for ArgoCD GitOps workflows.

## Repository Structure

### Recommended Layout
```bash
# Application repository structure
app-repo/
├── apps/
│   ├── production/
│   │   ├── app1/
│   │   └── app2/
│   └── staging/
│       ├── app1/
│       └── app2/
├── projects/
│   ├── production.yaml
│   └── staging.yaml
└── bootstrap/
    └── root-app.yaml
```

### App of Apps Pattern
```yaml
# root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/argocd-apps
    targetRevision: HEAD
    path: apps/production
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Application Management

### Environment Promotion
```bash
# Staging environment
apps/staging/myapp/
├── kustomization.yaml
├── deployment.yaml
└── service.yaml

# Production environment  
apps/production/myapp/
├── kustomization.yaml
├── deployment.yaml
└── service.yaml
```

### Resource Hooks
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: migrate/migrate
        command: ["migrate", "-path", "/migrations", "up"]
      restartPolicy: Never
```

## Security Best Practices

### Least Privilege Access
```yaml
# Minimal project permissions
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-a
spec:
  sourceRepos:
  - 'https://github.com/company/team-a-*'
  destinations:
  - namespace: 'team-a-*'
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

### Secret Management
```yaml
# External Secrets Operator integration
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: secret/myapp
      property: password
```

## Performance Optimization

### Resource Limits
```yaml
# ArgoCD server resource limits
spec:
  template:
    spec:
      containers:
      - name: argocd-server
        resources:
          limits:
            cpu: 500m
            memory: 256Mi
          requests:
            cpu: 250m
            memory: 128Mi
```

### Sync Optimization
```yaml
spec:
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    - RespectIgnoreDifferences=true
    - ApplyOutOfSyncOnly=true
```

This guide provides enterprise-grade ArgoCD best practices for production GitOps workflows.