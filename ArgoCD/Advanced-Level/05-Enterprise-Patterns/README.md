# ArgoCD Enterprise Patterns

Advanced architectural patterns, large-scale implementations, and enterprise integration strategies for ArgoCD.

## Enterprise Architecture Patterns

### Hub and Spoke Model
```yaml
# Central ArgoCD managing multiple clusters
# Hub Cluster (Management)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-management
  namespace: argocd
spec:
  project: platform
  source:
    repoURL: https://github.com/company/cluster-configs
    path: management
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

---
# Spoke Clusters Registration
apiVersion: v1
kind: Secret
metadata:
  name: prod-cluster-1
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
stringData:
  name: prod-cluster-1
  server: https://prod-cluster-1.company.com
  config: |
    {
      "bearerToken": "...",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "..."
      }
    }
```

### Multi-Tenant Architecture
```yaml
# Tenant isolation with projects
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-alpha
  namespace: argocd
spec:
  description: "Team Alpha Applications"
  sourceRepos:
  - 'https://github.com/company/team-alpha-*'
  destinations:
  - namespace: 'team-alpha-*'
    server: '*'
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  namespaceResourceWhitelist:
  - group: 'apps'
    kind: Deployment
  - group: ''
    kind: Service
  - group: 'networking.k8s.io'
    kind: Ingress
  roles:
  - name: team-alpha-admin
    description: "Full access for Team Alpha"
    policies:
    - p, proj:team-alpha:team-alpha-admin, applications, *, team-alpha/*, allow
    - p, proj:team-alpha:team-alpha-admin, repositories, *, *, allow
    groups:
    - company:team-alpha-admins
  - name: team-alpha-developer
    description: "Developer access for Team Alpha"
    policies:
    - p, proj:team-alpha:team-alpha-developer, applications, get, team-alpha/*, allow
    - p, proj:team-alpha:team-alpha-developer, applications, sync, team-alpha/*, allow
    groups:
    - company:team-alpha-developers
```

### Federated ArgoCD
```yaml
# Multiple ArgoCD instances with coordination
# Regional ArgoCD for US East
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: regional-apps-us-east
  namespace: argocd-us-east
spec:
  project: regional
  source:
    repoURL: https://github.com/company/regional-configs
    path: us-east
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: regional-apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

---
# Cross-region application coordination
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: global-applications
  namespace: argocd-global
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          region: us-east
      values:
        region: us-east
        argocd_namespace: argocd-us-east
  - clusters:
      selector:
        matchLabels:
          region: eu-west
      values:
        region: eu-west
        argocd_namespace: argocd-eu-west
  template:
    metadata:
      name: 'global-app-{{region}}'
    spec:
      project: global
      source:
        repoURL: https://github.com/company/global-apps
        path: 'regions/{{region}}'
        targetRevision: HEAD
      destination:
        server: '{{server}}'
        namespace: global-apps
```

## Enterprise Integration Patterns

### CI/CD Pipeline Integration
```yaml
# GitLab CI integration with ArgoCD
stages:
  - build
  - test
  - deploy-dev
  - deploy-staging
  - deploy-prod

variables:
  ARGOCD_SERVER: argocd.company.com
  ARGOCD_AUTH_TOKEN: $ARGOCD_TOKEN

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

update-dev-manifest:
  stage: deploy-dev
  script:
    - |
      # Update image tag in dev environment
      git clone https://oauth2:$GITLAB_TOKEN@gitlab.com/company/app-configs.git
      cd app-configs
      yq eval '.spec.source.helm.parameters[0].value = "'$CI_COMMIT_SHA'"' -i environments/dev/application.yaml
      git add .
      git commit -m "Update dev image to $CI_COMMIT_SHA"
      git push origin main
    - |
      # Trigger ArgoCD sync
      argocd app sync myapp-dev --server $ARGOCD_SERVER --auth-token $ARGOCD_AUTH_TOKEN
      argocd app wait myapp-dev --server $ARGOCD_SERVER --auth-token $ARGOCD_AUTH_TOKEN

promote-to-staging:
  stage: deploy-staging
  when: manual
  script:
    - |
      # Promote to staging
      git clone https://oauth2:$GITLAB_TOKEN@gitlab.com/company/app-configs.git
      cd app-configs
      yq eval '.spec.source.helm.parameters[0].value = "'$CI_COMMIT_SHA'"' -i environments/staging/application.yaml
      git add .
      git commit -m "Promote $CI_COMMIT_SHA to staging"
      git push origin main
```

### Service Mesh Integration
```yaml
# Istio integration with ArgoCD
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: istio-system
  namespace: argocd
spec:
  project: platform
  source:
    repoURL: https://github.com/company/istio-configs
    path: base
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: istio-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true

---
# Application with service mesh configuration
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: microservice-app
spec:
  source:
    repoURL: https://github.com/company/microservice-configs
    path: k8s
    helm:
      parameters:
      - name: istio.enabled
        value: "true"
      - name: istio.gateway
        value: "company-gateway"
      - name: istio.virtualService.enabled
        value: "true"
  destination:
    server: https://kubernetes.default.svc
    namespace: microservices
```

### External Secrets Integration
```yaml
# External Secrets Operator with ArgoCD
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: external-secrets-operator
  namespace: argocd
spec:
  project: platform
  source:
    repoURL: https://charts.external-secrets.io
    chart: external-secrets
    targetRevision: 0.9.0
  destination:
    server: https://kubernetes.default.svc
    namespace: external-secrets-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true

---
# Application using external secrets
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
  - secretKey: database-password
    remoteRef:
      key: secret/myapp
      property: db_password
```

## Compliance and Governance

### Policy as Code Integration
```yaml
# OPA Gatekeeper policies for ArgoCD
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: argocdrequiredlabels
spec:
  crd:
    spec:
      names:
        kind: ArgocdRequiredLabels
      validation:
        properties:
          labels:
            type: array
            items:
              type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package argocdrequiredlabels
        
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }

---
# Constraint for ArgoCD applications
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: ArgocdRequiredLabels
metadata:
  name: argocd-must-have-labels
spec:
  match:
    kinds:
      - apiGroups: ["argoproj.io"]
        kinds: ["Application"]
  parameters:
    labels: ["team", "environment", "cost-center"]
```

### Audit and Compliance Tracking
```yaml
# Audit logging configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cmd-params-cm
  namespace: argocd
data:
  # Enable audit logging
  server.audit.log.enabled: "true"
  server.audit.log.path: "/var/log/argocd/audit.log"
  
  # Application operation logging
  application.operation.processors: "10"
  application.operation.log.level: "info"

---
# Compliance reporting application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: compliance-reporter
  namespace: argocd
spec:
  project: platform
  source:
    repoURL: https://github.com/company/compliance-tools
    path: argocd-reporter
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: compliance
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## High Availability and Disaster Recovery

### Multi-Region HA Setup
```yaml
# Primary region ArgoCD
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd-primary
  namespace: argocd
spec:
  server:
    replicas: 3
    env:
    - name: ARGOCD_SERVER_ENABLE_GRPC_WEB
      value: "true"
    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
        cert-manager.io/cluster-issuer: letsencrypt-prod
      hosts:
      - argocd-primary.company.com
      tls:
      - secretName: argocd-server-tls
        hosts:
        - argocd-primary.company.com
  
  controller:
    replicas: 3
    env:
    - name: ARGOCD_CONTROLLER_REPLICAS
      value: "3"
  
  repoServer:
    replicas: 3
  
  redis:
    enabled: false  # Use external Redis cluster
  
  ha:
    enabled: true
    redisProxyImage: haproxy:2.4
    
---
# External Redis configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  redis.server: "redis-cluster.company.com:6379"
  redis.password: "$redis-password:password"
  redis.db: "0"
```

### Backup and Recovery Strategy
```yaml
# Backup configuration
apiVersion: batch/v1
kind: CronJob
metadata:
  name: argocd-backup
  namespace: argocd
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: argoproj/argocd:v2.8.0
            command:
            - /bin/bash
            - -c
            - |
              # Backup ArgoCD applications
              argocd app list -o json > /backup/applications-$(date +%Y%m%d).json
              
              # Backup ArgoCD projects
              kubectl get appprojects -n argocd -o json > /backup/projects-$(date +%Y%m%d).json
              
              # Backup ArgoCD repositories
              kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o json > /backup/repositories-$(date +%Y%m%d).json
              
              # Upload to S3
              aws s3 cp /backup/ s3://company-argocd-backups/$(date +%Y/%m/%d)/ --recursive
            env:
            - name: ARGOCD_SERVER
              value: "argocd-server.argocd.svc.cluster.local:443"
            - name: ARGOCD_AUTH_TOKEN
              valueFrom:
                secretKeyRef:
                  name: argocd-backup-token
                  key: token
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            emptyDir: {}
          restartPolicy: OnFailure
```

## Performance Optimization

### Resource Optimization
```yaml
# Optimized ArgoCD configuration
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd-optimized
  namespace: argocd
spec:
  controller:
    resources:
      limits:
        cpu: "2"
        memory: "4Gi"
      requests:
        cpu: "1"
        memory: "2Gi"
    env:
    - name: ARGOCD_CONTROLLER_REPO_SERVER_TIMEOUT_SECONDS
      value: "300"
    - name: ARGOCD_CONTROLLER_STATUS_PROCESSORS
      value: "20"
    - name: ARGOCD_CONTROLLER_OPERATION_PROCESSORS
      value: "10"
    - name: ARGOCD_CONTROLLER_APP_RESYNC_PERIOD
      value: "180s"
  
  server:
    resources:
      limits:
        cpu: "1"
        memory: "2Gi"
      requests:
        cpu: "500m"
        memory: "1Gi"
    env:
    - name: ARGOCD_SERVER_REPO_SERVER_TIMEOUT_SECONDS
      value: "300"
    - name: ARGOCD_SERVER_ENABLE_GRPC_WEB
      value: "true"
  
  repoServer:
    resources:
      limits:
        cpu: "1"
        memory: "2Gi"
      requests:
        cpu: "500m"
        memory: "1Gi"
    env:
    - name: ARGOCD_EXEC_TIMEOUT
      value: "300s"
    - name: ARGOCD_REPO_SERVER_PARALLELISM_LIMIT
      value: "10"
```

### Caching and Performance
```yaml
# Redis configuration for performance
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  # Repository caching
  repository.credentials: |
    - url: https://github.com/company
      passwordSecret:
        name: github-secret
        key: password
      usernameSecret:
        name: github-secret
        key: username
  
  # Application refresh settings
  timeout.reconciliation: 180s
  timeout.hard.reconciliation: 0s
  
  # Resource tracking optimization
  resource.customizations.ignoreDifferences.all: |
    managedFieldsManagers:
    - kube-controller-manager
    - kubectl-client-side-apply
    
  # Sync performance
  application.sync.retry.limit: "5"
  application.sync.retry.backoff.duration: "5s"
  application.sync.retry.backoff.factor: "2"
  application.sync.retry.backoff.maxDuration: "3m"
```

## Enterprise Monitoring and Alerting

### Comprehensive Monitoring Stack
```yaml
# Prometheus monitoring for ArgoCD
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics

---
# Grafana dashboard for ArgoCD
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-dashboard
  namespace: monitoring
data:
  argocd-dashboard.json: |
    {
      "dashboard": {
        "title": "ArgoCD Enterprise Dashboard",
        "panels": [
          {
            "title": "Application Sync Status",
            "type": "stat",
            "targets": [
              {
                "expr": "sum(argocd_app_info) by (sync_status)"
              }
            ]
          },
          {
            "title": "Application Health Status", 
            "type": "stat",
            "targets": [
              {
                "expr": "sum(argocd_app_info) by (health_status)"
              }
            ]
          }
        ]
      }
    }
```

This comprehensive guide covers enterprise-grade ArgoCD patterns essential for large-scale, production-ready GitOps implementations.