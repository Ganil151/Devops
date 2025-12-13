# ArgoCD Monitoring

Observability, metrics, and alerting for ArgoCD GitOps operations.

## Metrics Collection

### Prometheus Integration
```yaml
# ServiceMonitor for ArgoCD
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
```

### Key Metrics
```bash
# Application sync status
argocd_app_info{name="myapp", sync_status="Synced"}

# Sync operation duration
argocd_app_sync_total{name="myapp", phase="Succeeded"}

# Repository connection status
argocd_git_request_total{repo="https://github.com/user/repo"}

# Cluster connectivity
argocd_cluster_connection_status{server="https://kubernetes.default.svc"}
```

## Grafana Dashboards

### Application Overview Dashboard
```json
{
  "dashboard": {
    "title": "ArgoCD Applications",
    "panels": [
      {
        "title": "Application Sync Status",
        "type": "stat",
        "targets": [
          {
            "expr": "sum by (sync_status) (argocd_app_info)",
            "legendFormat": "{{sync_status}}"
          }
        ]
      },
      {
        "title": "Sync Operations",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(argocd_app_sync_total[5m])",
            "legendFormat": "{{name}} - {{phase}}"
          }
        ]
      }
    ]
  }
}
```

## Alerting Rules

### Critical Alerts
```yaml
# prometheus-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: argocd-alerts
  namespace: argocd
spec:
  groups:
  - name: argocd
    rules:
    - alert: ArgoCDAppOutOfSync
      expr: argocd_app_info{sync_status!="Synced"} == 1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "ArgoCD application {{ $labels.name }} is out of sync"
        
    - alert: ArgoCDAppSyncFailed
      expr: argocd_app_info{health_status="Degraded"} == 1
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "ArgoCD application {{ $labels.name }} sync failed"
        
    - alert: ArgoCDServerDown
      expr: up{job="argocd-server-metrics"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "ArgoCD server is down"
```

## Health Checks

### Application Health Monitoring
```bash
#!/bin/bash
# argocd-health-check.sh

ARGOCD_SERVER="argocd.example.com"
APPS=("app1" "app2" "app3")

for app in "${APPS[@]}"; do
    STATUS=$(argocd app get "$app" -o json | jq -r '.status.sync.status')
    HEALTH=$(argocd app get "$app" -o json | jq -r '.status.health.status')
    
    if [[ "$STATUS" != "Synced" || "$HEALTH" != "Healthy" ]]; then
        echo "ALERT: $app - Status: $STATUS, Health: $HEALTH"
    else
        echo "OK: $app - Status: $STATUS, Health: $HEALTH"
    fi
done
```

This guide provides comprehensive ArgoCD monitoring and observability capabilities.