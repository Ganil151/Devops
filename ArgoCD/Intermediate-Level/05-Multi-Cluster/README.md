# ArgoCD Clusters

Multi-cluster management and deployment strategies in ArgoCD.

## Cluster Management

### Adding Clusters
```bash
# Add cluster using kubeconfig
argocd cluster add kubernetes-admin@production-cluster --name production

# Add cluster with specific context
argocd cluster add staging-context --name staging

# List clusters
argocd cluster list

# Get cluster info
argocd cluster get https://production-cluster-api:6443
```

### Cluster Configuration
```yaml
# cluster-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: production-cluster
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
stringData:
  name: production
  server: https://production-cluster-api:6443
  config: |
    {
      "bearerToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9...",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "LS0tLS1CRUdJTi..."
      }
    }
```

## Multi-Cluster Applications

### Cross-Cluster Deployment
```yaml
# multi-cluster-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-cluster-app
spec:
  project: default
  source:
    repoURL: https://github.com/user/app
    path: k8s
    targetRevision: HEAD
  destinations:
  - server: https://production-cluster:6443
    namespace: production
  - server: https://staging-cluster:6443
    namespace: staging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### ApplicationSet for Multi-Cluster
```yaml
# cluster-applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-apps
  namespace: argocd
spec:
  generators:
  - clusters: {}
  template:
    metadata:
      name: '{{name}}-myapp'
    spec:
      project: default
      source:
        repoURL: https://github.com/user/myapp
        targetRevision: HEAD
        path: overlays/{{name}}
      destination:
        server: '{{server}}'
        namespace: myapp
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

## Cluster Security

### Service Account Setup
```yaml
# argocd-manager-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argocd-manager-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
- nonResourceURLs: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-manager-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argocd-manager-role
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: kube-system
```

### Network Policies
```yaml
# cluster-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: argocd-cluster-access
  namespace: argocd
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: argocd-application-controller
  policyTypes:
  - Egress
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 6443
    - protocol: TCP
      port: 443
```

This guide covers ArgoCD multi-cluster management and deployment strategies.