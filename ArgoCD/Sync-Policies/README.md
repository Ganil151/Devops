# ArgoCD Sync Policies

Synchronization strategies, policies, and automation patterns in ArgoCD.

## Sync Policy Types

### Manual Sync
```yaml
# No automated sync - manual only
spec:
  syncPolicy: {}
```

### Automated Sync
```yaml
spec:
  syncPolicy:
    automated:
      prune: true      # Delete resources not in Git
      selfHeal: true   # Revert manual changes
      allowEmpty: false # Prevent empty sync
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
```

### Conditional Sync
```yaml
spec:
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ApplyOutOfSyncOnly=true  # Only sync out-of-sync resources
    - RespectIgnoreDifferences=true
```

## Sync Windows

### Maintenance Windows
```yaml
spec:
  syncPolicy:
    syncWindows:
    - kind: allow
      schedule: "0 2 * * 1-5"  # Weekdays 2 AM
      duration: 4h
      applications:
      - production-*
      manualSync: true
    - kind: deny
      schedule: "0 18 * * 5"   # Friday 6 PM
      duration: 60h            # Until Monday 6 AM
      applications:
      - production-*
```

### Emergency Override
```yaml
spec:
  syncPolicy:
    syncWindows:
    - kind: allow
      schedule: "* * * * *"
      duration: 1h
      applications:
      - emergency-fix
      manualSync: true
      clusters:
      - production-cluster
```

## Resource Hooks

### Pre-Sync Hooks
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
    argocd.argoproj.io/sync-wave: "-1"
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: migrate/migrate
        command: ["migrate", "-path", "/migrations", "up"]
      restartPolicy: Never
```

### Post-Sync Hooks
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: smoke-test
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
    argocd.argoproj.io/sync-wave: "1"
spec:
  template:
    spec:
      containers:
      - name: test
        image: curlimages/curl
        command: ["curl", "-f", "http://myapp/health"]
      restartPolicy: Never
```

## Sync Waves

### Ordered Deployment
```yaml
# Database (wave -2)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  annotations:
    argocd.argoproj.io/sync-wave: "-2"
spec:
  # ... database deployment spec

---
# Application (wave -1)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
spec:
  # ... backend deployment spec

---
# Frontend (wave 0 - default)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  # ... frontend deployment spec
```

## Ignore Differences

### Resource-Specific Ignores
```yaml
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

### JQ Path Ignores
```yaml
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jqPathExpressions:
    - '.spec.template.spec.containers[]?.env[]? | select(.name == "DYNAMIC_VAR")'
```

This guide covers comprehensive ArgoCD synchronization policies and automation strategies.