# Intermediate Level: Observability

Deploying applications is only half the battle. You need to know if they are healthy, performing well, and what errors they are generating.

## 🎯 Learning Objectives
- specific distinctions between **Logging** and **Monitoring**.
- Access pod logs.
- Introduction to **Prometheus** and **Grafana**.

## 1. Logging
Kubernetes does not store logs permanently. If a pod dies, its logs are lost unless collected.

### Basic Logging
```bash
# Get logs for a pod
kubectl logs my-pod

# Stream logs
kubectl logs -f my-pod

# Logs for a specific container in a multi-container pod
kubectl logs my-pod -c my-container
```

### Centralized Logging (The EFK Stack)
In production, you often use:
- **Elasticsearch**: Database for logs.
- **Fluentd/Fluent Bit**: Collector running on every node (DaemonSet) to ship logs.
- **Kibana**: UI to search/visualize logs.

## 2. Monitoring (Metrics)
Metrics tell you "how much" (CPU, RAM, Request Rate) and "how many" (Errors, Saturation).

### Metrics Server
Enables `kubectl top` commands and Horizontal Pod Autoscaling (HPA).
```bash
# View node usage
kubectl top nodes

# View pod usage
kubectl top pods
```

### Prometheus & Grafana
- **Prometheus**: Time-series database that "scrapes" metrics from your pods and nodes.
- **Grafana**: Visualization tool to build dashboards from Prometheus data.

## 3. Health Checks (Probes)
Kubernetes needs to know if your app is alive (Liveness) and ready to receive traffic (Readiness).

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 3
  periodSeconds: 3
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
```
- **Liveness Fail**: Kubelet restarts the container.
- **Readiness Fail**: Endpoints controller removes pod from Service load balancing.

[Back to Intermediate Index](../README.md)
