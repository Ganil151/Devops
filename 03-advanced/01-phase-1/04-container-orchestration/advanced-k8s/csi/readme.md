# Container Storage Interface (CSI) Drivers

## Overview

**Container Storage Interface (CSI)** is a standard for exposing arbitrary block and file storage systems to containerized workloads on Kubernetes. CSI drivers enable storage vendors to develop plugins that work across multiple container orchestration systems.

## CSI Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CSI Architecture                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │ Kubernetes  │  │ CSI Driver  │  │    Storage      │     │
│  │   API       │  │             │  │    Backend      │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │ Controller  │  │   Node      │  │    Volume       │     │
│  │  Plugin     │  │  Plugin     │  │   Operations    │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## CSI Components

### Controller Plugin
```yaml
# CSI Controller Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csi-controller
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      app: csi-controller
  template:
    metadata:
      labels:
        app: csi-controller
    spec:
      serviceAccount: csi-controller-sa
      containers:
      # CSI Driver
      - name: csi-driver
        image: my-csi-driver:latest
        args:
        - --endpoint=$(CSI_ENDPOINT)
        - --mode=controller
        env:
        - name: CSI_ENDPOINT
          value: unix:///var/lib/csi/sockets/pluginproxy/csi.sock
        volumeMounts:
        - name: socket-dir
          mountPath: /var/lib/csi/sockets/pluginproxy/
      # CSI Provisioner
      - name: csi-provisioner
        image: k8s.gcr.io/sig-storage/csi-provisioner:v3.4.0
        args:
        - --csi-address=$(ADDRESS)
        - --v=2
        - --feature-gates=Topology=true
        env:
        - name: ADDRESS
          value: /var/lib/csi/sockets/pluginproxy/csi.sock
        volumeMounts:
        - name: socket-dir
          mountPath: /var/lib/csi/sockets/pluginproxy/
      # CSI Attacher
      - name: csi-attacher
        image: k8s.gcr.io/sig-storage/csi-attacher:v4.1.0
        args:
        - --csi-address=$(ADDRESS)
        - --v=2
        env:
        - name: ADDRESS
          value: /var/lib/csi/sockets/pluginproxy/csi.sock
        volumeMounts:
        - name: socket-dir
          mountPath: /var/lib/csi/sockets/pluginproxy/
      # CSI Resizer
      - name: csi-resizer
        image: k8s.gcr.io/sig-storage/csi-resizer:v1.7.0
        args:
        - --csi-address=$(ADDRESS)
        - --v=2
        env:
        - name: ADDRESS
          value: /var/lib/csi/sockets/pluginproxy/csi.sock
        volumeMounts:
        - name: socket-dir
          mountPath: /var/lib/csi/sockets/pluginproxy/
      volumes:
      - name: socket-dir
        emptyDir: {}
```

### Node Plugin
```yaml
# CSI Node DaemonSet
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: csi-node
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: csi-node
  template:
    metadata:
      labels:
        app: csi-node
    spec:
      serviceAccount: csi-node-sa
      hostNetwork: true
      containers:
      # CSI Driver
      - name: csi-driver
        image: my-csi-driver:latest
        args:
        - --endpoint=$(CSI_ENDPOINT)
        - --mode=node
        - --node-id=$(NODE_ID)
        env:
        - name: CSI_ENDPOINT
          value: unix:///csi/csi.sock
        - name: NODE_ID
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        securityContext:
          privileged: true
        volumeMounts:
        - name: plugin-dir
          mountPath: /csi
        - name: pods-mount-dir
          mountPath: /var/lib/kubelet
          mountPropagation: Bidirectional
        - name: device-dir
          mountPath: /dev
      # CSI Node Driver Registrar
      - name: csi-node-driver-registrar
        image: k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.7.0
        args:
        - --csi-address=$(ADDRESS)
        - --kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)
        - --v=2
        env:
        - name: ADDRESS
          value: /csi/csi.sock
        - name: DRIVER_REG_SOCK_PATH
          value: /var/lib/kubelet/plugins/my-csi-driver/csi.sock
        volumeMounts:
        - name: plugin-dir
          mountPath: /csi/
        - name: registration-dir
          mountPath: /registration/
      volumes:
      - name: registration-dir
        hostPath:
          path: /var/lib/kubelet/plugins_registry/
          type: DirectoryOrCreate
      - name: plugin-dir
        hostPath:
          path: /var/lib/kubelet/plugins/my-csi-driver
          type: DirectoryOrCreate
      - name: pods-mount-dir
        hostPath:
          path: /var/lib/kubelet
          type: Directory
      - name: device-dir
        hostPath:
          path: /dev
```

---

## CSI Driver Registration

### CSIDriver Object
```yaml
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: my-csi-driver.example.com
spec:
  # Indicates driver supports volume attachment
  attachRequired: true
  # Indicates driver supports pod info on mount
  podInfoOnMount: true
  # Volume lifecycle modes
  volumeLifecycleModes:
  - Persistent
  - Ephemeral
  # Supported access modes
  fsGroupPolicy: ReadWriteOnceWithFSType
  # Token requests for service account
  tokenRequests:
  - audience: "my-storage-system"
    expirationSeconds: 3600
  # Requires republish
  requiresRepublish: false
```

## Popular CSI Drivers

### AWS EBS CSI Driver
```yaml
# AWS EBS CSI Driver Installation
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret
  namespace: kube-system
stringData:
  key_id: "AKIAIOSFODNN7EXAMPLE"
  access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

### Google Cloud Persistent Disk CSI
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: pd-ssd
provisioner: pd.csi.storage.gke.io
parameters:
  type: pd-ssd
  replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

---

### Azure Disk CSI Driver
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
  cachingmode: ReadOnly
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

---

### Longhorn CSI Driver
```yaml
# Longhorn StorageClass
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn
provisioner: driver.longhorn.io
allowVolumeExpansion: true
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "2880"
  fromBackup: ""
  fsType: "ext4"
```

---

### Ceph RBD CSI Driver
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-rbd-sc
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

---

## CSI Snapshots

### VolumeSnapshotClass
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-snapclass
driver: ebs.csi.aws.com
deletionPolicy: Delete
parameters:
  tagSpecification_1: "Name=snapshot-{{.VolumeSnapshotName}}"
  tagSpecification_2: "CreatedBy=aws-ebs-csi-driver"
```

### VolumeSnapshot
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: new-snapshot-test
spec:
  volumeSnapshotClassName: csi-snapclass
  source:
    persistentVolumeClaimName: ebs-claim
```

### Restore from Snapshot
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim-restored
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 4Gi
  dataSource:
    name: new-snapshot-test
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

---

## CSI Volume Cloning

### Clone from PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: clone-of-pvc-1
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: csi-hostpath-sc
  resources:
    requests:
      storage: 10Gi
  dataSource:
    kind: PersistentVolumeClaim
    name: pvc-1
```

---

## CSI Ephemeral Volumes

### Inline CSI Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-csi-app
spec:
  containers:
  - name: my-frontend
    image: busybox:1.28
    volumeMounts:
    - mountPath: "/data"
      name: my-csi-inline-vol
    command: [ "sleep", "1000000" ]
  volumes:
  - name: my-csi-inline-vol
    csi:
      driver: inline.storage.kubernetes.io
      volumeAttributes:
        foo: bar
```

---

## CSI Driver Development

### Basic CSI Driver Structure
```go
// CSI Driver Interface Implementation
package main

import (
    "context"
    "github.com/container-storage-interface/spec/lib/go/csi"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
)

type Driver struct {
    name    string
    nodeID  string
    version string
    
    // CSI endpoints
    ids csi.IdentityServer
    ns  csi.NodeServer
    cs  csi.ControllerServer
}

// Identity Service
func (d *Driver) GetPluginInfo(ctx context.Context, req *csi.GetPluginInfoRequest) (*csi.GetPluginInfoResponse, error) {
    return &csi.GetPluginInfoResponse{
        Name:          d.name,
        VendorVersion: d.version,
    }, nil
}

func (d *Driver) GetPluginCapabilities(ctx context.Context, req *csi.GetPluginCapabilitiesRequest) (*csi.GetPluginCapabilitiesResponse, error) {
    return &csi.GetPluginCapabilitiesResponse{
        Capabilities: []*csi.PluginCapability{
            {
                Type: &csi.PluginCapability_Service_{
                    Service: &csi.PluginCapability_Service{
                        Type: csi.PluginCapability_Service_CONTROLLER_SERVICE,
                    },
                },
            },
            {
                Type: &csi.PluginCapability_Service_{
                    Service: &csi.PluginCapability_Service{
                        Type: csi.PluginCapability_Service_VOLUME_ACCESSIBILITY_CONSTRAINTS,
                    },
                },
            },
        },
    }, nil
}

// Controller Service
func (d *Driver) CreateVolume(ctx context.Context, req *csi.CreateVolumeRequest) (*csi.CreateVolumeResponse, error) {
    // Implement volume creation logic
    volumeID := generateVolumeID()
    
    return &csi.CreateVolumeResponse{
        Volume: &csi.Volume{
            VolumeId:      volumeID,
            CapacityBytes: req.GetCapacityRange().GetRequiredBytes(),
            VolumeContext: req.GetParameters(),
        },
    }, nil
}

func (d *Driver) DeleteVolume(ctx context.Context, req *csi.DeleteVolumeRequest) (*csi.DeleteVolumeResponse, error) {
    // Implement volume deletion logic
    return &csi.DeleteVolumeResponse{}, nil
}

// Node Service
func (d *Driver) NodeStageVolume(ctx context.Context, req *csi.NodeStageVolumeRequest) (*csi.NodeStageVolumeResponse, error) {
    // Implement volume staging logic
    return &csi.NodeStageVolumeResponse{}, nil
}

func (d *Driver) NodePublishVolume(ctx context.Context, req *csi.NodePublishVolumeRequest) (*csi.NodePublishVolumeResponse, error) {
    // Implement volume mounting logic
    return &csi.NodePublishVolumeResponse{}, nil
}
```

### CSI Driver Dockerfile
```dockerfile
FROM golang:1.19 AS builder
WORKDIR /go/src/github.com/example/csi-driver
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o csi-driver ./cmd/

FROM alpine:3.17
RUN apk add --no-cache ca-certificates e2fsprogs xfsprogs blkid
COPY --from=builder /go/src/github.com/example/csi-driver/csi-driver /bin/
ENTRYPOINT ["/bin/csi-driver"]
```

---

## CSI Sidecar Containers

### External Provisioner
```yaml
- name: csi-provisioner
  image: k8s.gcr.io/sig-storage/csi-provisioner:v3.4.0
  args:
  - --csi-address=$(ADDRESS)
  - --v=2
  - --feature-gates=Topology=true
  - --strict-topology
  - --immediate-topology=false
  env:
  - name: ADDRESS
    value: /var/lib/csi/sockets/pluginproxy/csi.sock
```

### External Attacher
```yaml
- name: csi-attacher
  image: k8s.gcr.io/sig-storage/csi-attacher:v4.1.0
  args:
  - --csi-address=$(ADDRESS)
  - --v=2
  - --timeout=60s
  - --retry-interval-start=10s
  env:
  - name: ADDRESS
    value: /var/lib/csi/sockets/pluginproxy/csi.sock
```

### External Resizer
```yaml
- name: csi-resizer
  image: k8s.gcr.io/sig-storage/csi-resizer:v1.7.0
  args:
  - --csi-address=$(ADDRESS)
  - --v=2
  - --timeout=60s
  env:
  - name: ADDRESS
    value: /var/lib/csi/sockets/pluginproxy/csi.sock
```

### External Snapshotter
```yaml
- name: csi-snapshotter
  image: k8s.gcr.io/sig-storage/csi-snapshotter:v6.2.1
  args:
  - --csi-address=$(ADDRESS)
  - --v=2
  - --timeout=60s
  env:
  - name: ADDRESS
    value: /var/lib/csi/sockets/pluginproxy/csi.sock
```

---

## CSI Driver Installation

### Helm Installation
```bash
# Install AWS EBS CSI Driver
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set enableVolumeScheduling=true \
  --set enableVolumeResizing=true \
  --set enableVolumeSnapshot=true

# Install Longhorn
helm repo add longhorn https://charts.longhorn.io
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

### Operator Installation
```bash
# Install Rook Ceph Operator
kubectl apply -f https://raw.githubusercontent.com/rook/rook/release-1.11/deploy/examples/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/release-1.11/deploy/examples/common.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/release-1.11/deploy/examples/operator.yaml
```

---

## CSI Monitoring

### Metrics Collection
```yaml
# CSI Driver Metrics
apiVersion: v1
kind: Service
metadata:
  name: csi-driver-metrics
  labels:
    app: csi-driver
spec:
  ports:
  - name: metrics
    port: 8080
    targetPort: 8080
  selector:
    app: csi-driver
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: csi-driver-metrics
spec:
  selector:
    matchLabels:
      app: csi-driver
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

### Prometheus Rules
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: csi-driver-alerts
spec:
  groups:
  - name: csi-driver
    rules:
    - alert: CSIVolumeProvisioningFailed
      expr: increase(csi_operations_seconds_count{method_name="CreateVolume",grpc_code!="OK"}[5m]) > 0
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "CSI volume provisioning failures detected"
    
    - alert: CSIVolumeAttachmentFailed
      expr: increase(csi_operations_seconds_count{method_name="ControllerPublishVolume",grpc_code!="OK"}[5m]) > 0
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "CSI volume attachment failures detected"
```

---

## CSI Troubleshooting

### Common Issues

#### 1. Driver Registration Issues
```bash
# Check CSI driver registration
kubectl get csidriver

# Check node driver registrar logs
kubectl logs -n kube-system -l app=csi-node -c csi-node-driver-registrar

# Check kubelet plugin directory
ls -la /var/lib/kubelet/plugins/
ls -la /var/lib/kubelet/plugins_registry/
```

#### 2. Volume Provisioning Issues
```bash
# Check controller logs
kubectl logs -n kube-system -l app=csi-controller -c csi-driver

# Check provisioner logs
kubectl logs -n kube-system -l app=csi-controller -c csi-provisioner

# Check PVC events
kubectl describe pvc my-pvc
```

#### 3. Volume Attachment Issues
```bash
# Check volume attachments
kubectl get volumeattachment

# Check attacher logs
kubectl logs -n kube-system -l app=csi-controller -c csi-attacher

# Check node plugin logs
kubectl logs -n kube-system -l app=csi-node -c csi-driver
```

#### 4. Mount Issues
```bash
# Check pod events
kubectl describe pod my-pod

# Check node plugin logs
kubectl logs -n kube-system -l app=csi-node -c csi-driver

# Check mount points on node
ssh node-name
mount | grep csi
```

### Debug Commands
```bash
# Check CSI components
kubectl get pods -n kube-system | grep csi
kubectl get csidriver
kubectl get csistoragecapacity

# Check volume operations
kubectl get pv,pvc
kubectl get volumeattachment
kubectl get volumesnapshot

# Check storage classes
kubectl get storageclass
kubectl describe storageclass my-storage-class
```

---

## CSI Best Practices

### 1. Driver Development
- Implement all required CSI interfaces
- Handle errors gracefully
- Support idempotent operations
- Implement proper logging and metrics
- Follow CSI specification strictly

### 2. Deployment
- Use appropriate resource limits
- Implement health checks
- Configure proper RBAC
- Use secure communication
- Plan for high availability

### 3. Operations
- Monitor driver performance
- Implement backup strategies
- Test disaster recovery
- Regular driver updates
- Capacity planning

### 4. Security
- Use least privilege principles
- Secure driver communications
- Implement proper authentication
- Regular security audits
- Encrypt sensitive data

---

## CSI Future Features

### Upcoming Capabilities
- **Volume Health Monitoring**: Real-time volume health status
- **Volume Populators**: Initialize volumes from data sources
- **Cross-Namespace Volume Access**: Share volumes across namespaces
- **Volume Group Snapshots**: Consistent snapshots of volume groups
- **Generic Ephemeral Volumes**: CSI-backed ephemeral volumes

## Conclusion

CSI drivers provide a standardized interface for integrating storage systems with Kubernetes, enabling:
- Vendor-neutral storage integration
- Rich feature support (snapshots, cloning, expansion)
- Consistent storage operations across platforms
- Extensible storage ecosystem
- Future-proof storage architecture

Understanding CSI architecture and implementation is crucial for managing modern Kubernetes storage infrastructure and developing custom storage solutions.