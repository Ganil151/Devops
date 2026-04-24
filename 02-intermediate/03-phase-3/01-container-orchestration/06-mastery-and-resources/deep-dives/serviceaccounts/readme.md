# Kubernetes Service Accounts

## Overview

**Kubernetes Service Accounts** provide an identity for processes that run in pods. Service accounts are used to control access to the Kubernetes API and other resources within the cluster.

## Basic Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

## Service Account with Secrets

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
secrets:
- name: my-service-account-token
imagePullSecrets:
- name: my-registry-secret
```

## Using Service Account in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: app
    image: nginx
```

## Service Account Token

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-service-account-token
  annotations:
    kubernetes.io/service-account.name: my-service-account
type: kubernetes.io/service-account-token
```

## RBAC Integration

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## Default Service Account

Every namespace has a default service account:
```bash
kubectl get serviceaccount default
```

## Token Projection

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: token-projection-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: token
      mountPath: /var/run/secrets/tokens
  volumes:
  - name: token
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
          audience: api
```

## Image Pull Secrets

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
imagePullSecrets:
- name: my-registry-secret
```

## Service Account Management

```bash
# Create service account
kubectl create serviceaccount my-service-account

# Get service accounts
kubectl get serviceaccounts

# Describe service account
kubectl describe serviceaccount my-service-account

# Get service account token
kubectl get secret $(kubectl get serviceaccount my-service-account -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -d
```

## Best Practices

- Use dedicated service accounts for applications
- Follow principle of least privilege
- Regularly rotate service account tokens
- Use token projection for enhanced security
- Monitor service account usage

## Troubleshooting

```bash
# Check service account permissions
kubectl auth can-i get pods --as=system:serviceaccount:default:my-service-account

# Check token expiration
kubectl get secret my-service-account-token -o jsonpath='{.data.token}' | base64 -d | jwt decode -

# Verify RBAC bindings
kubectl get rolebinding,clusterrolebinding -o wide | grep my-service-account
```

## Conclusion

Service Accounts provide essential identity and access management for applications running in Kubernetes, enabling secure API access and resource management.