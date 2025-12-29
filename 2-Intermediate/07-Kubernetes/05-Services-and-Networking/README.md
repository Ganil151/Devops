# Kubernetes DNS

## Overview

**Kubernetes DNS** provides service discovery and name resolution within the cluster. Every Kubernetes cluster includes a DNS service that automatically assigns DNS names to services and pods.

## DNS Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Pod      │───►│  CoreDNS    │───►│   etcd      │
│             │    │             │    │ (via API)   │
└─────────────┘    └─────────────┘    └─────────────┘
```

## DNS Records

### Service DNS Records
```bash
# Service FQDN format
<service-name>.<namespace>.svc.cluster.local

# Examples
nginx.default.svc.cluster.local
database.production.svc.cluster.local
```

### Pod DNS Records
```bash
# Pod FQDN format (if hostname and subdomain specified)
<hostname>.<subdomain>.<namespace>.pod.cluster.local

# Pod IP-based DNS (A records)
<pod-ip-with-dashes>.<namespace>.pod.cluster.local
# Example: 10-244-1-5.default.pod.cluster.local
```

## CoreDNS Configuration

### Basic CoreDNS ConfigMap
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

### Custom DNS Configuration
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
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        # Custom upstream DNS
        forward . 8.8.8.8 8.8.4.4 {
           max_concurrent 1000
        }
        # Custom domain forwarding
        forward example.com 192.168.1.10
        cache 30
        loop
        reload
        loadbalance
    }
```

## DNS Testing

### Basic DNS Resolution
```bash
# Test service DNS resolution
kubectl run test-pod --image=busybox -it --rm -- nslookup kubernetes.default

# Test external DNS resolution
kubectl run test-pod --image=busybox -it --rm -- nslookup google.com

# Test pod DNS resolution
kubectl run test-pod --image=busybox -it --rm -- nslookup 10-244-1-5.default.pod.cluster.local
```

### DNS Debugging
```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Check DNS configuration
kubectl get configmap -n kube-system coredns -o yaml

# Test DNS from specific pod
kubectl exec -it <pod-name> -- cat /etc/resolv.conf
```

## Pod DNS Configuration

### DNS Policy
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
spec:
  dnsPolicy: ClusterFirst  # Default
  containers:
  - name: test
    image: busybox
```

**DNS Policies**:
- `ClusterFirst`: Use cluster DNS first, then upstream
- `ClusterFirstWithHostNet`: For pods with hostNetwork
- `Default`: Use node's DNS resolution
- `None`: Use custom DNS configuration

### Custom DNS Configuration
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: custom-dns
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers:
    - 8.8.8.8
    - 8.8.4.4
    searches:
    - example.com
    - internal.example.com
    options:
    - name: ndots
      value: "2"
    - name: edns0
  containers:
  - name: test
    image: busybox
```

## Troubleshooting DNS

### Common Issues
```bash
# DNS resolution failures
kubectl run debug --image=busybox -it --rm -- nslookup kubernetes.default

# Check pod DNS configuration
kubectl exec <pod-name> -- cat /etc/resolv.conf

# Verify CoreDNS is running
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check service endpoints
kubectl get endpoints -n kube-system kube-dns
```

### Performance Issues
```bash
# Check CoreDNS metrics
kubectl port-forward -n kube-system svc/kube-dns 9153:9153
curl http://localhost:9153/metrics

# Monitor DNS queries
kubectl logs -n kube-system -l k8s-app=kube-dns -f
```

## Best Practices

- Use short service names within the same namespace
- Configure appropriate DNS caching
- Monitor DNS performance and errors
- Use custom DNS for external services
- Implement DNS-based service discovery