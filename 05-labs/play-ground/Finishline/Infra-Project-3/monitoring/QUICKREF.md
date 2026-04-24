# Monitoring Stack Quick Reference

## Quick Start

```bash
# Deploy monitoring stack
cd monitoring
chmod +x deploy.sh cleanup.sh
./deploy.sh

# Access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
# Open http://localhost:3000

# Get Grafana password
kubectl get secret -n monitoring grafana -o jsonpath='{.data.admin-password}' | base64 --decode
```

## Common Commands

### Check Status
```bash
# Check all monitoring resources
kubectl get all -n monitoring

# Check Prometheus status
kubectl get prometheus -n monitoring
kubectl describe prometheus -n monitoring

# Check Grafana status
kubectl get deployment grafana -n monitoring
kubectl logs -n monitoring deployment/grafana

# Check alert rules
kubectl get prometheusrule -n monitoring
kubectl describe prometheusrule finishline-alerts -n monitoring
```

### Port Forwarding
```bash
# Grafana (port 3000)
kubectl port-forward -n monitoring svc/grafana 3000:80

# Prometheus (port 9090)
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090

# AlertManager (port 9093)
kubectl port-forward -n monitoring svc/alertmanager-operated 9093:9093
```

### View Logs
```bash
# Prometheus logs
kubectl logs -n monitoring prometheus-0

# Grafana logs
kubectl logs -n monitoring deployment/grafana

# Prometheus Operator logs
kubectl logs -n monitoring deployment/prometheus-operator

# AlertManager logs
kubectl logs -n monitoring alertmanager-0
```

### Scaling
```bash
# Scale Grafana replicas
kubectl scale deployment grafana -n monitoring --replicas=2

# Check Prometheus storage
kubectl get pvc -n monitoring
kubectl describe pvc prometheus-kube-prometheus-prometheus-db-prometheus-0 -n monitoring
```

## Troubleshooting

### Prometheus not scraping metrics
```bash
# Check targets
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
# Visit http://localhost:9090/targets

# Check Prometheus config
kubectl get configmap -n monitoring prometheus-kube-prometheus-prometheus -o yaml

# Check ServiceMonitor resources
kubectl get servicemonitor -n monitoring
kubectl get servicemonitor -A
```

### Grafana not connecting to Prometheus
```bash
# Check datasource configuration
kubectl get configmap -n monitoring grafana-datasources -o yaml

# Test connection from Grafana pod
kubectl exec -it -n monitoring deployment/grafana -- \
  curl http://prometheus-operated:9090/-/healthy
```

### High disk usage
```bash
# Check Prometheus storage usage
kubectl exec -n monitoring prometheus-0 -- du -sh /prometheus

# Check retention settings
kubectl get prometheus -n monitoring -o yaml | grep retention

# Reduce retention (edit prometheus-values.yaml and upgrade)
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml
```

### Alerts not firing
```bash
# Check alert rules
kubectl get prometheusrule -n monitoring

# Check AlertManager config
kubectl get configmap -n monitoring alertmanager-kube-prometheus-alertmanager -o yaml

# Test AlertManager
kubectl port-forward -n monitoring svc/alertmanager-operated 9093:9093
# Visit http://localhost:9093
```

### Pod memory/CPU limits exceeded
```bash
# Check resource usage
kubectl top pod -n monitoring

# Edit Helm values and upgrade
# Modify prometheus-values.yaml resources section
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml
```

## Backup & Restore

### Backup Prometheus Data
```bash
# Create backup
kubectl exec -n monitoring prometheus-0 -- \
  tar czf - /prometheus > prometheus-backup-$(date +%Y%m%d).tar.gz

# Verify backup
tar tzf prometheus-backup-*.tar.gz | head -20
```

### Backup Grafana Dashboards
```bash
# Export all dashboards
kubectl exec -n monitoring deployment/grafana -- \
  grafana-cli admin export-dashboard > grafana-dashboards-$(date +%Y%m%d).json
```

### Restore Prometheus Data
```bash
# Extract backup to pod
tar xzf prometheus-backup-*.tar.gz
kubectl cp prometheus /prometheus -n monitoring -c prometheus

# Restart Prometheus
kubectl delete pod prometheus-0 -n monitoring
```

## Performance Tuning

### Reduce Prometheus Storage
```yaml
# In prometheus-values.yaml
prometheus:
  prometheusSpec:
    retention: 7d  # Reduce from 15d
    storageSpec:
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 30Gi  # Reduce from 50Gi
```

### Optimize Scrape Interval
```yaml
# In prometheus-values.yaml
prometheus:
  prometheusSpec:
    scrapeInterval: 60s  # Increase from 30s
    evaluationInterval: 60s  # Increase from 30s
```

### Reduce Cardinality
```yaml
# In prometheus-values.yaml
prometheus:
  prometheusSpec:
    # Drop high-cardinality labels
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: 'container_network_tcp_usage_total|container_network_udp_usage_total'
        action: drop
```

## Cleanup

```bash
# Remove monitoring stack
./cleanup.sh

# Or manually
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

## References

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Kubernetes Monitoring](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)
