# Advanced Kubernetes StatefulSets

## Overview

**Kubernetes StatefulSets** manage stateful applications in production environments, providing stable network identities, persistent storage, and ordered deployment/scaling. This guide covers advanced patterns, production best practices, and enterprise-grade configurations for StatefulSets.

> **Prerequisites**: Familiarity with basic StatefulSet concepts. See [Intermediate StatefulSets](../../../2-Intermediate/01-Kubernetes/Intermediate/StatefulSets/) for fundamentals.

---

## StatefulSet vs Deployment vs DaemonSet

| Feature | StatefulSet | Deployment | DaemonSet |
|---------|-------------|------------|----------|
| **Pod Identity** | Stable, ordinal-based | Random, ephemeral | Node-specific |
| **Naming** | Predictable (web-0, web-1) | Random hash suffix | One per node |
| **Storage** | Dedicated PVC per pod | Shared or ephemeral | Typically host paths |
| **Scaling** | Ordered, sequential | Parallel, simultaneous | Auto-scales with nodes |
| **Updates** | Reverse-ordinal rolling | Configurable rolling | Rolling per node |
| **DNS** | Stable hostname per pod | Service-level only | Per node |
| **Primary Use Case** | Databases, stateful apps | Web apps, APIs | Node agents, logging |
| **Data Persistence** | Required | Optional | Usually not needed |
| **Startup Order** | Matters (ordered) | Doesn't matter | Per node |
| **Pod Replaceability** | Not interchangeable | Fully interchangeable | Node-bound |

---

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

## Production Best Practices

### 1. Storage Configuration

```yaml
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      # Use high-performance storage for databases
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: 100Gi
```

**Best Practices:**
- Use SSD-backed storage classes for databases
- Size PVCs appropriately (allow for growth)
- Enable volume snapshots for backups
- Consider storage IOPS requirements
- Monitor disk usage and set alerts at 80%

### 2. Resource Management and QoS

```yaml
resources:
  requests:
    memory: "2Gi"
    cpu: "1000m"
    # Ensures pod gets guaranteed QoS class
  limits:
    memory: "2Gi"  # Same as request for Guaranteed QoS
    cpu: "2000m"
```

**QoS Classes:**
- **Guaranteed**: requests == limits (best for StatefulSets)
- **Burstable**: requests < limits (acceptable for non-critical)
- **BestEffort**: No requests/limits (avoid for StatefulSets)

### 3. Pod Disruption Budgets

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: postgres-pdb
spec:
  minAvailable: 2  # Always keep 2 pods running
  selector:
    matchLabels:
      app: postgres
```

### 4. Anti-Affinity for High Availability

```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - postgres
      topologyKey: kubernetes.io/hostname
```

Ensures pods are spread across different nodes.

### 5. Init Containers for Setup

```yaml
initContainers:
- name: init-permissions
  image: busybox
  command:
  - sh
  - -c
  - |
    chown -R 999:999 /data
    chmod 700 /data
  volumeMounts:
  - name: data
    mountPath: /data
```

### 6. Readiness and Liveness Probes

```yaml
livenessProbe:
  exec:
    command:
    - sh
    - -c
    - "pg_isready -U postgres"
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  exec:
    command:
    - sh
    - -c
    - "pg_isready -U postgres && psql -U postgres -c 'SELECT 1'"
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 2
  failureThreshold: 3
```

### 7. Graceful Shutdown

```yaml
terminationGracePeriodSeconds: 60  # Allow time for graceful shutdown

lifecycle:
  preStop:
    exec:
      command:
      - sh
      - -c
      - |
        # Drain connections before shutdown
        pg_ctl stop -D /data -m fast
```

### 8. Security Context

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 999
  fsGroup: 999
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
```

---

## Advanced Patterns

### Pattern 1: Canary Deployments with Partition

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 2  # Only update pods with ordinal >= 2
```

**Use Case**: Test new version on highest-ordinal pod before full rollout.

**Workflow:**
<b>1. Set partition to N-1</b>
<details>
<summary>Show Answer</summary>
Answer: update only last pod
</details>

2. Monitor metrics and logs
3. If successful, gradually decrease partition
4. Set partition to 0 for full rollout

### Pattern 2: Blue-Green Deployments

```yaml
# Blue StatefulSet (current)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: app-blue
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: myapp
        version: blue
---
# Green StatefulSet (new)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: app-green
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: myapp
        version: green
---
# Service switches between blue and green
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    version: blue  # Switch to 'green' when ready
```

### Pattern 3: Database Replication (Primary-Replica)

```yaml
# Init container determines if pod is primary or replica
initContainers:
- name: init-mysql
  image: mysql:8.0
  command:
  - bash
  - "-c"
  - |
    set -ex
    # Generate server-id from pod ordinal index
    [[ $(hostname) =~ -([0-9]+)$ ]] || exit 1
    ordinal=${BASH_REMATCH[1]}
    echo [mysqld] > /mnt/conf.d/server-id.cnf
    echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
    # Copy appropriate conf.d files from config-map to emptyDir
    if [[ $ordinal -eq 0 ]]; then
      cp /mnt/config-map/primary.cnf /mnt/conf.d/
    else
      cp /mnt/config-map/replica.cnf /mnt/conf.d/
    fi
  volumeMounts:
  - name: conf
    mountPath: /mnt/conf.d
  - name: config-map
    mountPath: /mnt/config-map
```

---

## Common Anti-Patterns (What to Avoid)

### ❌ Anti-Pattern 1: Using Deployments for Stateful Apps

**Problem**: Pods lose identity and data on restart.

**Solution**: Always use StatefulSets for stateful applications.

### ❌ Anti-Pattern 2: Not Setting PodDisruptionBudget

**Problem**: Cluster maintenance can take down all pods simultaneously.

**Solution**: Configure PDB to maintain minimum availability.

### ❌ Anti-Pattern 3: Deleting PVCs Without Backup

**Problem**: Permanent data loss.

**Solution**: 
```bash
# Backup before deletion
kubectl exec statefulset-0 -- pg_dump dbname > backup.sql
# Then delete
kubectl delete pvc data-statefulset-0
```

### ❌ Anti-Pattern 4: Not Using Headless Services

**Problem**: Cannot address specific pods by hostname.

**Solution**: Always create a headless service with `clusterIP: None`.

### ❌ Anti-Pattern 5: Inadequate Resource Limits

**Problem**: Pods can be OOM-killed, causing data corruption.

**Solution**: Set appropriate requests and limits, prefer Guaranteed QoS.

### ❌ Anti-Pattern 6: Parallel Pod Management for Ordered Apps

**Problem**: Breaks initialization dependencies.

**Solution**: Use `podManagementPolicy: OrderedReady` (default) for apps with dependencies.

### ❌ Anti-Pattern 7: Using `latest` Image Tag

**Problem**: Unpredictable updates, hard to rollback.

**Solution**: Use specific version tags (e.g., `postgres:14.5`).

---

## Advanced Troubleshooting

### Issue 1: Pods Stuck in Pending

**Symptoms:**
```bash
kubectl get pods -l app=myapp
# NAME     READY   STATUS    RESTARTS   AGE
# app-0    0/1     Pending   0          5m
```

**Diagnosis:**
```bash
# Check pod events
kubectl describe pod app-0 | grep -A 10 Events

# Check PVC status
kubectl get pvc
# If PVC is Pending, check PV availability
kubectl get pv

# Check storage class
kubectl describe storageclass fast-ssd
```

**Common Causes:**
- No available PersistentVolumes
- Storage class not found
- Insufficient resources on nodes
- Zone/region affinity conflicts

**Solution:**
```bash
# Check provisioner logs
kubectl logs -n kube-system -l app=ebs-csi-controller

# Manually create PV if using static provisioning
# Or ensure dynamic provisioner is working
```

### Issue 2: Pods Not Reaching Ready State

**Diagnosis:**
```bash
# Check readiness probe failures
kubectl describe pod app-0 | grep -A 5 Readiness

# Check application logs
kubectl logs app-0

# Execute commands in pod
kubectl exec -it app-0 -- bash
```

**Common Causes:**
- Readiness probe misconfigured
- Application taking too long to start
- Dependencies not available

**Solution:**
```yaml
# Adjust probe timings
readinessProbe:
  initialDelaySeconds: 30  # Increase if app is slow to start
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### Issue 3: Data Loss After Pod Restart

**Diagnosis:**
```bash
# Check if PVC is bound
kubectl get pvc data-app-0

# Check mount point
kubectl exec app-0 -- df -h | grep /data

# Verify PV still exists
kubectl get pv | grep data-app-0
```

**Common Causes:**
- PVC deleted accidentally
- Wrong mount path
- Using emptyDir instead of PVC

**Solution:**
```bash
# Restore from backup
kubectl cp backup.sql app-0:/tmp/
kubectl exec app-0 -- restore-script.sh
```

### Issue 4: StatefulSet Not Scaling

**Diagnosis:**
```bash
# Check StatefulSet status
kubectl describe statefulset app

# Look for controller errors
kubectl logs -n kube-system -l component=kube-controller-manager
```

**Common Causes:**
- Previous pod not Ready
- Resource quotas exceeded
- PVC creation failures

**Solution:**
```bash
# Check if current replicas are all Ready
kubectl get pods -l app=myapp

# Check resource quotas
kubectl describe resourcequota
```

### Issue 5: Slow Rolling Updates

**Diagnosis:**
```bash
# Monitor update progress
kubectl rollout status statefulset/app

# Check update strategy
kubectl get statefulset app -o yaml | grep -A 5 updateStrategy
```

**Solution:**
```yaml
# Use partition for faster updates of specific pods
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    partition: 0

# Or use Parallel pod management
podManagementPolicy: Parallel
```

### Issue 6: PVC Can't Bind to PV

**Diagnosis:**
```bash
# Check PVC status
kubectl describe pvc data-app-0

# Check PV availability
kubectl get pv --sort-by=.metadata.creationTimestamp

# Check storageclass
kubectl get storageclass
```

**Common Causes:**
- No PV matches PVC requirements
- Access mode mismatch
- Storage size too large
- Zone affinity issues

**Solution:**
```bash
# Create matching PV or fix storage class provisioner
# Check CSI driver logs
kubectl logs -n kube-system -l app=csi-driver
```

### Useful Debug Commands

```bash
# Check StatefulSet status
kubectl get statefulset -o wide

# Check all pods with ordering
kubectl get pods -l app=nginx --sort-by=.metadata.name

# Check PVCs
kubectl get pvc -l app=nginx

# Check detailed events
kubectl get events --sort-by='.lastTimestamp' | grep statefulset

# Check pod logs
kubectl logs web-0 --previous  # Previous instance logs

# Describe StatefulSet
kubectl describe statefulset web

# Check pod YAML
kubectl get pod web-0 -o yaml

# Force delete stuck pod
kubectl delete pod web-0 --grace-period=0 --force

# Check controller logs
kubectl logs -n kube-system -l component=kube-controller-manager
```

## Use Cases

- **Databases**: PostgreSQL, MySQL, MongoDB
- **Message Queues**: Kafka, RabbitMQ
- **Distributed Systems**: Elasticsearch, Cassandra
- **Caching**: Redis Cluster

## Backup and Disaster Recovery

### Strategy 1: Volume Snapshots (CSI)

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: postgres-snapshot
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: data-postgres-0
```

### Strategy 2: Application-Level Backups

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
spec:
  schedule: "0 2 * * *"  # 2 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:14
            command:
            - sh
            - -c
            - |
              pg_dump -h postgres-0.postgres-headless \
                -U postgres dbname > /backup/backup-$(date +%Y%m%d).sql
              # Upload to S3 or other storage
            volumeMounts:
            - name: backup
              mountPath: /backup
          volumes:
          - name: backup
            persistentVolumeClaim:
              claimName: backup-storage
          restartPolicy: OnFailure
```

---

## Monitoring and Observability

### Key Metrics to Monitor

1. **Pod Status**: All pods Running and Ready
2. **PVC Usage**: Disk space utilization
3. **Replication Lag**: For database replicas
4. **Update Progress**: During rolling updates
5. **Resource Usage**: CPU, memory per pod

### Prometheus ServiceMonitor Example

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: postgres-metrics
spec:
  selector:
    matchLabels:
      app: postgres
  endpoints:
  - port: metrics
    interval: 30s
```

---

## Related Documentation

- **[Intermediate StatefulSets](../../../2-Intermediate/01-Kubernetes/Intermediate/StatefulSets/)**: Core concepts and basic examples
- **[StatefulSet Diagrams](../../../2-Intermediate/01-Kubernetes/Beginner/Diagrams/statefulsets/)**: Visual architecture guides
- **[Persistent Volumes](../../../2-Intermediate/01-Kubernetes/Intermediate/PersistentVolumes/)**: Storage fundamentals
- **[Pod Disruption Budgets](./Autoscaling/pdb/)**: Availability management
- **[VPA with StatefulSets](./Autoscaling/vpa/)**: Vertical scaling patterns

---

## Conclusion

StatefulSets are essential for running production stateful applications in Kubernetes. Key takeaways:

✅ **Use for stateful workloads** requiring stable identities and persistent storage
✅ **Configure resource limits** with Guaranteed QoS class
✅ **Implement PodDisruptionBudgets** for high availability
✅ **Use anti-affinity rules** to spread pods across nodes
✅ **Regular backups** are critical for data safety
✅ **Monitor PVC usage** to prevent storage exhaustion
✅ **Test disaster recovery** procedures regularly

For production deployments, combine StatefulSets with proper monitoring, backup strategies, and disaster recovery plans.