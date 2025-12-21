# Redis Cluster StatefulSet Example

This example demonstrates deploying a Redis cluster using StatefulSets with persistent storage and proper cluster configuration.

## Overview

Redis Cluster provides:
- **High Availability**: Automatic failover
- **Horizontal Scaling**: Data sharding across multiple nodes
- **Data Persistence**: Persistent storage for each Redis instance

---

## Architecture

A minimal Redis Cluster requires:
- **3 Master nodes**: Each holds a portion of data (hash slots)
- **3 Replica nodes**: One replica per master for failover
- **Total: 6 Redis instances**

---

## Step 1: Create ConfigMap for Redis Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-cluster-config
data:
  redis.conf: |
    cluster-enabled yes
    cluster-config-file /data/nodes.conf
    cluster-node-timeout 5000
    appendonly yes
    appendfilename "appendonly.aof"
    dir /data
    port 6379
    protected-mode no
    # Persistence settings
    save 900 1
    save 300 10
    save 60 10000
    # Memory management
    maxmemory 256mb
    maxmemory-policy allkeys-lru
```

---

## Step 2: Create Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-cluster-headless
  labels:
    app: redis-cluster
spec:
  clusterIP: None
  selector:
    app: redis-cluster
  ports:
  - name: redis
    port: 6379
    targetPort: 6379
  - name: cluster
    port: 16379
    targetPort: 16379
```

---

## Step 3: Create Redis StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster
spec:
  serviceName: redis-cluster-headless
  replicas: 6  # 3 masters + 3 replicas
  selector:
    matchLabels:
      app: redis-cluster
  template:
    metadata:
      labels:
        app: redis-cluster
    spec:
      containers:
      - name: redis
        image: redis:7.0-alpine
        command:
        - redis-server
        - /etc/redis/redis.conf
        ports:
        - name: redis
          containerPort: 6379
        - name: cluster
          containerPort: 16379
        volumeMounts:
        # Data directory
        - name: redis-data
          mountPath: /data
        # Configuration
        - name: redis-config
          mountPath: /etc/redis
        # Liveness probe
        livenessProbe:
          exec:
            command:
            - sh
            - -c
            - "redis-cli ping | grep PONG"
          initialDelaySeconds: 30
          periodSeconds: 10
        # Readiness probe
        readinessProbe:
          exec:
            command:
            - sh
            - -c
            - "redis-cli ping | grep PONG"
          initialDelaySeconds: 5
          periodSeconds: 5
        # Resource limits
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: redis-config
        configMap:
          name: redis-cluster-config
  # PVC for each pod
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "standard"
      resources:
        requests:
          storage: 1Gi
```

---

## Step 4: Create Regular Service for Client Access

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-cluster
  labels:
    app: redis-cluster
spec:
  type: ClusterIP
  selector:
    app: redis-cluster
  ports:
  - name: redis
    port: 6379
    targetPort: 6379
  - name: cluster
    port: 16379
    targetPort: 16379
```

---

## Step 5: Initialize Redis Cluster

After all pods are running, initialize the cluster:

```bash
# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app=redis-cluster --timeout=300s

# Get pod IPs
kubectl get pods -l app=redis-cluster -o wide

# Create cluster by connecting to one of the pods
kubectl exec -it redis-cluster-0 -- redis-cli --cluster create \
  $(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ') \
  --cluster-replicas 1 \
  --cluster-yes
```

Or use this helper script:

```bash
#!/bin/bash
# init-redis-cluster.sh

# Get all pod IPs
REDIS_NODES=$(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')

echo "Creating Redis Cluster with nodes: $REDIS_NODES"

# Execute cluster create command
kubectl exec -it redis-cluster-0 -- redis-cli --cluster create \
  $REDIS_NODES \
  --cluster-replicas 1 \
  --cluster-yes

echo "Cluster created successfully!"

# Verify cluster status
kubectl exec -it redis-cluster-0 -- redis-cli cluster info
kubectl exec -it redis-cluster-0 -- redis-cli cluster nodes
```

---

## Deployment Commands

```bash
# Step 1: Apply ConfigMap
kubectl apply -f redis-configmap.yaml

# Step 2: Apply Services
kubectl apply -f redis-headless-service.yaml
kubectl apply -f redis-service.yaml

# Step 3: Apply StatefulSet
kubectl apply -f redis-statefulset.yaml

# Step 4: Wait for pods to be ready
kubectl get pods -l app=redis-cluster -w

# Step 5: Initialize cluster
chmod +x init-redis-cluster.sh
./init-redis-cluster.sh
```

---

## Verify Cluster Status

```bash
# Check cluster info
kubectl exec -it redis-cluster-0 -- redis-cli cluster info

# Check cluster nodes
kubectl exec -it redis-cluster-0 -- redis-cli cluster nodes

# Check specific pod role (master or slave)
kubectl exec -it redis-cluster-0 -- redis-cli role

# Check keyspace distribution
kubectl exec -it redis-cluster-0 -- redis-cli cluster slots
```

---

## Testing the Cluster

### Set and Get Data

```bash
# Connect to Redis CLI in cluster mode
kubectl exec -it redis-cluster-0 -- redis-cli -c

# Inside redis-cli
> SET user:1 "John Doe"
OK

> GET user:1
"John Doe"

# Check which node holds the key
> CLUSTER KEYSLOT user:1
(integer) 9842

# Set multiple keys
> SET product:101 "Laptop"
> SET product:102 "Mouse"
> SET product:103 "Keyboard"

# Verify data distribution
> KEYS *
```

### Test Failover

```bash
# Delete a master pod to trigger failover
kubectl delete pod redis-cluster-0

# Watch cluster rebalance
kubectl exec -it redis-cluster-1 -- redis-cli cluster nodes

# The replica will be promoted to master
```

---

## Accessing Redis from Applications

### DNS Hostnames

Each Redis instance is accessible via:
```
redis-cluster-0.redis-cluster-headless.default.svc.cluster.local:6379
redis-cluster-1.redis-cluster-headless.default.svc.cluster.local:6379
redis-cluster-2.redis-cluster-headless.default.svc.cluster.local:6379
...
```

### Example Application Connection (Python)

```python
from rediscluster import RedisCluster

startup_nodes = [
    {"host": "redis-cluster-0.redis-cluster-headless", "port": "6379"},
    {"host": "redis-cluster-1.redis-cluster-headless", "port": "6379"},
    {"host": "redis-cluster-2.redis-cluster-headless", "port": "6379"}
]

rc = RedisCluster(startup_nodes=startup_nodes, decode_responses=True)

# Set a key
rc.set("mykey", "myvalue")

# Get a key
value = rc.get("mykey")
print(value)  # Output: myvalue
```

### Example Application Connection (Go)

```go
package main

import (
    "github.com/go-redis/redis/v8"
    "context"
)

func main() {
    ctx := context.Background()
    
    rdb := redis.NewClusterClient(&redis.ClusterOptions{
        Addrs: []string{
            "redis-cluster-0.redis-cluster-headless:6379",
            "redis-cluster-1.redis-cluster-headless:6379",
            "redis-cluster-2.redis-cluster-headless:6379",
        },
    })

    // Set a key
    err := rdb.Set(ctx, "key", "value", 0).Err()
    
    // Get a key
    val, err := rdb.Get(ctx, "key").Result()
    println(val)
}
```

---

## Scaling the Cluster

### Add More Nodes

```bash
# Scale to 9 nodes (for more replicas)
kubectl scale statefulset redis-cluster --replicas=9

# Wait for new pods
kubectl wait --for=condition=ready pod -l app=redis-cluster --timeout=300s

# Add new nodes to cluster
kubectl exec -it redis-cluster-0 -- redis-cli --cluster add-node \
  <new-node-ip>:6379 \
  <existing-node-ip>:6379

# Rebalance the cluster
kubectl exec -it redis-cluster-0 -- redis-cli --cluster rebalance \
  <cluster-node-ip>:6379
```

---

## Monitoring

```bash
# Check memory usage
kubectl exec -it redis-cluster-0 -- redis-cli info memory

# Check connected clients
kubectl exec -it redis-cluster-0 -- redis-cli info clients

# Check persistence status
kubectl exec -it redis-cluster-0 -- redis-cli info persistence

# Monitor in real-time
kubectl exec -it redis-cluster-0 -- redis-cli --stat
```

---

## Backup and Restore

### Manual Backup

```bash
# Trigger RDB snapshot
kubectl exec -it redis-cluster-0 -- redis-cli BGSAVE

# Wait for save to complete
kubectl exec -it redis-cluster-0 -- redis-cli LASTSAVE

# Copy dump file
kubectl cp redis-cluster-0:/data/dump.rdb ./redis-backup-$(date +%Y%m%d).rdb
```

### Restore from Backup

```bash
# Copy backup to pod
kubectl cp ./redis-backup.rdb redis-cluster-0:/data/dump.rdb

# Restart Redis
kubectl delete pod redis-cluster-0
```

---

## Cleanup

```bash
# Delete StatefulSet
kubectl delete statefulset redis-cluster

# Delete Services
kubectl delete service redis-cluster redis-cluster-headless

# Delete ConfigMap
kubectl delete configmap redis-cluster-config

# Delete PVCs (WARNING: This deletes all data)
kubectl delete pvc -l app=redis-cluster
```

---

## Troubleshooting

### Cluster Not Forming

```bash
# Check cluster state on each node
for i in {0..5}; do
  kubectl exec redis-cluster-$i -- redis-cli cluster info
done

# Check cluster nodes
kubectl exec redis-cluster-0 -- redis-cli cluster nodes

# Reset cluster if needed (WARNING: Data loss)
kubectl exec redis-cluster-0 -- redis-cli CLUSTER RESET
```

### Connection Issues

```bash
# Test connectivity between pods
kubectl exec redis-cluster-0 -- ping redis-cluster-1.redis-cluster-headless

# Check Redis is listening
kubectl exec redis-cluster-0 -- netstat -tulpn | grep 6379

# Check firewall/network policies
kubectl get networkpolicies
```

### Performance Issues

```bash
# Check slow queries
kubectl exec redis-cluster-0 -- redis-cli SLOWLOG GET 10

# Monitor operations per second
kubectl exec redis-cluster-0 -- redis-cli --stat

# Check memory fragmentation
kubectl exec redis-cluster-0 -- redis-cli info memory | grep fragmentation
```

---

## Best Practices

1. **Use odd number of masters** (3, 5, 7) for quorum
2. **Configure resource limits** to prevent OOM kills
3. **Enable persistence** (AOF and RDB) for data durability
4. **Regular backups** especially before cluster operations
5. **Monitor memory usage** and set appropriate maxmemory
6. **Use cluster mode** in client applications
7. **Plan for failover** - ensure replicas are on different nodes
8. **Network policies** to secure Redis communication

---

## Next Steps

- Configure **authentication** with requirepass
- Enable **TLS/SSL** for encrypted communication
- Set up **monitoring** with Prometheus and Grafana
- Implement **automated backups** using CronJobs
- Configure **anti-affinity** to spread pods across nodes
