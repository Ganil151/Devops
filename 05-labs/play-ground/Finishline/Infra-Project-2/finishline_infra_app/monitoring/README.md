# Monitoring Stack: Grafana + Prometheus

This directory contains the monitoring infrastructure for the Finishline EKS cluster using Grafana and Prometheus.

## Architecture

```
EKS Cluster
├── Prometheus (metrics collection)
│   ├── Node Exporter (node metrics)
│   ├── kube-state-metrics (Kubernetes metrics)
│   └── cAdvisor (container metrics)
├── Grafana (visualization)
│   ├── Dashboards
│   └── Alerts
└── AlertManager (alert routing)
```

## Components

### Prometheus
- Scrapes metrics from Kubernetes components and applications
- Stores time-series data locally
- Retention: 15 days (configurable)
- Storage: 50GB persistent volume

### Grafana
- Visualizes Prometheus metrics
- Pre-configured dashboards for EKS, nodes, pods
- Alert notifications
- User authentication

### Node Exporter
- Collects host-level metrics (CPU, memory, disk, network)
- Runs as DaemonSet on all nodes

### kube-state-metrics
- Exposes Kubernetes object metrics
- Pod, deployment, statefulset status

## Deployment

### Prerequisites
- EKS cluster running
- kubectl configured
- Helm 3.x installed

### Install via Helm

```bash
# Add Prometheus community Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus Stack (includes Prometheus, Grafana, AlertManager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml

# Install Grafana (if separate)
helm install grafana grafana/grafana \
  --namespace monitoring \
  --values grafana-values.yaml
```

### Access Grafana

```bash
# Port forward to Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Default credentials
# Username: admin
# Password: (check secret)
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Access Prometheus

```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
```

## Configuration Files

- `prometheus-values.yaml` - Prometheus Helm chart values
- `grafana-values.yaml` - Grafana Helm chart values
- `prometheus-rules.yaml` - Alert rules
- `dashboards/` - Pre-built Grafana dashboards

## Metrics Collected

### Node Metrics
- CPU usage, load average
- Memory usage, available
- Disk usage, I/O
- Network traffic

### Kubernetes Metrics
- Pod CPU/memory requests and limits
- Pod restart count
- Deployment replica status
- StatefulSet replica status
- Job completion status

### Application Metrics
- HTTP request rate
- Request latency
- Error rate
- Custom application metrics

## Alerting

Alerts are configured for:
- High CPU usage (>80%)
- High memory usage (>85%)
- Disk usage (>90%)
- Pod restart loops
- Node not ready
- Persistent volume usage

Configure alert destinations in `prometheus-rules.yaml`.

## Backup & Restore

### Backup Prometheus Data
```bash
kubectl exec -n monitoring prometheus-0 -- tar czf - /prometheus > prometheus-backup.tar.gz
```

### Backup Grafana Dashboards
```bash
kubectl exec -n monitoring grafana-0 -- grafana-cli admin export-dashboard > dashboards-backup.json
```

## Troubleshooting

### Prometheus not scraping metrics
```bash
kubectl logs -n monitoring prometheus-0
kubectl get targets -n monitoring
```

### Grafana not connecting to Prometheus
```bash
# Check datasource configuration
kubectl get configmap -n monitoring grafana-datasources -o yaml
```

### High disk usage
- Reduce retention period in `prometheus-values.yaml`
- Increase persistent volume size
- Enable compression

## Cost Optimization

- **Storage**: Prometheus uses local storage; adjust retention based on needs
- **Compute**: Adjust resource requests/limits in Helm values
- **No CloudWatch costs**: Eliminates CloudWatch Logs charges (~$24-112/month)

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
