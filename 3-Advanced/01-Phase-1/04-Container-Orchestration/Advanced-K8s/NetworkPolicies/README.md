# Kubernetes Network Policies

## Overview

**Kubernetes Network Policies** provide network-level security by controlling traffic flow between pods, namespaces, and external endpoints. They act as a firewall for your Kubernetes cluster, implementing microsegmentation and zero-trust networking principles.

## Network Policy Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                Network Policy Architecture                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │   Ingress   │  │   Egress    │  │    Policy       │     │
│  │   Rules     │  │   Rules     │  │  Controller     │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐     │
│  │ Pod Selector│  │ Namespace   │  │   CNI Plugin    │     │
│  │   Labels    │  │  Selector   │  │ Implementation  │     │
│  └─────────────┘  └─────────────┘  └─────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Basic Network Policy

### Default Deny All
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

### Allow Specific Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## Advanced Network Policies

### Multi-tier Application Security
```yaml
# Frontend network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from: []  # Allow from anywhere (internet)
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 8080
  - to: {}  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
---
# Backend network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
  - to: {}  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
---
# Database network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Cross-Namespace Communication
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-cross-namespace
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api-gateway
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: staging
      podSelector:
        matchLabels:
          app: test-client
    ports:
    - protocol: TCP
      port: 8080
```

### External Traffic Control
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-db
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/8
        except:
        - 10.0.1.0/24
    ports:
    - protocol: TCP
      port: 5432
  - to: {}  # Allow DNS
    ports:
    - protocol: UDP
      port: 53
```

## Policy Selectors

### Pod Selector Examples
```yaml
# Select by single label
podSelector:
  matchLabels:
    app: web

# Select by multiple labels (AND)
podSelector:
  matchLabels:
    app: web
    version: v1

# Select by label expressions
podSelector:
  matchExpressions:
  - key: app
    operator: In
    values: ["web", "api"]
  - key: version
    operator: NotIn
    values: ["v0"]
```

### Namespace Selector Examples
```yaml
# Select namespace by label
namespaceSelector:
  matchLabels:
    environment: production

# Select multiple namespaces
namespaceSelector:
  matchExpressions:
  - key: environment
    operator: In
    values: ["production", "staging"]
```

## CNI Plugin Requirements

### Calico Network Policies
```yaml
# Calico GlobalNetworkPolicy
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: deny-all-non-system
spec:
  selector: projectcalico.org/namespace != "kube-system"
  types:
  - Ingress
  - Egress
```

### Cilium Network Policies
```yaml
# Cilium CiliumNetworkPolicy
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: l7-policy
  namespace: production
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
      - port: "8080"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/api/.*"
```

## Monitoring and Troubleshooting

### Policy Validation
```bash
# List all network policies
kubectl get networkpolicies --all-namespaces

# Describe specific policy
kubectl describe networkpolicy frontend-policy -n production

# Check policy events
kubectl get events --field-selector involvedObject.kind=NetworkPolicy

# Validate policy syntax
kubectl apply --dry-run=client -f network-policy.yaml
```

### Traffic Testing
```bash
# Test connectivity between pods
kubectl exec -it frontend-pod -- curl backend-service:8080

# Test from specific namespace
kubectl exec -it -n staging test-pod -- curl production-api:8080

# Monitor network traffic (with Calico)
kubectl exec -it -n kube-system calico-node-xxx -- calicoctl get workloadendpoint
```

### Debugging Network Issues
```bash
# Check CNI plugin logs
kubectl logs -n kube-system -l k8s-app=calico-node

# Verify policy enforcement
kubectl exec -it -n kube-system calico-node-xxx -- calicoctl get policy

# Test DNS resolution
kubectl exec -it test-pod -- nslookup kubernetes.default.svc.cluster.local
```

## Security Patterns

### Zero Trust Networking
```yaml
# Implement zero trust with default deny
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: zero-trust-default
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  egress:
  # Allow DNS
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Allow specific external services
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32  # Block metadata service
    ports:
    - protocol: TCP
      port: 443
```

### Microsegmentation
```yaml
# Segment by environment
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: environment-isolation
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          environment: production
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          environment: production
```

### Service Mesh Integration
```yaml
# Istio AuthorizationPolicy
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: frontend-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: frontend
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/api-gateway"]
    to:
    - operation:
        methods: ["GET", "POST"]
```

## Best Practices

### 1. Policy Design
```yaml
# Start with default deny
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

# Add specific allow rules
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - protocol: TCP
      port: 8080
```

### 2. Namespace Labeling
```yaml
# Label namespaces for policy selection
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
    security-level: high
    network-policy: enabled
```

### 3. Testing Strategy
```bash
# Test network policies in staging first
kubectl apply -f network-policies/ --dry-run=server

# Gradual rollout
kubectl apply -f 01-default-deny.yaml
# Wait and monitor
kubectl apply -f 02-allow-specific.yaml

# Monitor application logs for connection issues
kubectl logs -f deployment/frontend
```

### 4. Documentation
```yaml
# Document policy purpose
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-security
  namespace: production
  annotations:
    description: "Allows frontend pods to communicate with backend API"
    owner: "security-team"
    last-reviewed: "2024-01-15"
spec:
  # Policy configuration...
```

## Advanced Features

### Policy Priorities (Calico)
```yaml
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: high-priority-deny
spec:
  order: 100  # Lower number = higher priority
  selector: has(security-critical)
  types:
  - Ingress
  - Egress
```

### Time-based Policies (Calico)
```yaml
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: business-hours-only
  namespace: production
spec:
  selector: app == "admin-panel"
  ingress:
  - action: Allow
    source:
      selector: role == "admin"
    destination:
      ports: [8080]
    # Time restriction (requires Calico Enterprise)
    schedule: "0 9 * * 1-5"  # 9 AM, Monday-Friday
```

### Logging and Monitoring
```yaml
# Enable policy logging (Calico)
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: logged-policy
  namespace: production
spec:
  selector: app == "sensitive-app"
  types:
  - Ingress
  ingress:
  - action: Allow
    source:
      selector: role == "authorized"
    destination:
      ports: [8080]
    # Log allowed connections
    log: true
```

## Compliance and Auditing

### Policy Compliance Check
```bash
# Check for default deny policies
kubectl get networkpolicy --all-namespaces -o json | \
  jq '.items[] | select(.spec.podSelector == {} and (.spec.policyTypes | contains(["Ingress", "Egress"])))'

# Verify namespace isolation
kubectl get networkpolicy --all-namespaces -o json | \
  jq '.items[] | select(.spec.ingress[].from[]?.namespaceSelector)'

# Check for overly permissive policies
kubectl get networkpolicy --all-namespaces -o json | \
  jq '.items[] | select(.spec.ingress[].from[] == {})'
```

### Audit Reports
```bash
# Generate policy coverage report
kubectl get pods --all-namespaces -o json | \
  jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' | \
  while read pod; do
    echo "Checking $pod"
    kubectl get networkpolicy -n $(echo $pod | cut -d/ -f1) -o json | \
      jq --arg pod "$(echo $pod | cut -d/ -f2)" \
      '.items[] | select(.spec.podSelector.matchLabels // {} | to_entries[] | .value == $pod)'
  done
```

## Troubleshooting Guide

### Common Issues

#### 1. Policy Not Applied
```bash
# Check CNI plugin supports NetworkPolicy
kubectl get nodes -o json | jq '.items[].status.nodeInfo.containerRuntimeVersion'

# Verify policy controller is running
kubectl get pods -n kube-system | grep -E "(calico|cilium|weave)"

# Check policy syntax
kubectl apply --dry-run=server -f policy.yaml
```

#### 2. Connectivity Issues
```bash
# Test basic connectivity
kubectl exec -it source-pod -- nc -zv target-service 8080

# Check if policy is blocking
kubectl describe networkpolicy policy-name -n namespace

# Verify pod labels match selectors
kubectl get pods --show-labels -n namespace
```

#### 3. DNS Resolution Problems
```bash
# Ensure DNS egress is allowed
kubectl exec -it pod-name -- nslookup kubernetes.default.svc.cluster.local

# Check CoreDNS accessibility
kubectl get networkpolicy -n kube-system
```

## Performance Considerations

### Policy Optimization
```yaml
# Use specific selectors instead of broad ones
spec:
  podSelector:
    matchLabels:
      app: web
      version: v1  # More specific

# Avoid empty selectors when possible
spec:
  podSelector: {}  # Matches all pods - use carefully
```

### Scaling Considerations
```bash
# Monitor policy evaluation performance
kubectl top nodes
kubectl get events --field-selector reason=NetworkPolicyEvaluation

# Check CNI plugin resource usage
kubectl top pods -n kube-system -l k8s-app=calico-node
```

## Conclusion

Network Policies provide essential network security for Kubernetes clusters through traffic segmentation and access control. Proper implementation requires understanding of CNI plugin capabilities, careful policy design, and comprehensive testing. Regular auditing and monitoring ensure policies remain effective and don't inadvertently block legitimate traffic.