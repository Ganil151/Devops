# CoreDNS

## Overview

**CoreDNS** is the default DNS server for Kubernetes clusters, providing service discovery and name resolution for pods and services. It replaced kube-dns as the standard DNS solution starting from Kubernetes 1.13.

## CoreDNS Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CoreDNS in Kubernetes                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │    Pod      │  │   Service   │  │    CoreDNS      │     │
│  │             │  │             │  │     Pod         │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │ DNS Query   │  │ Service IP  │  │ DNS Response    │     │
│  │ Resolution  │  │ Resolution  │  │ Cache & Forward │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## CoreDNS Configuration

### Default Corefile
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
```

### CoreDNS Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
spec:
  replicas: 2
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
    spec:
      containers:
      - name: coredns
        image: coredns/coredns:1.10.1
        args: [ "-conf", "/etc/coredns/Corefile" ]
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: coredns
          items:
          - key: Corefile
            path: Corefile
```

## DNS Resolution Flow

### Service Discovery
```bash
# Service DNS format
<service-name>.<namespace>.svc.cluster.local

# Pod DNS format
<pod-ip-with-dashes>.<namespace>.pod.cluster.local

# Examples
nginx.default.svc.cluster.local
10-244-1-5.default.pod.cluster.local
```

### DNS Query Process
```
1. Pod makes DNS query
2. Query sent to CoreDNS (via kube-dns service)
3. CoreDNS checks kubernetes plugin
4. If not found, forwards to upstream DNS
5. Response cached and returned to pod
```

## CoreDNS Plugins

### Core Plugins
```yaml
# Kubernetes plugin
kubernetes cluster.local in-addr.arpa ip6.arpa {
   pods insecure
   fallthrough in-addr.arpa ip6.arpa
   ttl 30
}

# Forward plugin
forward . 8.8.8.8 8.8.4.4 {
   max_concurrent 1000
}

# Cache plugin
cache 30

# Health plugin
health {
   lameduck 5s
}
```

### Custom Plugins
```yaml
# Rewrite plugin
rewrite name regex (.*)\.example\.com {1}.default.svc.cluster.local

# Hosts plugin
hosts {
   192.168.1.100 custom.example.com
   fallthrough
}

# Log plugin
log . {
   class denial error
}
```

## DNS Service Configuration

### kube-dns Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.96.0.10
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP
```

### Pod DNS Configuration
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
spec:
  dnsPolicy: ClusterFirst
  dnsConfig:
    nameservers:
    - 8.8.8.8
    searches:
    - custom.local
    options:
    - name: ndots
      value: "2"
  containers:
  - name: test
    image: busybox
```

## DNS Policies

### ClusterFirst (Default)
```yaml
spec:
  dnsPolicy: ClusterFirst
  # Uses cluster DNS (CoreDNS) first, then upstream
```

### ClusterFirstWithHostNet
```yaml
spec:
  dnsPolicy: ClusterFirstWithHostNet
  hostNetwork: true
  # For pods using host network
```

### Default
```yaml
spec:
  dnsPolicy: Default
  # Uses node's DNS configuration
```

### None
```yaml
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers:
    - 1.1.1.1
  # Custom DNS configuration only
```

## Monitoring CoreDNS

### Metrics
```bash
# CoreDNS metrics endpoint
curl http://coredns-pod-ip:9153/metrics

# Key metrics
coredns_dns_requests_total
coredns_dns_responses_total
coredns_cache_hits_total
coredns_cache_misses_total
```

### Health Checks
```bash
# Health endpoint
curl http://coredns-pod-ip:8080/health

# Ready endpoint
curl http://coredns-pod-ip:8181/ready
```

## Troubleshooting DNS

### Common Issues
```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Check kube-dns service
kubectl get svc -n kube-system kube-dns

# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

### DNS Debug Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dnsutils
spec:
  containers:
  - name: dnsutils
    image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
    command:
      - sleep
      - "infinity"
```

### DNS Test Commands
```bash
# Test service resolution
nslookup kubernetes.default.svc.cluster.local

# Test external resolution
nslookup google.com

# Check DNS configuration
cat /etc/resolv.conf

# Test specific nameserver
nslookup kubernetes.default 10.96.0.10
```

## Performance Tuning

### CoreDNS Optimization
```yaml
# Increase cache size
cache 300

# Adjust concurrent queries
forward . /etc/resolv.conf {
   max_concurrent 2000
}

# Enable negative caching
cache 30 {
   success 9984 30
   denial 9984 5
}
```

### Resource Limits
```yaml
resources:
  limits:
    memory: 170Mi
    cpu: 100m
  requests:
    memory: 70Mi
    cpu: 100m
```

## Custom DNS Configuration

### External DNS Integration
```yaml
# External DNS for custom domains
rewrite name regex (.*)\.external\.com {1}.external-ns.svc.cluster.local

# Conditional forwarding
forward consul.local 10.0.0.10
forward vault.local 10.0.0.11
```

### Multi-Zone Setup
```yaml
kubernetes cluster.local in-addr.arpa ip6.arpa {
   pods insecure
   fallthrough in-addr.arpa ip6.arpa
   ttl 30
}
kubernetes zone2.local {
   pods insecure
   endpoint https://zone2-apiserver:6443
   ttl 30
}
```

## Security Considerations

### DNS Security
```yaml
# Enable DNS over TLS
forward . tls://1.1.1.1 tls://1.0.0.1 {
   tls_servername cloudflare-dns.com
}

# Rate limiting
ratelimit 100 per-second

# Access control
acl {
   allow net 10.0.0.0/8
   block net 192.168.1.0/24
}
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: coredns-policy
  namespace: kube-system
spec:
  podSelector:
    matchLabels:
      k8s-app: kube-dns
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

## Best Practices

### 1. Configuration Management
- Use ConfigMaps for Corefile
- Version control DNS configurations
- Test changes in staging first
- Monitor DNS performance

### 2. High Availability
- Run multiple CoreDNS replicas
- Use anti-affinity rules
- Configure proper resource limits
- Monitor health endpoints

### 3. Performance
- Tune cache settings appropriately
- Monitor query patterns
- Use appropriate TTL values
- Consider DNS query load

### 4. Security
- Restrict DNS access with network policies
- Use secure upstream DNS servers
- Monitor DNS query logs
- Regular security updates

## Conclusion

CoreDNS provides robust, flexible DNS services for Kubernetes clusters with extensive plugin support and configuration options. Proper configuration and monitoring ensure reliable service discovery and name resolution for your applications.