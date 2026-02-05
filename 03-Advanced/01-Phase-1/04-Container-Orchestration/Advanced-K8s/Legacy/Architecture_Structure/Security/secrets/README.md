# Kubernetes Secrets Management

## Overview

**Kubernetes Secrets** provide a secure way to store and manage sensitive information such as passwords, OAuth tokens, SSH keys, and TLS certificates. Secrets are stored separately from pod specifications and can be mounted as volumes or exposed as environment variables.

## Secret Types

### Generic Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: generic-secret
  namespace: production
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded 'admin'
  password: MWYyZDFlMmU2N2Rm  # base64 encoded password
stringData:
  config.yaml: |
    apiUrl: "https://api.example.com"
    timeout: 30
```

### Docker Registry Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJyZWdpc3RyeS5leGFtcGxlLmNvbSI6eyJ1c2VybmFtZSI6InVzZXIiLCJwYXNzd29yZCI6InBhc3MiLCJhdXRoIjoiZFhObGNqcHdZWE56In19fQ==
```

### TLS Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...  # base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi...  # base64 encoded private key
```

### SSH Auth Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ssh-secret
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: LS0tLS1CRUdJTi...  # base64 encoded SSH private key
```

### Service Account Token Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sa-token-secret
  annotations:
    kubernetes.io/service-account.name: my-service-account
type: kubernetes.io/service-account-token
```

## Creating Secrets

### Using kubectl
```bash
# Create generic secret from literals
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secretpassword

# Create secret from files
kubectl create secret generic app-config \
  --from-file=config.properties \
  --from-file=database.conf

# Create TLS secret from certificate files
kubectl create secret tls tls-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key

# Create docker registry secret
kubectl create secret docker-registry registry-secret \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=password \
  --docker-email=user@example.com
```

### Using YAML Manifests
```yaml
# Multi-type secret
apiVersion: v1
kind: Secret
metadata:
  name: multi-secret
  namespace: production
  labels:
    app: web-app
    environment: production
type: Opaque
data:
  # Database credentials
  db-username: cG9zdGdyZXM=
  db-password: c2VjcmV0cGFzc3dvcmQ=
  # API keys
  api-key: YWJjZGVmZ2hpams=
  # Configuration files
stringData:
  app.properties: |
    database.url=jdbc:postgresql://db:5432/myapp
    cache.enabled=true
    log.level=INFO
  redis.conf: |
    bind 127.0.0.1
    port 6379
    timeout 300
```

## Using Secrets in Pods

### Environment Variables
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    env:
    # Single secret key
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
    # All keys from secret
    envFrom:
    - secretRef:
        name: app-config
    # Optional secret (won't fail if missing)
    - secretRef:
        name: optional-secret
        optional: true
```

### Volume Mounts
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    # Mount entire secret
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
    # Mount specific keys
    - name: config-volume
      mountPath: /etc/config
      readOnly: true
  volumes:
  # Mount all secret keys
  - name: secret-volume
    secret:
      secretName: db-secret
      defaultMode: 0400  # Read-only for owner
  # Mount specific keys with custom paths
  - name: config-volume
    secret:
      secretName: app-config
      items:
      - key: app.properties
        path: application.properties
        mode: 0644
      - key: redis.conf
        path: redis/redis.conf
        mode: 0600
```

### Projected Volumes
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: projected-secrets-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: projected-volume
      mountPath: /etc/combined
      readOnly: true
  volumes:
  - name: projected-volume
    projected:
      sources:
      # Multiple secrets
      - secret:
          name: db-secret
          items:
          - key: username
            path: db/username
      - secret:
          name: api-secret
          items:
          - key: api-key
            path: api/key
      # ConfigMap
      - configMap:
          name: app-config
          items:
          - key: config.yaml
            path: config/app.yaml
      # Service account token
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
```

## Advanced Secret Management

### Immutable Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: immutable-secret
type: Opaque
immutable: true  # Cannot be updated after creation
data:
  api-key: YWJjZGVmZ2hpams=
```

### Secret Rotation
```yaml
# Deployment with secret rotation support
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  template:
    metadata:
      annotations:
        # Force pod restart on secret change
        secret-hash: "{{ .Values.secretHash }}"
    spec:
      containers:
      - name: app
        image: nginx:1.21
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
```

### External Secrets Operator
```yaml
# External secret from AWS Secrets Manager
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: aws-secret
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-store
    kind: SecretStore
  target:
    name: db-credentials
    creationPolicy: Owner
  data:
  - secretKey: username
    remoteRef:
      key: prod/database
      property: username
  - secretKey: password
    remoteRef:
      key: prod/database
      property: password
---
# AWS Secrets Store
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-store
  namespace: production
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-west-2
      auth:
        secretRef:
          accessKeyID:
            name: aws-credentials
            key: access-key-id
          secretAccessKey:
            name: aws-credentials
            key: secret-access-key
```

### HashiCorp Vault Integration
```yaml
# Vault secret injection
apiVersion: v1
kind: Pod
metadata:
  name: vault-pod
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "myapp"
    vault.hashicorp.com/agent-inject-secret-database: "secret/data/database"
    vault.hashicorp.com/agent-inject-template-database: |
      {{- with secret "secret/data/database" -}}
      export DB_USERNAME="{{ .Data.data.username }}"
      export DB_PASSWORD="{{ .Data.data.password }}"
      {{- end }}
spec:
  serviceAccountName: vault-auth
  containers:
  - name: app
    image: nginx:1.21
    command: ["/bin/sh"]
    args: ["-c", "source /vault/secrets/database && exec nginx -g 'daemon off;'"]
```

## Encryption at Rest

### etcd Encryption Configuration
```yaml
# Encryption configuration for etcd
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
- resources:
  - configmaps
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: c2VjcmV0IGlzIHNlY3VyZQ==
  - identity: {}
```

### KMS Integration
```yaml
# AWS KMS encryption
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - kms:
      name: aws-kms
      endpoint: unix:///tmp/socketfile.sock
      cachesize: 100
      timeout: 3s
  - identity: {}
```

## Secret Security Best Practices

### 1. Least Privilege Access
```yaml
# RBAC for secret access
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
  namespace: production
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
  resourceNames: ["app-secrets", "db-secrets"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secret-reader-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: production
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

### 2. Secret Scanning and Validation
```yaml
# OPA Gatekeeper policy for secret validation
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredsecretlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredSecretLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredsecretlabels
        
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Secret must have label: %v", [missing])
        }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredSecretLabels
metadata:
  name: must-have-owner
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Secret"]
  parameters:
    labels: ["owner", "environment"]
```

### 3. Secret Lifecycle Management
```yaml
# Secret with expiration annotation
apiVersion: v1
kind: Secret
metadata:
  name: expiring-secret
  annotations:
    secret.kubernetes.io/expires-at: "2024-12-31T23:59:59Z"
    secret.kubernetes.io/rotation-schedule: "0 0 1 * *"  # Monthly rotation
    secret.kubernetes.io/owner: "security-team"
type: Opaque
data:
  api-key: YWJjZGVmZ2hpams=
```

## Monitoring and Auditing

### Secret Access Monitoring
```yaml
# Prometheus monitoring for secret access
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: secret-monitoring
spec:
  groups:
  - name: secrets
    rules:
    - alert: UnauthorizedSecretAccess
      expr: |
        increase(apiserver_audit_total{verb="get",objectRef_resource="secrets"}[5m]) > 10
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "High number of secret access attempts"
    
    - alert: SecretCreatedWithoutLabels
      expr: |
        increase(apiserver_audit_total{verb="create",objectRef_resource="secrets"}[5m])
        unless on(objectRef_name, objectRef_namespace)
        kube_secret_labels{label_owner!=""}
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: "Secret created without required labels"
```

### Audit Policy for Secrets
```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# Log secret access at RequestResponse level
- level: RequestResponse
  verbs: ["get", "list", "create", "update", "patch", "delete"]
  resources:
  - group: ""
    resources: ["secrets"]
  namespaces: ["production", "staging"]

# Log secret mount events
- level: Request
  verbs: ["create", "update", "patch"]
  resources:
  - group: ""
    resources: ["pods"]
  omitStages:
  - RequestReceived
```

## Troubleshooting Secrets

### Common Issues

#### 1. Secret Not Found
```bash
# Check if secret exists
kubectl get secrets -n namespace-name

# Verify secret name and namespace
kubectl describe pod pod-name | grep -A 10 "Volumes:"

# Check RBAC permissions
kubectl auth can-i get secrets --as=system:serviceaccount:namespace:sa-name
```

#### 2. Base64 Encoding Issues
```bash
# Encode secret value
echo -n "mysecret" | base64

# Decode secret value
kubectl get secret secret-name -o jsonpath='{.data.key}' | base64 -d

# Verify encoding
echo "bXlzZWNyZXQ=" | base64 -d
```

#### 3. Permission Denied
```bash
# Check pod security context
kubectl describe pod pod-name | grep -A 5 "Security Context"

# Verify file permissions in mounted volume
kubectl exec -it pod-name -- ls -la /etc/secrets/

# Check volume mount configuration
kubectl describe pod pod-name | grep -A 10 "Mounts:"
```

### Secret Validation Tools
```bash
# Check for secrets in plain text
kubectl get secrets --all-namespaces -o json | \
  jq -r '.items[] | select(.data != null) | .data | to_entries[] | .value' | \
  base64 -d | grep -E "(password|key|token)"

# Validate secret references in pods
kubectl get pods --all-namespaces -o json | \
  jq -r '.items[] | select(.spec.containers[]?.env[]?.valueFrom?.secretKeyRef != null) | 
  "\(.metadata.namespace)/\(.metadata.name)"'

# Check for unused secrets
kubectl get secrets --all-namespaces -o json | \
  jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' | \
  while read secret; do
    if ! kubectl get pods --all-namespaces -o json | \
       jq -e --arg secret "$secret" '.items[] | 
       select(.spec.volumes[]?.secret?.secretName == ($secret | split("/")[1]) or
              .spec.containers[]?.env[]?.valueFrom?.secretKeyRef?.name == ($secret | split("/")[1]))' > /dev/null; then
      echo "Unused secret: $secret"
    fi
  done
```

## Secret Management Tools

### Sealed Secrets
```yaml
# SealedSecret for GitOps
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: sealed-secret
  namespace: production
spec:
  encryptedData:
    password: AgBy3i4OJSWK+PiTySYZZA9rO43cGDEQAx...
  template:
    metadata:
      name: db-secret
      namespace: production
    type: Opaque
```

### SOPS (Secrets OPerationS)
```yaml
# SOPS encrypted secret
apiVersion: v1
kind: Secret
metadata:
    name: sops-secret
type: Opaque
data:
    password: ENC[AES256_GCM,data:Tr7o1qrqw5g=,iv:1=,aad:No=,tag:k=]
sops:
    kms:
    - arn: arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012
    version: 3.7.1
```

### External Secrets with Azure Key Vault
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: azure-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: azure-keyvault-store
    kind: SecretStore
  target:
    name: app-secrets
  data:
  - secretKey: database-password
    remoteRef:
      key: database-password
---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: azure-keyvault-store
spec:
  provider:
    azurekv:
      vaultUrl: "https://my-keyvault.vault.azure.net/"
      authSecretRef:
        clientId:
          name: azure-credentials
          key: client-id
        clientSecret:
          name: azure-credentials
          key: client-secret
      tenantId: "12345678-1234-1234-1234-123456789012"
```

## Compliance and Standards

### SOC 2 Compliance
```yaml
# Secret with compliance annotations
apiVersion: v1
kind: Secret
metadata:
  name: compliant-secret
  annotations:
    compliance.kubernetes.io/soc2: "true"
    security.kubernetes.io/classification: "confidential"
    audit.kubernetes.io/retention: "7years"
    encryption.kubernetes.io/algorithm: "AES256"
type: Opaque
data:
  sensitive-data: c2Vuc2l0aXZlLWRhdGE=
```

### PCI DSS Requirements
```yaml
# PCI DSS compliant secret handling
apiVersion: v1
kind: Secret
metadata:
  name: pci-secret
  labels:
    pci-dss: "true"
    data-classification: "restricted"
  annotations:
    security.kubernetes.io/encryption-required: "true"
    audit.kubernetes.io/access-logging: "enabled"
type: Opaque
data:
  credit-card-key: Y3JlZGl0LWNhcmQta2V5
```

## Conclusion

Kubernetes Secrets management requires careful consideration of security, compliance, and operational requirements. Proper implementation includes encryption at rest, access controls, rotation policies, and integration with external secret management systems. Regular auditing and monitoring ensure secrets remain secure throughout their lifecycle.