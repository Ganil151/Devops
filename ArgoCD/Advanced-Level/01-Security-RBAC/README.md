# ArgoCD Security

RBAC, authentication, and security hardening for ArgoCD in production environments.

## Authentication

### OIDC Integration
```yaml
# argocd-server-config
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-server-config
  namespace: argocd
data:
  oidc.config: |
    name: OIDC
    issuer: https://auth.example.com
    clientId: argocd
    clientSecret: $oidc.clientSecret
    requestedScopes: ["openid", "profile", "email", "groups"]
    requestedIDTokenClaims: {"groups": {"essential": true}}
```

### LDAP Integration
```yaml
data:
  dex.config: |
    connectors:
    - type: ldap
      id: ldap
      name: LDAP
      config:
        host: ldap.example.com:636
        insecureNoSSL: false
        bindDN: cn=admin,dc=example,dc=com
        bindPW: $ldap.bindPW
        userSearch:
          baseDN: ou=users,dc=example,dc=com
          filter: "(objectClass=person)"
          username: uid
        groupSearch:
          baseDN: ou=groups,dc=example,dc=com
          filter: "(objectClass=groupOfNames)"
```

## RBAC Configuration

### Role Definitions
```yaml
# argocd-rbac-cm
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    # Admin role
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow
    
    # Developer role
    p, role:developer, applications, get, */*, allow
    p, role:developer, applications, sync, */*, allow
    p, role:developer, applications, action/*, */*, allow
    
    # Read-only role
    p, role:readonly, applications, get, */*, allow
    p, role:readonly, clusters, get, *, allow
    
    # Group mappings
    g, argocd-admins, role:admin
    g, developers, role:developer
    g, viewers, role:readonly
```

### Project-Level RBAC
```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  roles:
  - name: admin
    policies:
    - p, proj:production:admin, applications, *, production/*, allow
    groups:
    - production-admins
  - name: developer
    policies:
    - p, proj:production:developer, applications, get, production/*, allow
    - p, proj:production:developer, applications, sync, production/*, allow
    groups:
    - production-developers
```

## Security Hardening

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: argocd-network-policy
  namespace: argocd
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 6379
```

### Pod Security Standards
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

This guide covers comprehensive ArgoCD security configuration and hardening practices.