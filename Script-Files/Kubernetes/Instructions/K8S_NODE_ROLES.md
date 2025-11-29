# Kubernetes Setup Scripts - Node Roles and Labels

## Overview
This directory contains initialization scripts for setting up a Kubernetes cluster with one master node and two worker nodes (agents).

## Node Architecture

### Cluster Topology
```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────┐                                   │
│  │  Master Node     │ (Control Plane)                   │
│  │  K8s-Master      │                                   │
│  │  Role:           │                                   │
│  │  control-plane   │                                   │
│  └──────────────────┘                                   │
│           │                                               │
│           ├─────────────────┬─────────────────┐         │
│           │                 │                 │         │
│  ┌────────▼──────┐  ┌──────▼────────┐  ┌────▼──────┐  │
│  │  Agent 1       │  │  Agent 2       │  │  (Future)  │  │
│  │  K8s-Worker    │  │  K8s-Agent-2   │  │  Nodes     │  │
│  │  Role:         │  │  Role:         │  │            │  │
│  │  primary-agent │  │  secondary-    │  │            │  │
│  │                │  │  agent         │  │            │  │
│  └────────────────┘  └────────────────┘  └────────────┘  │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## Node Roles and Labels

### 1. Master Node (Control Plane)
- **Hostname**: `K8s-Master-Server`
- **Script**: `k8s_master.sh`
- **Role**: Control Plane
- **Labels**:
  - `node-role.kubernetes.io/control-plane=control-plane`
  - `node.kubernetes.io/role=control-plane`
- **Responsibilities**:
  - Cluster management
  - API server
  - Scheduler
  - Controller manager
  - etcd (cluster state)

### 2. Primary Agent (Worker Node 1)
- **Hostname**: `K8s-Worker-Server`
- **Script**: `k8s_agent_1_server.sh`
- **Role**: Primary Agent / Worker
- **Labels**:
  - `node-role.kubernetes.io/worker=worker`
  - `node.kubernetes.io/role=K8s-primary-agent`
- **Responsibilities**:
  - Run application workloads
  - Execute pods assigned by scheduler
  - Primary worker for production workloads

### 3. Secondary Agent (Worker Node 2)
- **Hostname**: `K8s-Agent-2-Server`
- **Script**: `k8s_agent_2_server.sh`
- **Role**: Secondary Agent / Worker
- **Labels**:
  - `node-role.kubernetes.io/worker=worker`
  - `node.kubernetes.io/role=K8s-secondary-agent`
- **Responsibilities**:
  - Run application workloads
  - Execute pods assigned by scheduler
  - Secondary worker for load distribution

## Setup Sequence

### Step 1: Initialize Master Node
```bash
# On the master node
sudo bash k8s_master.sh
```

This will:
- Install and configure Kubernetes control plane
- Initialize the cluster with Calico CNI
- Generate join command
- Apply control-plane labels automatically

### Step 2: Setup Worker Nodes
```bash
# On Agent 1 (Primary)
sudo bash k8s_agent_1_server.sh

# On Agent 2 (Secondary)
sudo bash k8s_agent_2_server.sh
```

### Step 3: Join Workers to Cluster
```bash
# On each worker node, run the join command from master
# Get the command from master:
ssh master-node 'sudo kubeadm token create --print-join-command'

# Then execute it on the worker:
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### Step 4: Apply Node Labels
```bash
# Run these commands FROM THE MASTER NODE after workers have joined

# Label Agent 1 (Primary Worker)
kubectl label node K8s-Worker-Server node-role.kubernetes.io/worker=worker
kubectl label node K8s-Worker-Server node.kubernetes.io/role=K8s-primary-agent

# Label Agent 2 (Secondary Worker)
kubectl label node K8s-Agent-2-Server node-role.kubernetes.io/worker=worker
kubectl label node K8s-Agent-2-Server node.kubernetes.io/role=K8s-secondary-agent
```

### Step 5: Verify Cluster
```bash
# Check node status
kubectl get nodes

# Check node labels
kubectl get nodes --show-labels

# View nodes with specific columns
kubectl get nodes -o wide
```

## Label Usage

### Why Label Nodes?

1. **Pod Scheduling**: Use nodeSelector or nodeAffinity to assign pods to specific nodes
2. **Resource Organization**: Group nodes by role or purpose
3. **Monitoring**: Easily identify node types in monitoring dashboards
4. **Maintenance**: Target specific node groups for updates or maintenance

### Example: Scheduling Pods to Specific Agents

#### Deploy to Primary Agent Only
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: primary-app
spec:
  nodeSelector:
    node.kubernetes.io/role: K8s-primary-agent
  containers:
  - name: app
    image: nginx
```

#### Deploy to Secondary Agent Only
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secondary-app
spec:
  nodeSelector:
    node.kubernetes.io/role: K8s-secondary-agent
  containers:
  - name: app
    image: nginx
```

#### Deploy to Any Worker (Primary or Secondary)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: worker-app
spec:
  nodeSelector:
    node-role.kubernetes.io/worker: worker
  containers:
  - name: app
    image: nginx
```

## Scripts Included

### Application Server Scripts
- `master.sh` - Jenkins master server setup
- `worker.sh` - Application worker/build server setup
- `monitoring.sh` - Prometheus & Grafana monitoring server
- `mysql.sh` - MySQL database server

### Kubernetes Cluster Scripts
- `k8s_master.sh` - Kubernetes master/control-plane node
- `k8s_agent_1_server.sh` - Primary worker agent
- `k8s_agent_2_server.sh` - Secondary worker agent

## Common Commands

### View All Node Labels
```bash
kubectl get nodes --show-labels
```

### Add Custom Label
```bash
kubectl label node <node-name> <label-key>=<label-value>
```

### Remove Label
```bash
kubectl label node <node-name> <label-key>-
```

### View Pods by Node
```bash
kubectl get pods -o wide --all-namespaces
```

### Drain Node for Maintenance
```bash
kubectl drain <node-name> --ignore-daemonsets
```

### Uncordon Node After Maintenance
```bash
kubectl uncordon <node-name>
```

## Troubleshooting

### Check if nodes joined successfully
```bash
kubectl get nodes
```

### View node details
```bash
kubectl describe node <node-name>
```

### Check kubelet status on worker
```bash
sudo systemctl status kubelet
sudo journalctl -u kubelet -f
```

### Regenerate join command
```bash
# On master node
sudo kubeadm token create --print-join-command
```

### Reset node to rejoin
```bash
# On worker node
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d /var/lib/kubelet
# Then run join command again
```

## Best Practices

1. **Label Immediately After Join**: Apply labels as soon as workers join the cluster
2. **Consistent Naming**: Use consistent naming conventions for labels
3. **Document Labels**: Keep this documentation updated with any custom labels
4. **Use Namespaces**: Combine node labels with namespaces for better organization
5. **Monitor Resources**: Use labels in monitoring queries to track per-node metrics

## Version Information
- **Kubernetes Version**: v1.31.0
- **Container Runtime**: containerd
- **CNI Plugin**: Calico v3.27.2
- **OS**: RHEL 9 / Amazon Linux 2023
