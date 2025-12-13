# Kubernetes

Complete guide to Kubernetes container orchestration, architecture, and production deployment strategies.

## Overview

Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications across clusters of hosts.

## Core Concepts

### Cluster Architecture
```bash
# Master Node Components
- kube-apiserver: API gateway and authentication
- etcd: Distributed key-value store
- kube-scheduler: Pod placement decisions
- kube-controller-manager: Control loops
- cloud-controller-manager: Cloud provider integration

# Worker Node Components
- kubelet: Node agent
- kube-proxy: Network proxy
- container-runtime: Docker/containerd/CRI-O
```

### Workload Resources
```bash
# Pods
- Smallest deployable unit
- One or more containers
- Shared network and storage
- Ephemeral by nature

# Deployments
- Declarative updates for Pods
- ReplicaSet management
- Rolling updates
- Rollback capabilities

# StatefulSets
- Stable network identities
- Persistent storage
- Ordered deployment/scaling
- Database workloads

# DaemonSets
- One Pod per node
- System-level services
- Monitoring agents
- Network plugins
```

## Networking

### Service Types
```bash
# ClusterIP (Default)
- Internal cluster communication
- Load balancing within cluster
- DNS-based service discovery

# NodePort
- External access via node ports
- Port range: 30000-32767
- Simple external exposure

# LoadBalancer
- Cloud provider integration
- External load balancer
- Automatic provisioning

# ExternalName
- DNS CNAME mapping
- External service integration
- No proxy or load balancing
```

### Ingress
```bash
# HTTP/HTTPS routing
- Path-based routing
- Host-based routing
- SSL termination
- Load balancing

Example Ingress:
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

## Storage

### Volume Types
```bash
# Persistent Volumes (PV)
- Cluster-level storage resource
- Independent of Pod lifecycle
- Various storage backends
- Reclaim policies

# Persistent Volume Claims (PVC)
- User request for storage
- Binds to available PV
- Storage class specification
- Access modes definition

# Storage Classes
- Dynamic provisioning
- Storage parameters
- Provisioner specification
- Reclaim policies
```

## Security

### Authentication & Authorization
```bash
# Authentication Methods
- X.509 certificates
- Bearer tokens
- Service accounts
- OIDC integration

# RBAC (Role-Based Access Control)
- Roles and ClusterRoles
- RoleBindings and ClusterRoleBindings
- Principle of least privilege
- Fine-grained permissions

# Pod Security
- Security contexts
- Pod security policies
- Network policies
- Admission controllers
```

## Configuration Management

### ConfigMaps and Secrets
```bash
# ConfigMaps
- Non-sensitive configuration data
- Environment variables
- Configuration files
- Command-line arguments

# Secrets
- Sensitive information
- Base64 encoded
- Encrypted at rest
- Automatic mounting

Example ConfigMap:
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://localhost:5432/mydb"
  debug_mode: "true"
```

## Monitoring and Observability

### Metrics and Logging
```bash
# Prometheus Integration
- Metrics collection
- Alerting rules
- Service discovery
- Grafana dashboards

# Logging Stack
- Fluentd/Fluent Bit
- Elasticsearch
- Kibana
- Log aggregation

# Distributed Tracing
- Jaeger
- Zipkin
- OpenTelemetry
- Request tracing
```

## Deployment Strategies

### Rolling Updates
```bash
# Default deployment strategy
- Gradual Pod replacement
- Zero-downtime deployment
- Configurable parameters
- Automatic rollback

Strategy Configuration:
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

### Blue-Green Deployment
```bash
# Two identical environments
- Complete environment switch
- Instant rollback capability
- Resource intensive
- Full testing opportunity

Implementation:
1. Deploy to green environment
2. Test green environment
3. Switch traffic to green
4. Keep blue for rollback
```

### Canary Deployment
```bash
# Gradual traffic shifting
- Risk mitigation
- Performance monitoring
- Automated rollback
- A/B testing capability

Tools:
- Istio service mesh
- Flagger operator
- Argo Rollouts
- NGINX ingress
```

## Production Best Practices

### Resource Management
```bash
# Resource Requests and Limits
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"

# Quality of Service Classes
- Guaranteed: requests = limits
- Burstable: requests < limits
- BestEffort: no requests/limits
```

### High Availability
```bash
# Multi-Master Setup
- Multiple control plane nodes
- Load balancer for API server
- etcd clustering
- Geographic distribution

# Pod Disruption Budgets
- Voluntary disruptions
- Maintenance operations
- Cluster upgrades
- Node scaling

# Anti-Affinity Rules
- Pod distribution
- Node failure tolerance
- Zone awareness
- Performance optimization
```

### Backup and Disaster Recovery
```bash
# etcd Backup
ETCDCTL_API=3 etcdctl snapshot save backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Application Data Backup
- Persistent volume snapshots
- Database backups
- Configuration backups
- Disaster recovery testing
```

## Troubleshooting

### Common Issues
```bash
# Pod Issues
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/bash

# Service Issues
kubectl get endpoints
kubectl describe service <service-name>
kubectl port-forward service/<service-name> 8080:80

# Network Issues
kubectl get networkpolicies
kubectl describe ingress <ingress-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Debugging Tools
```bash
# Cluster Information
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes
kubectl top pods

# Resource Analysis
kubectl describe node <node-name>
kubectl get events --all-namespaces
kubectl get pods --all-namespaces -o wide
```

## Tools and Ecosystem

### Package Management
```bash
# Helm
- Kubernetes package manager
- Chart repositories
- Template engine
- Release management

# Kustomize
- Configuration management
- Overlay system
- Built into kubectl
- GitOps friendly
```

### Development Tools
```bash
# kubectl
- Command-line interface
- Cluster management
- Resource manipulation
- Debugging capabilities

# k9s
- Terminal-based UI
- Real-time cluster view
- Resource navigation
- Log streaming

# Lens
- Desktop application
- Cluster management
- Visual interface
- Multi-cluster support
```

This comprehensive Kubernetes guide covers all essential aspects from basic concepts to production deployment and troubleshooting strategies.