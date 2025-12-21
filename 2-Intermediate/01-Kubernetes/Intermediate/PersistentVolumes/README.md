# Kubernetes Persistent Volumes

## Overview

**Kubernetes Persistent Volumes (PV)** provide durable storage that exists beyond the lifecycle of individual pods. PVs work with Persistent Volume Claims (PVCs) to provide storage abstraction.

## Persistent Volume

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-example
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
```

## Persistent Volume Claim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-example
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```

## Access Modes

- **ReadWriteOnce (RWO)**: Volume can be mounted read-write by single node
- **ReadOnlyMany (ROX)**: Volume can be mounted read-only by many nodes
- **ReadWriteMany (RWX)**: Volume can be mounted read-write by many nodes

## Reclaim Policies

- **Retain**: Manual reclamation of the resource
- **Delete**: Associated storage asset is deleted
- **Recycle**: Basic scrub (deprecated)

## Volume Binding Modes

- **Immediate**: PV binding occurs immediately when PVC is created
- **WaitForFirstConsumer**: PV binding delayed until pod using PVC is created

## Using PVC in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pv-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc-example
```

## Dynamic Provisioning

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 10Gi
```

## Volume Expansion

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: expandable-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: expandable-storage
  resources:
    requests:
      storage: 20Gi  # Increased from 10Gi
```

## Best Practices

- Use appropriate access modes
- Set proper reclaim policies
- Monitor storage usage
- Implement backup strategies
- Use dynamic provisioning when possible

## Troubleshooting

```bash
# Check PV status
kubectl get pv

# Check PVC status
kubectl get pvc

# Describe PVC for events
kubectl describe pvc my-pvc

# Check storage class
kubectl get storageclass
```

## Conclusion

Persistent Volumes provide essential durable storage capabilities for stateful applications in Kubernetes, enabling data persistence beyond pod lifecycles.