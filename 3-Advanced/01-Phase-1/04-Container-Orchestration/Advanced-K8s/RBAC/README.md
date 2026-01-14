# Kubernetes RBAC (Role-Based Access Control)

## Overview

**Kubernetes RBAC** provides fine-grained access control to Kubernetes resources. RBAC uses roles and role bindings to determine what actions users, groups, and service accounts can perform.

## Core Components

### Role
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

### ClusterRole
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

### RoleBinding
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRoleBinding
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: User
  name: manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

## Service Account RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: service-reader
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-services
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: service-reader
  apiGroup: rbac.authorization.k8s.io
```

## Common Verbs

- **get**: Read a specific resource
- **list**: Read all resources of a type
- **watch**: Watch for changes to resources
- **create**: Create new resources
- **update**: Update existing resources
- **patch**: Partially update resources
- **delete**: Delete resources
- **deletecollection**: Delete collections of resources

## Permission Checking

```bash
# Check if you can perform an action
kubectl auth can-i create pods

# Check for specific user
kubectl auth can-i create pods --as=jane

# Check in specific namespace
kubectl auth can-i create pods --namespace=production

# List allowed actions
kubectl auth can-i --list
```

## Best Practices

- Follow principle of least privilege
- Use service accounts for applications
- Regularly audit RBAC permissions
- Use groups for user management
- Implement namespace-based isolation

## Troubleshooting

```bash
# Check current user
kubectl config current-context

# Describe RBAC resources
kubectl describe clusterrole system:admin
kubectl describe rolebinding -n default

# Check effective permissions
kubectl auth can-i --list --as=system:serviceaccount:default:my-sa
```

## Conclusion

RBAC provides essential security controls for Kubernetes clusters, enabling fine-grained access control and supporting multi-tenant environments.