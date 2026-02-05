# Kubernetes Network Policies

## Overview

**Kubernetes Network Policies** provide network-level security by controlling traffic flow between pods. Network policies act as firewalls for pods, defining ingress and egress rules.

## Basic Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          name: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
```

## Deny All Traffic

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

## Allow All Traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
```

## Namespace Isolation

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: namespace-isolation
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: production
```

## Database Access Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
```

## Web Application Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-app-policy
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

## CNI Requirements

Network policies require a CNI plugin that supports them. Not all CNI plugins implement NetworkPolicy enforcement.

### Supported CNI Plugins

#### 1. Calico
**Network Policy Support**: Full support for Kubernetes NetworkPolicies + Calico-specific policies

**Features**:
- Layer 3/4 and Layer 7 policies
- Global network policies
- Host endpoint policies
- Encryption support
- eBPF dataplane option

**Installation**:
```bash
# Install Calico operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

# Install Calico custom resources
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
```

**Policy Example**:
```yaml
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-tcp-6379
  namespace: production
spec:
  selector: role == 'database'
  types:
  - Ingress
  - Egress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: role == 'frontend'
    destination:
      ports:
      - 6379
  egress:
  - action: Allow
```

#### 2. Cilium
**Network Policy Support**: Full Kubernetes NetworkPolicies + Cilium-specific L7 policies

**Features**:
- eBPF-based enforcement
- Layer 7 HTTP/gRPC/Kafka policies
- DNS-based policies
- Service mesh integration
- Advanced observability

**Installation**:
```bash
# Using Helm
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.14.0 \
  --namespace kube-system \
  --set kubeProxyReplacement=partial
```

**L7 Policy Example**:
```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "l7-rule"
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: frontend
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/api/.*"
```

#### 3. Weave Net
**Network Policy Support**: Basic Kubernetes NetworkPolicies

**Features**:
- Simple policy enforcement
- Automatic network discovery
- Encryption support
- Multi-cloud networking

**Installation**:
```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

#### 4. Antrea
**Network Policy Support**: Full Kubernetes NetworkPolicies + Antrea-specific policies

**Features**:
- Open vSwitch (OVS) based
- Antrea ClusterNetworkPolicy
- Tier-based policy ordering
- Flow visibility
- Multi-cluster support

**Installation**:
```bash
kubectl apply -f https://github.com/antrea-io/antrea/releases/download/v1.13.0/antrea.yml
```

### CNI Plugins WITHOUT NetworkPolicy Support

#### Flannel
**Network Policy Support**: None

**Limitation**: Flannel focuses on basic connectivity and does not implement NetworkPolicy enforcement.

### CNI Plugin Comparison for NetworkPolicies

| Feature | Calico | Cilium | Weave Net | Antrea | Flannel |
|---------|--------|--------|-----------|--------|---------|
| **K8s NetworkPolicy** | ✅ Full | ✅ Full | ✅ Basic | ✅ Full | ❌ None |
| **L7 Policies** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Global Policies** | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| **DNS Policies** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Host Policies** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Encryption** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Observability** | ✅ Good | ✅ Excellent | ❌ Basic | ✅ Good | ❌ None |

## Best Practices

### 1. CNI Selection for NetworkPolicies
- **Production environments**: Use Calico or Cilium for full feature support
- **Simple setups**: Weave Net for basic policy needs
- **VMware environments**: Consider Antrea for OVS integration
- **Avoid Flannel**: If NetworkPolicies are required

### 2. Policy Design
- Start with deny-all policies as baseline
- Use namespace-based isolation for multi-tenancy
- Implement least privilege access principles
- Test policies in non-production environments first
- Monitor network traffic patterns before implementing

### 3. CNI-Specific Considerations
- **Calico**: Leverage GlobalNetworkPolicies for cluster-wide rules
- **Cilium**: Use L7 policies for application-aware security
- **Antrea**: Utilize policy tiers for organized rule management
- **Weave Net**: Keep policies simple due to limited features

## Troubleshooting

### General NetworkPolicy Debugging
```bash
# Check network policies
kubectl get networkpolicy

# Describe network policy
kubectl describe networkpolicy my-policy

# Test connectivity
kubectl exec -it pod1 -- nc -zv pod2-ip 80

# Verify CNI plugin supports NetworkPolicies
ls /etc/cni/net.d/
```

### CNI-Specific Troubleshooting

#### Calico Debugging
```bash
# Check Calico node status
kubectl get pods -n kube-system -l k8s-app=calico-node

# Check policy programming
calicoctl get networkpolicy --output wide

# Check Calico logs
kubectl logs -n kube-system -l k8s-app=calico-node | grep -i policy

# Verify Felix configuration
calicoctl get felixconfiguration default -o yaml
```

#### Cilium Debugging
```bash
# Check Cilium agent status
kubectl get pods -n kube-system -l k8s-app=cilium

# Check policy enforcement
cilium policy get

# Monitor policy decisions
cilium monitor --type policy-verdict

# Check connectivity
cilium connectivity test
```

#### Antrea Debugging
```bash
# Check Antrea agent status
kubectl get pods -n kube-system -l app=antrea

# Check policy status
kubectl get networkpolicy -o yaml

# Check Antrea controller logs
kubectl logs -n kube-system deployment/antrea-controller
```

#### Weave Net Debugging
```bash
# Check Weave Net status
kubectl get pods -n kube-system -l name=weave-net

# Check Weave Net logs
kubectl logs -n kube-system -l name=weave-net -c weave

# Check NPC (Network Policy Controller)
kubectl logs -n kube-system -l name=weave-net -c weave-npc
```

## Conclusion

Network Policies provide essential micro-segmentation capabilities for Kubernetes clusters, enabling zero-trust networking and enhanced security posture.