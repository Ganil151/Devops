# Container Network Interface (CNI) Plugins

## Overview

**CNI Plugins** implement the Container Network Interface specification to provide networking capabilities for Kubernetes pods. CNI plugins handle pod IP assignment, network connectivity, and policy enforcement.

## CNI Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CNI Plugin System                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   kubelet   │  │ CNI Plugin  │  │    Network      │     │
│  │             │  │             │  │   Interface     │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │ Pod Create  │  │ IP Assign   │  │ Route Config    │     │
│  │ Request     │  │ Network     │  │ Policy Apply    │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Popular CNI Plugins

### 1. Flannel
**Simple overlay networking**

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

### 2. Calico
**Policy-enabled networking**

```yaml
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
```

### 3. Cilium
**eBPF-based networking**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cilium-config
  namespace: kube-system
data:
  enable-ipv4: "true"
  enable-bpf-masquerade: "true"
  kube-proxy-replacement: "partial"
```

### 4. Weave Net
**Multi-host networking**

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: weave-net
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - name: weave
        image: weaveworks/weave-kube:2.8.1
        env:
        - name: IPALLOC_RANGE
          value: 10.32.0.0/12
```

## CNI Configuration

### Configuration Directory
```bash
# CNI configuration location
/etc/cni/net.d/

# CNI binary location
/opt/cni/bin/
```

### Basic CNI Config
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
    "subnet": "10.22.0.0/16"
  }
}
```

## IPAM (IP Address Management)

### Host-Local IPAM
```json
{
  "ipam": {
    "type": "host-local",
    "subnet": "10.244.0.0/16",
    "rangeStart": "10.244.1.20",
    "rangeEnd": "10.244.1.50",
    "gateway": "10.244.1.1"
  }
}
```

### DHCP IPAM
```json
{
  "ipam": {
    "type": "dhcp"
  }
}
```

## CNI Plugin Comparison

| Feature | Flannel | Calico | Cilium | Weave | Antrea |
|---------|---------|--------|--------|-------|--------|
| **Encapsulation** | VXLAN/UDP | IPIP/VXLAN | VXLAN/Geneve | VXLAN | VXLAN/Geneve |
| **Network Policies** | ❌ | ✅ | ✅ | ✅ | ✅ |
| **eBPF Support** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Multi-cluster** | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Performance** | Good | Excellent | Excellent | Good | Good |
| **Complexity** | Low | Medium | High | Low | Medium |

## Installation Examples

### Flannel Installation
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

### Calico Installation
```bash
# Operator method
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
```

### Cilium Installation
```bash
# Helm method
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --namespace kube-system
```

## Troubleshooting CNI

### Common Issues
```bash
# Check CNI configuration
ls -la /etc/cni/net.d/
cat /etc/cni/net.d/*.conf*

# Check CNI binaries
ls -la /opt/cni/bin/

# Check pod networking
kubectl get pods -o wide
kubectl describe pod <pod-name>

# Test pod connectivity
kubectl exec -it pod1 -- ping <pod2-ip>
```

### CNI Plugin Logs
```bash
# Flannel logs
kubectl logs -n kube-system -l app=flannel

# Calico logs
kubectl logs -n kube-system -l k8s-app=calico-node

# Cilium logs
kubectl logs -n kube-system -l k8s-app=cilium
```

## Best Practices

### 1. CNI Selection
- **Simple setups**: Flannel
- **Policy requirements**: Calico or Cilium
- **High performance**: Cilium with eBPF
- **Multi-cloud**: Weave Net

### 2. Network Planning
- Plan IP address ranges carefully
- Consider MTU settings
- Plan for multi-cluster scenarios
- Document network architecture

### 3. Performance
- Choose appropriate encapsulation
- Configure proper MTU
- Monitor network performance
- Optimize for your workload

### 4. Security
- Enable network policies
- Use encryption when needed
- Monitor network traffic
- Regular security updates

## Advanced CNI Features

### Multi-CNI Setup
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: multus-cni-config
data:
  cni-conf.json: |
    {
      "name": "multus-cni-network",
      "type": "multus",
      "delegates": [
        {
          "type": "flannel"
        },
        {
          "type": "sriov"
        }
      ]
    }
```

### Custom CNI Plugin
```bash
#!/bin/bash
# Simple CNI plugin example
case $CNI_COMMAND in
ADD)
    # Add network interface to container
    ;;
DEL)
    # Remove network interface from container
    ;;
CHECK)
    # Check if interface exists
    ;;
VERSION)
    # Return supported CNI versions
    ;;
esac
```

## Conclusion

CNI plugins are fundamental to Kubernetes networking, providing the foundation for pod-to-pod communication, network policies, and advanced networking features. Choosing the right CNI plugin depends on your specific requirements for performance, security, and operational complexity.