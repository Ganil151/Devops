# Kubernetes Dynamic Provisioning

## Overview

**Dynamic Provisioning** allows storage volumes to be created on-demand when PersistentVolumeClaims (PVCs) are created. This eliminates the need for cluster administrators to pre-provision storage and enables automatic storage allocation based on application requirements.

## Dynamic Provisioning Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                Dynamic Provisioning Flow                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │     PVC     │  │StorageClass │  │  Provisioner    │     │
│  │  (Request)  │  │ (Template)  │  │   (Creator)     │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Binding   │  │ Parameters  │  │      PV         │     │
│  │   Process   │  │ & Policies  │  │   (Created)     │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│                          │                 │              │
│                          ▼                 ▼              │
│                   ┌─────────────────────────────────┐     │
│                   │      Storage Backend            │     │
│                   │   (Cloud, CSI, etc.)           │     │
│                   └─────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## How Dynamic Provisioning Works

### 1. PVC Creation
```yaml
# User creates a PVC with StorageClass
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
  namespace: default
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd  # References StorageClass
  resources:
    requests:
      storage: 10Gi
```

### 2. StorageClass Definition
```yaml
# StorageClass defines provisioning template
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: ebs.csi.aws.com  # CSI driver
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### 3. Automatic PV Creation
```yaml
# Provisioner creates PV automatically
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pvc-12345678-1234-1234-1234-123456789012
  annotations:
    pv.kubernetes.io/provisioned-by: ebs.csi.aws.com
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: fast-ssd
  csi:
    driver: ebs.csi.aws.com
    volumeHandle: vol-1234567890abcdef0
    fsType: ext4
```

## Provisioners

### Built-in Provisioners (Deprecated)
```yaml
# Legacy built-in provisioners (being phased out)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: legacy-ebs
provisioner: kubernetes.io/aws-ebs  # Deprecated
parameters:
  type: gp2
  zones: us-west-2a,us-west-2b
```

### CSI Provisioners (Recommended)
```yaml
# Modern CSI-based provisioners
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: modern-ebs
provisioner: ebs.csi.aws.com  # CSI driver
parameters:
  type: gp3
  iops: "3000"
  encrypted: "true"
```

### External Provisioners
```yaml
# Third-party provisioners
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.example.com
  share: /exports/kubernetes
mountOptions:
- hard
- nfsvers=4.1
```

## Cloud Provider Dynamic Provisioning

### AWS EBS Dynamic Provisioning
```yaml
# AWS EBS with various volume types
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
  kmsKeyId: "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
# High-performance IO2 volumes
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-io2
provisioner: ebs.csi.aws.com
parameters:
  type: io2
  iops: "10000"
  encrypted: "true"
reclaimPolicy: Retain
allowVolumeExpansion: true
---
# Cost-optimized throughput volumes
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-st1
provisioner: ebs.csi.aws.com
parameters:
  type: st1  # Throughput Optimized HDD
  encrypted: "false"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

### Google Cloud Persistent Disk
```yaml
# Standard persistent disk
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gce-pd-standard
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-standard
  zones: us-central1-a,us-central1-b,us-central1-c
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
# SSD persistent disk
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gce-pd-ssd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
# Balanced persistent disk
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gce-pd-balanced
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-balanced
  provisioned-iops-on-create: "3000"
allowVolumeExpansion: true
```

### Azure Disk Dynamic Provisioning
```yaml
# Premium SSD
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-premium
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
  cachingmode: ReadOnly
  kind: Managed
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
# Ultra SSD for high performance
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-ultra
provisioner: disk.csi.azure.com
parameters:
  skuName: UltraSSD_LRS
  diskIOPSReadWrite: "2000"
  diskMBpsReadWrite: "320"
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
# Standard HDD for cost optimization
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-standard
provisioner: disk.csi.azure.com
parameters:
  skuName: Standard_LRS
  cachingmode: None
reclaimPolicy: Delete
allowVolumeExpansion: true
```

## Volume Binding Modes

### Immediate Binding
```yaml
# Volume is provisioned immediately when PVC is created
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: immediate-binding
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
volumeBindingMode: Immediate  # Default mode
reclaimPolicy: Delete
```

### WaitForFirstConsumer
```yaml
# Volume provisioning is delayed until pod is scheduled
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: wait-for-consumer
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
volumeBindingMode: WaitForFirstConsumer  # Topology-aware
reclaimPolicy: Delete
allowedTopologies:
- matchLabelExpressions:
  - key: topology.ebs.csi.aws.com/zone
    values:
    - us-west-2a
    - us-west-2b
```

## Topology-Aware Provisioning

### Zone-Specific Provisioning
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: zone-specific
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
- matchLabelExpressions:
  - key: topology.ebs.csi.aws.com/zone
    values:
    - us-west-2a  # Only provision in this zone
```

### Multi-Zone with Preferences
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: multi-zone-preferred
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
- matchLabelExpressions:
  - key: topology.gke.io/zone
    values:
    - us-central1-a
    - us-central1-b
    - us-central1-c
```

## Default StorageClass

### Setting Default StorageClass
```yaml
# Mark StorageClass as default
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: default-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
reclaimPolicy: Delete
allowVolumeExpansion: true
```

### Using Default StorageClass
```yaml
# PVC without storageClassName uses default
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: default-pvc
spec:
  accessModes:
  - ReadWriteOnce
  # storageClassName omitted - uses default
  resources:
    requests:
      storage: 10Gi
```

### Disabling Dynamic Provisioning
```yaml
# Explicitly disable dynamic provisioning
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ""  # Empty string disables dynamic provisioning
  resources:
    requests:
      storage: 10Gi
```

## Advanced Provisioning Features

### Volume Expansion
```yaml
# Enable volume expansion
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-storage
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
allowVolumeExpansion: true  # Enable expansion
reclaimPolicy: Delete
```

### Custom Parameters
```yaml
# StorageClass with custom parameters
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: custom-storage
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "4000"
  throughput: "250"
  encrypted: "true"
  kmsKeyId: "alias/kubernetes-storage"
  # Custom tags
  tagSpecification_1: "Name={{.PVCName}}"
  tagSpecification_2: "Namespace={{.PVCNamespace}}"
  tagSpecification_3: "Environment=production"
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
- debug
- noatime
```

### Mount Options
```yaml
# StorageClass with mount options
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-with-options
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.example.com
  share: /exports/data
mountOptions:
- hard
- nfsvers=4.1
- rsize=1048576
- wsize=1048576
- timeo=600
- retrans=2
reclaimPolicy: Retain
```

## Provisioning Monitoring

### Provisioning Metrics
```bash
# Check provisioning status
kubectl get pvc --all-namespaces
kubectl get pv --all-namespaces

# Monitor provisioning events
kubectl get events --field-selector reason=ProvisioningSucceeded
kubectl get events --field-selector reason=ProvisioningFailed

# Check storage classes
kubectl get storageclass
kubectl describe storageclass fast-ssd
```

### Prometheus Monitoring
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: dynamic-provisioning-alerts
spec:
  groups:
  - name: provisioning
    rules:
    - alert: PVCProvisioningFailed
      expr: increase(storage_operation_duration_seconds_count{operation_name="provision",status="fail-unknown"}[5m]) > 0
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "PVC provisioning failures detected"
    
    - alert: PVCPendingTooLong
      expr: kube_persistentvolumeclaim_status_phase{phase="Pending"} == 1
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "PVC has been pending for too long"
```

## Troubleshooting Dynamic Provisioning

### Common Issues

#### 1. PVC Stuck in Pending
```bash
# Check PVC status and events
kubectl describe pvc my-pvc

# Check StorageClass
kubectl describe storageclass fast-ssd

# Check provisioner logs
kubectl logs -n kube-system -l app=ebs-csi-controller -c csi-provisioner

# Check for quota limits
kubectl describe quota --all-namespaces
```

#### 2. Provisioner Not Found
```bash
# Check if CSI driver is installed
kubectl get csidriver

# Check provisioner pods
kubectl get pods -n kube-system | grep csi

# Verify StorageClass provisioner
kubectl get storageclass -o jsonpath='{.items[*].provisioner}'
```

#### 3. Permission Issues
```bash
# Check CSI driver permissions
kubectl describe clusterrole ebs-csi-controller-role

# Check service account
kubectl describe serviceaccount -n kube-system ebs-csi-controller-sa

# Check cloud provider permissions (AWS IAM, etc.)
```

#### 4. Topology Constraints
```bash
# Check node labels
kubectl get nodes --show-labels

# Check allowed topologies
kubectl get storageclass fast-ssd -o yaml | grep -A 10 allowedTopologies

# Check pod scheduling
kubectl describe pod my-pod | grep -A 5 "Node-Selectors"
```

### Debug Commands
```bash
# List all storage resources
kubectl get storageclass,pv,pvc --all-namespaces

# Check provisioning events
kubectl get events --sort-by='.lastTimestamp' | grep -i provision

# Check CSI driver status
kubectl get pods -n kube-system -l app=ebs-csi-controller
kubectl logs -n kube-system -l app=ebs-csi-controller -c csi-provisioner

# Test provisioning
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 1Gi
EOF
```

## Best Practices

### 1. StorageClass Design
- Create multiple StorageClasses for different performance tiers
- Use descriptive names that indicate characteristics
- Set appropriate default StorageClass
- Document StorageClass purposes and costs

### 2. Performance Optimization
- Use WaitForFirstConsumer for multi-zone clusters
- Choose appropriate volume types for workloads
- Configure proper IOPS and throughput settings
- Consider local storage for high-performance needs

### 3. Cost Management
- Use cost-effective storage types for non-critical workloads
- Implement proper reclaim policies
- Monitor storage usage and costs
- Set up automated cleanup for unused volumes

### 4. Security
- Enable encryption for sensitive data
- Use appropriate access modes
- Implement proper RBAC for StorageClass management
- Secure provisioner configurations

### 5. Operations
- Monitor provisioning success rates
- Implement backup strategies
- Plan for disaster recovery
- Test volume expansion procedures

## Provisioning Patterns

### Database Storage Pattern
```yaml
# High-performance storage for databases
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: database-storage
provisioner: ebs.csi.aws.com
parameters:
  type: io2
  iops: "10000"
  throughput: "500"
  encrypted: "true"
reclaimPolicy: Retain  # Preserve data
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Application Storage Pattern
```yaml
# Balanced storage for applications
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: app-storage
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
reclaimPolicy: Delete  # Clean up automatically
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Backup Storage Pattern
```yaml
# Cost-optimized storage for backups
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: backup-storage
provisioner: ebs.csi.aws.com
parameters:
  type: sc1  # Cold HDD
  encrypted: "true"
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

## Multi-Cloud Provisioning

### Hybrid Cloud Strategy
```yaml
# Primary cloud provider
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: primary-storage
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
---
# Secondary cloud provider
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: secondary-storage
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
```

## Conclusion

Dynamic Provisioning in Kubernetes provides:
- **Automated Storage Management**: On-demand volume creation
- **Flexibility**: Multiple storage types and configurations
- **Scalability**: Automatic scaling based on demand
- **Cost Optimization**: Pay-as-you-use storage model
- **Operational Efficiency**: Reduced manual intervention

Understanding dynamic provisioning is essential for building scalable, efficient storage solutions that can adapt to changing application requirements while optimizing costs and performance.