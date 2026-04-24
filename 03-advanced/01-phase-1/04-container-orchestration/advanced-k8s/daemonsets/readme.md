# Kubernetes DaemonSets

## Overview

**Kubernetes DaemonSets** ensure that all (or some) nodes run a copy of a pod. DaemonSets are typically used for cluster-wide services like logging agents, monitoring agents, or network plugins.

## Basic DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-daemonset
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.14
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

## Node Selection

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
```

## Tolerations for System Nodes

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: system-daemonset
spec:
  selector:
    matchLabels:
      app: system-agent
  template:
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      containers:
      - name: system-agent
        image: system-agent:latest
```

## Update Strategy

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: rolling-update-daemonset
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      app: my-daemon
  template:
    spec:
      containers:
      - name: my-daemon
        image: my-daemon:v2
```

## Common Use Cases

### Log Collection
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    spec:
      containers:
      - name: log-collector
        image: fluentd:latest
        volumeMounts:
        - name: logs
          mountPath: /var/log
      volumes:
      - name: logs
        hostPath:
          path: /var/log
```

### Monitoring Agent
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-agent
spec:
  selector:
    matchLabels:
      app: monitoring-agent
  template:
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: monitoring-agent
        image: datadog/agent:latest
        env:
        - name: DD_API_KEY
          valueFrom:
            secretKeyRef:
              name: datadog-secret
              key: api-key
```

### Network Plugin
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-proxy
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  template:
    spec:
      hostNetwork: true
      containers:
      - name: kube-proxy
        image: k8s.gcr.io/kube-proxy:v1.28.0
        command:
        - /usr/local/bin/kube-proxy
        - --config=/var/lib/kube-proxy/config.conf
```

## DaemonSet Management

```bash
# Create DaemonSet
kubectl apply -f daemonset.yaml

# Get DaemonSets
kubectl get daemonsets

# Describe DaemonSet
kubectl describe daemonset my-daemonset

# Update DaemonSet
kubectl set image daemonset/my-daemonset container=new-image:tag

# Check rollout status
kubectl rollout status daemonset/my-daemonset

# Delete DaemonSet
kubectl delete daemonset my-daemonset
```

## Best Practices

- Use appropriate resource limits
- Configure proper tolerations
- Implement health checks
- Use rolling updates for zero-downtime
- Monitor DaemonSet pod distribution

## Troubleshooting

```bash
# Check DaemonSet status
kubectl get daemonset -o wide

# Check pods on specific node
kubectl get pods -o wide --field-selector spec.nodeName=node-name

# Check DaemonSet events
kubectl describe daemonset my-daemonset

# Check node taints
kubectl describe node node-name | grep Taints
```

## Conclusion

DaemonSets provide essential cluster-wide service deployment capabilities, ensuring critical system components run on every node in the cluster.