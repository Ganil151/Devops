# Kube-Prometheus-Stack: Kubernetes-Native Monitoring

The **Kube-Prometheus-Stack** (formerly known as Prometheus Operator) is the industry standard for monitoring Kubernetes clusters. It provides a complete observability stack including Prometheus, Grafana, Alertmanager, and a suite of exporters, all managed by the **Prometheus Operator**.

---

## 🏛️ Architecture Overview

The power of this stack lies in the **Operator Pattern**. Instead of manually managing configuration files, you interact with Kubernetes **Custom Resource Definitions (CRDs)**.

### The Component Map
- **Prometheus Operator**: The brain of the stack. It watches for CRDs and automatically generates Prometheus configuration.
- **Prometheus**: The core time-series database and scraping engine.
- **Alertmanager**: Handles alerts sent by Prometheus, deduplicates them, and sends notifications (Slack, PagerDuty, Email).
- **Grafana**: The visualization layer with pre-configured dashboards for Kubernetes components.
- **Node Exporter**: Collects hardware and OS metrics from every node.
- **Kube-State-Metrics**: Listens to the Kubernetes API server and generates metrics about the state of objects (pods, deployments, etc.).

### Monitoring Flow (Mermaid)
> **⚠️ Missing Image**: *Monitoring Flow* ('../../../../../09-Resources/03-Images-Diagrams/Kubernetes/KubeMonStack.png')

---

## 🚀 Installation Guide

The recommended way to deploy the stack is via **Helm**.

### 1. Add the Repository
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 2. Basic Installation
```bash
# Create a namespace
kubectl create namespace monitoring

# Install the stack
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring
```

### 3. Customizing the Installation
Create a `values.yaml` file to override defaults (e.g., persistence, external access):
```yaml
grafana:
  persistence:
    enabled: true
    storageClassName: standard
    size: 10Gi

prometheus:
  prometheusSpec:
    retention: 15d
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: standard
          resources:
            requests:
              storage: 20Gi
```
```bash
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring -f values.yaml
```

---

## 🛠️ Configuration (CRDs)

### ServiceMonitor
The `ServiceMonitor` tells Prometheus *which* services to scrape. It matches services based on labels.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
  labels:
    release: kube-prometheus # Crucial: Must match the Prometheus selector
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: web
    interval: 30s
```

### PrometheusRule
Define your alerts as Kubernetes objects.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: instance-alerts
  labels:
    release: kube-prometheus
spec:
  groups:
  - name: node-exporter.rules
    rules:
    - alert: NodeDown
      expr: up{job="node-exporter"} == 0
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Node {{ $labels.instance }} is down"
```

---

## 🔍 Best Practices
1. **Don't Edit Prometheus Config Directly**: Always use `ServiceMonitors` and `PodMonitors`.
2. **Label Management**: Ensure your CRDs have the correct labels (usually `release: <helm-release-name>`) so the Operator sees them.
3. **Storage**: Always enable persistence for Prometheus and Grafana in production.
4. **Relabeling**: Use `relabelings` in `ServiceMonitor` to clean up or transform metrics before they hit Prometheus.

---

**Next Steps**: Learn how to correlate these metrics with logs in the [ELK Stack Guide](../03-Logging-ELK/README.md) or dive deeper into [Advanced Kubernetes Patterns](../../../../README.md).
