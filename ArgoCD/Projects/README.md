# ArgoCD Projects

Project organization, multi-tenancy, and resource management in ArgoCD.

## Project Basics

### Creating Projects
```yaml
# production-project.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: Production applications
  sourceRepos:
  - 'https://github.com/company/production-*'
  destinations:
  - namespace: 'production-*'
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  - group: 'networking.k8s.io'
    kind: NetworkPolicy
  namespaceResourceWhitelist:
  - group: 'apps'
    kind: Deployment
  - group: ''
    kind: Service
  - group: ''
    kind: ConfigMap
```

### CLI Project Management
```bash
# Create project
argocd proj create production \
  --description "Production applications" \
  --src 'https://github.com/company/production-*' \
  --dest https://kubernetes.default.svc,production-*

# Add source repository
argocd proj add-source production https://github.com/company/new-repo

# Add destination
argocd proj add-destination production https://kubernetes.default.svc staging-*

# List projects
argocd proj list
```

## Multi-Tenancy

### Team-Based Projects
```yaml
# team-a-project.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-a
  namespace: argocd
spec:
  description: Team A applications
  sourceRepos:
  - 'https://github.com/company/team-a-*'
  destinations:
  - namespace: 'team-a-*'
    server: https://kubernetes.default.svc
  roles:
  - name: admin
    policies:
    - p, proj:team-a:admin, applications, *, team-a/*, allow
    - p, proj:team-a:admin, repositories, *, *, allow
    groups:
    - team-a-admins
  - name: developer
    policies:
    - p, proj:team-a:developer, applications, get, team-a/*, allow
    - p, proj:team-a:developer, applications, sync, team-a/*, allow
    groups:
    - team-a-developers
```

### Environment Isolation
```yaml
# staging-project.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: staging
  namespace: argocd
spec:
  sourceRepos:
  - '*'
  destinations:
  - namespace: 'staging-*'
    server: https://kubernetes.default.svc
  syncWindows:
  - kind: allow
    schedule: "* * * * *"
    duration: 24h
    applications:
    - '*'
  - kind: deny
    schedule: "0 22 * * 5"  # Friday 10 PM
    duration: 60h           # Until Monday 6 AM
    applications:
    - '*'
```

## Resource Policies

### Security Policies
```yaml
spec:
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  - group: 'rbac.authorization.k8s.io'
    kind: Role
  - group: 'rbac.authorization.k8s.io'
    kind: RoleBinding
  
  clusterResourceBlacklist:
  - group: ''
    kind: Secret
  - group: 'rbac.authorization.k8s.io'
    kind: ClusterRole
  
  namespaceResourceWhitelist:
  - group: 'apps'
    kind: Deployment
  - group: ''
    kind: Service
  - group: ''
    kind: ConfigMap
```

This guide covers ArgoCD project management and multi-tenancy patterns.