# Kubernetes ConfigMaps

## Overview

**Kubernetes ConfigMaps** are objects that store non-confidential configuration data in key-value pairs. ConfigMaps allow you to decouple configuration artifacts from image content to keep containerized applications portable and environment-agnostic.

## What are Kubernetes ConfigMaps?

Kubernetes ConfigMaps are:
- Objects that hold configuration data
- Stored as plain text (not encoded)
- Used to store environment-specific settings
- Consumed by pods as environment variables or volume mounts

## ConfigMap Architecture

### ConfigMap Storage Flow
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

### ConfigMap Consumption Methods
```
┌─────────────────────────────────────────┐
│            ConfigMap Usage              │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Environment │  │    Volume       │   │
│  │ Variables   │  │    Mount        │   │
│  └─────────────┘  └─────────────────┘   │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Command     │  │ Init Container  │   │
│  │ Arguments   │  │ Configuration   │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

## Creating ConfigMaps

### Using kubectl

#### From Literal Values
```bash
# Single key-value pair
kubectl create configmap app-config --from-literal=database.host=localhost

# Multiple key-value pairs
kubectl create configmap app-config \
  --from-literal=database.host=localhost \
  --from-literal=database.port=5432 \
  --from-literal=database.name=myapp
```

#### From Files
```bash
# From single file
kubectl create configmap app-config --from-file=app.properties

# From multiple files
kubectl create configmap app-config \
  --from-file=app.properties \
  --from-file=logging.conf

# From file with custom key
kubectl create configmap app-config --from-file=config=app.properties
```

#### From Directory
```bash
# From entire directory
kubectl create configmap app-config --from-file=config/

# Directory structure:
# config/
# ├── app.properties
# ├── logging.conf
# └── database.yaml
```

#### From Environment File
```bash
# From .env file
kubectl create configmap app-config --from-env-file=app.env

# app.env content:
# DATABASE_HOST=localhost
# DATABASE_PORT=5432
# DEBUG=true
```

### Using YAML Manifests

#### Basic ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  database.host: "localhost"
  database.port: "5432"
  database.name: "myapp"
  debug: "true"
```

#### ConfigMap with File Content
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    database.host=localhost
    database.port=5432
    database.name=myapp
    debug=true
  logging.conf: |
    [loggers]
    keys=root
    
    [handlers]
    keys=consoleHandler
    
    [formatters]
    keys=simpleFormatter
    
    [logger_root]
    level=INFO
    handlers=consoleHandler
```

#### ConfigMap with Binary Data
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: binary-config
data:
  text-data: "plain text content"
binaryData:
  binary-file: iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==
```

## Using ConfigMaps in Pods

### Environment Variables

#### Single ConfigMap Key
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-env-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.port
```

#### All ConfigMap Keys
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-envfrom-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    envFrom:
    - configMapRef:
        name: app-config
```

#### Multiple ConfigMaps
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-configmap-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    envFrom:
    - configMapRef:
        name: app-config
    - configMapRef:
        name: database-config
    - configMapRef:
        name: logging-config
```

### Volume Mounts

#### Basic Volume Mount
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

#### Specific Keys and Paths
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-selective-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
      - key: app.properties
        path: application.properties
      - key: logging.conf
        path: log4j.properties
        mode: 0644
```

#### Default Mode and Optional
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-mode-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      defaultMode: 0644
      optional: true
```

### Command Arguments
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-args-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c"]
    args:
    - echo "Database host is $(DATABASE_HOST) and port is $(DATABASE_PORT)"
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.port
```

## ConfigMap Patterns

### Application Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config
data:
  app.yaml: |
    server:
      port: 8080
      host: 0.0.0.0
    database:
      host: postgres.default.svc.cluster.local
      port: 5432
      name: webapp
      pool_size: 10
    redis:
      host: redis.default.svc.cluster.local
      port: 6379
    logging:
      level: INFO
      format: json
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://webapp:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
```

### Environment-Specific Configuration
```yaml
# Development ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: development
data:
  environment: "development"
  debug: "true"
  log_level: "DEBUG"
  api_url: "https://api-dev.example.com"
  database_pool_size: "5"
---
# Production ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
data:
  environment: "production"
  debug: "false"
  log_level: "INFO"
  api_url: "https://api.example.com"
  database_pool_size: "20"
```

### Feature Flags
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
data:
  features.json: |
    {
      "new_ui": true,
      "beta_features": false,
      "experimental_api": false,
      "maintenance_mode": false,
      "rate_limiting": true,
      "cache_enabled": true
    }
```

## ConfigMap with Deployments

### Deployment with ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config
data:
  database.host: "postgres.default.svc.cluster.local"
  database.port: "5432"
  redis.host: "redis.default.svc.cluster.local"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: webapp:latest
        envFrom:
        - configMapRef:
            name: webapp-config
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: webapp-config
```

### Rolling Updates with ConfigMap Changes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  template:
    metadata:
      annotations:
        configmap-hash: "abc123"  # Change this to trigger rolling update
    spec:
      containers:
      - name: webapp
        image: webapp:latest
        envFrom:
        - configMapRef:
            name: webapp-config
```

## ConfigMap Management

### Viewing ConfigMaps
```bash
# List ConfigMaps
kubectl get configmaps

# Describe ConfigMap
kubectl describe configmap app-config

# Get ConfigMap data
kubectl get configmap app-config -o yaml

# Get specific key
kubectl get configmap app-config -o jsonpath='{.data.database\.host}'

# Get all keys
kubectl get configmap app-config -o jsonpath='{.data}' | jq -r 'keys[]'
```

### Updating ConfigMaps
```bash
# Replace ConfigMap
kubectl create configmap app-config \
  --from-literal=database.host=newhost \
  --from-literal=database.port=5432 \
  --dry-run=client -o yaml | kubectl apply -f -

# Patch ConfigMap
kubectl patch configmap app-config -p='{"data":{"database.host":"newhost"}}'

# Edit ConfigMap interactively
kubectl edit configmap app-config
```

### ConfigMap Immutability
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: immutable-config
immutable: true
data:
  database.host: "localhost"
  database.port: "5432"
```

## Advanced ConfigMap Usage

### Init Container Configuration
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-configmap-pod
spec:
  initContainers:
  - name: init-config
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Initializing with config:"
      cat /etc/config/app.properties
      cp /etc/config/* /shared-config/
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: shared-config
      mountPath: /shared-config
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: shared-config
      mountPath: /app/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: shared-config
    emptyDir: {}
```

### ConfigMap with Subpath
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: subpath-configmap-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
    - name: config-volume
      mountPath: /app/config/app.properties
      subPath: app.properties
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### Hot Reload Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hot-reload-config
data:
  reload.sh: |
    #!/bin/bash
    while inotifywait -e modify /etc/config/app.properties; do
      echo "Config file changed, reloading application..."
      kill -HUP $(pgrep -f "myapp")
    done
---
apiVersion: v1
kind: Pod
metadata:
  name: hot-reload-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  - name: config-reloader
    image: alpine:latest
    command: ["/bin/sh", "/scripts/reload.sh"]
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: script-volume
      mountPath: /scripts
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: script-volume
    configMap:
      name: hot-reload-config
      defaultMode: 0755
```

## ConfigMap Validation

### Schema Validation
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: validated-config
  annotations:
    config.kubernetes.io/schema: |
      {
        "type": "object",
        "properties": {
          "database.host": {"type": "string"},
          "database.port": {"type": "string", "pattern": "^[0-9]+$"}
        },
        "required": ["database.host", "database.port"]
      }
data:
  database.host: "localhost"
  database.port: "5432"
```

### Configuration Testing
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-test-pod
spec:
  restartPolicy: Never
  containers:
  - name: config-tester
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Testing configuration..."
      if [ -z "$DATABASE_HOST" ]; then
        echo "ERROR: DATABASE_HOST not set"
        exit 1
      fi
      if [ -z "$DATABASE_PORT" ]; then
        echo "ERROR: DATABASE_PORT not set"
        exit 1
      fi
      echo "Configuration test passed"
    envFrom:
    - configMapRef:
        name: app-config
```

## ConfigMap Troubleshooting

### Common Issues

#### 1. ConfigMap Not Found
```bash
# Check if ConfigMap exists
kubectl get configmap app-config

# Check namespace
kubectl get configmap app-config -n correct-namespace

# List all ConfigMaps
kubectl get configmaps --all-namespaces
```

#### 2. Key Not Found
```bash
# Check ConfigMap keys
kubectl get configmap app-config -o jsonpath='{.data}' | jq 'keys'

# Verify key exists
kubectl get configmap app-config -o jsonpath='{.data.database\.host}'

# Check for typos in key names
kubectl describe configmap app-config
```

#### 3. Mount Issues
```bash
# Check pod events
kubectl describe pod my-pod

# Verify volume mounts
kubectl get pod my-pod -o jsonpath='{.spec.volumes[*]}'

# Check mounted files
kubectl exec my-pod -- ls -la /etc/config/
kubectl exec my-pod -- cat /etc/config/app.properties
```

#### 4. Environment Variable Issues
```bash
# Check environment variables
kubectl exec my-pod -- env | grep DATABASE

# Verify ConfigMap reference
kubectl get pod my-pod -o yaml | grep -A 10 configMapKeyRef

# Test environment variable resolution
kubectl exec my-pod -- sh -c 'echo $DATABASE_HOST'
```

### Debug Commands
```bash
# Check ConfigMap usage in pods
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes[?(@.configMap)]}{"\n"}{end}'

# Find pods using specific ConfigMap
kubectl get pods -o json | jq -r '.items[] | select(.spec.volumes[]?.configMap.name=="app-config") | .metadata.name'

# Check ConfigMap size
kubectl get configmap app-config -o jsonpath='{.data}' | wc -c
```

## Best Practices

### 1. Organization
- Use meaningful ConfigMap names
- Group related configuration together
- Use namespaces for environment separation
- Document ConfigMap purposes and usage

### 2. Data Management
- Keep ConfigMaps small (< 1MB recommended)
- Use appropriate data types (string vs binary)
- Validate configuration data
- Version configuration changes

### 3. Security
- Don't store sensitive data in ConfigMaps
- Use Secrets for confidential information
- Implement proper RBAC for ConfigMap access
- Audit ConfigMap changes

### 4. Application Design
- Design applications to handle configuration changes
- Use volume mounts for large configuration files
- Implement configuration validation
- Handle missing or invalid configuration gracefully

### 5. Operations
- Monitor ConfigMap usage and size
- Implement configuration testing
- Use GitOps for ConfigMap management
- Plan for configuration rollback scenarios

## ConfigMap Patterns

### Multi-Tier Application
```yaml
# Frontend ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  api_url: "http://backend.default.svc.cluster.local:8080"
  cdn_url: "https://cdn.example.com"
  analytics_id: "GA-123456789"
---
# Backend ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  database_url: "postgres://postgres.default.svc.cluster.local:5432/myapp"
  redis_url: "redis://redis.default.svc.cluster.local:6379"
  jwt_expiry: "3600"
---
# Database ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-config
data:
  postgresql.conf: |
    max_connections = 100
    shared_buffers = 128MB
    effective_cache_size = 4GB
    maintenance_work_mem = 64MB
```

### Microservices Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: service-discovery
data:
  services.yaml: |
    services:
      user-service:
        url: http://user-service.default.svc.cluster.local:8080
        timeout: 30s
      order-service:
        url: http://order-service.default.svc.cluster.local:8080
        timeout: 45s
      payment-service:
        url: http://payment-service.default.svc.cluster.local:8080
        timeout: 60s
      notification-service:
        url: http://notification-service.default.svc.cluster.local:8080
        timeout: 15s
```

## Conclusion

Kubernetes ConfigMaps provide:
- Centralized configuration management
- Environment-specific configuration
- Separation of configuration from application code
- Flexible consumption methods
- Support for various data formats

Understanding ConfigMap usage patterns and best practices is essential for building maintainable, portable, and configurable applications in Kubernetes environments.