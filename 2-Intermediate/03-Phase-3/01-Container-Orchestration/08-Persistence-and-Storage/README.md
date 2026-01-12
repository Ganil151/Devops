# Kubernetes StorageClass

## Overview

**Kubernetes StorageClass** provides a way to describe different classes of storage available in a cluster. StorageClasses enable dynamic provisioning of persistent volumes, allowing administrators to define storage types and users to request storage without knowing the underlying infrastructure details.

## What is StorageClass?

StorageClass is:
- A cluster-scoped resource that defines storage types
- Used for dynamic provisioning of PersistentVolumes
- A way to abstract storage implementation details
- The bridge between storage requests and storage provisioners

## StorageClass Architecture

### Dynamic Provisioning Flow
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│     PVC     │───►│StorageClass │───►│ Provisioner │
│  (Request)  │    │ (Template)  │    │  (Create)   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   ▼                   │
       │            ┌─────────────┐            │
       │            │ Parameters  │            │
       │            │ & Policies  │            │
       │            └─────────────┘            │
       │                   │                   │
       │                   ▼                   │
       └────────────┌─────────────┐◄───────────┘
                    │     PV      │
                    │ (Created)   │
                    └─────────────┘
```

### Storage Ecosystem
```
┌─────────────────────────────────────────────────────────────┐
│                    Storage Ecosystem                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │     Pod     │  │     PVC     │  │  StorageClass   │     │
│  │             │  │             │  │                 │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Volume    │  │     PV      │  │  Provisioner    │     │
│  │   Mount     │  │             │  │                 │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│                          │                 │              │
│                          ▼                 ▼              │
│                   ┌─────────────────────────────────┐     │
│                   │      Storage Backend            │     │
│                   │   (AWS EBS, GCE PD, etc.)      │     │
│                   └─────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Basic StorageClass Configuration

### Simple StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Default StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
reclaimPolicy: Delete
allowVolumeExpansion: true
```

## Cloud Provider StorageClasses

### AWS EBS StorageClass
```yaml
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
```

### Google Cloud StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gce-pd-ssd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
  zones: us-central1-a,us-central1-b
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gce-pd-balanced
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-balanced
  provisioned-iops-on-create: "3000"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

### Azure Disk StorageClass
```yaml
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
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-ultra
provisioner: disk.csi.azure.com
parameters:
  skuName: UltraSSD_LRS
  diskIOPSReadWrite: "2000"
  diskMBpsReadWrite: "320"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

## StorageClass Parameters

### Common Parameters

#### Reclaim Policy
```yaml
# Delete - PV is deleted when PVC is deleted
reclaimPolicy: Delete

# Retain - PV is retained when PVC is deleted
reclaimPolicy: Retain

# Recycle - PV data is scrubbed and made available again (deprecated)
reclaimPolicy: Recycle
```

#### Volume Binding Mode
```yaml
# Immediate - PV is created immediately when PVC is created
volumeBindingMode: Immediate

# WaitForFirstConsumer - PV creation is delayed until pod is scheduled
volumeBindingMode: WaitForFirstConsumer
```

#### Volume Expansion
```yaml
# Allow volume expansion
allowVolumeExpansion: true

# Disallow volume expansion
allowVolumeExpansion: false
```

### Provider-Specific Parameters

#### AWS EBS Parameters
```yaml
parameters:
  type: gp3                    # Volume type (gp2, gp3, io1, io2, sc1, st1)
  iops: "3000"                # IOPS for gp3, io1, io2
  throughput: "125"           # Throughput for gp3 (MiB/s)
  encrypted: "true"           # Enable encryption
  kmsKeyId: "key-id"          # KMS key for encryption
  fsType: ext4                # Filesystem type
```

#### GCE Persistent Disk Parameters
```yaml
parameters:
  type: pd-ssd                # Disk type (pd-standard, pd-ssd, pd-balanced)
  zones: us-central1-a,us-central1-b  # Availability zones
  replication-type: regional-pd        # Replication type
  provisioned-iops-on-create: "3000"  # Provisioned IOPS
```

#### Azure Disk Parameters
```yaml
parameters:
  skuName: Premium_LRS        # Storage type (Standard_LRS, Premium_LRS, UltraSSD_LRS)
  kind: Managed              # Disk kind (Shared, Dedicated, Managed)
  cachingmode: ReadOnly      # Caching mode (None, ReadOnly, ReadWrite)
  diskIOPSReadWrite: "2000"  # IOPS for Ultra SSD
  diskMBpsReadWrite: "320"   # Throughput for Ultra SSD
```

## Using StorageClass with PVCs

### Basic PVC with StorageClass
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 10Gi
```

### PVC with Default StorageClass
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: default-pvc
spec:
  accessModes:
  - ReadWriteOnce
  # storageClassName omitted - uses default StorageClass
  resources:
    requests:
      storage: 5Gi
```

### PVC without StorageClass (Static Provisioning)
```yaml
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
      storage: 20Gi
```

## Advanced StorageClass Features

### Topology-Aware Provisioning
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: topology-aware
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
- matchLabelExpressions:
  - key: topology.ebs.csi.aws.com/zone
    values:
    - us-west-2a
    - us-west-2b
```

### Mount Options
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.example.com
  share: /exports/data
mountOptions:
- hard
- nfsvers=4.1
- rsize=1048576
- wsize=1048576
reclaimPolicy: Retain
```

### Volume Expansion Policy
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: expandable-storage
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

## CSI StorageClasses

### Local Path Provisioner
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
provisioner: rancher.io/local-path
parameters:
  nodePath: /opt/local-path-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

### Longhorn StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "2880"
  fromBackup: ""
  fsType: "ext4"
  dataLocality: "disabled"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

### Ceph RBD StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ceph-rbd
provisioner: rbd.csi.ceph.com
parameters:
  clusterID: b9127830-b0cc-4e34-aa47-9d1a2e9949a8
  pool: kubernetes
  imageFeatures: layering
  csi.storage.k8s.io/provisioner-secret-name: csi-rbd-secret
  csi.storage.k8s.io/provisioner-secret-namespace: default
  csi.storage.k8s.io/controller-expand-secret-name: csi-rbd-secret
  csi.storage.k8s.io/controller-expand-secret-namespace: default
  csi.storage.k8s.io/node-stage-secret-name: csi-rbd-secret
  csi.storage.k8s.io/node-stage-secret-namespace: default
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
- discard
```

## StorageClass Management

### Viewing StorageClasses
```bash
# List all StorageClasses
kubectl get storageclass

# Show default StorageClass
kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}'

# Describe StorageClass
kubectl describe storageclass fast-ssd

# Get StorageClass YAML
kubectl get storageclass fast-ssd -o yaml
```

### Setting Default StorageClass
```bash
# Remove existing default
kubectl patch storageclass old-default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Set new default
kubectl patch storageclass new-default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### Creating StorageClass
```bash
# Create from YAML
kubectl apply -f storageclass.yaml

# Verify creation
kubectl get storageclass
kubectl describe storageclass my-storage-class
```

## Performance Optimization

### High-Performance StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: high-performance
provisioner: ebs.csi.aws.com
parameters:
  type: io2
  iops: "20000"
  throughput: "1000"
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
mountOptions:
- noatime
- nodiratime
```

### Cost-Optimized StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cost-optimized
provisioner: ebs.csi.aws.com
parameters:
  type: sc1  # Cold HDD
  encrypted: "false"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Balanced StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: balanced
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

## Multi-Zone StorageClass

### Regional Persistent Disk
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: regional-ssd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
- matchLabelExpressions:
  - key: topology.gke.io/zone
    values:
    - us-central1-a
    - us-central1-b
    - us-central1-c
```

### Multi-AZ EBS
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: multi-az-ebs
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
- matchLabelExpressions:
  - key: topology.ebs.csi.aws.com/zone
    values:
    - us-west-2a
    - us-west-2b
    - us-west-2c
```

## StorageClass Troubleshooting

### Common Issues

#### 1. PVC Stuck in Pending
```bash
# Check PVC status
kubectl describe pvc my-pvc

# Check StorageClass
kubectl describe storageclass fast-ssd

# Check provisioner logs
kubectl logs -n kube-system -l app=ebs-csi-controller

# Check events
kubectl get events --field-selector involvedObject.name=my-pvc
```

#### 2. Provisioner Not Found
```bash
# Check available provisioners
kubectl get csidriver

# Check StorageClass provisioner
kubectl get storageclass -o jsonpath='{.items[*].provisioner}'

# Verify CSI driver installation
kubectl get pods -n kube-system | grep csi
```

#### 3. Volume Expansion Issues
```bash
# Check if expansion is allowed
kubectl get storageclass fast-ssd -o jsonpath='{.allowVolumeExpansion}'

# Check PVC expansion status
kubectl describe pvc my-pvc | grep -A 5 "Conditions"

# Check filesystem expansion
kubectl exec my-pod -- df -h /data
```

#### 4. Mount Issues
```bash
# Check pod events
kubectl describe pod my-pod

# Check volume attachment
kubectl get volumeattachment

# Check node CSI driver
kubectl get pods -n kube-system -o wide | grep csi-node
```

### Debug Commands
```bash
# Check PV created by StorageClass
kubectl get pv -o custom-columns=NAME:.metadata.name,STORAGECLASS:.spec.storageClassName,STATUS:.status.phase

# Check PVC to StorageClass mapping
kubectl get pvc -o custom-columns=NAME:.metadata.name,STORAGECLASS:.spec.storageClassName,STATUS:.status.phase

# Check provisioner events
kubectl get events --field-selector reason=ProvisioningSucceeded
kubectl get events --field-selector reason=ProvisioningFailed
```

## Best Practices

### 1. StorageClass Design
- Create multiple StorageClasses for different use cases
- Use descriptive names that indicate performance characteristics
- Set appropriate default StorageClass
- Document StorageClass purposes and limitations

### 2. Performance Considerations
- Choose appropriate volume types for workload requirements
- Use WaitForFirstConsumer for multi-zone clusters
- Configure appropriate IOPS and throughput settings
- Consider mount options for performance optimization

### 3. Cost Management
- Use cost-effective storage types for non-critical workloads
- Implement volume expansion policies
- Set appropriate reclaim policies
- Monitor storage usage and costs

### 4. Security
- Enable encryption for sensitive data
- Use appropriate access modes
- Implement proper RBAC for StorageClass management
- Secure CSI driver configurations

### 5. Operations
- Monitor provisioning success rates
- Implement backup strategies for persistent data
- Plan for disaster recovery scenarios
- Test volume expansion procedures

## StorageClass Patterns

### Database StorageClass
```yaml
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
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
mountOptions:
- noatime
```

### Log Storage StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: log-storage
provisioner: ebs.csi.aws.com
parameters:
  type: st1  # Throughput Optimized HDD
  encrypted: "false"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

### Backup StorageClass
```yaml
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

## Environment-Specific StorageClasses

### Development Environment
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: dev-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "false"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

### Production Environment
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: prod-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
  kmsKeyId: "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

## Conclusion

Kubernetes StorageClass provides:
- Dynamic provisioning of persistent volumes
- Abstraction of storage implementation details
- Flexible storage configuration options
- Integration with cloud provider storage services
- Support for various storage backends and CSI drivers

Understanding StorageClass configuration and management is essential for providing appropriate storage solutions for different application requirements while optimizing for performance, cost, and operational efficiency.