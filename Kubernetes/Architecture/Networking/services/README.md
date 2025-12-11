# Kubernetes Services

## Overview

**Kubernetes Services** provide stable network endpoints for accessing pods. Services abstract away the complexity of pod networking and provide load balancing, service discovery, and external access to applications running in the cluster.

## Service Types

### ClusterIP (Default)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

### NodePort
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodeport-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

### LoadBalancer
```yaml
apiVersion: v1
kind: Service
metadata:
  name: loadbalancer-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

### ExternalName
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: ExternalName
  externalName: database.example.com
```

## Pod-to-Pod Communication

### Direct Pod Communication
Pods can communicate directly using their IP addresses within the cluster network:

```bash
# Get pod IPs
kubectl get pods -o wide

# Test direct pod communication
kubectl exec -it pod1 -- ping 10.244.1.5
kubectl exec -it pod1 -- curl http://10.244.2.3:8080
```

### Pod Network Architecture
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Node 1    │    │   Node 2    │    │   Node 3    │
│ 10.244.1.0  │    │ 10.244.2.0  │    │ 10.244.3.0  │
│    /24      │    │    /24      │    │    /24      │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                    CNI Plugin
                  (Flannel/Calico)
```

### Pod Communication Methods

#### 1. Same Node Communication
```bash
# Pods on same node communicate via local bridge
# No network overhead - direct kernel routing
kubectl exec pod-a -- ping pod-b-ip  # Same node
```

#### 2. Cross-Node Communication
```bash
# Pods on different nodes use CNI overlay
# Traffic encapsulated (VXLAN/IPIP) or routed (BGP)
kubectl exec pod-a -- ping pod-c-ip  # Different node
```

#### 3. Service-Based Communication (Recommended)
```bash
# Use service names instead of direct IPs
kubectl exec pod-a -- curl http://my-service:80
kubectl exec pod-a -- curl http://my-service.namespace.svc.cluster.local:80
```

## kube-proxy

**kube-proxy** runs on every node and implements Services by maintaining network rules.

### kube-proxy Modes

#### 1. iptables Mode (Default)
```bash
# kube-proxy creates iptables rules for service load balancing
# Check iptables rules created by kube-proxy
sudo iptables -t nat -L KUBE-SERVICES
sudo iptables -t nat -L KUBE-SVC-*
```

**Characteristics**:
- Uses iptables for load balancing
- Random selection of endpoints
- Lower CPU overhead
- No connection tracking

#### 2. IPVS Mode
```yaml
# kube-proxy configuration for IPVS
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  scheduler: "rr"  # round-robin
  strictARP: true
```

**Characteristics**:
- Uses IPVS for load balancing
- Multiple scheduling algorithms (rr, lc, sh)
- Better performance for large clusters
- Connection tracking support

#### 3. userspace Mode (Legacy)
**Deprecated**: High latency due to userspace processing

### kube-proxy Service Implementation

#### ClusterIP Implementation
```bash
# kube-proxy creates virtual IP and load balances to endpoints
# Example iptables rules:
# -A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m tcp --dport 80 -j KUBE-SVC-HASH
# -A KUBE-SVC-HASH -j KUBE-SEP-POD1 --probability 0.33333
# -A KUBE-SVC-HASH -j KUBE-SEP-POD2 --probability 0.50000
# -A KUBE-SVC-HASH -j KUBE-SEP-POD3
```

#### NodePort Implementation
```bash
# kube-proxy opens port on all nodes and forwards to service
# Example iptables rules:
# -A KUBE-NODEPORTS -p tcp -m tcp --dport 30080 -j KUBE-SVC-HASH
```

#### LoadBalancer Implementation
```bash
# kube-proxy + Cloud Controller creates external load balancer
# External LB -> NodePort -> ClusterIP -> Pods
```

### kube-proxy Configuration

```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 0.0.0.0
clientConnection:
  kubeconfig: /var/lib/kube-proxy/kubeconfig.conf
clusterCIDR: 10.244.0.0/16
mode: "iptables"
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  minSyncPeriod: 0s
  scheduler: "rr"
  syncPeriod: 30s
  strictARP: false
```

### kube-proxy Troubleshooting

```bash
# Check kube-proxy status
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# Check kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy

# Check kube-proxy configuration
kubectl get configmap -n kube-system kube-proxy -o yaml

# Test service connectivity
kubectl run test-pod --image=busybox -it --rm -- nslookup my-service

# Check iptables rules (on node)
sudo iptables -t nat -L | grep KUBE

# Check IPVS rules (if using IPVS mode)
sudo ipvsadm -L -n
```

## Service Discovery

### DNS-Based Discovery
```bash
# Service FQDN format
<service-name>.<namespace>.svc.cluster.local

# Examples
my-service.default.svc.cluster.local
database.production.svc.cluster.local
```

### Environment Variables
```bash
# Kubernetes automatically creates environment variables for services
echo $MY_SERVICE_SERVICE_HOST
echo $MY_SERVICE_SERVICE_PORT
```

### Endpoints and EndpointSlices
```yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
- addresses:
  - ip: 10.244.1.5
  - ip: 10.244.2.3
  ports:
  - port: 8080
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: my-service-abc123
  labels:
    kubernetes.io/service-name: my-service
addressType: IPv4
endpoints:
- addresses:
  - "10.244.1.5"
  conditions:
    ready: true
ports:
- port: 8080
  protocol: TCP
```

## Best Practices

- Use meaningful service names
- Implement proper health checks
- Configure appropriate session affinity
- Monitor service endpoint health

## Troubleshooting

### Service Connectivity Issues
```bash
# Check service endpoints
kubectl get endpoints my-service

# Test service connectivity
kubectl run test-pod --image=busybox -it --rm -- wget -qO- my-service

# Check service DNS resolution
kubectl run test-pod --image=busybox -it --rm -- nslookup my-service
```

### Pod-to-Pod Communication Issues
```bash
# Check pod IPs and node placement
kubectl get pods -o wide

# Test direct pod connectivity
kubectl exec -it pod1 -- ping <pod2-ip>
kubectl exec -it pod1 -- telnet <pod2-ip> <port>

# Check CNI plugin status
kubectl get pods -n kube-system | grep -E "(flannel|calico|cilium|weave)"

# Check node network configuration
kubectl describe node <node-name> | grep -A 10 "PodCIDR"
```

### kube-proxy Issues
```bash
# Check kube-proxy pods
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# Check kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy

# Verify kube-proxy mode
kubectl logs -n kube-system kube-proxy-<node> | grep "Using"

# Check iptables rules (iptables mode)
sudo iptables -t nat -L KUBE-SERVICES
sudo iptables -t nat -L | grep <service-name>

# Check IPVS rules (IPVS mode)
sudo ipvsadm -L -n

# Test service from node
curl <cluster-ip>:<port>
```

### Network Debugging Commands
```bash
# Check cluster networking
kubectl cluster-info dump | grep -i cidr

# Check DNS configuration
kubectl get configmap -n kube-system coredns -o yaml

# Test cross-node communication
kubectl run test1 --image=busybox --overrides='{"spec":{"nodeName":"node1"}}' -- sleep 3600
kubectl run test2 --image=busybox --overrides='{"spec":{"nodeName":"node2"}}' -- sleep 3600
kubectl exec test1 -- ping $(kubectl get pod test2 -o jsonpath='{.status.podIP}')

# Check network routes
ip route show
route -n
```