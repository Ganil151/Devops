# Kubernetes StatefulSets

## Overview

**Kubernetes StatefulSets** manage stateful applications, providing stable network identities, persistent storage, and ordered deployment/scaling. StatefulSets are ideal for databases, message queues, and other stateful services.

## Basic StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: 1Gi
```

## Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
```

## Database StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          value: postgres
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: 10Gi
```

## Ordered Deployment

StatefulSets deploy pods in order:
- web-0 is created first
- web-1 is created after web-0 is Running and Ready
- web-2 is created after web-1 is Running and Ready

## Stable Network Identity

Each pod gets a stable hostname:
- web-0.nginx.default.svc.cluster.local
- web-1.nginx.default.svc.cluster.local
- web-2.nginx.default.svc.cluster.local

## Update Strategies

### Rolling Update (Default)
```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
```

### On Delete
```yaml
spec:
  updateStrategy:
    type: OnDelete
```

## Pod Management Policy

### OrderedReady (Default)
```yaml
spec:
  podManagementPolicy: OrderedReady
```

### Parallel
```yaml
spec:
  podManagementPolicy: Parallel
```

## StatefulSet Management

```bash
# Create StatefulSet
kubectl apply -f statefulset.yaml

# Get StatefulSets
kubectl get statefulsets

# Scale StatefulSet
kubectl scale statefulset web --replicas=5

# Update StatefulSet
kubectl patch statefulset web -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.21"}]}}}}'

# Delete StatefulSet (keep PVCs)
kubectl delete statefulset web --cascade=orphan

# Delete StatefulSet and PVCs
kubectl delete statefulset web
kubectl delete pvc -l app=nginx
```

## Persistent Volume Claims

StatefulSets automatically create PVCs:
- www-web-0
- www-web-1
- www-web-2

## Best Practices

- Use headless services for StatefulSets
- Configure appropriate storage classes
- Implement proper backup strategies
- Use init containers for setup tasks
- Monitor persistent volume usage

## Troubleshooting

```bash
# Check StatefulSet status
kubectl get statefulset -o wide

# Check pod order
kubectl get pods -l app=nginx -o wide

# Check PVCs
kubectl get pvc -l app=nginx

# Check events
kubectl describe statefulset web

# Check pod logs
kubectl logs web-0
```

## Use Cases

- **Databases**: PostgreSQL, MySQL, MongoDB
- **Message Queues**: Kafka, RabbitMQ
- **Distributed Systems**: Elasticsearch, Cassandra
- **Caching**: Redis Cluster

## Conclusion

StatefulSets provide essential capabilities for running stateful applications in Kubernetes, offering stable identities, persistent storage, and ordered operations.