# Kubernetes Nodes

## Overview

**Kubernetes Nodes** are the worker machines in a Kubernetes cluster where application workloads run. Each node contains the necessary services to run pods and is managed by the control plane. Nodes can be physical machines or virtual machines.

## What are Kubernetes Nodes?

Kubernetes Nodes are:
- Worker machines that run containerized applications
- Managed by the Kubernetes control plane
- Can be physical servers, VMs, or cloud instances
- The compute resources where pods are scheduled and executed

## Node Architecture

### Node Components
```
┌─────────────────────────────────────────┐
│              Kubernetes Node            │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   kubelet   │  │ Container       │   │
│  │             │  │ Runtime         │   │
│  └─────────────┘  └─────────────────┘   │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ kube-proxy  │  │ Pod Network     │   │
│  │             │  │ (CNI)           │   │
│  └─────────────┘  └─────────────────┘   │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Pods        │  │ System          │   │
│  │             │  │ Services        │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

### Communication Flow
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Control     │───►│    Node     │───►│    Pods     │
│ Plane       │    │  (kubelet)  │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   ▼                   │
       │            ┌─────────────┐            │
       │            │ kube-proxy  │            │
       │            │ (Networking)│            │
       │            └─────────────┘            │
       │                   │                   │
       │                   ▼                   │
       └────────────┌─────────────┐◄───────────┘
                    │ Container   │
                    │ Runtime     │
                    └─────────────┘
```

## Node Types

### 1. Control Plane Nodes (Master Nodes)
**Purpose**: Run control plane components

**Components**:
- API Server
- etcd
- Controller Manager
- Scheduler
- Cloud Controller Manager (if applicable)

```yaml
apiVersion: v1
kind: Node
metadata:
  name: control-plane-node
  labels:
    node-role.kubernetes.io/control-plane: ""
    node-role.kubernetes.io/master: ""
spec:
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
```

### 2. Worker Nodes
**Purpose**: Run application workloads

**Components**:
- kubelet
- kube-proxy
- Container Runtime
- CNI Plugin

```yaml
apiVersion: v1
kind: Node
metadata:
  name: worker-node-1
  labels:
    node-role.kubernetes.io/worker: ""
    kubernetes.io/arch: amd64
    kubernetes.io/os: linux
spec:
  podCIDR: 10.244.1.0/24
```

## Node Lifecycle

### Node Registration
```yaml
# Automatic registration via kubelet
apiVersion: v1
kind: Node
metadata:
  name: worker-node-1
  labels:
    kubernetes.io/arch: amd64
    kubernetes.io/os: linux
    kubernetes.io/hostname: worker-node-1
spec:
  podCIDR: 10.244.1.0/24
  providerID: aws:///us-west-2a/i-1234567890abcdef0
status:
  capacity:
    cpu: "4"
    memory: 8Gi
    pods: "110"
    storage: 100Gi
  allocatable:
    cpu: "3800m"
    memory: 7.5Gi
    pods: "110"
    storage: 95Gi
```

### Node Status Conditions
```yaml
status:
  conditions:
  - type: Ready
    status: "True"
    reason: KubeletReady
    message: kubelet is posting ready status
  - type: MemoryPressure
    status: "False"
    reason: KubeletHasSufficientMemory
  - type: DiskPressure
    status: "False"
    reason: KubeletHasNoDiskPressure
  - type: PIDPressure
    status: "False"
    reason: KubeletHasSufficientPID
  - type: NetworkUnavailable
    status: "False"
    reason: RouteCreated
```

### Node Phases
1. **Pending**: Node registered but not ready
2. **Running**: Node is healthy and ready for pods
3. **Terminated**: Node is being removed from cluster
4. **Unknown**: Node status cannot be determined

## Node Resources

### Resource Types
```yaml
status:
  capacity:
    cpu: "8"                    # CPU cores
    memory: "16Gi"              # RAM
    ephemeral-storage: "100Gi"  # Local storage
    pods: "110"                 # Maximum pods
    nvidia.com/gpu: "2"         # Custom resources
  allocatable:
    cpu: "7800m"                # Available CPU (after system reservation)
    memory: "15Gi"              # Available memory
    ephemeral-storage: "95Gi"   # Available storage
    pods: "110"                 # Available pod slots
    nvidia.com/gpu: "2"         # Available GPUs
```

### Resource Reservation
```yaml
# Kubelet configuration for resource reservation
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
kubeReserved:
  cpu: "100m"
  memory: "100Mi"
  ephemeral-storage: "1Gi"
systemReserved:
  cpu: "100m"
  memory: "100Mi"
  ephemeral-storage: "1Gi"
evictionHard:
  memory.available: "100Mi"
  nodefs.available: "10%"
  imagefs.available: "15%"
```

## Node Management

### Node Operations

#### View Nodes
```bash
# List all nodes
kubectl get nodes

# Detailed node information
kubectl get nodes -o wide

# Node with labels
kubectl get nodes --show-labels

# Specific node details
kubectl describe node worker-node-1
```

#### Node Labeling
```bash
# Add label to node
kubectl label nodes worker-node-1 disktype=ssd

# Update existing label
kubectl label nodes worker-node-1 disktype=nvme --overwrite

# Remove label
kubectl label nodes worker-node-1 disktype-

# Label multiple nodes
kubectl label nodes worker-node-1 worker-node-2 environment=production
```

#### Node Tainting
```bash
# Add taint to node
kubectl taint nodes worker-node-1 key=value:NoSchedule

# Remove taint
kubectl taint nodes worker-node-1 key=value:NoSchedule-

# Multiple taints
kubectl taint nodes worker-node-1 gpu=true:NoSchedule
kubectl taint nodes worker-node-1 dedicated=ml:NoExecute
```

### Node Scheduling

#### Node Selectors
```yaml
apiVersion: v1
kind: Pod
spec:
  nodeSelector:
    disktype: ssd
    kubernetes.io/arch: amd64
  containers:
  - name: app
    image: nginx
```

#### Node Affinity
```yaml
apiVersion: v1
kind: Pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values: ["amd64"]
          - key: disktype
            operator: In
            values: ["ssd", "nvme"]
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values: ["us-west-2a"]
```

#### Tolerations
```yaml
apiVersion: v1
kind: Pod
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  - key: "dedicated"
    operator: "Equal"
    value: "ml"
    effect: "NoExecute"
    tolerationSeconds: 3600
```

## Node Maintenance

### Draining Nodes
```bash
# Drain node for maintenance
kubectl drain worker-node-1 --ignore-daemonsets --delete-emptydir-data

# Drain with grace period
kubectl drain worker-node-1 --grace-period=300 --ignore-daemonsets

# Force drain
kubectl drain worker-node-1 --force --ignore-daemonsets --delete-emptydir-data

# Drain specific pods
kubectl drain worker-node-1 --pod-selector="app!=critical"
```

### Cordoning Nodes
```bash
# Cordon node (prevent new pods)
kubectl cordon worker-node-1

# Uncordon node (allow scheduling)
kubectl uncordon worker-node-1

# Check node scheduling status
kubectl get nodes
```

### Node Replacement
```bash
# Remove node from cluster
kubectl delete node worker-node-1

# Reset node (on the node itself)
kubeadm reset

# Rejoin node to cluster
kubeadm join <control-plane-endpoint> --token <token> --discovery-token-ca-cert-hash <hash>
```

## Node Monitoring

### Node Metrics
```bash
# Node resource usage
kubectl top nodes

# Detailed node metrics
kubectl top nodes --sort-by=cpu
kubectl top nodes --sort-by=memory

# Node capacity and allocation
kubectl describe nodes | grep -A 5 "Allocated resources"
```

### Node Events
```bash
# View node events
kubectl get events --field-selector involvedObject.kind=Node

# Node-specific events
kubectl get events --field-selector involvedObject.name=worker-node-1

# Recent events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Health Checks
```bash
# Check node conditions
kubectl get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,REASON:.status.conditions[-1].reason

# Node readiness
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'

# System pod status on nodes
kubectl get pods -o wide --all-namespaces | grep worker-node-1
```

## Node Security

### Node Hardening
```bash
# Disable unnecessary services
systemctl disable cups
systemctl disable avahi-daemon

# Configure firewall
ufw enable
ufw allow 22/tcp
ufw allow 10250/tcp  # kubelet
ufw allow 30000:32767/tcp  # NodePort services

# Kernel parameters
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```

### Pod Security
```yaml
# Pod Security Standards
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## Node Troubleshooting

### Common Issues

#### 1. Node Not Ready
```bash
# Check node status
kubectl describe node worker-node-1

# Check kubelet logs
journalctl -u kubelet -f

# Check system resources
df -h
free -h
top
```

#### 2. Pod Scheduling Issues
```bash
# Check node capacity
kubectl describe node worker-node-1 | grep -A 10 "Allocated resources"

# Check taints and tolerations
kubectl describe node worker-node-1 | grep -A 5 Taints

# Check node selectors
kubectl get pods -o wide | grep Pending
kubectl describe pod <pending-pod>
```

#### 3. Network Issues
```bash
# Check CNI configuration
ls -la /etc/cni/net.d/

# Check network interfaces
ip addr show

# Test pod-to-pod connectivity
kubectl exec -it pod1 -- ping <pod2-ip>

# Check kube-proxy
kubectl get pods -n kube-system | grep kube-proxy
kubectl logs -n kube-system kube-proxy-<node>
```

#### 4. Storage Issues
```bash
# Check disk usage
df -h
du -sh /var/lib/kubelet/
du -sh /var/lib/containerd/

# Check volume mounts
mount | grep kubelet

# Clean up unused images
crictl rmi --prune
docker system prune -f
```

### Debug Commands
```bash
# Node system information
kubectl get nodes -o yaml

# Kubelet configuration
kubectl proxy &
curl http://localhost:8001/api/v1/nodes/worker-node-1/proxy/configz

# Node metrics
curl http://localhost:8001/api/v1/nodes/worker-node-1/proxy/metrics

# System pods on node
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=worker-node-1
```

## Node Scaling

### Manual Scaling
```bash
# Add new node
kubeadm join <control-plane-endpoint> --token <token> --discovery-token-ca-cert-hash <hash>

# Remove node
kubectl drain worker-node-3 --ignore-daemonsets --delete-emptydir-data
kubectl delete node worker-node-3
```

### Cluster Autoscaler
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/my-cluster
```

## Node Performance Optimization

### System Tuning
```bash
# CPU governor
echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Kernel parameters
echo 'vm.swappiness = 1' >> /etc/sysctl.conf
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
echo 'kernel.panic = 10' >> /etc/sysctl.conf
echo 'kernel.panic_on_oops = 1' >> /etc/sysctl.conf

# Network optimization
echo 'net.core.somaxconn = 32768' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 16384' >> /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 16384' >> /etc/sysctl.conf
```

### Resource Limits
```yaml
# Kubelet configuration
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 250
podsPerCore: 10
kubeAPIQPS: 50
kubeAPIBurst: 100
serializeImagePulls: false
registryPullQPS: 10
registryBurst: 20
```

### Container Runtime Optimization
```toml
# containerd configuration
[plugins."io.containerd.grpc.v1.cri"]
  max_concurrent_downloads = 10
  
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"
  
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
```

## Best Practices

### 1. Node Configuration
- Use consistent node configurations across the cluster
- Implement proper resource reservations
- Configure appropriate eviction thresholds
- Use systemd for service management

### 2. Security
- Harden nodes according to CIS benchmarks
- Implement network policies
- Use Pod Security Standards
- Regular security updates

### 3. Monitoring
- Monitor node health and resource usage
- Set up alerting for node conditions
- Track node capacity and utilization
- Monitor system-level metrics

### 4. Maintenance
- Plan for regular node maintenance windows
- Implement graceful node draining procedures
- Keep nodes updated with security patches
- Test disaster recovery procedures

## Cloud Provider Integration

### AWS Integration
```yaml
apiVersion: v1
kind: Node
metadata:
  name: ip-10-0-1-100.us-west-2.compute.internal
  labels:
    beta.kubernetes.io/instance-type: m5.large
    failure-domain.beta.kubernetes.io/region: us-west-2
    failure-domain.beta.kubernetes.io/zone: us-west-2a
    kubernetes.io/arch: amd64
    kubernetes.io/os: linux
    node.kubernetes.io/instance-type: m5.large
spec:
  providerID: aws:///us-west-2a/i-1234567890abcdef0
```

### GCP Integration
```yaml
apiVersion: v1
kind: Node
metadata:
  name: gke-cluster-default-pool-12345678-abcd
  labels:
    cloud.google.com/gke-nodepool: default-pool
    kubernetes.io/arch: amd64
    kubernetes.io/os: linux
spec:
  providerID: gce://project-id/us-central1-a/gke-cluster-default-pool-12345678-abcd
```

### Azure Integration
```yaml
apiVersion: v1
kind: Node
metadata:
  name: aks-nodepool1-12345678-vmss000000
  labels:
    agentpool: nodepool1
    kubernetes.azure.com/cluster: aks-cluster
    kubernetes.io/arch: amd64
    kubernetes.io/os: linux
spec:
  providerID: azure:///subscriptions/sub-id/resourceGroups/rg/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-12345678-vmss/virtualMachines/0
```

## Conclusion

Kubernetes Nodes are essential for:
- Running application workloads in the cluster
- Providing compute, memory, and storage resources
- Enabling distributed application deployment
- Supporting cluster scalability and reliability

Understanding node architecture, management, and troubleshooting is crucial for maintaining healthy Kubernetes clusters and ensuring optimal application performance.