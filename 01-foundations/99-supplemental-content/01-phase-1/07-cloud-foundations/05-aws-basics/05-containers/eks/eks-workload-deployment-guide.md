# EKS Workload Deployment Guide

## Table of Contents
1. [Deployment Strategies](#deployment-strategies)
2. [Application Deployment](#application-deployment)
3. [Service Configuration](#service-configuration)
4. [Ingress and Load Balancing](#ingress-and-load-balancing)
5. [ConfigMaps and Secrets](#configmaps-and-secrets)
6. [Persistent Storage](#persistent-storage)
7. [Auto Scaling](#auto-scaling)
8. [Health Checks and Monitoring](#health-checks-and-monitoring)
9. [CI/CD Integration](#cicd-integration)
10. [Best Practices](#best-practices)

## Deployment Strategies

### Rolling Deployment
```yaml
# rolling-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
  labels:
    app: web-app
    version: v1.0.0
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
        version: v1.0.0
    spec:
      containers:
      - name: web-app
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Blue-Green Deployment
```yaml
# blue-green-deployment.yaml
# Blue version (current)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-blue
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
      version: blue
  template:
    metadata:
      labels:
        app: web-app
        version: blue
    spec:
      containers:
      - name: web-app
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080

---
# Green version (new)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-green
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
      version: green
  template:
    metadata:
      labels:
        app: web-app
        version: green
    spec:
      containers:
      - name: web-app
        image: myapp:v2.0.0
        ports:
        - containerPort: 8080

---
# Service switches between blue and green
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: production
spec:
  selector:
    app: web-app
    version: blue  # Switch to 'green' for deployment
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

### Canary Deployment
```yaml
# canary-deployment.yaml
# Stable version
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-stable
  namespace: production
spec:
  replicas: 9
  selector:
    matchLabels:
      app: web-app
      track: stable
  template:
    metadata:
      labels:
        app: web-app
        track: stable
    spec:
      containers:
      - name: web-app
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080

---
# Canary version (10% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-canary
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
      track: canary
  template:
    metadata:
      labels:
        app: web-app
        track: canary
    spec:
      containers:
      - name: web-app
        image: myapp:v2.0.0
        ports:
        - containerPort: 8080

---
# Service routes to both versions
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: production
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
```

## Application Deployment

### Multi-Container Pod
```yaml
# multi-container-pod.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-with-sidecar
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app-sidecar
  template:
    metadata:
      labels:
        app: web-app-sidecar
    spec:
      containers:
      # Main application container
      - name: web-app
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
      
      # Logging sidecar container
      - name: log-shipper
        image: fluent/fluent-bit:1.9
        volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      
      volumes:
      - name: shared-logs
        emptyDir: {}
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
```

### Init Containers
```yaml
# init-container-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-with-init
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app-init
  template:
    metadata:
      labels:
        app: web-app-init
    spec:
      initContainers:
      # Database migration init container
      - name: db-migration
        image: migrate/migrate:v4.15.2
        command: ['migrate']
        args: ['-path', '/migrations', '-database', 'postgres://user:pass@db:5432/mydb?sslmode=disable', 'up']
        volumeMounts:
        - name: migrations
          mountPath: /migrations
      
      # Configuration setup init container
      - name: config-setup
        image: busybox:1.35
        command: ['sh', '-c']
        args: ['cp /tmp/config/* /app/config/ && chmod 644 /app/config/*']
        volumeMounts:
        - name: config-source
          mountPath: /tmp/config
        - name: app-config
          mountPath: /app/config
      
      containers:
      - name: web-app
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: app-config
          mountPath: /app/config
        env:
        - name: CONFIG_PATH
          value: "/app/config"
      
      volumes:
      - name: migrations
        configMap:
          name: db-migrations
      - name: config-source
        secret:
          secretName: app-config
      - name: app-config
        emptyDir: {}
```

### StatefulSet Deployment
```yaml
# statefulset-deployment.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
  namespace: production
spec:
  serviceName: database-headless
  replicas: 3
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:14-alpine
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: gp3-encrypted
      resources:
        requests:
          storage: 10Gi

---
# Headless service for StatefulSet
apiVersion: v1
kind: Service
metadata:
  name: database-headless
  namespace: production
spec:
  clusterIP: None
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
```

## Service Configuration

### ClusterIP Service
```yaml
# clusterip-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: production
  labels:
    app: backend
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: metrics
    port: 9090
    targetPort: 9090
    protocol: TCP
```

### NodePort Service
```yaml
# nodeport-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
  namespace: production
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30080
    protocol: TCP
```

### LoadBalancer Service
```yaml
# loadbalancer-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-lb
  namespace: production
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval: "10"
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

## Ingress and Load Balancing

### AWS Load Balancer Controller Ingress
```yaml
# alb-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-app-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/success-codes: '200'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
  tls:
  - hosts:
    - myapp.example.com
```

### NGINX Ingress Controller
```yaml
# nginx-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
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
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
```

## ConfigMaps and Secrets

### ConfigMap Examples
```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
data:
  # Simple key-value pairs
  database_host: "postgres.production.svc.cluster.local"
  database_port: "5432"
  log_level: "info"
  
  # Configuration file
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
  
  # JSON configuration
  app.json: |
    {
      "server": {
        "port": 8080,
        "host": "0.0.0.0"
      },
      "database": {
        "host": "postgres.production.svc.cluster.local",
        "port": 5432,
        "ssl": true
      },
      "features": {
        "authentication": true,
        "logging": true
      }
    }

---
# Using ConfigMap in deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-config
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-with-config
  template:
    metadata:
      labels:
        app: app-with-config
    spec:
      containers:
      - name: app
        image: myapp:v1.0.0
        env:
        # Environment variables from ConfigMap
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_host
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: log_level
        volumeMounts:
        # Mount configuration files
        - name: config-volume
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: app-config-volume
          mountPath: /app/config.json
          subPath: app.json
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: app-config-volume
        configMap:
          name: app-config
```

### Secret Management
```yaml
# secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
data:
  # Base64 encoded values
  database-username: cG9zdGdyZXM=  # postgres
  database-password: c2VjcmV0UGFzcw==  # secretPass
  api-key: YWJjZGVmZ2hpams=  # abcdefghijk

---
# TLS Secret
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
  namespace: production
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi... # Base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi... # Base64 encoded private key

---
# Docker registry secret
apiVersion: v1
kind: Secret
metadata:
  name: registry-secret
  namespace: production
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJyZWdpc3RyeS5leGFtcGxlLmNvbSI6eyJ1c2VybmFtZSI6InVzZXIiLCJwYXNzd29yZCI6InBhc3MiLCJhdXRoIjoiZFhObGNqcHdZWE56In19fQ==

---
# Using secrets in deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-secrets
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-with-secrets
  template:
    metadata:
      labels:
        app: app-with-secrets
    spec:
      imagePullSecrets:
      - name: registry-secret
      containers:
      - name: app
        image: registry.example.com/myapp:v1.0.0
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-password
        volumeMounts:
        - name: tls-certs
          mountPath: /etc/ssl/certs
          readOnly: true
      volumes:
      - name: tls-certs
        secret:
          secretName: tls-secret
```

## Persistent Storage

### EBS Storage
```yaml
# ebs-storage.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3-encrypted
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
  fsType: ext4
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3-encrypted
  resources:
    requests:
      storage: 10Gi

---
# Using PVC in deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-storage
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-with-storage
  template:
    metadata:
      labels:
        app: app-with-storage
    spec:
      containers:
      - name: app
        image: myapp:v1.0.0
        volumeMounts:
        - name: app-data
          mountPath: /data
      volumes:
      - name: app-data
        persistentVolumeClaim:
          claimName: app-storage
```

### EFS Storage
```yaml
# efs-storage.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-12345678
  directoryPerms: "700"
  gidRangeStart: "1000"
  gidRangeEnd: "2000"
  basePath: "/dynamic_provisioning"

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
  namespace: production
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi

---
# Shared storage deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shared-storage-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shared-storage-app
  template:
    metadata:
      labels:
        app: shared-storage-app
    spec:
      containers:
      - name: app
        image: nginx:1.21-alpine
        volumeMounts:
        - name: shared-data
          mountPath: /shared
      volumes:
      - name: shared-data
        persistentVolumeClaim:
          claimName: efs-claim
```

## Auto Scaling

### Horizontal Pod Autoscaler
```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 3
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1k"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
```

### Vertical Pod Autoscaler
```yaml
# vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: web-app-vpa
  namespace: production
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: web-app
      minAllowed:
        cpu: 100m
        memory: 50Mi
      maxAllowed:
        cpu: 1
        memory: 500Mi
      controlledResources: ["cpu", "memory"]
```

## Health Checks and Monitoring

### Comprehensive Health Checks
```yaml
# health-checks.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: robust-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: robust-app
  template:
    metadata:
      labels:
        app: robust-app
    spec:
      containers:
      - name: app
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 9090
          name: metrics
        
        # Startup probe - for slow starting containers
        startupProbe:
          httpGet:
            path: /startup
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 30
          successThreshold: 1
        
        # Liveness probe - restart container if unhealthy
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            httpHeaders:
            - name: Custom-Header
              value: liveness
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
          successThreshold: 1
        
        # Readiness probe - remove from service if not ready
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1
        
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        
        env:
        - name: PORT
          value: "8080"
        - name: METRICS_PORT
          value: "9090"
```

### ServiceMonitor for Prometheus
```yaml
# service-monitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: web-app-metrics
  namespace: production
  labels:
    app: web-app
spec:
  selector:
    matchLabels:
      app: web-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
    honorLabels: true
```

## CI/CD Integration

### GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy to EKS

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-west-2
  EKS_CLUSTER_NAME: production-cluster
  ECR_REPOSITORY: myapp

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build, tag, and push image to Amazon ECR
      id: build-image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT
    
    - name: Update kube config
      run: aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION
    
    - name: Deploy to EKS
      env:
        IMAGE_URI: ${{ steps.build-image.outputs.image }}
      run: |
        sed -i.bak "s|CONTAINER_IMAGE|$IMAGE_URI|g" k8s/deployment.yaml
        kubectl apply -f k8s/
        kubectl rollout status deployment/web-app -n production
```

### GitLab CI/CD Pipeline
```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

variables:
  AWS_DEFAULT_REGION: us-west-2
  EKS_CLUSTER_NAME: production-cluster
  DOCKER_DRIVER: overlay2

build:
  stage: build
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  before_script:
    - apk add --no-cache curl jq python3 py3-pip
    - pip install awscli
    - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main

deploy:
  stage: deploy
  image: alpine/k8s:1.24.0
  before_script:
    - apk add --no-cache curl
    - curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
    - chmod +x ./aws-iam-authenticator
    - mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
    - aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name $EKS_CLUSTER_NAME
  script:
    - sed -i "s|CONTAINER_IMAGE|$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA|g" k8s/deployment.yaml
    - kubectl apply -f k8s/
    - kubectl rollout status deployment/web-app -n production --timeout=300s
  only:
    - main
```

### ArgoCD Application
```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web-application
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/company/k8s-manifests
    targetRevision: HEAD
    path: applications/web-app
    helm:
      valueFiles:
      - values-production.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

## Best Practices

### Resource Management
```yaml
# resource-best-practices.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: optimized-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: optimized-app
  template:
    metadata:
      labels:
        app: optimized-app
    spec:
      # Security context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      
      containers:
      - name: app
        image: myapp:v1.0.0
        
        # Security context for container
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
        
        # Resource requests and limits
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
            ephemeral-storage: "1Gi"
          limits:
            memory: "256Mi"
            cpu: "200m"
            ephemeral-storage: "2Gi"
        
        # Environment variables
        env:
        - name: NODE_ENV
          value: "production"
        - name: LOG_LEVEL
          value: "info"
        
        # Volume mounts for writable directories
        volumeMounts:
        - name: tmp-volume
          mountPath: /tmp
        - name: cache-volume
          mountPath: /app/cache
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
      
      volumes:
      - name: tmp-volume
        emptyDir: {}
      - name: cache-volume
        emptyDir: {}
      
      # Node selection
      nodeSelector:
        kubernetes.io/arch: amd64
      
      # Tolerations for spot instances
      tolerations:
      - key: "spot-instance"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      
      # Pod anti-affinity for high availability
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - optimized-app
              topologyKey: kubernetes.io/hostname
```

### Network Policies
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-app-netpol
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: web-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

### Quality Gates
```bash
#!/bin/bash
# deployment-quality-gates.sh

set -e

NAMESPACE="production"
DEPLOYMENT="web-app"
TIMEOUT=300

echo "Starting deployment quality gates..."

# 1. Check deployment rollout status
echo "Checking deployment rollout..."
kubectl rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=${TIMEOUT}s

# 2. Verify all pods are ready
echo "Verifying pod readiness..."
kubectl wait --for=condition=ready pod -l app=$DEPLOYMENT -n $NAMESPACE --timeout=${TIMEOUT}s

# 3. Check service endpoints
echo "Checking service endpoints..."
ENDPOINTS=$(kubectl get endpoints $DEPLOYMENT-service -n $NAMESPACE -o jsonpath='{.subsets[*].addresses[*].ip}' | wc -w)
if [ "$ENDPOINTS" -eq 0 ]; then
    echo "ERROR: No service endpoints available"
    exit 1
fi

# 4. Health check
echo "Performing health check..."
SERVICE_IP=$(kubectl get service $DEPLOYMENT-service -n $NAMESPACE -o jsonpath='{.spec.clusterIP}')
kubectl run health-check --rm -i --restart=Never --image=curlimages/curl -- \
    curl -f http://$SERVICE_IP/health || exit 1

# 5. Load test (optional)
echo "Running basic load test..."
kubectl run load-test --rm -i --restart=Never --image=curlimages/curl -- \
    sh -c "for i in \$(seq 1 10); do curl -f http://$SERVICE_IP/ && sleep 1; done"

echo "All quality gates passed!"
```

## Troubleshooting

### Common Issues and Solutions
```bash
# Debug pod issues
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

# Check resource usage
kubectl top pods -n <namespace>
kubectl top nodes

# Debug service connectivity
kubectl run debug --rm -i --restart=Never --image=busybox -- nslookup <service-name>
kubectl run debug --rm -i --restart=Never --image=curlimages/curl -- curl -v <service-name>

# Check ingress
kubectl describe ingress <ingress-name> -n <namespace>
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp

# Debug storage issues
kubectl describe pvc <pvc-name> -n <namespace>
kubectl get storageclass
```

This comprehensive guide covers all aspects of deploying and managing workloads on EKS, from basic deployments to advanced CI/CD integration and troubleshooting.