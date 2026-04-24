# Kubelet - Kubernetes Node Agent

## Overview

**Kubelet** is the primary node agent that runs on each worker node in a Kubernetes cluster. It ensures that containers are running in pods as specified by the API Server and manages the node's lifecycle, pod execution, and resource monitoring.

## What is Kubelet?

Kubelet is:
- The primary node agent running on every Kubernetes node
- Responsible for pod lifecycle management on the node
- The bridge between the Kubernetes control plane and container runtime
- A critical component for node health and pod execution

## Role in Kubernetes Architecture

### Primary Functions

1. **Pod Lifecycle Management**
   - Creates, starts, stops, and deletes pods
   - Monitors pod health and status
   - Manages container restarts and failures

2. **Node Management**
   - Registers node with the API Server
   - Reports node status and resource usage
   - Manages node-level operations

3. **Resource Monitoring**
   - Collects node and pod metrics
   - Enforces resource limits and requests
   - Reports resource usage to control plane

## Kubelet Architecture

### Component Interaction
```
┌─────────────────────────────────────────┐
│              Kubelet                    │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Pod Manager │  │ Node Status     │   │
│  │             │  │ Manager         │   │
│  └─────────────┘  └─────────────────┘   │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Container   │  │ Volume Manager  │   │
│  │ Runtime     │  │                 │   │
│  └─────────────┘  └─────────────────┘   │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ cAdvisor    │  │ Device Manager  │   │
│  │             │  │                 │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

### Communication Flow
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ API Server  │───►│   Kubelet   │───►│ Container   │
│             │    │             │    │ Runtime     │
└─────────────┘    └─────────────┘    └─────────────┘
       ▲                   │                   │
       │                   ▼                   │
       │            ┌─────────────┐            │
       │            │   cAdvisor  │            │
       │            │  (Metrics)  │            │
       │            └─────────────┘            │
       │                   │                   │
       │                   ▼                   │
       └────────────┌─────────────┐◄───────────┘
                    │   Node      │
                    │   Status    │
                    └─────────────┘
```

## Core Components

### 1. Pod Manager
**Purpose**: Manages pod lifecycle on the node

**Responsibilities**:
- Receives pod specifications from API Server
- Creates and manages pod sandboxes
- Handles pod startup and shutdown
- Manages pod status updates

### 2. Container Runtime Interface (CRI)
**Purpose**: Interfaces with container runtimes

**Supported Runtimes**:
- containerd
- CRI-O
- Docker (deprecated)

```yaml
# Runtime configuration
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
```

### 3. Volume Manager
**Purpose**: Manages volume mounting and unmounting

**Responsibilities**:
- Mounts volumes before container startup
- Unmounts volumes after container termination
- Handles volume plugins and CSI drivers
- Manages persistent volume claims

### 4. Device Manager
**Purpose**: Manages hardware devices

**Responsibilities**:
- Discovers and advertises hardware resources
- Allocates devices to containers
- Manages GPU, FPGA, and other specialized hardware
- Handles device plugin lifecycle

### 5. cAdvisor
**Purpose**: Collects resource usage metrics

**Responsibilities**:
- Monitors container resource usage
- Collects CPU, memory, network, and disk metrics
- Provides metrics API endpoint
- Integrates with monitoring systems

## Kubelet Configuration

### Configuration File
```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
authorization:
  mode: Webhook
clusterDomain: cluster.local
clusterDNS:
- 10.96.0.10
containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
cgroupDriver: systemd
failSwapOn: false
```

### Command Line Flags
```bash
kubelet \
  --config=/var/lib/kubelet/config.yaml \
  --kubeconfig=/etc/kubernetes/kubelet.conf \
  --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf \
  --rotate-certificates=true \
  --cert-dir=/var/lib/kubelet/pki \
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
  --pod-infra-container-image=k8s.gcr.io/pause:3.7 \
  --resolv-conf=/run/systemd/resolve/resolv.conf \
  --v=2
```

## Pod Lifecycle Management

### Pod Creation Process
```
1. API Server → Kubelet: Pod Specification
2. Kubelet → Runtime: Create Pod Sandbox
3. Kubelet → Runtime: Create Init Containers
4. Kubelet → Runtime: Create App Containers
5. Kubelet → API Server: Pod Status Update
```

### Pod States
```yaml
# Pod status phases
status:
  phase: Running  # Pending, Running, Succeeded, Failed, Unknown
  conditions:
  - type: Initialized
    status: "True"
  - type: Ready
    status: "True"
  - type: ContainersReady
    status: "True"
  - type: PodScheduled
    status: "True"
```

### Container Lifecycle Hooks
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo 'Container started'"]
      preStop:
        exec:
          command: ["/bin/sh", "-c", "echo 'Container stopping'"]
```

## Resource Management

### Resource Requests and Limits
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
```

### Quality of Service Classes

#### Guaranteed
```yaml
# All containers have requests = limits
resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "500m"
    memory: "1Gi"
```

#### Burstable
```yaml
# At least one container has requests < limits
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

#### BestEffort
```yaml
# No requests or limits specified
resources: {}
```

### Resource Enforcement
- **CPU**: Throttling via cgroups
- **Memory**: OOM killing when limits exceeded
- **Storage**: Eviction when disk usage high
- **Network**: Bandwidth limiting (CNI dependent)

## Node Management

### Node Registration
```yaml
# Automatic node registration
apiVersion: v1
kind: Node
metadata:
  name: worker-node-1
  labels:
    kubernetes.io/arch: amd64
    kubernetes.io/os: linux
    node-role.kubernetes.io/worker: ""
spec:
  podCIDR: 10.244.1.0/24
status:
  capacity:
    cpu: "4"
    memory: 8Gi
    pods: "110"
  allocatable:
    cpu: "3800m"
    memory: 7.5Gi
    pods: "110"
```

### Node Status Reporting
```yaml
status:
  conditions:
  - type: Ready
    status: "True"
    reason: KubeletReady
  - type: MemoryPressure
    status: "False"
  - type: DiskPressure
    status: "False"
  - type: PIDPressure
    status: "False"
  - type: NetworkUnavailable
    status: "False"
```

### Node Heartbeat
```bash
# Kubelet sends heartbeat every 10 seconds (default)
--node-status-update-frequency=10s

# Node lease renewal
--node-lease-duration-seconds=40
```

## Health Checks and Probes

### Liveness Probes
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: nginx
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
```

### Readiness Probes
```yaml
readinessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Startup Probes
```yaml
startupProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 30
```

## Volume Management

### Volume Types
```yaml
apiVersion: v1
kind: Pod
spec:
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: secret-volume
    secret:
      secretName: app-secret
  - name: pv-storage
    persistentVolumeClaim:
      claimName: my-pvc
  - name: host-volume
    hostPath:
      path: /var/log
      type: Directory
```

### Volume Mounting
```yaml
containers:
- name: app
  image: nginx
  volumeMounts:
  - name: config-volume
    mountPath: /etc/config
  - name: secret-volume
    mountPath: /etc/secrets
    readOnly: true
  - name: pv-storage
    mountPath: /data
```

## Security Features

### Pod Security Standards
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
```

### Container Security Context
```yaml
containers:
- name: app
  image: nginx
  securityContext:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 1000
    capabilities:
      drop:
      - ALL
      add:
      - NET_BIND_SERVICE
```

### AppArmor and SELinux
```yaml
metadata:
  annotations:
    container.apparmor.security.beta.kubernetes.io/app: runtime/default
spec:
  securityContext:
    seLinuxOptions:
      level: "s0:c123,c456"
```

## Monitoring and Observability

### Kubelet Metrics
```bash
# Kubelet metrics endpoint
curl -k https://node-ip:10250/metrics

# cAdvisor metrics endpoint
curl http://node-ip:10255/metrics/cadvisor
```

### Key Metrics

#### Node Metrics
- **kubelet_node_config_error**: Node configuration errors
- **kubelet_runtime_operations_total**: Container runtime operations
- **kubelet_pod_start_duration_seconds**: Pod startup time
- **kubelet_running_pods**: Number of running pods

#### Resource Metrics
- **container_cpu_usage_seconds_total**: CPU usage
- **container_memory_usage_bytes**: Memory usage
- **container_fs_usage_bytes**: Filesystem usage
- **container_network_receive_bytes_total**: Network received bytes

### Health Endpoints
```bash
# Kubelet health check
curl -k https://node-ip:10250/healthz

# Pod logs
curl -k https://node-ip:10250/logs/

# Running pods
curl -k https://node-ip:10250/runningpods/
```

## Troubleshooting

### Common Issues

#### 1. Pod Startup Failures
```bash
# Check kubelet logs
journalctl -u kubelet -f

# Check pod events
kubectl describe pod <pod-name>

# Check container runtime
crictl ps -a
crictl logs <container-id>
```

#### 2. Resource Issues
```bash
# Check node resources
kubectl describe node <node-name>

# Check disk usage
df -h
du -sh /var/lib/kubelet/

# Check memory pressure
free -h
cat /proc/meminfo
```

#### 3. Network Issues
```bash
# Check CNI configuration
ls -la /etc/cni/net.d/

# Check network interfaces
ip addr show

# Check DNS resolution
nslookup kubernetes.default.svc.cluster.local
```

#### 4. Certificate Issues
```bash
# Check kubelet certificates
openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -text -noout

# Check certificate rotation
ls -la /var/lib/kubelet/pki/

# Restart kubelet for certificate refresh
systemctl restart kubelet
```

### Debug Commands
```bash
# Enable verbose logging
kubelet --v=4

# Check kubelet configuration
kubelet --print-join-command

# Validate configuration
kubelet --config=/var/lib/kubelet/config.yaml --dry-run

# Check runtime connectivity
crictl version
crictl info
```

## Performance Tuning

### Resource Allocation
```yaml
# Kubelet configuration for performance
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 250
podsPerCore: 10
kubeReserved:
  cpu: "100m"
  memory: "100Mi"
systemReserved:
  cpu: "100m"
  memory: "100Mi"
evictionHard:
  memory.available: "100Mi"
  nodefs.available: "10%"
```

### Container Runtime Optimization
```bash
# containerd configuration
[plugins."io.containerd.grpc.v1.cri"]
  max_concurrent_downloads = 10
  max_container_log_line_size = 16384

[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"
  default_runtime_name = "runc"
```

### System Optimization
```bash
# Kernel parameters
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

## High Availability

### Node Redundancy
```yaml
# Anti-affinity for critical workloads
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: critical-app
      topologyKey: kubernetes.io/hostname
```

### Graceful Node Shutdown
```yaml
# Kubelet configuration
shutdownGracePeriod: 60s
shutdownGracePeriodCriticalPods: 20s
```

### Node Maintenance
```bash
# Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Cordon node (prevent new pods)
kubectl cordon <node-name>

# Uncordon node (allow scheduling)
kubectl uncordon <node-name>
```

## Security Best Practices

### 1. Authentication and Authorization
- Enable webhook authentication
- Use RBAC for fine-grained permissions
- Rotate certificates regularly
- Disable anonymous access

### 2. Network Security
- Use network policies
- Secure kubelet API with TLS
- Restrict access to kubelet ports
- Use CNI with security features

### 3. Container Security
- Use non-root containers
- Enable read-only root filesystem
- Drop unnecessary capabilities
- Use security contexts

### 4. System Security
- Keep kubelet updated
- Harden host OS
- Use container image scanning
- Enable audit logging

## Integration with Container Runtimes

### containerd Integration
```toml
# /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "k8s.gcr.io/pause:3.7"
  
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"
  
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
```

### CRI-O Integration
```toml
# /etc/crio/crio.conf
[crio.runtime]
default_runtime = "runc"
pause_image = "k8s.gcr.io/pause:3.7"
cgroup_manager = "systemd"
```

## Device Plugins

### GPU Device Plugin Example
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nvidia-device-plugin
spec:
  selector:
    matchLabels:
      name: nvidia-device-plugin
  template:
    spec:
      containers:
      - name: nvidia-device-plugin
        image: nvidia/k8s-device-plugin:v0.12.0
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        volumeMounts:
        - name: device-plugin
          mountPath: /var/lib/kubelet/device-plugins
```

## Conclusion

Kubelet is essential for:
- Pod lifecycle management on worker nodes
- Node health monitoring and reporting
- Resource enforcement and management
- Container runtime integration
- Security policy enforcement

Understanding kubelet configuration and operation is crucial for maintaining healthy Kubernetes nodes and ensuring reliable pod execution.