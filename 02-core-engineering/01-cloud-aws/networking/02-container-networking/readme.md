# Container Networking for DevOps

Advanced container networking concepts for modern DevOps environments. This section covers Docker networking, Kubernetes networking model, CNI implementations, and multi-cluster networking strategies.

## 🎯 Learning Objectives

- Master Docker networking models and implementations
- Understand Kubernetes networking architecture deeply
- Implement Container Network Interface (CNI) plugins
- Design network policies for security and segmentation
- Configure multi-cluster and service mesh networking
- Optimize container network performance

## 🐳 Docker Networking Deep Dive

### Docker Network Drivers

**Bridge Network (Default):**
```bash
# Create custom bridge network
docker network create --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  --opt com.docker.network.bridge.name=docker1 \
  custom-bridge

# Run container with specific IP
docker run -d --name web1 \
  --network custom-bridge \
  --ip 172.20.1.10 \
  nginx

# Inspect network
docker network inspect custom-bridge
```

**Host Network:**
```bash
# Container shares host network stack
docker run -d --name web-host \
  --network host \
  nginx

# No network isolation - container uses host IP directly
```

**Overlay Network (Swarm Mode):**
```bash
# Initialize Docker Swarm
docker swarm init --advertise-addr 192.168.1.10

# Create overlay network
docker network create --driver overlay \
  --subnet=10.0.0.0/24 \
  --attachable \
  my-overlay

# Deploy service across swarm
docker service create --name web \
  --network my-overlay \
  --replicas 3 \
  nginx
```

**Macvlan Network:**
```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  macvlan-net

# Container gets MAC address on physical network
docker run -d --name web-macvlan \
  --network macvlan-net \
  --ip=192.168.1.100 \
  nginx
```

### Docker Network Troubleshooting

**Network Inspection Tools:**
```bash
# List all networks
docker network ls

# Inspect network details
docker network inspect bridge

# Show container network settings
docker inspect container_name | jq '.[0].NetworkSettings'

# Test connectivity between containers
docker exec container1 ping container2
docker exec container1 nslookup container2

# Monitor network traffic
docker exec container1 tcpdump -i eth0

# Check iptables rules created by Docker
sudo iptables -t nat -L DOCKER
sudo iptables -L DOCKER-USER
```

**Custom Network Configuration:**
```bash
# Create network with custom DNS
docker network create --driver bridge \
  --subnet=172.25.0.0/16 \
  --dns=8.8.8.8 \
  --dns=8.8.4.4 \
  custom-dns-net

# Network with custom MTU
docker network create --driver bridge \
  --opt com.docker.network.driver.mtu=1450 \
  low-mtu-net
```

## ☸️ Kubernetes Networking Architecture

### Kubernetes Network Model

**Fundamental Requirements:**
1. Every Pod gets its own IP address
2. Pods can communicate without NAT
3. Nodes can communicate with all Pods
4. Agents on nodes can communicate with all Pods

```
┌─────────────────────────────────────────┐
│              Cluster Network            │
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │    Node 1   │    │    Node 2   │     │
│  │             │    │             │     │
│  │ ┌─────────┐ │    │ ┌─────────┐ │     │
│  │ │  Pod A  │ │    │ │  Pod C  │ │     │
│  │ │10.1.1.2 │ │    │ │10.1.2.2 │ │     │
│  │ └─────────┘ │    │ └─────────┘ │     │
│  │             │    │             │     │
│  │ ┌─────────┐ │    │ ┌─────────┐ │     │
│  │ │  Pod B  │ │    │ │  Pod D  │ │     │
│  │ │10.1.1.3 │ │    │ │10.1.2.3 │ │     │
│  │ └─────────┘ │    │ └─────────┘ │     │
│  └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────┘
```

### Container Network Interface (CNI)

**CNI Plugin Configuration:**
```json
{
  "cniVersion": "0.4.0",
  "name": "mynet",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "subnet": "10.244.0.0/16",
    "routes": [
      {
        "dst": "0.0.0.0/0"
      }
    ]
  }
}
```

**Popular CNI Plugins:**

**Calico (Policy-Rich Networking):**
```yaml
# Calico installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
```

**Flannel (Simple Overlay):**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-flannel-cfg
  namespace: kube-system
data:
  cni-conf.json: |
    {
      "name": "cbr0",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "flannel",
          "delegate": {
            "hairpinMode": true,
            "isDefaultGateway": true
          }
        },
        {
          "type": "portmap",
          "capabilities": {
            "portMappings": true
          }
        }
      ]
    }
  net-conf.json: |
    {
      "Network": "10.244.0.0/16",
      "Backend": {
        "Type": "vxlan"
      }
    }
```

**Cilium (eBPF-based):**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cilium-config
  namespace: kube-system
data:
  cluster-name: "default"
  cluster-id: "0"
  enable-ipv4: "true"
  enable-ipv6: "false"
  enable-bpf-masquerade: "true"
  enable-ip-masq-agent: "false"
  tunnel: "vxlan"
  monitor-aggregation: "medium"
  bpf-policy-map-max: "16384"
  preallocate-bpf-maps: "false"
```

### Kubernetes Services

**Service Types and Implementation:**

**ClusterIP Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

**NodePort Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

**LoadBalancer Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

**Headless Service (for StatefulSets):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: database-headless
spec:
  clusterIP: None
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
```

### Ingress Controllers

**Nginx Ingress Controller:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /api/v1/(.*)
        pathType: Prefix
        backend:
          service:
            name: api-v1-service
            port:
              number: 80
      - path: /api/v2/(.*)
        pathType: Prefix
        backend:
          service:
            name: api-v2-service
            port:
              number: 80
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

**Traefik Ingress Controller:**
```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: web-ingressroute
spec:
  entryPoints:
  - websecure
  routes:
  - match: Host(`example.com`) && PathPrefix(`/api`)
    kind: Rule
    services:
    - name: api-service
      port: 80
    middlewares:
    - name: api-ratelimit
  - match: Host(`example.com`)
    kind: Rule
    services:
    - name: web-service
      port: 80
  tls:
    certResolver: letsencrypt
```

## 🛡️ Network Policies

### Kubernetes Network Policies

**Default Deny All Policy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**Allow Specific Traffic:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-netpol
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to: []  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
```

**Advanced Network Policy with CIDR:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: external-access-policy
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 10.0.0.0/8
        except:
        - 10.1.0.0/16  # Exclude specific subnet
    ports:
    - protocol: TCP
      port: 443
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32  # Block metadata service
    ports:
    - protocol: TCP
      port: 443
```

### Calico Network Policies

**Global Network Policy:**
```yaml
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: deny-all-non-system-traffic
spec:
  order: 1000
  selector: projectcalico.org/namespace != "kube-system"
  types:
  - Ingress
  - Egress
  egress:
  - action: Allow
    destination:
      selector: projectcalico.org/namespace == "kube-system"
  - action: Allow
    protocol: UDP
    destination:
      ports: [53]
```

**Host Endpoint Policy:**
```yaml
apiVersion: projectcalico.org/v3
kind: HostEndpoint
metadata:
  name: node1-eth0
  labels:
    environment: production
spec:
  node: node1
  interfaceName: eth0
  expectedIPs:
  - 192.168.1.10
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: host-protection
spec:
  selector: environment == "production"
  types:
  - Ingress
  ingress:
  - action: Allow
    protocol: TCP
    destination:
      ports: [22, 179, 2379, 2380, 6443, 10250]
  - action: Deny
```

## 🌐 Multi-Cluster Networking

### Cluster Mesh with Cilium

**Cilium Cluster Mesh Configuration:**
```yaml
# Enable cluster mesh
apiVersion: v1
kind: ConfigMap
metadata:
  name: cilium-config
  namespace: kube-system
data:
  cluster-name: "cluster1"
  cluster-id: "1"
  enable-cluster-mesh: "true"
  cluster-mesh-config: |
    clusters:
    - name: cluster1
      address: cluster1.mesh.cilium.io
      port: 2379
    - name: cluster2
      address: cluster2.mesh.cilium.io
      port: 2379
```

**Cross-Cluster Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: global-service
  annotations:
    io.cilium/global-service: "true"
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

### Submariner Multi-Cluster

**Submariner Broker Setup:**
```bash
# Install submariner CLI
curl -Ls https://get.submariner.io | bash

# Deploy broker
subctl deploy-broker --kubeconfig cluster1-config

# Join clusters
subctl join --kubeconfig cluster1-config broker-info.subm
subctl join --kubeconfig cluster2-config broker-info.subm

# Verify connectivity
subctl verify --kubeconfig cluster1-config --tocontext cluster2
```

**Service Export/Import:**
```yaml
# Export service from cluster1
apiVersion: multicluster.x-k8s.io/v1alpha1
kind: ServiceExport
metadata:
  name: web-service
  namespace: default
---
# Import in cluster2
apiVersion: multicluster.x-k8s.io/v1alpha1
kind: ServiceImport
metadata:
  name: web-service
  namespace: default
spec:
  type: ClusterSetIP
  ports:
  - port: 80
    protocol: TCP
```

## 🕸️ Service Mesh Integration

### Istio Service Mesh Networking

**Istio Installation:**
```bash
# Download and install Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Install Istio
istioctl install --set values.defaultRevision=default

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled
```

**Virtual Service Configuration:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: web-vs
spec:
  hosts:
  - web-service
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: web-service
        subset: v2
      weight: 100
  - route:
    - destination:
        host: web-service
        subset: v1
      weight: 90
    - destination:
        host: web-service
        subset: v2
      weight: 10
```

**Destination Rule:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: web-dr
spec:
  host: web-service
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 10
    circuitBreaker:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 50
```

**Gateway Configuration:**
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: web-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: web-tls-secret
    hosts:
    - example.com
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - example.com
    tls:
      httpsRedirect: true
```

## 🔧 Performance Optimization

### Network Performance Tuning

**Pod Network Optimization:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-performance-pod
  annotations:
    k8s.v1.cni.cncf.io/networks: |
      [{
        "name": "sriov-network",
        "interface": "net1"
      }]
spec:
  containers:
  - name: app
    image: myapp:latest
    resources:
      requests:
        intel.com/sriov_netdevice: '1'
      limits:
        intel.com/sriov_netdevice: '1'
```

**CPU and Memory Optimization:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-optimized-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    resources:
      requests:
        cpu: "2"
        memory: "4Gi"
      limits:
        cpu: "4"
        memory: "8Gi"
  nodeSelector:
    node-type: "high-performance"
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "network-intensive"
    effect: "NoSchedule"
```

### Container Network Monitoring

**Prometheus Network Metrics:**
```yaml
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: container-network-metrics
spec:
  selector:
    matchLabels:
      app: network-exporter
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

**Grafana Dashboard for Container Networks:**
```json
{
  "dashboard": {
    "title": "Container Network Performance",
    "panels": [
      {
        "title": "Pod Network I/O",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_network_receive_bytes_total[5m])",
            "legendFormat": "{{pod}} - RX"
          },
          {
            "expr": "rate(container_network_transmit_bytes_total[5m])",
            "legendFormat": "{{pod}} - TX"
          }
        ]
      },
      {
        "title": "Network Latency",
        "type": "singlestat",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(istio_request_duration_milliseconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ]
  }
}
```

## 🧪 Advanced Labs

### Lab 1: Custom CNI Plugin Development

**Objective:** Create a simple CNI plugin

**Simple CNI Plugin (Go):**
```go
package main

import (
    "encoding/json"
    "fmt"
    "net"
    "os"
    
    "github.com/containernetworking/cni/pkg/skel"
    "github.com/containernetworking/cni/pkg/types"
    "github.com/containernetworking/cni/pkg/version"
)

type NetConf struct {
    types.NetConf
    Subnet string `json:"subnet"`
}

func cmdAdd(args *skel.CmdArgs) error {
    conf := NetConf{}
    if err := json.Unmarshal(args.StdinData, &conf); err != nil {
        return err
    }
    
    // Implement network setup logic
    // This is a simplified example
    
    result := &types.Result{
        IP4: &types.IPConfig{
            IP: net.IPNet{
                IP:   net.ParseIP("10.244.1.2"),
                Mask: net.CIDRMask(24, 32),
            },
            Gateway: net.ParseIP("10.244.1.1"),
        },
    }
    
    return types.PrintResult(result, conf.CNIVersion)
}

func cmdDel(args *skel.CmdArgs) error {
    // Implement cleanup logic
    return nil
}

func main() {
    skel.PluginMain(cmdAdd, cmdDel, version.All)
}
```

### Lab 2: Multi-Cluster Service Mesh

**Objective:** Deploy Istio across multiple clusters

**Primary Cluster Setup:**
```bash
# Install Istio on primary cluster
istioctl install --set values.pilot.env.EXTERNAL_ISTIOD=true

# Create eastwest gateway
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: eastwest
spec:
  revision: ""
  components:
    ingressGateways:
      - name: istio-eastwestgateway
        label:
          istio: eastwestgateway
          app: istio-eastwestgateway
        enabled: true
        k8s:
          service:
            type: LoadBalancer
            ports:
              - port: 15021
                targetPort: 15021
                name: status-port
              - port: 15012
                targetPort: 15012
                name: tls
              - port: 15017
                targetPort: 15017
                name: tls-istiod
EOF

# Expose control plane
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istiod-gateway
  namespace: istio-system
spec:
  selector:
    istio: eastwestgateway
  servers:
    - port:
        number: 15012
        name: tls-istiod
        protocol: TLS
      tls:
        mode: PASSTHROUGH
      hosts:
        - "*"
EOF
```

### Lab 3: Network Policy Testing

**Objective:** Implement and test comprehensive network policies

**Test Environment Setup:**
```bash
# Create test namespaces
kubectl create namespace frontend
kubectl create namespace backend
kubectl create namespace database

# Label namespaces
kubectl label namespace frontend name=frontend
kubectl label namespace backend name=backend
kubectl label namespace database name=database

# Deploy test applications
kubectl run frontend --image=nginx --namespace=frontend --labels="app=frontend"
kubectl run backend --image=nginx --namespace=backend --labels="app=backend"
kubectl run database --image=postgres --namespace=database --labels="app=database"

# Test connectivity before policies
kubectl exec -n frontend frontend -- curl backend.backend.svc.cluster.local
kubectl exec -n backend backend -- curl database.database.svc.cluster.local
```

## 🔍 Troubleshooting Container Networks

### Common Issues and Solutions

**Pod-to-Pod Communication Issues:**
```bash
# Check pod IPs and network interfaces
kubectl get pods -o wide
kubectl exec pod-name -- ip addr show

# Test DNS resolution
kubectl exec pod-name -- nslookup kubernetes.default.svc.cluster.local
kubectl exec pod-name -- dig service-name.namespace.svc.cluster.local

# Check network policies
kubectl get networkpolicy -A
kubectl describe networkpolicy policy-name -n namespace

# Verify CNI plugin status
kubectl get pods -n kube-system | grep cni
kubectl logs -n kube-system daemonset/calico-node
```

**Service Discovery Problems:**
```bash
# Check service endpoints
kubectl get endpoints service-name
kubectl describe service service-name

# Verify kube-proxy configuration
kubectl get pods -n kube-system | grep kube-proxy
kubectl logs -n kube-system kube-proxy-xxxxx

# Check iptables rules
kubectl exec node-name -- iptables -t nat -L KUBE-SERVICES
```

**Ingress Controller Issues:**
```bash
# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Verify ingress configuration
kubectl get ingress -A
kubectl describe ingress ingress-name

# Test backend connectivity
kubectl port-forward service/backend-service 8080:80
curl localhost:8080
```

## ✅ Advanced Assessment

### Practical Skills Evaluation

**Network Architecture Design:**
- [ ] Design multi-tier application networking
- [ ] Implement network segmentation with policies
- [ ] Configure cross-cluster communication
- [ ] Optimize network performance for specific workloads

**Troubleshooting Scenarios:**
- [ ] Diagnose pod connectivity issues
- [ ] Resolve service discovery problems
- [ ] Fix ingress routing issues
- [ ] Optimize network performance bottlenecks

**Security Implementation:**
- [ ] Implement zero-trust network policies
- [ ] Configure service mesh security
- [ ] Set up network monitoring and alerting
- [ ] Design compliance-ready network architecture

## 🔗 Next Steps

- **[Service Mesh](readme.md)** - Advanced service-to-service communication
- **[Cloud Networking](readme.md)** - Multi-cloud networking strategies
- **[Performance Optimization](readme.md)** - Network performance tuning

---

*Container networking is fundamental to modern application architecture. Master these concepts to build scalable, secure, and performant containerized applications.*