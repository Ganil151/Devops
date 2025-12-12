# Enterprise Trivy Implementation

## Trivy Server Deployment

### High Availability Setup
```yaml
# trivy-ha-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trivy-server
  namespace: security
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: trivy-server
  template:
    metadata:
      labels:
        app: trivy-server
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
                  - trivy-server
              topologyKey: kubernetes.io/hostname
      containers:
      - name: trivy
        image: aquasec/trivy:latest
        args:
          - server
          - --listen
          - 0.0.0.0:8080
          - --cache-dir
          - /tmp/trivy/.cache
        ports:
        - containerPort: 8080
          name: http
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          limits:
            cpu: 2000m
            memory: 4Gi
          requests:
            cpu: 1000m
            memory: 2Gi
        volumeMounts:
        - name: cache
          mountPath: /tmp/trivy/.cache
      volumes:
      - name: cache
        persistentVolumeClaim:
          claimName: trivy-cache-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: trivy-server-service
  namespace: security
spec:
  selector:
    app: trivy-server
  ports:
  - port: 8080
    targetPort: 8080
    name: http
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: trivy-cache-pvc
  namespace: security
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
```

### Load Balancer Configuration
```yaml
# trivy-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: trivy-server-ingress
  namespace: security
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - trivy.company.com
    secretName: trivy-tls
  rules:
  - host: trivy.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: trivy-server-service
            port:
              number: 8080
```

## Custom Database Management

### Private Database Setup
```bash
#!/bin/bash
# setup-private-db.sh

# Download and host Trivy database privately
DB_VERSION="2"
DB_URL="https://github.com/aquasecurity/trivy-db/releases/latest/download/trivy-offline.db.tar.gz"
PRIVATE_REGISTRY="registry.company.com/security"

# Download database
wget $DB_URL -O trivy-offline.db.tar.gz

# Create custom database image
cat > Dockerfile.db << EOF
FROM scratch
COPY trivy-offline.db.tar.gz /db/trivy-offline.db.tar.gz
EOF

# Build and push
docker build -f Dockerfile.db -t $PRIVATE_REGISTRY/trivy-db:v$DB_VERSION .
docker push $PRIVATE_REGISTRY/trivy-db:v$DB_VERSION

# Configure Trivy to use private database
export TRIVY_DB_REPOSITORY="$PRIVATE_REGISTRY/trivy-db"
```

### Database Update Automation
```yaml
# trivy-db-updater.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: trivy-db-updater
  namespace: security
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: db-updater
            image: aquasec/trivy:latest
            command:
            - /bin/sh
            - -c
            - |
              # Download latest database
              trivy image --download-db-only
              
              # Verify database integrity
              trivy image --download-db-only --cache-dir /tmp/verify
              
              # Update shared cache
              cp -r /root/.cache/trivy/* /shared-cache/
              
              echo "Database updated successfully"
            volumeMounts:
            - name: shared-cache
              mountPath: /shared-cache
          volumes:
          - name: shared-cache
            persistentVolumeClaim:
              claimName: trivy-cache-pvc
          restartPolicy: OnFailure
```

## Policy as Code Framework

### Advanced Policy Engine
```rego
# security-policies.rego
package trivy

import future.keywords.if
import future.keywords.in

# Deny critical vulnerabilities in production images
deny[msg] {
    input.ArtifactName
    contains(input.ArtifactName, "prod")
    vuln := input.Results[_].Vulnerabilities[_]
    vuln.Severity == "CRITICAL"
    msg := sprintf("Critical vulnerability %s found in production image %s", [vuln.VulnerabilityID, input.ArtifactName])
}

# Deny high vulnerabilities with CVSS > 8.0
deny[msg] {
    vuln := input.Results[_].Vulnerabilities[_]
    vuln.Severity == "HIGH"
    vuln.CVSS.nvd.V3Score > 8.0
    msg := sprintf("High severity vulnerability %s with CVSS score %v exceeds threshold", [vuln.VulnerabilityID, vuln.CVSS.nvd.V3Score])
}

# Deny secrets in any environment
deny[msg] {
    secret := input.Results[_].Secrets[_]
    msg := sprintf("Secret detected: %s in %s", [secret.Title, secret.StartLine])
}

# Deny misconfigurations in Kubernetes manifests
deny[msg] {
    misconfig := input.Results[_].Misconfigurations[_]
    misconfig.Severity in ["HIGH", "CRITICAL"]
    msg := sprintf("Misconfiguration: %s - %s", [misconfig.ID, misconfig.Title])
}

# Allow exceptions for approved vulnerabilities
exception[vuln_id] {
    vuln_id := input.Results[_].Vulnerabilities[_].VulnerabilityID
    approved_exceptions[vuln_id]
}

approved_exceptions := {
    "CVE-2021-44228": "Log4j not used in this application",
    "CVE-2022-12345": "Fixed in next release, low risk"
}

# Custom compliance rules
compliance_docker_cis[result] {
    # CIS Docker Benchmark 4.1 - Ensure a user for the container has been created
    input.Config.User == ""
    result := {
        "id": "CIS-4.1",
        "title": "Container should not run as root",
        "severity": "HIGH",
        "message": "Create a non-root user for the container"
    }
}
```

### Policy Enforcement Pipeline
```bash
#!/bin/bash
# policy-enforcement.sh

IMAGE_NAME=$1
POLICY_DIR="policies"
RESULTS_DIR="results"

mkdir -p $RESULTS_DIR

echo "Scanning $IMAGE_NAME with policy enforcement..."

# Run Trivy scan with custom policies
trivy image \
    --format json \
    --output "$RESULTS_DIR/scan-results.json" \
    --policy "$POLICY_DIR" \
    --exit-code 1 \
    $IMAGE_NAME

SCAN_EXIT_CODE=$?

# Generate policy report
cat > "$RESULTS_DIR/policy-report.json" << EOF
{
    "image": "$IMAGE_NAME",
    "scan_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "policy_compliance": $([ $SCAN_EXIT_CODE -eq 0 ] && echo "true" || echo "false"),
    "exit_code": $SCAN_EXIT_CODE
}
EOF

# Send to compliance dashboard
curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $COMPLIANCE_API_TOKEN" \
    -d @"$RESULTS_DIR/policy-report.json" \
    "$COMPLIANCE_API_URL/reports"

exit $SCAN_EXIT_CODE
```

## Enterprise Integration

### LDAP/SSO Integration
```yaml
# trivy-auth-proxy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trivy-auth-proxy
  namespace: security
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trivy-auth-proxy
  template:
    metadata:
      labels:
        app: trivy-auth-proxy
    spec:
      containers:
      - name: oauth2-proxy
        image: quay.io/oauth2-proxy/oauth2-proxy:latest
        args:
          - --provider=oidc
          - --oidc-issuer-url=https://auth.company.com
          - --client-id=$(CLIENT_ID)
          - --client-secret=$(CLIENT_SECRET)
          - --cookie-secret=$(COOKIE_SECRET)
          - --upstream=http://trivy-server-service:8080
          - --http-address=0.0.0.0:4180
          - --email-domain=company.com
        env:
        - name: CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: oauth2-secrets
              key: client-id
        - name: CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: oauth2-secrets
              key: client-secret
        - name: COOKIE_SECRET
          valueFrom:
            secretKeyRef:
              name: oauth2-secrets
              key: cookie-secret
        ports:
        - containerPort: 4180
```

### RBAC Configuration
```yaml
# trivy-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: trivy-operator
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["security.istio.io"]
  resources: ["authorizationpolicies"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: trivy-operator-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: trivy-operator
subjects:
- kind: ServiceAccount
  name: trivy-operator
  namespace: security
```

## Monitoring and Observability

### Prometheus Metrics
```yaml
# trivy-metrics-exporter.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trivy-metrics-exporter
  namespace: security
spec:
  replicas: 1
  selector:
    matchLabels:
      app: trivy-metrics-exporter
  template:
    metadata:
      labels:
        app: trivy-metrics-exporter
    spec:
      containers:
      - name: exporter
        image: prom/node-exporter:latest
        args:
          - --path.rootfs=/host
          - --collector.textfile.directory=/var/lib/node_exporter/textfile_collector
        volumeMounts:
        - name: metrics
          mountPath: /var/lib/node_exporter/textfile_collector
        - name: host
          mountPath: /host
          readOnly: true
      - name: trivy-collector
        image: aquasec/trivy:latest
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            # Collect metrics from Trivy server
            curl -s http://trivy-server-service:8080/metrics > /metrics/trivy.prom
            sleep 60
          done
        volumeMounts:
        - name: metrics
          mountPath: /metrics
      volumes:
      - name: metrics
        emptyDir: {}
      - name: host
        hostPath:
          path: /
```

### Grafana Dashboard
```json
{
  "dashboard": {
    "title": "Trivy Security Dashboard",
    "panels": [
      {
        "title": "Vulnerability Trends",
        "type": "graph",
        "targets": [
          {
            "expr": "trivy_vulnerabilities_total",
            "legendFormat": "{{severity}} - {{image}}"
          }
        ]
      },
      {
        "title": "Critical Vulnerabilities",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(trivy_vulnerabilities_total{severity=\"critical\"})"
          }
        ]
      },
      {
        "title": "Scan Success Rate",
        "type": "gauge",
        "targets": [
          {
            "expr": "rate(trivy_scans_successful_total[5m]) / rate(trivy_scans_total[5m]) * 100"
          }
        ]
      }
    ]
  }
}
```

## Air-Gapped Environment Setup

### Offline Database Management
```bash
#!/bin/bash
# offline-setup.sh

# Create air-gapped Trivy setup
OFFLINE_DIR="/opt/trivy-offline"
DB_VERSION="2"

# Download components on internet-connected machine
mkdir -p $OFFLINE_DIR/{db,cache,policies}

# Download Trivy binary
wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.tar.gz
tar -xzf trivy_Linux-64bit.tar.gz -C $OFFLINE_DIR/

# Download vulnerability database
$OFFLINE_DIR/trivy image --download-db-only --cache-dir $OFFLINE_DIR/cache

# Download Java database
$OFFLINE_DIR/trivy image --download-java-db-only --cache-dir $OFFLINE_DIR/cache

# Package for air-gapped environment
tar -czf trivy-offline-package.tar.gz -C $OFFLINE_DIR .

echo "Offline package created: trivy-offline-package.tar.gz"
echo "Transfer this file to your air-gapped environment"
```

### Air-Gapped Deployment
```bash
#!/bin/bash
# air-gapped-deploy.sh

INSTALL_DIR="/opt/trivy"
PACKAGE_FILE="trivy-offline-package.tar.gz"

# Extract package
mkdir -p $INSTALL_DIR
tar -xzf $PACKAGE_FILE -C $INSTALL_DIR

# Set up environment
export TRIVY_CACHE_DIR="$INSTALL_DIR/cache"
export TRIVY_OFFLINE_SCAN=true

# Create systemd service
cat > /etc/systemd/system/trivy-server.service << EOF
[Unit]
Description=Trivy Security Scanner Server
After=network.target

[Service]
Type=simple
User=trivy
Group=trivy
ExecStart=$INSTALL_DIR/trivy server --listen 0.0.0.0:8080 --cache-dir $INSTALL_DIR/cache
Environment=TRIVY_OFFLINE_SCAN=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create user and set permissions
useradd -r -s /bin/false trivy
chown -R trivy:trivy $INSTALL_DIR

# Start service
systemctl daemon-reload
systemctl enable trivy-server
systemctl start trivy-server

echo "Trivy server started in air-gapped mode"
```

## Performance Tuning

### Resource Optimization
```yaml
# trivy-performance-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: trivy-config
  namespace: security
data:
  trivy.yaml: |
    # Performance optimizations
    cache:
      redis:
        addr: redis:6379
        password: ""
        db: 0
    
    # Scan optimizations
    scan:
      parallel: 4
      timeout: 300s
      skip-files:
        - "/usr/share/doc/*"
        - "/usr/share/man/*"
        - "*.test"
    
    # Database settings
    db:
      skip-update: false
      download-only: false
      reset: false
    
    # Output settings
    format: json
    severity:
      - HIGH
      - CRITICAL
```

### Horizontal Scaling
```yaml
# trivy-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: trivy-server-hpa
  namespace: security
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: trivy-server
  minReplicas: 3
  maxReplicas: 10
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
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```