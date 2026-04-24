# SonarQube Kubernetes Deployment Guide

Complete guide for deploying SonarQube on Kubernetes with high availability, persistence, and production-ready configurations.

## Prerequisites

- Kubernetes cluster (1.20+)
- kubectl configured
- Helm 3.x (optional)
- StorageClass for persistent volumes
- Minimum 8GB RAM per SonarQube pod

## Quick Start with Helm

### Add SonarQube Helm Repository
```bash
# Add SonarSource Helm repository
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

# Install with default values
helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --create-namespace
```

### Custom Values Installation
```bash
# Create custom values file
cat > sonarqube-values.yaml << 'EOF'
# SonarQube configuration
sonarqube:
  image:
    tag: "10.3-community"
  
  # Resource requirements
  resources:
    limits:
      cpu: 2000m
      memory: 4Gi
    requests:
      cpu: 1000m
      memory: 2Gi
  
  # JVM options
  jvmOpts: "-Xmx3G -Xms1G"
  jvmCeOpts: "-Xmx1G -Xms1G"
  
  # Persistence
  persistence:
    enabled: true
    storageClass: "fast-ssd"
    size: 20Gi

# PostgreSQL configuration
postgresql:
  enabled: true
  auth:
    username: sonar
    password: sonar-password
    database: sonarqube
  
  primary:
    persistence:
      enabled: true
      storageClass: "fast-ssd"
      size: 20Gi
    
    resources:
      limits:
        cpu: 1000m
        memory: 2Gi
      requests:
        cpu: 500m
        memory: 1Gi

# Ingress configuration
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
  hosts:
    - host: sonarqube.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: sonarqube-tls
      hosts:
        - sonarqube.example.com

# Service configuration
service:
  type: ClusterIP
  port: 9000
EOF

# Install with custom values
helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --create-namespace \
  --values sonarqube-values.yaml
```

## Manual Kubernetes Deployment

### Namespace and ConfigMap
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sonarqube
  labels:
    name: sonarqube
---
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sonarqube-config
  namespace: sonarqube
data:
  sonar.properties: |
    # Database
    sonar.jdbc.username=sonar
    sonar.jdbc.password=sonar-password
    sonar.jdbc.url=jdbc:postgresql://postgresql:5432/sonarqube
    
    # Web Server
    sonar.web.host=0.0.0.0
    sonar.web.port=9000
    sonar.web.javaAdditionalOpts=-server -Xmx3G -Xms1G
    
    # Search Engine
    sonar.search.javaOpts=-Xmx1G -Xms1G
    
    # Security
    sonar.forceAuthentication=true
    
    # Performance
    sonar.web.http.maxThreads=50
    sonar.web.http.minThreads=5
```

### PostgreSQL Deployment
```yaml
# postgresql-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-secret
  namespace: sonarqube
type: Opaque
data:
  username: c29uYXI=  # base64 encoded 'sonar'
  password: c29uYXItcGFzc3dvcmQ=  # base64 encoded 'sonar-password'
  database: c29uYXJxdWJl  # base64 encoded 'sonarqube'
---
# postgresql-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-pvc
  namespace: sonarqube
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 20Gi
---
# postgresql-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  namespace: sonarqube
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
      - name: postgresql
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: password
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: database
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - name: postgresql-storage
          mountPath: /var/lib/postgresql/data
        resources:
          limits:
            cpu: 1000m
            memory: 2Gi
          requests:
            cpu: 500m
            memory: 1Gi
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - sonar
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - sonar
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgresql-storage
        persistentVolumeClaim:
          claimName: postgresql-pvc
---
# postgresql-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgresql
  namespace: sonarqube
spec:
  selector:
    app: postgresql
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
```

### SonarQube Deployment
```yaml
# sonarqube-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sonarqube-data-pvc
  namespace: sonarqube
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sonarqube-extensions-pvc
  namespace: sonarqube
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 5Gi
---
# sonarqube-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarqube
  namespace: sonarqube
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sonarqube
  template:
    metadata:
      labels:
        app: sonarqube
    spec:
      securityContext:
        fsGroup: 1000
      initContainers:
      - name: init-sysctl
        image: busybox:1.35
        securityContext:
          privileged: true
        command:
        - sh
        - -c
        - |
          sysctl -w vm.max_map_count=524288
          sysctl -w fs.file-max=131072
      containers:
      - name: sonarqube
        image: sonarqube:10.3-community
        ports:
        - containerPort: 9000
        env:
        - name: SONAR_JDBC_URL
          value: jdbc:postgresql://postgresql:5432/sonarqube
        - name: SONAR_JDBC_USERNAME
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: username
        - name: SONAR_JDBC_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: password
        - name: SONAR_WEB_JAVAOPTS
          value: "-Xmx3G -Xms1G"
        - name: SONAR_SEARCH_JAVAOPTS
          value: "-Xmx1G -Xms1G"
        volumeMounts:
        - name: sonarqube-data
          mountPath: /opt/sonarqube/data
        - name: sonarqube-extensions
          mountPath: /opt/sonarqube/extensions
        - name: sonarqube-config
          mountPath: /opt/sonarqube/conf/sonar.properties
          subPath: sonar.properties
        resources:
          limits:
            cpu: 2000m
            memory: 4Gi
          requests:
            cpu: 1000m
            memory: 2Gi
        livenessProbe:
          httpGet:
            path: /api/system/status
            port: 9000
          initialDelaySeconds: 120
          periodSeconds: 30
          timeoutSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/system/status
            port: 9000
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
        securityContext:
          runAsUser: 1000
          runAsGroup: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
      volumes:
      - name: sonarqube-data
        persistentVolumeClaim:
          claimName: sonarqube-data-pvc
      - name: sonarqube-extensions
        persistentVolumeClaim:
          claimName: sonarqube-extensions-pvc
      - name: sonarqube-config
        configMap:
          name: sonarqube-config
---
# sonarqube-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: sonarqube
  namespace: sonarqube
spec:
  selector:
    app: sonarqube
  ports:
  - port: 9000
    targetPort: 9000
  type: ClusterIP
```

### Ingress Configuration
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sonarqube-ingress
  namespace: sonarqube
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - sonarqube.example.com
    secretName: sonarqube-tls
  rules:
  - host: sonarqube.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sonarqube
            port:
              number: 9000
```

## High Availability Setup

### StatefulSet for SonarQube
```yaml
# sonarqube-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: sonarqube
  namespace: sonarqube
spec:
  serviceName: sonarqube-headless
  replicas: 2
  selector:
    matchLabels:
      app: sonarqube
  template:
    metadata:
      labels:
        app: sonarqube
    spec:
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
                  - sonarqube
              topologyKey: kubernetes.io/hostname
      containers:
      - name: sonarqube
        image: sonarqube:10.3-community
        env:
        - name: SONAR_CLUSTER_ENABLED
          value: "true"
        - name: SONAR_CLUSTER_NODE_TYPE
          value: "application"
        - name: SONAR_CLUSTER_HOSTS
          value: "sonarqube-0.sonarqube-headless:9003,sonarqube-1.sonarqube-headless:9003"
        - name: SONAR_CLUSTER_SEARCH_HOSTS
          value: "sonarqube-search-0.sonarqube-search-headless:9001,sonarqube-search-1.sonarqube-search-headless:9001"
        # ... other configurations
  volumeClaimTemplates:
  - metadata:
      name: sonarqube-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 20Gi
---
# sonarqube-headless-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: sonarqube-headless
  namespace: sonarqube
spec:
  clusterIP: None
  selector:
    app: sonarqube
  ports:
  - port: 9000
    name: http
  - port: 9003
    name: hazelcast
```

### Elasticsearch Cluster for Search
```yaml
# elasticsearch-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: sonarqube-search
  namespace: sonarqube
spec:
  serviceName: sonarqube-search-headless
  replicas: 3
  selector:
    matchLabels:
      app: sonarqube-search
  template:
    metadata:
      labels:
        app: sonarqube-search
    spec:
      containers:
      - name: elasticsearch
        image: elasticsearch:7.17.0
        env:
        - name: cluster.name
          value: sonarqube-cluster
        - name: node.name
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: discovery.seed_hosts
          value: "sonarqube-search-headless"
        - name: cluster.initial_master_nodes
          value: "sonarqube-search-0,sonarqube-search-1,sonarqube-search-2"
        - name: ES_JAVA_OPTS
          value: "-Xms1g -Xmx1g"
        ports:
        - containerPort: 9200
          name: http
        - containerPort: 9300
          name: transport
        resources:
          limits:
            cpu: 1000m
            memory: 2Gi
          requests:
            cpu: 500m
            memory: 1Gi
        volumeMounts:
        - name: elasticsearch-data
          mountPath: /usr/share/elasticsearch/data
  volumeClaimTemplates:
  - metadata:
      name: elasticsearch-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 10Gi
```

## Monitoring and Observability

### ServiceMonitor for Prometheus
```yaml
# servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sonarqube
  namespace: sonarqube
  labels:
    app: sonarqube
spec:
  selector:
    matchLabels:
      app: sonarqube
  endpoints:
  - port: http
    path: /api/monitoring/metrics
    interval: 30s
```

### Grafana Dashboard ConfigMap
```yaml
# grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sonarqube-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  sonarqube-dashboard.json: |
    {
      "dashboard": {
        "title": "SonarQube Metrics",
        "panels": [
          {
            "title": "Lines of Code",
            "type": "stat",
            "targets": [
              {
                "expr": "sonarqube_lines_of_code_total"
              }
            ]
          },
          {
            "title": "Code Coverage",
            "type": "gauge",
            "targets": [
              {
                "expr": "sonarqube_coverage_percentage"
              }
            ]
          }
        ]
      }
    }
```

## Security Configuration

### Network Policies
```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sonarqube-netpol
  namespace: sonarqube
spec:
  podSelector:
    matchLabels:
      app: sonarqube
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
      port: 9000
  - from:
    - podSelector:
        matchLabels:
          app: sonarqube
    ports:
    - protocol: TCP
      port: 9003  # Hazelcast
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432
  - to: []
    ports:
    - protocol: TCP
      port: 443  # HTTPS
    - protocol: TCP
      port: 53   # DNS
  - to: []
    ports:
    - protocol: UDP
      port: 53   # DNS
```

### Pod Security Policy
```yaml
# pod-security-policy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: sonarqube-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

## Backup and Disaster Recovery

### Database Backup CronJob
```yaml
# backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sonarqube-backup
  namespace: sonarqube
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15-alpine
            command:
            - /bin/bash
            - -c
            - |
              pg_dump -h postgresql -U sonar sonarqube > /backup/sonarqube_$(date +%Y%m%d_%H%M%S).sql
              # Upload to S3 or other storage
              aws s3 cp /backup/sonarqube_$(date +%Y%m%d_%H%M%S).sql s3://backup-bucket/sonarqube/
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgresql-secret
                  key: password
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            emptyDir: {}
          restartPolicy: OnFailure
```

## Troubleshooting

### Common Issues and Solutions

#### Pod Startup Issues
```bash
# Check pod status
kubectl get pods -n sonarqube

# Check pod logs
kubectl logs -n sonarqube deployment/sonarqube

# Check events
kubectl get events -n sonarqube --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n sonarqube
```

#### Database Connection Issues
```bash
# Test database connectivity
kubectl exec -n sonarqube deployment/postgresql -- psql -U sonar -d sonarqube -c "SELECT version();"

# Check database logs
kubectl logs -n sonarqube deployment/postgresql
```

#### Performance Issues
```bash
# Check resource limits
kubectl describe pod -n sonarqube <pod-name>

# Monitor resource usage
kubectl top pods -n sonarqube --containers

# Check JVM metrics
kubectl exec -n sonarqube deployment/sonarqube -- curl localhost:9000/api/monitoring/metrics
```

### Debugging Commands
```bash
# Get shell access to SonarQube pod
kubectl exec -it -n sonarqube deployment/sonarqube -- bash

# Check SonarQube configuration
kubectl exec -n sonarqube deployment/sonarqube -- cat /opt/sonarqube/conf/sonar.properties

# Check system resources
kubectl exec -n sonarqube deployment/sonarqube -- free -h
kubectl exec -n sonarqube deployment/sonarqube -- df -h
```

This completes the comprehensive Kubernetes deployment guide for SonarQube with high availability, monitoring, security, and troubleshooting configurations.