# MySQL StatefulSet Example

This example demonstrates deploying a MySQL database with StatefulSets, including persistent storage, configuration via ConfigMap, and secure password management with Secrets.

## Prerequisites

- Kubernetes cluster running
- kubectl configured
- Storage class available (check with `kubectl get storageclass`)

---

## Step 1: Create MySQL Secret

Store the MySQL root password securely:

```bash
kubectl create secret generic mysql-secret \
  --from-literal=mysql-root-password='MySecureP@ssw0rd' \
  --from-literal=mysql-password='userP@ssw0rd'
```

Or create via YAML:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  # Base64 encoded: echo -n 'MySecureP@ssw0rd' | base64
  mysql-root-password: TXlTZWN1cmVQQHNzdzByZA==
  mysql-password: dXNlclBAc3N3MHJk
```

---

## Step 2: Create ConfigMap for MySQL Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  my.cnf: |
    [mysqld]
    default-authentication-plugin=mysql_native_password
    max_connections=200
    innodb_buffer_pool_size=256M
    character-set-server=utf8mb4
    collation-server=utf8mb4_unicode_ci
```

---

## Step 3: Create Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
  labels:
    app: mysql
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - name: mysql
    port: 3306
    targetPort: 3306
```

---

## Step 4: Create MySQL StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-headless
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - name: mysql
          containerPort: 3306
        env:
        # MySQL root password from Secret
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-root-password
        # Create a database on startup
        - name: MYSQL_DATABASE
          value: "myapp"
        # Create a non-root user
        - name: MYSQL_USER
          value: "appuser"
        # User password from Secret
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-password
        volumeMounts:
        # Main data directory
        - name: mysql-data
          mountPath: /var/lib/mysql
          subPath: mysql  # Avoid mounting to root of PVC
        # Custom configuration
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
        # Liveness probe: check if MySQL is alive
        livenessProbe:
          exec:
            command:
            - sh
            - -c
            - "mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD}"
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        # Readiness probe: check if MySQL is ready to accept connections
        readinessProbe:
          exec:
            command:
            - sh
            - -c
            - "mysql -u root -p${MYSQL_ROOT_PASSWORD} -e 'SELECT 1'"
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 2
        # Resource limits
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
      volumes:
      # Mount the ConfigMap
      - name: mysql-config
        configMap:
          name: mysql-config
  # PVC template for persistent storage
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "standard"  # Adjust to your storage class
      resources:
        requests:
          storage: 10Gi
```

---

## Step 5: Create Regular Service (Optional)

For applications that need to access MySQL via a stable endpoint:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  type: ClusterIP
  selector:
    app: mysql
  ports:
  - name: mysql
    port: 3306
    targetPort: 3306
```

---

## Deployment Commands

```bash
# Apply all resources
kubectl apply -f mysql-secret.yaml
kubectl apply -f mysql-configmap.yaml
kubectl apply -f mysql-headless-service.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f mysql-service.yaml

# Check StatefulSet status
kubectl get statefulset mysql

# Check pods
kubectl get pods -l app=mysql

# Check PVCs
kubectl get pvc -l app=mysql
```

---

## Accessing MySQL

### From Within the Cluster

```bash
# Using the headless service (direct pod access)
mysql-0.mysql-headless.default.svc.cluster.local:3306

# Using the regular service (load balanced)
mysql.default.svc.cluster.local:3306
```

### Test Connection

```bash
# Create a test pod
kubectl run mysql-client --rm -it --image=mysql:8.0 -- bash

# Inside the pod, connect to MySQL
mysql -h mysql-0.mysql-headless -u appuser -p
# Enter password when prompted: userP@ssw0rd

# Or using the service
mysql -h mysql -u appuser -p
```

---

## Common Operations

### Check MySQL Logs

```bash
kubectl logs mysql-0
```

### Execute Commands in MySQL Pod

```bash
kubectl exec -it mysql-0 -- bash

# Inside the pod
mysql -u root -p
```

### Backup Database

```bash
# Backup using mysqldump
kubectl exec mysql-0 -- mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > backup.sql

# Or create a backup job
kubectl exec mysql-0 -- sh -c 'mysqldump -u root -p${MYSQL_ROOT_PASSWORD} myapp > /tmp/myapp-backup.sql'
kubectl cp mysql-0:/tmp/myapp-backup.sql ./myapp-backup.sql
```

### Restore Database

```bash
# Copy backup to pod
kubectl cp ./myapp-backup.sql mysql-0:/tmp/myapp-backup.sql

# Restore
kubectl exec mysql-0 -- sh -c 'mysql -u root -p${MYSQL_ROOT_PASSWORD} myapp < /tmp/myapp-backup.sql'
```

### Scale MySQL (Replica Set)

For production, you might want MySQL replication:

```bash
# Scale to 3 replicas (requires additional configuration for replication)
kubectl scale statefulset mysql --replicas=3
```

> **Note**: MySQL replication requires additional configuration (master/slave setup) which is beyond this basic example.

---

## Cleanup

```bash
# Delete StatefulSet
kubectl delete statefulset mysql

# Delete Services
kubectl delete service mysql mysql-headless

# Delete ConfigMap
kubectl delete configmap mysql-config

# Delete Secret
kubectl delete secret mysql-secret

# Delete PVCs (WARNING: This deletes all data)
kubectl delete pvc mysql-data-mysql-0
```

---

## Best Practices

1. **Always use Secrets** for sensitive data like passwords
2. **Configure resource limits** to prevent resource exhaustion
3. **Implement health checks** (liveness and readiness probes)
4. **Use subPath** when mounting to avoid issues with lost+found directory
5. **Regular backups** are critical for production databases
6. **Monitor storage usage** to prevent running out of disk space
7. **Use appropriate storage class** (SSD for production databases)

---

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl describe pod mysql-0

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check logs
kubectl logs mysql-0
```

### PVC Not Binding

```bash
# Check PVC status
kubectl get pvc

# Check PV availability
kubectl get pv

# Check storage class
kubectl get storageclass
```

### Connection Issues

```bash
# Check if MySQL is listening
kubectl exec mysql-0 -- netstat -tulpn | grep 3306

# Check MySQL status
kubectl exec mysql-0 -- mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} status
```

---

## Next Steps

- Configure **MySQL replication** for high availability
- Implement **automated backups** using CronJobs
- Set up **monitoring** with Prometheus
- Configure **performance tuning** via ConfigMap
- Implement **TLS/SSL** for secure connections
