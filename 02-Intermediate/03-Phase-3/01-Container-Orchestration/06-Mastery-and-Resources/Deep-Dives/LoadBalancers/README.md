# Kubernetes Load Balancers

## Overview

**Kubernetes Load Balancers** distribute network traffic across multiple pods to ensure high availability, fault tolerance, and optimal resource utilization. Load balancing in Kubernetes operates at multiple layers, from internal service discovery to external traffic management.

## Load Balancing Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 Kubernetes Load Balancing                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Client    │  │   Ingress   │  │   External LB   │     │
│  │  Request    │  │ Controller  │  │  (Cloud/MetalLB)│     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Service   │  │ kube-proxy  │  │     Pods        │     │
│  │ (ClusterIP) │  │ (iptables/  │  │  (Endpoints)    │     │
│  │             │  │   IPVS)     │  │                 │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Load Balancing Layers

### 1. Service Load Balancing (kube-proxy)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

### 2. External Load Balancing
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-lb
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### 3. Ingress Load Balancing
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## kube-proxy Implementation

### iptables Mode (Default)
```bash
# View iptables rules for services
sudo iptables -t nat -L KUBE-SERVICES

# Example iptables rule for load balancing
# Random selection using probability
-A KUBE-SVC-XXX -m statistic --mode random --probability 0.33333 -j KUBE-SEP-YYY
-A KUBE-SVC-XXX -m statistic --mode random --probability 0.50000 -j KUBE-SEP-ZZZ
-A KUBE-SVC-XXX -j KUBE-SEP-AAA
```

**iptables Characteristics**:
- Random load balancing
- No connection tracking
- O(n) complexity for rule processing
- Limited to ~5000 services
___

### IPVS Mode (Advanced)
```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  scheduler: "rr"
  excludeCIDRs:
  - "169.254.169.254/32"
  strictARP: true
  syncPeriod: 30s
  minSyncPeriod: 5s
```

**IPVS Schedulers**:
- `rr`: Round Robin (default)
- `lc`: Least Connection
- `dh`: Destination Hashing
- `sh`: Source Hashing
- `sed`: Shortest Expected Delay
- `nq`: Never Queue
- `lblc`: Locality-Based Least Connection
- `lblcr`: Locality-Based Least Connection with Replication
- `wlc`: Weighted Least Connection
- `wrr`: Weighted Round Robin

### IPVS Configuration Examples
```bash
# View IPVS virtual servers
sudo ipvsadm -L -n

# Example IPVS output
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.96.0.1:443 rr
  -> 192.168.1.10:6443            Masq    1      0          0
  -> 192.168.1.11:6443            Masq    1      0          0
```
___

### Userspace Mode (Legacy)
```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "userspace"
# Not recommended for production
```

---

## Load Balancing Algorithms Deep Dive

### Round Robin (RR)
```yaml
# Equal distribution across all endpoints
# Best for: Homogeneous backend pods
ipvs:
  scheduler: "rr"
```

### Weighted Round Robin (WRR)
```yaml
# Distribution based on weights
# Configure via service annotations
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
spec:
  # Weights configured via endpoint subsets
```

### Least Connection (LC)
```yaml
# Routes to endpoint with fewest active connections
# Best for: Long-lived connections
ipvs:
  scheduler: "lc"
```

### Source Hashing (SH)
```yaml
# Consistent routing based on client IP
# Best for: Session persistence
ipvs:
  scheduler: "sh"
```

### Destination Hashing (DH)
```yaml
# Routing based on destination IP
# Best for: Cache affinity
ipvs:
  scheduler: "dh"
```
---

## Cloud Load Balancers

### AWS Load Balancer Controller
```yaml
# Application Load Balancer (ALB)
apiVersion: v1
kind: Service
metadata:
  name: aws-alb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb-ip"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: "/health"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval-seconds: "10"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout-seconds: "5"
    service.beta.kubernetes.io/aws-load-balancer-healthy-threshold-count: "2"
    service.beta.kubernetes.io/aws-load-balancer-unhealthy-threshold-count: "2"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

### Network Load Balancer (NLB)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: aws-nlb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"
    service.beta.kubernetes.io/aws-load-balancer-subnets: "subnet-12345,subnet-67890"
    service.beta.kubernetes.io/aws-load-balancer-eip-allocations: "eipalloc-12345,eipalloc-67890"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 443
    targetPort: 8443
    protocol: TCP
```

### Google Cloud Load Balancer
```yaml
# External HTTP(S) Load Balancer
apiVersion: v1
kind: Service
metadata:
  name: gcp-external-lb
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/backend-config: '{"default": "my-backend-config"}'
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
---
# Internal Load Balancer
apiVersion: v1
kind: Service
metadata:
  name: gcp-internal-lb
  annotations:
    cloud.google.com/load-balancer-type: "Internal"
    cloud.google.com/load-balancer-subnet: "my-subnet"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

### GCP Backend Configuration
```yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: my-backend-config
spec:
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
    healthyThreshold: 2
    unhealthyThreshold: 3
    type: HTTP
    requestPath: /health
  sessionAffinity:
    affinityType: "CLIENT_IP"
    affinityCookieTtlSec: 3600
  connectionDraining:
    drainingTimeoutSec: 60
```

### Azure Load Balancer
```yaml
# Public Load Balancer
apiVersion: v1
kind: Service
metadata:
  name: azure-public-lb
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "false"
    service.beta.kubernetes.io/azure-load-balancer-resource-group: "my-rg"
    service.beta.kubernetes.io/azure-pip-name: "my-public-ip"
    service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: "/health"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
---
# Internal Load Balancer
apiVersion: v1
kind: Service
metadata:
  name: azure-internal-lb
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "my-subnet"
spec:
  type: LoadBalancer
  loadBalancerIP: 10.0.0.100
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

## Session Affinity & Persistence

### Client IP Affinity
```yaml
apiVersion: v1
kind: Service
metadata:
  name: sticky-service
spec:
  selector:
    app: web
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800  # 3 hours (max: 86400)
  ports:
  - port: 80
    targetPort: 8080
```

### Cookie-Based Session Affinity (Ingress)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cookie-affinity
  annotations:
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/affinity-mode: "persistent"
    nginx.ingress.kubernetes.io/session-cookie-name: "INGRESSCOOKIE"
    nginx.ingress.kubernetes.io/session-cookie-expires: "86400"
    nginx.ingress.kubernetes.io/session-cookie-max-age: "86400"
    nginx.ingress.kubernetes.io/session-cookie-path: "/"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### Header-Based Affinity
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: header-affinity
  annotations:
    nginx.ingress.kubernetes.io/upstream-hash-by: "$http_x_user_id"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```
---

## MetalLB (Bare Metal Load Balancing)

### MetalLB Installation
```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
```

### Layer 2 Configuration
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250
  - 192.168.1.100/32
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```

### BGP Configuration
```yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
  name: sample
  namespace: metallb-system
spec:
  myASN: 64500
  peerASN: 64501
  peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
  peers:
  - sample
```

### MetalLB Service with Specific IP
```yaml
apiVersion: v1
kind: Service
metadata:
  name: metallb-service
  annotations:
    metallb.universe.tf/address-pool: first-pool
    metallb.universe.tf/allow-shared-ip: "sharing-key"
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
  loadBalancerIP: 192.168.1.100
```

## Ingress Controllers & Advanced Load Balancing

### NGINX Ingress Controller
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-advanced
  annotations:
    # Load balancing method
    nginx.ingress.kubernetes.io/load-balance: "round_robin"  # ip_hash, least_conn, random
    # Upstream hashing
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
    # Connection limits
    nginx.ingress.kubernetes.io/upstream-max-fails: "3"
    nginx.ingress.kubernetes.io/upstream-fail-timeout: "30s"
    # Keep-alive
    nginx.ingress.kubernetes.io/upstream-keepalive-connections: "32"
    nginx.ingress.kubernetes.io/upstream-keepalive-requests: "100"
    nginx.ingress.kubernetes.io/upstream-keepalive-timeout: "60s"
    # Rate limiting
    nginx.ingress.kubernetes.io/rate-limit-connections: "10"
    nginx.ingress.kubernetes.io/rate-limit-requests-per-second: "5"
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### NGINX Custom Upstream Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
data:
  upstream-keepalive-connections: "32"
  upstream-keepalive-requests: "100"
  upstream-keepalive-timeout: "60s"
  load-balance: "least_conn"
  max-worker-connections: "16384"
```

### Traefik Load Balancing
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik-advanced
  annotations:
    # Load balancer method
    traefik.ingress.kubernetes.io/service.loadbalancer.method: "wrr"  # drr, wrr
    # Health checks
    traefik.ingress.kubernetes.io/service.loadbalancer.healthcheck.path: "/health"
    traefik.ingress.kubernetes.io/service.loadbalancer.healthcheck.interval: "10s"
    # Sticky sessions
    traefik.ingress.kubernetes.io/service.loadbalancer.sticky.cookie: "true"
    traefik.ingress.kubernetes.io/service.loadbalancer.sticky.cookie.name: "traefik"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### HAProxy Ingress Controller
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: haproxy-ingress
  annotations:
    haproxy.org/balance-algorithm: "roundrobin"  # leastconn, source, uri
    haproxy.org/check: "true"
    haproxy.org/check-interval: "10s"
    haproxy.org/cookie-persistence: "SERVERID"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### Istio Gateway Load Balancing
```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: web-destination
spec:
  host: web-service
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN  # ROUND_ROBIN, LEAST_CONN, RANDOM, PASSTHROUGH
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 10
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
```

## Health Checks & Probes

### Comprehensive Health Check Configuration
```yaml
apiVersion: v1
kind: Service
metadata:
  name: health-check-service
  annotations:
    # AWS Load Balancer health checks
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: "/health"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "8080"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol: "HTTP"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval-seconds: "10"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout-seconds: "5"
    service.beta.kubernetes.io/aws-load-balancer-healthy-threshold-count: "2"
    service.beta.kubernetes.io/aws-load-balancer-unhealthy-threshold-count: "3"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

### Advanced Pod Probes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
        # Readiness probe - determines if pod receives traffic
        readinessProbe:
          httpGet:
            path: /health
            port: 80
            httpHeaders:
            - name: Custom-Header
              value: Awesome
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
        # Liveness probe - determines if pod should be restarted
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        # Startup probe - protects slow starting containers
        startupProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 30
```

### TCP and Command Probes
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
spec:
  containers:
  - name: database
    image: postgres:13
    # TCP probe for database
    readinessProbe:
      tcpSocket:
        port: 5432
      initialDelaySeconds: 5
      periodSeconds: 10
    # Command probe
    livenessProbe:
      exec:
        command:
        - /bin/sh
        - -c
        - "pg_isready -U postgres"
      initialDelaySeconds: 30
      periodSeconds: 30
```
---

## Load Balancer Monitoring & Observability

### Metrics Collection
```bash
# Check service endpoints and their health
kubectl get endpoints web-service -o yaml

# Monitor load balancer status
kubectl get service web-lb -o wide
kubectl describe service web-lb

# Check ingress status and backends
kubectl get ingress web-ingress -o yaml
kubectl describe ingress web-ingress

# Monitor kube-proxy metrics
curl http://localhost:10249/metrics
```

### Prometheus Monitoring
```yaml
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: kube-proxy-metrics
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  endpoints:
  - port: http-metrics
    interval: 30s
    path: /metrics
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: load-balancer-alerts
spec:
  groups:
  - name: load-balancer
    rules:
    - alert: ServiceEndpointDown
      expr: up{job="kubernetes-endpoints"} == 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Service endpoint is down"
```

### Performance Testing & Load Generation
```bash
# Simple load test with curl
for i in {1..1000}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://example.com
done | sort | uniq -c

# Load test with Apache Bench
ab -n 10000 -c 100 -H "Host: example.com" http://load-balancer-ip/

# Load test with wrk
wrk -t12 -c400 -d30s --latency http://example.com/

# Kubernetes load testing with hey
kubectl run load-test --image=williamyeh/hey:latest --rm -it --restart=Never -- \
  -n 1000 -c 10 http://web-service.default.svc.cluster.local
```

### Connection Distribution Analysis
```bash
# Monitor pod distribution
kubectl get pods -o wide -l app=web

# Check connection distribution (IPVS)
sudo ipvsadm -L -n --stats

# Monitor endpoint slice distribution
kubectl get endpointslices -l kubernetes.io/service-name=web-service

# Check service topology
kubectl get service web-service -o jsonpath='{.spec.topologyKeys}'
```

### Real-time Monitoring Dashboard
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-lb
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Load Balancer Metrics",
        "panels": [
          {
            "title": "Request Rate",
            "targets": [
              {
                "expr": "rate(nginx_ingress_controller_requests[5m])"
              }
            ]
          },
          {
            "title": "Response Time",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(nginx_ingress_controller_request_duration_seconds_bucket[5m]))"
              }
            ]
          }
        ]
      }
    }
```
---

## Troubleshooting Load Balancers

### Common Load Balancer Issues

#### 1. Service Not Getting External IP
```bash
# Check service status and events
kubectl describe service web-lb
kubectl get events --field-selector involvedObject.name=web-lb

# Verify cloud provider configuration
kubectl get nodes -o wide
kubectl describe node <node-name> | grep ProviderID

# Check cloud controller manager logs
kubectl logs -n kube-system -l component=cloud-controller-manager
```

#### 2. Connection Timeouts
```bash
# Test connectivity step by step
curl -v --connect-timeout 10 http://<external-ip>
telnet <external-ip> 80

# Check security groups/firewall rules
# AWS: Check security groups
# GCP: Check firewall rules
# Azure: Check NSG rules

# Verify target group health (AWS)
aws elbv2 describe-target-health --target-group-arn <arn>
```

#### 3. Uneven Load Distribution
```bash
# Check endpoint distribution
kubectl get endpoints web-service -o yaml

# Monitor actual traffic distribution
kubectl exec -it <pod-name> -- netstat -an | grep :8080

# Check pod readiness and resource usage
kubectl get pods -l app=web -o wide
kubectl top pods -l app=web

# Verify service selector matches pods
kubectl get pods --show-labels -l app=web
kubectl describe service web-service | grep Selector
```

#### 4. Session Affinity Issues
```bash
# Test session persistence
for i in {1..10}; do
  curl -b cookies.txt -c cookies.txt http://example.com/session
done

# Check session affinity configuration
kubectl get service web-service -o yaml | grep -A5 sessionAffinity

# Monitor IPVS persistence (if using IPVS)
sudo ipvsadm -L -n --persistent-conn
```

### Advanced Debugging

#### Network Packet Analysis
```bash
# Capture packets on load balancer
sudo tcpdump -i any -n port 80

# Trace network path
traceroute <external-ip>
mtr <external-ip>

# Check DNS resolution
nslookup <service-name>.<namespace>.svc.cluster.local
```

#### kube-proxy Debugging
```bash
# Check kube-proxy configuration
kubectl get configmap -n kube-system kube-proxy -o yaml

# View kube-proxy logs
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=100

# Check iptables rules (iptables mode)
sudo iptables -t nat -L KUBE-SERVICES -n --line-numbers
sudo iptables -t nat -L KUBE-SVC-<hash> -n

# Check IPVS configuration (IPVS mode)
sudo ipvsadm -L -n
sudo ipvsadm -L -n --stats
sudo ipvsadm -L -n --rate
```

#### Health Check Debugging
```bash
# Test health check endpoints directly
kubectl port-forward pod/<pod-name> 8080:8080
curl http://localhost:8080/health

# Check probe configuration
kubectl describe pod <pod-name> | grep -A10 Readiness

# Monitor probe failures
kubectl get events --field-selector reason=Unhealthy
```

### Performance Optimization

#### Connection Pooling
```yaml
# NGINX Ingress connection pooling
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
data:
  upstream-keepalive-connections: "32"
  upstream-keepalive-requests: "100"
  upstream-keepalive-timeout: "60s"
  worker-connections: "16384"
```

#### Resource Optimization
```yaml
# Optimize kube-proxy for high load
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  scheduler: "lc"  # Use least connection for better distribution
  syncPeriod: 5s   # Faster sync for dynamic environments
  minSyncPeriod: 1s
conntrack:
  maxPerCore: 32768
  min: 131072
  tcpEstablishedTimeout: 86400s
  tcpCloseWaitTimeout: 3600s
```

--

## Best Practices & Production Guidelines

### 1. Load Balancer Architecture Design

#### Service Type Selection
```yaml
# Internal microservices communication
apiVersion: v1
kind: Service
spec:
  type: ClusterIP  # Default, internal only

# External application access
apiVersion: v1
kind: Service
spec:
  type: LoadBalancer  # Cloud provider LB

# HTTP/HTTPS with advanced routing
apiVersion: networking.k8s.io/v1
kind: Ingress  # Layer 7 load balancing
```

#### Multi-tier Load Balancing
> **⚠️ Missing Image**: *Multi-tier-LB* ('../../../../../09-Resources/03-Images-Diagrams/Kubernetes/LB-1.png')

### 2. High Availability Configuration

#### Multi-AZ Deployment
> **⚠️ Missing Image**: *Multi-AZ* ('../../../../../09-Resources/03-Images-Diagrams/Kubernetes/multi-AZ-Deployment.png')
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 6
  selector:
    matchLabels:
      app: web
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - web
              topologyKey: topology.kubernetes.io/zone
```

#### Cross-Region Load Balancing
```yaml
# Global load balancer with GCP
apiVersion: v1
kind: Service
metadata:
  annotations:
    cloud.google.com/global-access: "true"
    cloud.google.com/load-balancer-type: "External"
spec:
  type: LoadBalancer
```

### 3. Performance Optimization

#### Connection Limits and Timeouts
```yaml
# Service-level configuration
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
    service.beta.kubernetes.io/aws-load-balancer-connection-draining-timeout: "300"
spec:
  type: LoadBalancer
```

#### Resource Allocation
```yaml
# Ingress controller resource optimization
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
spec:
  template:
    spec:
      containers:
      - name: nginx-ingress-controller
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 2000m
            memory: 2Gi
        args:
        - --worker-processes=auto
        - --worker-connections=16384
```

### 4. Security Best Practices

#### TLS Configuration
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - example.com
    secretName: example-tls
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

#### Network Policies for Load Balancers
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-controller-policy
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from: []  # Allow from anywhere
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
```

### 5. Monitoring and Alerting

#### SLI/SLO Definition
```yaml
# Prometheus recording rules
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: load-balancer-sli
spec:
  groups:
  - name: load-balancer-sli
    interval: 30s
    rules:
    - record: lb:request_rate
      expr: sum(rate(nginx_ingress_controller_requests[5m]))
    - record: lb:error_rate
      expr: sum(rate(nginx_ingress_controller_requests{status=~"5.."}[5m])) / sum(rate(nginx_ingress_controller_requests[5m]))
    - record: lb:latency_p99
      expr: histogram_quantile(0.99, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket[5m])) by (le))
```

#### Critical Alerts
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: load-balancer-alerts
spec:
  groups:
  - name: load-balancer-critical
    rules:
    - alert: LoadBalancerDown
      expr: up{job="kubernetes-service-endpoints"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Load balancer endpoint is down"
    - alert: HighErrorRate
      expr: lb:error_rate > 0.05
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
```

### 6. Capacity Planning

#### Horizontal Pod Autoscaling
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-deployment
  minReplicas: 3
  maxReplicas: 100
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
```

### 7. Disaster Recovery

#### Multi-Region Failover
```yaml
# External DNS for failover
apiVersion: externaldns.k8s.io/v1alpha1
kind: DNSEndpoint
metadata:
  name: app-failover
spec:
  endpoints:
  - dnsName: app.example.com
    recordType: A
    targets:
    - 1.2.3.4  # Primary region LB
  - dnsName: app-backup.example.com
    recordType: A
    targets:
    - 5.6.7.8  # Backup region LB
```

### 8. Cost Optimization

#### Resource Right-sizing
```bash
# Monitor actual resource usage
kubectl top pods -l app=web --containers

# Analyze load balancer costs
# AWS: Monitor ELB costs in Cost Explorer
# GCP: Use Cloud Billing reports
# Azure: Monitor Load Balancer costs
```

#### Efficient Load Balancer Usage
```yaml
# Share load balancers across services
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:..."
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8080
```

## Conclusion

Kubernetes load balancing is a multi-layered system that requires careful planning and configuration. Success depends on understanding the different load balancing mechanisms, choosing appropriate algorithms, implementing proper health checks, and maintaining comprehensive monitoring. Regular performance testing and capacity planning ensure your load balancing infrastructure can handle production workloads effectively.