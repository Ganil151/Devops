# ArgoCD Helm Integration

Helm chart management, deployment patterns, and best practices in ArgoCD.

## Helm Applications

### Basic Helm Application
```yaml
# helm-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-helm
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: nginx
    targetRevision: 13.2.23
    helm:
      values: |
        replicaCount: 3
        service:
          type: LoadBalancer
        ingress:
          enabled: true
          hostname: nginx.example.com
  destination:
    server: https://kubernetes.default.svc
    namespace: nginx
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### Helm with External Values
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-with-values
spec:
  sources:
  - repoURL: https://charts.example.com
    chart: myapp
    targetRevision: 2.1.0
    helm:
      valueFiles:
      - $values/production/values.yaml
      - $values/production/secrets.yaml
  - repoURL: https://github.com/user/helm-values
    targetRevision: HEAD
    ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

## Helm Parameters

### Value Overrides
```yaml
spec:
  source:
    helm:
      parameters:
      - name: image.tag
        value: v1.2.3
      - name: replicaCount
        value: "5"
      - name: service.type
        value: ClusterIP
      values: |
        ingress:
          enabled: true
          annotations:
            kubernetes.io/ingress.class: nginx
            cert-manager.io/cluster-issuer: letsencrypt
          hosts:
          - host: myapp.example.com
            paths:
            - path: /
              pathType: Prefix
```

### File Parameters
```yaml
spec:
  source:
    helm:
      valueFiles:
      - values-production.yaml
      - secrets.yaml
      fileParameters:
      - name: config.ssl.cert
        path: certs/tls.crt
      - name: config.ssl.key
        path: certs/tls.key
```

## Helm Hooks Integration

### ArgoCD + Helm Hooks
```yaml
# pre-install-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-install-setup
  annotations:
    # Helm hook
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
    # ArgoCD sync wave
    argocd.argoproj.io/sync-wave: "-1"
spec:
  template:
    spec:
      containers:
      - name: setup
        image: alpine:latest
        command: ["sh", "-c", "echo 'Pre-install setup complete'"]
      restartPolicy: Never
```

## Helm Repository Management

### Private Helm Repositories
```yaml
# helm-repo-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-helm-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: helm
  name: private-charts
  url: https://charts.private.com
  username: myuser
  password: mytoken
```

### OCI Helm Repositories
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: oci-helm-app
spec:
  source:
    repoURL: oci://registry.example.com/charts
    chart: myapp
    targetRevision: 1.0.0
    helm:
      values: |
        image:
          repository: registry.example.com/myapp
          tag: v1.0.0
```

## Helm Best Practices

### Version Pinning
```yaml
spec:
  source:
    chart: nginx
    targetRevision: "=13.2.23"  # Exact version
    # targetRevision: "~13.2.0"   # Patch updates only
    # targetRevision: "^13.0.0"   # Minor updates allowed
```

### Values Validation
```yaml
# values-schema.json in Helm chart
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "replicaCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10
    },
    "image": {
      "type": "object",
      "properties": {
        "tag": {
          "type": "string",
          "pattern": "^v[0-9]+\\.[0-9]+\\.[0-9]+$"
        }
      },
      "required": ["tag"]
    }
  },
  "required": ["replicaCount", "image"]
}
```

### Helm Diff Plugin
```bash
# Install helm diff plugin for ArgoCD
kubectl patch configmap argocd-cm -n argocd --patch '
data:
  application.instanceLabelKey: argocd.argoproj.io/instance
  helm.valuesFileSchemes: >-
    secrets+gpg-import, secrets+gpg-import-kubernetes,
    secrets+age-import, secrets+age-import-kubernetes,
    secrets, secrets+literal,
    https
'
```

This guide covers comprehensive ArgoCD Helm integration and chart management strategies.