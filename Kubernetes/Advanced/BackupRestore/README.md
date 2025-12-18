# Kubernetes Backup and Restore

## Overview

**Kubernetes Backup and Restore** encompasses strategies and tools for protecting cluster state, application data, and configurations. A comprehensive backup strategy includes cluster metadata, persistent volumes, and application-specific data.

## Backup Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                Kubernetes Backup Strategy                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Cluster   │  │   Volume    │  │  Application    │     │
│  │  Metadata   │  │    Data     │  │     Data        │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │    etcd     │  │  Snapshots  │  │   Database      │     │
│  │   Backup    │  │   & CSI     │  │    Dumps        │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│                          │                 │              │
│                          ▼                 ▼              │
│                   ┌─────────────────────────────────┐     │
│                   │      Backup Storage             │     │
│                   │   (S3, GCS, Azure, etc.)       │     │
│                   └─────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Backup Components

### 1. Cluster State Backup (etcd)
```bash
# etcd snapshot backup
ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify snapshot
ETCDCTL_API=3 etcdctl snapshot status /backup/etcd-snapshot.db --write-out=table
```

### 2. Kubernetes Resources Backup
```bash
# Backup all resources in a namespace
kubectl get all,pvc,secrets,configmaps -n production -o yaml > production-backup.yaml

# Backup specific resource types
kubectl get deployments,services,ingress --all-namespaces -o yaml > workloads-backup.yaml

# Backup cluster-wide resources
kubectl get clusterroles,clusterrolebindings,storageclasses -o yaml > cluster-resources-backup.yaml
```

### 3. Persistent Volume Backup
```yaml
# Volume snapshot for backup
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: database-backup-snapshot
  namespace: production
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: database-pvc
```

## Backup Tools

### Velero (Recommended)

#### Velero Installation
```bash
# Install Velero CLI
curl -fsSL -o velero-v1.12.1-linux-amd64.tar.gz \
  https://github.com/vmware-tanzu/velero/releases/download/v1.12.1/velero-v1.12.1-linux-amd64.tar.gz
tar -xzf velero-v1.12.1-linux-amd64.tar.gz
sudo mv velero-v1.12.1-linux-amd64/velero /usr/local/bin/

# Install Velero server (AWS example)
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.8.0 \
  --bucket velero-backups \
  --backup-location-config region=us-west-2 \
  --snapshot-location-config region=us-west-2 \
  --secret-file ./credentials-velero
```

#### Velero Backup Configuration
```yaml
# Backup storage location
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: aws-s3
  namespace: velero
spec:
  provider: aws
  objectStorage:
    bucket: velero-backups
    prefix: cluster-1
  config:
    region: us-west-2
    s3ForcePathStyle: "false"
---
# Volume snapshot location
apiVersion: velero.io/v1
kind: VolumeSnapshotLocation
metadata:
  name: aws-ebs
  namespace: velero
spec:
  provider: aws
  config:
    region: us-west-2
```

#### Velero Backup Examples
```bash
# Full cluster backup
velero backup create full-backup --include-namespaces '*'

# Namespace-specific backup
velero backup create production-backup --include-namespaces production

# Selective resource backup
velero backup create app-backup \
  --include-namespaces production \
  --include-resources deployments,services,configmaps,secrets

# Backup with volume snapshots
velero backup create full-backup-with-volumes \
  --include-namespaces production \
  --snapshot-volumes=true

# Scheduled backup
velero schedule create daily-backup \
  --schedule="0 2 * * *" \
  --include-namespaces production \
  --ttl 720h0m0s
```

#### Velero Restore Examples
```bash
# List available backups
velero backup get

# Restore from backup
velero restore create --from-backup production-backup

# Restore to different namespace
velero restore create --from-backup production-backup \
  --namespace-mappings production:staging

# Restore specific resources
velero restore create --from-backup full-backup \
  --include-resources deployments,services

# Restore with different storage class
velero restore create --from-backup production-backup \
  --restore-volumes=true \
  --storage-class-mappings old-storage:new-storage
```

### Kasten K10

#### K10 Installation
```bash
# Add Kasten Helm repository
helm repo add kasten https://charts.kasten.io/
helm repo update

# Install K10
helm install k10 kasten/k10 --namespace kasten-io --create-namespace

# Get K10 dashboard URL
kubectl --namespace kasten-io port-forward service/gateway 8080:8000
```

#### K10 Policy Configuration
```yaml
apiVersion: config.kio.kasten.io/v1alpha1
kind: Policy
metadata:
  name: production-backup-policy
  namespace: kasten-io
spec:
  frequency: "@daily"
  retention:
    daily: 7
    weekly: 4
    monthly: 12
    yearly: 1
  actions:
  - action: backup
    backupParameters:
      profile:
        name: s3-profile
      filters:
        includeResources:
        - group: ""
          version: v1
          resource: persistentvolumeclaims
        - group: apps
          version: v1
          resource: deployments
        includeNamespaces:
        - production
```

### Stash (Backup Operator)

#### Stash Installation
```bash
# Install Stash operator
helm repo add appscode https://charts.appscode.com/stable/
helm install stash appscode/stash --namespace kube-system
```

#### Stash Backup Configuration
```yaml
# Repository for storing backups
apiVersion: stash.appscode.com/v1alpha1
kind: Repository
metadata:
  name: s3-repo
  namespace: production
spec:
  backend:
    s3:
      endpoint: s3.amazonaws.com
      bucket: stash-backups
      prefix: /production
      region: us-west-2
    storageSecretName: s3-secret
---
# Backup configuration
apiVersion: stash.appscode.com/v1beta1
kind: BackupConfiguration
metadata:
  name: database-backup
  namespace: production
spec:
  repository:
    name: s3-repo
  schedule: "0 2 * * *"
  target:
    ref:
      apiVersion: apps/v1
      kind: StatefulSet
      name: database
    volumeMounts:
    - name: data
      mountPath: /var/lib/postgresql/data
  retentionPolicy:
    name: keep-last-30
    keepLast: 30
    prune: true
```

## Database-Specific Backups

### PostgreSQL Backup
```yaml
# PostgreSQL backup CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: production
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: postgres-backup
            image: postgres:13
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            command:
            - /bin/bash
            - -c
            - |
              DATE=$(date +%Y%m%d-%H%M%S)
              pg_dump -h postgres-service -U postgres -d myapp > /backup/postgres-backup-$DATE.sql
              # Upload to S3
              aws s3 cp /backup/postgres-backup-$DATE.sql s3://backups/postgres/
              # Cleanup local files older than 7 days
              find /backup -name "postgres-backup-*.sql" -mtime +7 -delete
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
```

### MySQL Backup
```yaml
# MySQL backup with mysqldump
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mysql-backup
  namespace: production
spec:
  schedule: "0 3 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: mysql-backup
            image: mysql:8.0
            env:
            - name: MYSQL_PWD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: password
            command:
            - /bin/bash
            - -c
            - |
              DATE=$(date +%Y%m%d-%H%M%S)
              mysqldump -h mysql-service -u root --single-transaction --routines --triggers myapp > /backup/mysql-backup-$DATE.sql
              gzip /backup/mysql-backup-$DATE.sql
              # Upload to cloud storage
              aws s3 cp /backup/mysql-backup-$DATE.sql.gz s3://backups/mysql/
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          restartPolicy: OnFailure
```

### MongoDB Backup
```yaml
# MongoDB backup with mongodump
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mongodb-backup
  namespace: production
spec:
  schedule: "0 1 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: mongodb-backup
            image: mongo:5.0
            env:
            - name: MONGO_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mongodb-secret
                  key: password
            command:
            - /bin/bash
            - -c
            - |
              DATE=$(date +%Y%m%d-%H%M%S)
              mongodump --host mongodb-service:27017 --username admin --password $MONGO_PASSWORD --authenticationDatabase admin --out /backup/mongodb-backup-$DATE
              tar -czf /backup/mongodb-backup-$DATE.tar.gz -C /backup mongodb-backup-$DATE
              rm -rf /backup/mongodb-backup-$DATE
              # Upload to cloud storage
              aws s3 cp /backup/mongodb-backup-$DATE.tar.gz s3://backups/mongodb/
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          restartPolicy: OnFailure
```

## Disaster Recovery Strategies

### Multi-Region Backup
```yaml
# Cross-region backup replication
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cross-region-backup
  namespace: velero
spec:
  schedule: "0 4 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup-replicator
            image: amazon/aws-cli:latest
            command:
            - /bin/bash
            - -c
            - |
              # Sync backups to secondary region
              aws s3 sync s3://velero-backups-primary s3://velero-backups-secondary --region us-east-1
              
              # Verify backup integrity
              aws s3 ls s3://velero-backups-secondary --recursive --region us-east-1
          restartPolicy: OnFailure
```

### Cluster Migration
```bash
# Export cluster resources for migration
kubectl get all,pvc,secrets,configmaps --all-namespaces -o yaml > cluster-export.yaml

# Migrate to new cluster
kubectl apply -f cluster-export.yaml --dry-run=client
kubectl apply -f cluster-export.yaml
```

## Backup Automation

### Automated Backup Pipeline
```yaml
# Comprehensive backup workflow
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  name: backup-workflow
spec:
  entrypoint: backup-pipeline
  templates:
  - name: backup-pipeline
    steps:
    - - name: etcd-backup
        template: etcd-backup
    - - name: velero-backup
        template: velero-backup
    - - name: database-backup
        template: database-backup
    - - name: verify-backups
        template: verify-backups
  
  - name: etcd-backup
    container:
      image: k8s.gcr.io/etcd:3.5.0-0
      command: ["/bin/sh"]
      args:
      - -c
      - |
        ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-$(date +%Y%m%d-%H%M%S).db \
          --endpoints=https://etcd:2379 \
          --cacert=/etc/kubernetes/pki/etcd/ca.crt \
          --cert=/etc/kubernetes/pki/etcd/server.crt \
          --key=/etc/kubernetes/pki/etcd/server.key
  
  - name: velero-backup
    container:
      image: velero/velero:v1.12.1
      command: ["velero"]
      args: ["backup", "create", "automated-backup-{{workflow.creationTimestamp}}", "--wait"]
  
  - name: database-backup
    container:
      image: postgres:13
      command: ["/bin/bash"]
      args:
      - -c
      - |
        pg_dump -h postgres -U postgres myapp > /backup/db-$(date +%Y%m%d-%H%M%S).sql
  
  - name: verify-backups
    container:
      image: alpine:latest
      command: ["/bin/sh"]
      args:
      - -c
      - |
        echo "Verifying backup integrity..."
        # Add verification logic here
```

## Backup Monitoring

### Backup Health Monitoring
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: backup-monitoring
spec:
  groups:
  - name: backup-alerts
    rules:
    - alert: BackupFailed
      expr: increase(velero_backup_failure_total[1h]) > 0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: "Velero backup failed"
        description: "Backup {{ $labels.schedule }} has failed"
    
    - alert: BackupNotCompleted
      expr: time() - velero_backup_last_successful_timestamp > 86400
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: "No successful backup in 24 hours"
    
    - alert: EtcdBackupMissing
      expr: time() - etcd_backup_last_timestamp > 86400
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: "etcd backup is overdue"
```

### Backup Verification
```bash
# Verify Velero backups
velero backup get
velero backup describe production-backup

# Test restore in separate namespace
velero restore create test-restore \
  --from-backup production-backup \
  --namespace-mappings production:test-restore \
  --include-namespaces production

# Verify etcd backup
ETCDCTL_API=3 etcdctl snapshot status /backup/etcd-snapshot.db --write-out=table

# Test database backup
pg_restore --list /backup/postgres-backup.sql
```

## Restore Procedures

### Complete Cluster Restore

#### 1. etcd Restore
```bash
# Stop etcd
sudo systemctl stop etcd

# Restore from snapshot
ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd-snapshot.db \
  --data-dir=/var/lib/etcd-restore \
  --name=master-1 \
  --initial-cluster=master-1=https://10.0.0.10:2380 \
  --initial-advertise-peer-urls=https://10.0.0.10:2380

# Update etcd configuration
sudo mv /var/lib/etcd /var/lib/etcd-backup
sudo mv /var/lib/etcd-restore /var/lib/etcd

# Start etcd
sudo systemctl start etcd
```

#### 2. Application Restore
```bash
# Restore using Velero
velero restore create cluster-restore --from-backup full-backup

# Monitor restore progress
velero restore get
velero restore describe cluster-restore

# Verify restored resources
kubectl get all --all-namespaces
```

### Selective Restore
```bash
# Restore specific namespace
velero restore create production-restore \
  --from-backup full-backup \
  --include-namespaces production

# Restore specific resources
velero restore create app-restore \
  --from-backup full-backup \
  --include-resources deployments,services \
  --namespace-mappings production:production-restored
```

## Best Practices

### 1. Backup Strategy
- Implement 3-2-1 backup rule (3 copies, 2 different media, 1 offsite)
- Regular backup testing and validation
- Document recovery procedures
- Automate backup processes

### 2. Data Protection
- Encrypt backups at rest and in transit
- Implement proper access controls
- Regular backup integrity checks
- Compliance with data retention policies

### 3. Performance
- Schedule backups during low-activity periods
- Use incremental backups when possible
- Optimize backup storage and compression
- Monitor backup performance metrics

### 4. Security
- Secure backup storage locations
- Implement proper authentication and authorization
- Regular security audits of backup systems
- Encrypt sensitive data in backups

### 5. Testing
- Regular disaster recovery drills
- Test restore procedures in isolated environments
- Validate backup completeness and integrity
- Document and update recovery procedures

## Backup Retention Policies

### Lifecycle Management
```yaml
# S3 lifecycle policy for backup retention
apiVersion: v1
kind: ConfigMap
metadata:
  name: backup-lifecycle-policy
data:
  policy.json: |
    {
      "Rules": [
        {
          "ID": "BackupRetention",
          "Status": "Enabled",
          "Filter": {"Prefix": "velero/"},
          "Transitions": [
            {
              "Days": 30,
              "StorageClass": "STANDARD_IA"
            },
            {
              "Days": 90,
              "StorageClass": "GLACIER"
            },
            {
              "Days": 365,
              "StorageClass": "DEEP_ARCHIVE"
            }
          ],
          "Expiration": {
            "Days": 2555
          }
        }
      ]
    }
```

### Automated Cleanup
```yaml
# Backup cleanup job
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cleanup
spec:
  schedule: "0 5 * * 0"  # Weekly on Sunday
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: velero/velero:v1.12.1
            command:
            - /bin/bash
            - -c
            - |
              # Delete backups older than 30 days
              velero backup get -o json | \
              jq -r '.items[] | select(.status.completionTimestamp < (now - 30*24*3600 | strftime("%Y-%m-%dT%H:%M:%SZ"))) | .metadata.name' | \
              xargs -r velero backup delete --confirm
          restartPolicy: OnFailure
```

## Conclusion

Kubernetes Backup and Restore strategies provide:
- **Data Protection**: Comprehensive backup of cluster state and application data
- **Disaster Recovery**: Ability to recover from various failure scenarios
- **Business Continuity**: Minimize downtime and data loss
- **Compliance**: Meet regulatory requirements for data retention
- **Operational Confidence**: Tested and validated recovery procedures

A robust backup and restore strategy is essential for production Kubernetes environments, ensuring data integrity and enabling rapid recovery from disasters or operational errors.