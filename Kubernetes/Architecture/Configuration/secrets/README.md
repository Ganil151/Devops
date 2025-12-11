# Kubernetes Secrets

## Overview

**Kubernetes Secrets** are objects that store sensitive data such as passwords, OAuth tokens, SSH keys, and TLS certificates. Secrets provide a secure way to manage confidential information separately from application code and container images.

## What are Kubernetes Secrets?

Kubernetes Secrets are:
- Objects that hold sensitive data
- Base64 encoded (not encrypted by default)
- Stored in etcd and can be encrypted at rest
- Mounted as volumes or exposed as environment variables

## Secret Architecture

### Secret Storage Flow
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   kubectl   │───►│ API Server  │───►│    etcd     │
│  (create)   │    │ (validate)  │    │  (store)    │
└─────────────┘    └─────────────┘    └─────────────┘
                          │                   │
                          ▼                   │
                   ┌─────────────┐            │
                   │   kubelet   │◄───────────┘
                   │ (retrieve)  │
                   └─────────────┘
                          │
                          ▼
                   ┌─────────────┐
                   │    Pod      │
                   │ (consume)   │
                   └─────────────┘
```

### Secret Consumption Methods
```
┌─────────────────────────────────────────┐
│              Secret Usage               │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Environment │  │    Volume       │   │
│  │ Variables   │  │    Mount        │   │
│  └─────────────┘  └─────────────────┘   │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Image Pull  │  │ TLS Ingress     │   │
│  │ Secrets     │  │ Certificates    │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

## Secret Types

### 1. Opaque Secrets (Generic)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: generic-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded "admin"
  password: MWYyZDFlMmU2N2Rm  # base64 encoded "1f2d1e2e67df"
```

### 2. Docker Registry Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJyZWdpc3RyeS5leGFtcGxlLmNvbSI6eyJ1c2VybmFtZSI6InVzZXIiLCJwYXNzd29yZCI6InBhc3MiLCJhdXRoIjoiZFhObGNqcHdZWE56In19fQ==
```

### 3. TLS Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t...
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t...
```

### 4. SSH Auth Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ssh-secret
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0...
```

### 5. Basic Auth Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth-secret
type: kubernetes.io/basic-auth
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```

### 6. Service Account Token Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sa-token-secret
  annotations:
    kubernetes.io/service-account.name: my-service-account
type: kubernetes.io/service-account-token
data:
  token: ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNklpSjk...
  ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t...
  namespace: ZGVmYXVsdA==
```

## Creating Secrets

### Using kubectl

#### Generic Secret
```bash
# From literal values
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secretpassword

# From files
kubectl create secret generic my-secret \
  --from-file=username.txt \
  --from-file=password.txt

# From directory
kubectl create secret generic my-secret \
  --from-file=path/to/secret/dir/
```

#### Docker Registry Secret
```bash
# Docker registry authentication
kubectl create secret docker-registry my-registry-secret \
  --docker-server=registry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com
```

#### TLS Secret
```bash
# TLS certificate and key
kubectl create secret tls my-tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/cert.key
```

### Using YAML Manifests

#### Manual Base64 Encoding
```bash
# Encode values
echo -n 'admin' | base64  # YWRtaW4=
echo -n 'secretpassword' | base64  # c2VjcmV0cGFzc3dvcmQ=
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: manual-secret
type: Opaque
data:
  username: YWRtaW4=
  password: c2VjcmV0cGFzc3dvcmQ=
```

#### Using stringData (No Base64 Required)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: string-secret
type: Opaque
stringData:
  username: admin
  password: secretpassword
  config.yaml: |
    database:
      host: db.example.com
      port: 5432
      name: myapp
```

## Using Secrets in Pods

### Environment Variables

#### Single Secret Key
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

#### All Secret Keys
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-envfrom-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    envFrom:
    - secretRef:
        name: db-secret
```

### Volume Mounts

#### Basic Volume Mount
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: my-secret
```

#### Specific Keys and Paths
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-selective-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/config
  volumes:
  - name: secret-volume
    secret:
      secretName: my-secret
      items:
      - key: username
        path: db-username
      - key: password
        path: db-password
        mode: 0400
```

#### Default Mode and Optional
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-mode-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
  volumes:
  - name: secret-volume
    secret:
      secretName: my-secret
      defaultMode: 0400
      optional: true
```

## Image Pull Secrets

### Docker Registry Authentication
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-image-pod
spec:
  imagePullSecrets:
  - name: my-registry-secret
  containers:
  - name: app
    image: registry.example.com/myapp:latest
```

### Service Account with Image Pull Secrets
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
imagePullSecrets:
- name: my-registry-secret
---
apiVersion: v1
kind: Pod
metadata:
  name: sa-image-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: app
    image: registry.example.com/myapp:latest
```

## TLS and Ingress Secrets

### TLS Secret for Ingress
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t...
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t...
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: tls-secret
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

### Certificate Manager Integration
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: myapp-cert
spec:
  secretName: myapp-tls-secret
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - myapp.example.com
  - www.myapp.example.com
```

## Secret Security

### Encryption at Rest
```yaml
# EncryptionConfiguration
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: c2VjcmV0IGlzIHNlY3VyZQ==
  - identity: {}
```

### RBAC for Secrets
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["my-secret"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

### Pod Security Context
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-secret-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app
    image: nginx:1.20
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: my-secret
      defaultMode: 0400
```

## Secret Management

### Viewing Secrets
```bash
# List secrets
kubectl get secrets

# Describe secret (without showing data)
kubectl describe secret my-secret

# Get secret data (base64 encoded)
kubectl get secret my-secret -o yaml

# Decode secret data
kubectl get secret my-secret -o jsonpath='{.data.username}' | base64 -d

# Get all keys from secret
kubectl get secret my-secret -o jsonpath='{.data}' | jq -r 'keys[]'
```

### Updating Secrets
```bash
# Update secret with new data
kubectl create secret generic my-secret \
  --from-literal=username=newuser \
  --from-literal=password=newpassword \
  --dry-run=client -o yaml | kubectl apply -f -

# Patch secret
kubectl patch secret my-secret -p='{"data":{"password":"bmV3cGFzc3dvcmQ="}}'

# Edit secret interactively
kubectl edit secret my-secret
```

### Secret Rotation
```yaml
# Rolling update deployment after secret change
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    metadata:
      annotations:
        secret-hash: "abc123"  # Change this to trigger rolling update
    spec:
      containers:
      - name: app
        image: myapp:latest
        envFrom:
        - secretRef:
            name: my-secret
```

## External Secret Management

### External Secrets Operator
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "myapp"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: vault-secret
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: myapp-secret
    creationPolicy: Owner
  data:
  - secretKey: password
    remoteRef:
      key: myapp
      property: password
```

### AWS Secrets Manager
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-west-2
      auth:
        secretRef:
          accessKeyID:
            name: aws-creds
            key: access-key-id
          secretAccessKey:
            name: aws-creds
            key: secret-access-key
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: aws-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: myapp-aws-secret
  data:
  - secretKey: database-password
    remoteRef:
      key: prod/myapp/database
      property: password
```

## Secret Troubleshooting

### Common Issues

#### 1. Secret Not Found
```bash
# Check if secret exists
kubectl get secret my-secret

# Check namespace
kubectl get secret my-secret -n correct-namespace

# Check secret creation
kubectl describe secret my-secret
```

#### 2. Base64 Encoding Issues
```bash
# Verify base64 encoding
echo "YWRtaW4=" | base64 -d

# Check for trailing newlines
echo -n "admin" | base64

# Validate secret data
kubectl get secret my-secret -o jsonpath='{.data.username}' | base64 -d
```

#### 3. Permission Issues
```bash
# Check RBAC permissions
kubectl auth can-i get secrets

# Check service account permissions
kubectl auth can-i get secrets --as=system:serviceaccount:default:my-sa

# Describe RBAC
kubectl describe rolebinding,clusterrolebinding | grep -A 10 -B 10 secrets
```

#### 4. Mount Issues
```bash
# Check pod events
kubectl describe pod my-pod

# Check volume mounts
kubectl get pod my-pod -o jsonpath='{.spec.volumes[*]}'

# Verify secret exists in pod
kubectl exec my-pod -- ls -la /etc/secrets/
```

### Debug Commands
```bash
# Check secret usage in pods
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes[?(@.secret)]}{"\n"}{end}'

# Find pods using specific secret
kubectl get pods -o json | jq -r '.items[] | select(.spec.volumes[]?.secret.secretName=="my-secret") | .metadata.name'

# Check environment variables from secrets
kubectl exec my-pod -- env | grep -i secret
```

## Best Practices

### 1. Security
- Enable encryption at rest for etcd
- Use RBAC to limit secret access
- Avoid logging secret values
- Use read-only mounts when possible
- Implement secret rotation policies

### 2. Management
- Use external secret management systems
- Implement automated secret rotation
- Monitor secret access and usage
- Use meaningful secret names and labels
- Document secret purposes and owners

### 3. Application Design
- Prefer volume mounts over environment variables
- Handle secret updates gracefully
- Implement proper error handling
- Use init containers for secret validation
- Avoid hardcoding secret references

### 4. Operations
- Regular secret audits and cleanup
- Monitor secret expiration dates
- Implement backup and recovery procedures
- Use GitOps for secret management
- Test secret rotation procedures

## Secret Patterns

### Database Connection Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-secret
type: Opaque
stringData:
  host: postgres.example.com
  port: "5432"
  database: myapp
  username: appuser
  password: secretpassword
  connection-string: "postgresql://appuser:secretpassword@postgres.example.com:5432/myapp"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: connection-string
```

### API Keys and Tokens
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-keys
type: Opaque
stringData:
  stripe-api-key: sk_live_...
  sendgrid-api-key: SG....
  jwt-secret: your-jwt-secret-key
  oauth-client-id: your-oauth-client-id
  oauth-client-secret: your-oauth-client-secret
```

### Multi-Environment Secrets
```yaml
# Development
apiVersion: v1
kind: Secret
metadata:
  name: app-config
  namespace: development
type: Opaque
stringData:
  api-url: https://api-dev.example.com
  debug: "true"
---
# Production
apiVersion: v1
kind: Secret
metadata:
  name: app-config
  namespace: production
type: Opaque
stringData:
  api-url: https://api.example.com
  debug: "false"
```

## Conclusion

Kubernetes Secrets provide:
- Secure storage for sensitive data
- Flexible consumption methods (env vars, volumes)
- Integration with various authentication systems
- Foundation for secure application deployment
- Support for external secret management systems

Understanding secret management is crucial for building secure Kubernetes applications and maintaining proper security practices in containerized environments.