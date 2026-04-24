# Kubernetes Storage

## Overview

**Kubernetes Storage** provides persistent data management for containerized applications. The storage system abstracts underlying storage infrastructure and provides a consistent interface for applications to consume storage resources.

## Storage Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 Kubernetes Storage System                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │    Pod      │  │     PVC     │  │ StorageClass    │     │
│  │  (Consumer) │  │ (Request)   │  │  (Template)     │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Volume    │  │     PV      │  │  Provisioner    │     │
│  │   Mount     │  │ (Resource)  │  │   (Creator)     │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│                          │                 │              │
│                          ▼                 ▼              │
│                   ┌─────────────────────────────────┐     │
│                   │      Storage Backend            │     │
│                   │   (Cloud, NFS, Ceph, etc.)     │     │
│                   └─────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Storage Components

### 1. [Persistent Volumes (PV)](readme.md)
- **Cluster Resources**: Storage resources in the cluster
- **Lifecycle**: Independent of pod lifecycle
- **Access Modes**: ReadWriteOnce, ReadOnlyMany, ReadWriteMany
- **Reclaim Policies**: Retain, Delete, Recycle

### 2. [Storage Classes](readme.md)
- **Dynamic Provisioning**: Automatic PV creation
- **Storage Templates**: Define storage characteristics
- **Provisioner Integration**: Cloud and CSI driver support
- **Policy Configuration**: Binding modes and reclaim policies

### 3. [CSI Drivers](readme.md)
- **Container Storage Interface**: Standardized storage plugin API
- **Vendor Integration**: Support for various storage systems
- **Feature Support**: Snapshots, cloning, expansion
- **Lifecycle Management**: Volume creation, attachment, mounting

### 4. [Volume Types](readme.md)
- **Ephemeral Volumes**: EmptyDir, ConfigMap, Secret
- **Network Volumes**: NFS, iSCSI, Ceph
- **Cloud Volumes**: AWS EBS, GCE PD, Azure Disk
- **Local Volumes**: HostPath, Local PV

### 5. [Volume Snapshots](readme.md)
- **Point-in-Time Copies**: Volume state preservation
- **Backup Integration**: Data protection strategies
- **Clone Operations**: Volume duplication
- **Restore Capabilities**: Data recovery

### 6. [Dynamic Provisioning](readme.md)
- **Automatic Creation**: On-demand PV provisioning
- **Template-Based**: StorageClass-driven provisioning
- **Parameter Passing**: Custom storage configuration
- **Lifecycle Management**: Creation and deletion automation

### 7. [Backup & Restore](readme.md)
- **Data Protection**: Backup strategies and tools
- **Disaster Recovery**: Cross-cluster data migration
- **Snapshot Management**: Automated backup workflows
- **Restore Procedures**: Data recovery processes

## Storage Patterns

### Stateful Applications
```yaml
# Database with persistent storage
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
spec:
  serviceName: database
  replicas: 3
  template:
    spec:
      containers:
      - name: db
        image: postgres:13
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 100Gi
```

### Shared Storage
```yaml
# Shared file system for multiple pods
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-storage
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: nfs-storage
  resources:
    requests:
      storage: 1Ti
```

### Backup Storage
```yaml
# Cold storage for backups
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-storage
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: cold-storage
  resources:
    requests:
      storage: 10Ti
```

## Storage Performance

### Performance Tiers
```yaml
# High-performance storage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: high-performance
provisioner: ebs.csi.aws.com
parameters:
  type: io2
  iops: "20000"
  throughput: "1000"
---
# Balanced performance
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: balanced
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
---
# Cost-optimized storage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cost-optimized
provisioner: ebs.csi.aws.com
parameters:
  type: sc1
```

### Performance Monitoring
```bash
# Monitor storage performance
kubectl top nodes
kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,STATUS:.status.phase

# Check volume metrics
kubectl get --raw /metrics | grep volume
```

## Storage Security

### Encryption at Rest
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: encrypted-storage
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
  kmsKeyId: "arn:aws:kms:region:account:key/key-id"
```

### Access Control
```yaml
# RBAC for storage resources
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: storage-admin
rules:
- apiGroups: [""]
  resources: ["persistentvolumes", "persistentvolumeclaims"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
```

## Multi-Cloud Storage

### Cloud Provider Integration
```yaml
# AWS EBS
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
---
# Google Cloud Persistent Disk
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gce-pd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
---
# Azure Disk
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
```

## Storage Troubleshooting

### Common Issues
```bash
# PVC stuck in Pending
kubectl describe pvc my-pvc
kubectl get events --field-selector involvedObject.name=my-pvc

# Volume mount failures
kubectl describe pod my-pod
kubectl logs my-pod

# Storage capacity issues
kubectl get pv,pvc
kubectl describe node node-name | grep -A 5 "Allocated resources"
```

### Debug Commands
```bash
# Check storage components
kubectl get storageclass
kubectl get pv,pvc
kubectl get volumeattachment

# Check CSI drivers
kubectl get csidriver
kubectl get pods -n kube-system | grep csi

# Monitor storage events
kubectl get events --field-selector reason=ProvisioningFailed
kubectl get events --field-selector reason=VolumeMount
```

## Best Practices

### 1. Storage Planning
- Assess application storage requirements
- Choose appropriate storage classes
- Plan for data growth and scaling
- Consider backup and disaster recovery

### 2. Performance Optimization
- Match storage performance to workload needs
- Use appropriate access modes
- Configure proper volume binding modes
- Monitor storage metrics

### 3. Cost Management
- Use cost-effective storage tiers
- Implement data lifecycle policies
- Monitor storage usage and costs
- Clean up unused volumes

### 4. Security
- Enable encryption for sensitive data
- Implement proper access controls
- Use secure storage backends
- Regular security audits

### 5. Operations
- Automate backup procedures
- Test disaster recovery scenarios
- Monitor storage health
- Plan capacity management

## Storage Ecosystem

### Open Source Solutions
- **Rook**: Cloud-native storage orchestrator
- **Longhorn**: Distributed block storage
- **OpenEBS**: Container-attached storage
- **Portworx**: Enterprise storage platform

### Cloud Native Storage
- **AWS EBS CSI**: Elastic Block Store
- **GCE PD CSI**: Persistent Disk
- **Azure Disk CSI**: Managed Disks
- **NetApp Trident**: Enterprise storage

### Traditional Storage
- **NFS**: Network File System
- **iSCSI**: Internet Small Computer Systems Interface
- **Ceph**: Distributed storage system
- **GlusterFS**: Scale-out network-attached storage

## Conclusion

Kubernetes storage provides a flexible and powerful system for managing persistent data in containerized environments. Understanding the various storage components, patterns, and best practices is essential for building robust, scalable, and efficient storage solutions for modern applications.

## Directory Structure

```
Storage/
├── README.md                 # This overview
├── persistent-volumes/       # PV and PVC management
├── storage-class/           # Dynamic provisioning templates
├── csi-drivers/            # Container Storage Interface
├── volume-types/           # Different volume implementations
├── volume-snapshots/       # Snapshot and backup
├── dynamic-provisioning/   # Automated storage provisioning
└── backup-restore/         # Data protection strategies
```