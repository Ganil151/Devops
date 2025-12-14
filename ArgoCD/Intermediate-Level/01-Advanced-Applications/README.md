# Advanced ArgoCD Applications

Comprehensive guide to complex application patterns, ApplicationSets, and advanced deployment strategies in ArgoCD.

## ApplicationSets

### What are ApplicationSets?
ApplicationSets provide a way to automatically generate ArgoCD Applications based on templates and generators, enabling multi-cluster and multi-environment deployments at scale.

### Basic ApplicationSet Structure
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-env-app
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - cluster: dev
        url: https://dev-cluster.example.com
        namespace: myapp-dev
      - cluster: staging  
        url: https://staging-cluster.example.com
        namespace: myapp-staging
      - cluster: prod
        url: https://prod-cluster.example.com
        namespace: myapp-prod
  template:
    metadata:
      name: 'myapp-{{cluster}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/company/myapp-config
        targetRevision: HEAD
        path: 'environments/{{cluster}}'
      destination:
        server: '{{url}}'
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

## ApplicationSet Generators

### List Generator
```yaml
# Static list of environments/clusters
generators:
- list:
    elements:
    - env: development
      cluster: dev-cluster
      replicas: "1"
      image_tag: latest
    - env: production
      cluster: prod-cluster
      replicas: "3"
      image_tag: stable
```

### Cluster Generator
```yaml
# Generate applications for all registered clusters
generators:
- clusters:
    selector:
      matchLabels:
        environment: production
    values:
      revision: stable
      namespace: myapp
```

### Git Generator
```yaml
# Generate applications based on Git repository structure
generators:
- git:
    repoURL: https://github.com/company/app-configs
    revision: HEAD
    directories:
    - path: apps/*
    - path: environments/*/apps/*
      exclude: environments/*/apps/excluded-app
```

### Matrix Generator
```yaml
# Combine multiple generators
generators:
- matrix:
    generators:
    - git:
        repoURL: https://github.com/company/apps
        revision: HEAD
        directories:
        - path: apps/*
    - clusters:
        selector:
          matchLabels:
            environment: production
```

## Progressive Delivery Patterns

### Blue-Green Deployment
```yaml
# Blue-Green ApplicationSet
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: blue-green-deployment
spec:
  generators:
  - list:
      elements:
      - color: blue
        weight: "100"
        active: "true"
      - color: green
        weight: "0"
        active: "false"
  template:
    metadata:
      name: 'myapp-{{color}}'
    spec:
      source:
        repoURL: https://github.com/company/myapp
        path: k8s
        helm:
          parameters:
          - name: image.tag
            value: '{{color}}-latest'
          - name: service.weight
            value: '{{weight}}'
          - name: deployment.active
            value: '{{active}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: myapp
```

### Canary Deployment with Argo Rollouts
```yaml
# Canary deployment configuration
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp-rollout
spec:
  replicas: 10
  strategy:
    canary:
      steps:
      - setWeight: 10
      - pause: {duration: 30s}
      - setWeight: 20
      - pause: {duration: 30s}
      - setWeight: 50
      - pause: {duration: 30s}
      - setWeight: 100
      canaryService: myapp-canary
      stableService: myapp-stable
      trafficRouting:
        nginx:
          stableIngress: myapp-stable
          annotationPrefix: nginx.ingress.kubernetes.io
          additionalIngressAnnotations:
            canary-by-header: X-Canary
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        ports:
        - containerPort: 8080
```

## Advanced Application Configurations

### Multi-Source Applications
```yaml
# Application with multiple sources
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-source-app
spec:
  sources:
  - repoURL: https://github.com/company/app-manifests
    path: base
    targetRevision: HEAD
  - repoURL: https://github.com/company/app-config
    path: overlays/production
    targetRevision: HEAD
  - repoURL: https://helm-charts.company.com
    chart: monitoring
    targetRevision: 1.2.3
    helm:
      values: |
        prometheus:
          enabled: true
        grafana:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
```

### Resource Hooks and Lifecycle
```yaml
# Pre-sync hook example
apiVersion: batch/v1
kind: Job
metadata:
  name: database-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: migrate/migrate
        command: ["migrate", "-path", "/migrations", "-database", "postgres://...", "up"]
      restartPolicy: Never
---
# Post-sync hook example  
apiVersion: batch/v1
kind: Job
metadata:
  name: smoke-test
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: test
        image: curlimages/curl
        command: ["curl", "-f", "http://myapp-service/health"]
      restartPolicy: Never
```

### Sync Waves
```yaml
# Database deployment (Wave 0)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  # Database deployment spec
---
# Application deployment (Wave 1)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: application
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  # Application deployment spec
---
# Ingress configuration (Wave 2)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: application-ingress
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  # Ingress spec
```

## Application Health Assessment

### Custom Health Checks
```yaml
# Custom resource health check
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  resource.customizations.health.mycompany.io_MyResource: |
    hs = {}
    if obj.status ~= nil then
      if obj.status.phase == "Running" then
        hs.status = "Healthy"
        hs.message = "Resource is running"
      elseif obj.status.phase == "Failed" then
        hs.status = "Degraded"
        hs.message = "Resource failed"
      else
        hs.status = "Progressing"
        hs.message = "Resource is starting"
      end
    end
    return hs
```

### Health Check Annotations
```yaml
# Skip health check for specific resources
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
data:
  config.yaml: |
    # Configuration data
---
# Custom health check timeout
apiVersion: apps/v1
kind: Deployment
metadata:
  name: slow-starting-app
  annotations:
    argocd.argoproj.io/sync-options: HealthCheckGracePeriod=300
spec:
  # Deployment spec
```

## Application Dependencies

### Inter-Application Dependencies
```yaml
# Parent application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: database-app
spec:
  # Database application spec
---
# Dependent application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web-app
  annotations:
    argocd.argoproj.io/sync-options: WaitForCompletion=true
spec:
  # Web application spec that depends on database
```

### Resource Dependencies with Sync Waves
```yaml
# Namespace creation (Wave -1)
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
---
# Secret creation (Wave 0)
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: myapp
  annotations:
    argocd.argoproj.io/sync-wave: "0"
data:
  # Secret data
---
# ConfigMap creation (Wave 0)
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: myapp
  annotations:
    argocd.argoproj.io/sync-wave: "0"
data:
  # Config data
---
# Application deployment (Wave 1)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: myapp
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  # Deployment that uses secrets and config
```

## Advanced Sync Options

### Selective Sync
```yaml
# Sync only specific resources
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: selective-sync-app
spec:
  syncPolicy:
    syncOptions:
    - ApplyOutOfSyncOnly=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
  # Application spec
```

### Replace and Force Sync
```yaml
# Force replacement of resources
apiVersion: apps/v1
kind: Deployment
metadata:
  name: force-replace-app
  annotations:
    argocd.argoproj.io/sync-options: Replace=true,Force=true
spec:
  # Deployment spec
```

### Ignore Differences
```yaml
# Ignore specific fields during sync
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ignore-differences-app
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
  - group: ""
    kind: Service
    managedFieldsManagers:
    - kube-controller-manager
```

## Application Monitoring and Observability

### Application Metrics
```yaml
# Enable application metrics
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitored-app
  annotations:
    argocd.argoproj.io/tracking-id: myapp-v1.0.0
spec:
  # Application spec with monitoring enabled
```

### Custom Application Labels
```yaml
# Application with custom labels for monitoring
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: labeled-app
  labels:
    team: platform
    environment: production
    version: v1.2.3
    cost-center: engineering
spec:
  # Application spec
```

This comprehensive guide covers advanced ArgoCD application patterns essential for complex deployment scenarios and enterprise-scale GitOps workflows.