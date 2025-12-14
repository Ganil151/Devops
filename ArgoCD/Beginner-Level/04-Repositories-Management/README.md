# ArgoCD Repositories

Git repository integration, authentication, and management in ArgoCD.

## Repository Configuration

### Public Repositories
```bash
# Add public repository
argocd repo add https://github.com/user/public-repo

# List repositories
argocd repo list
```

### Private Repositories

#### SSH Key Authentication
```bash
# Generate SSH key
ssh-keygen -t ed25519 -f ~/.ssh/argocd_rsa

# Add repository with SSH key
argocd repo add git@github.com:user/private-repo.git \
  --ssh-private-key-path ~/.ssh/argocd_rsa
```

#### HTTPS Authentication
```bash
# Add repository with username/password
argocd repo add https://github.com/user/private-repo.git \
  --username myuser \
  --password mytoken

# Add repository with token
argocd repo add https://github.com/user/private-repo.git \
  --username oauth2 \
  --password ghp_xxxxxxxxxxxx
```

### Repository Secrets
```yaml
# repository-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/user/private-repo
  username: myuser
  password: mytoken
```

## Multi-Repository Applications

### Kustomize with Multiple Sources
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-repo-app
spec:
  sources:
  - repoURL: https://github.com/user/base-manifests
    path: base
    targetRevision: HEAD
  - repoURL: https://github.com/user/environment-configs
    path: overlays/production
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

### Helm with Values Repository
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helm-multi-repo
spec:
  sources:
  - repoURL: https://charts.example.com
    chart: myapp
    targetRevision: 1.0.0
    helm:
      valueFiles:
      - $values/production/values.yaml
  - repoURL: https://github.com/user/helm-values
    targetRevision: HEAD
    ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: production
```

## Repository Webhooks

### GitHub Webhook
```bash
# Configure webhook in GitHub repository
# URL: https://argocd.example.com/api/webhook
# Content type: application/json
# Events: push, pull_request

# ArgoCD webhook configuration
kubectl patch configmap argocd-cmd-params-cm -n argocd --patch '
data:
  application.instanceLabelKey: argocd.argoproj.io/instance
'
```

### GitLab Webhook
```yaml
# gitlab-webhook-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-webhook
  namespace: argocd
stringData:
  webhook.gitlab.secret: "your-webhook-secret"
```

This guide covers comprehensive ArgoCD repository integration and management.