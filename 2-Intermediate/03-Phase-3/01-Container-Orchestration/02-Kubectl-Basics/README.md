# kubectl - Kubernetes Command Line Interface

## Overview

**kubectl** is the official command-line interface (CLI) tool for interacting with Kubernetes clusters. It communicates with the Kubernetes API Server to perform operations on cluster resources, making it the primary tool for cluster administration, application deployment, and troubleshooting.

## What is kubectl?

kubectl is:
- A command-line tool for controlling Kubernetes clusters
- The primary interface for cluster administrators and developers
- A client that communicates with the Kubernetes API Server
- Cross-platform tool available for Linux, macOS, and Windows

## Role in Kubernetes Architecture

### Primary Functions

1. **Cluster Management**
   - Deploy and manage applications
   - Configure cluster resources
   - Monitor cluster health and status

2. **Resource Operations**
   - Create, read, update, and delete (CRUD) operations
   - Apply configuration files
   - Manage resource lifecycles

3. **Debugging and Troubleshooting**
   - View logs and events
   - Execute commands in containers
   - Port forwarding and proxy connections

## kubectl Architecture

### Communication Flow
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   kubectl   │───►│ API Server  │───►│   etcd      │
│   Client    │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   ▼                   │
       │            ┌─────────────┐            │
       │            │ Controller  │            │
       │            │ Manager     │            │
       │            └─────────────┘            │
       │                   │                   │
       │                   ▼                   │
       │            ┌─────────────┐            │
       └───────────►│  Scheduler  │◄───────────┘
                    └─────────────┘
```

### Configuration Components
```
┌─────────────────────────────────────────┐
│            kubectl Config               │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Clusters    │  │ Users           │   │
│  │ - server    │  │ - credentials   │   │
│  │ - ca-cert   │  │ - tokens        │   │
│  └─────────────┘  └─────────────────┘   │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │ Contexts    │  │ Current Context │   │
│  │ - cluster   │  │ - active config │   │
│  │ - user      │  │                 │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

## Installation and Setup

### Installation Methods

#### 1. Package Managers
```bash
# macOS (Homebrew)
brew install kubectl

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y kubectl

# CentOS/RHEL
sudo yum install -y kubectl

# Windows (Chocolatey)
choco install kubernetes-cli
```

#### 2. Direct Download
```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# macOS
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Windows
curl -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
```

#### 3. Docker
```bash
# Run kubectl in Docker container
docker run --rm -it -v ~/.kube:/root/.kube kubectl:latest version
```

### Configuration Setup

#### kubeconfig File Structure
```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTi...
    server: https://kubernetes.example.com:6443
  name: production-cluster
contexts:
- context:
    cluster: production-cluster
    user: admin-user
    namespace: default
  name: production-context
current-context: production-context
users:
- name: admin-user
  user:
    client-certificate-data: LS0tLS1CRUdJTi...
    client-key-data: LS0tLS1CRUdJTi...
```

#### Context Management
```bash
# View current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context production-context

# Set namespace for current context
kubectl config set-context --current --namespace=my-namespace
```

## Core Commands

### Resource Management

#### Create Resources
```bash
# Create from file
kubectl create -f deployment.yaml

# Create from URL
kubectl create -f https://example.com/deployment.yaml

# Create from stdin
cat deployment.yaml | kubectl create -f -

# Create specific resources
kubectl create deployment nginx --image=nginx:1.20
kubectl create service clusterip my-service --tcp=80:8080
kubectl create configmap my-config --from-file=config.properties
```

#### Apply Resources
```bash
# Apply configuration (declarative)
kubectl apply -f deployment.yaml

# Apply directory of files
kubectl apply -f ./manifests/

# Apply with server-side apply
kubectl apply --server-side -f deployment.yaml

# Dry run
kubectl apply --dry-run=client -f deployment.yaml
```

#### Get Resources
```bash
# List pods
kubectl get pods

# List all resources in namespace
kubectl get all

# Get with custom output
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json

# Get with selectors
kubectl get pods -l app=nginx
kubectl get pods --field-selector=status.phase=Running
```

#### Describe Resources
```bash
# Describe pod
kubectl describe pod nginx-pod

# Describe node
kubectl describe node worker-node-1

# Describe service
kubectl describe service nginx-service
```

#### Delete Resources
```bash
# Delete by name
kubectl delete pod nginx-pod

# Delete by file
kubectl delete -f deployment.yaml

# Delete by selector
kubectl delete pods -l app=nginx

# Force delete
kubectl delete pod nginx-pod --force --grace-period=0
```

### Cluster Information

#### Cluster Status
```bash
# Cluster info
kubectl cluster-info

# Node information
kubectl get nodes
kubectl describe nodes

# Component status
kubectl get componentstatuses

# API versions
kubectl api-versions
kubectl api-resources
```

#### Resource Usage
```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods

# Resource usage by namespace
kubectl top pods --all-namespaces
```

### Debugging and Troubleshooting

#### Logs
```bash
# Pod logs
kubectl logs nginx-pod

# Container logs in multi-container pod
kubectl logs nginx-pod -c nginx-container

# Follow logs
kubectl logs -f nginx-pod

# Previous container logs
kubectl logs nginx-pod --previous

# Logs from all containers
kubectl logs nginx-pod --all-containers=true
```

#### Execute Commands
```bash
# Execute command in pod
kubectl exec nginx-pod -- ls /app

# Interactive shell
kubectl exec -it nginx-pod -- /bin/bash

# Execute in specific container
kubectl exec -it nginx-pod -c nginx-container -- /bin/sh
```

#### Port Forwarding
```bash
# Forward local port to pod
kubectl port-forward nginx-pod 8080:80

# Forward to service
kubectl port-forward service/nginx-service 8080:80

# Forward with specific address
kubectl port-forward --address 0.0.0.0 nginx-pod 8080:80
```

#### Proxy
```bash
# Start proxy server
kubectl proxy

# Proxy with specific port
kubectl proxy --port=8001

# Access API through proxy
curl http://localhost:8001/api/v1/namespaces/default/pods
```

## Advanced Features

### Resource Scaling

#### Manual Scaling
```bash
# Scale deployment
kubectl scale deployment nginx --replicas=5

# Scale replicaset
kubectl scale rs nginx-rs --replicas=3

# Scale with conditions
kubectl scale deployment nginx --replicas=5 --current-replicas=3
```

#### Autoscaling
```bash
# Create horizontal pod autoscaler
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=10

# View autoscaler status
kubectl get hpa
```

### Rolling Updates

#### Deployment Updates
```bash
# Update image
kubectl set image deployment/nginx nginx=nginx:1.21

# Update with record
kubectl set image deployment/nginx nginx=nginx:1.21 --record

# Rollout status
kubectl rollout status deployment/nginx

# Rollout history
kubectl rollout history deployment/nginx

# Rollback
kubectl rollout undo deployment/nginx
kubectl rollout undo deployment/nginx --to-revision=2
```

### Resource Patching

#### Strategic Merge Patch
```bash
# Patch deployment
kubectl patch deployment nginx -p '{"spec":{"replicas":3}}'

# Patch with file
kubectl patch deployment nginx --patch-file patch.yaml
```

#### JSON Patch
```bash
# JSON patch
kubectl patch deployment nginx --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value": 3}]'
```

#### Merge Patch
```bash
# Merge patch
kubectl patch deployment nginx --type='merge' -p='{"spec":{"replicas":3}}'
```

### Labels and Annotations

#### Label Management
```bash
# Add label
kubectl label pods nginx-pod environment=production

# Update label
kubectl label pods nginx-pod environment=staging --overwrite

# Remove label
kubectl label pods nginx-pod environment-

# Show labels
kubectl get pods --show-labels
```

#### Annotation Management
```bash
# Add annotation
kubectl annotate pods nginx-pod description="Web server pod"

# Update annotation
kubectl annotate pods nginx-pod description="Updated web server" --overwrite

# Remove annotation
kubectl annotate pods nginx-pod description-
```

## Configuration and Customization

### kubectl Configuration

#### Config Commands
```bash
# View config
kubectl config view

# Set cluster
kubectl config set-cluster production --server=https://k8s.example.com:6443

# Set credentials
kubectl config set-credentials admin --client-certificate=admin.crt --client-key=admin.key

# Set context
kubectl config set-context production --cluster=production --user=admin

# Use context
kubectl config use-context production
```

#### Environment Variables
```bash
# Override kubeconfig location
export KUBECONFIG=/path/to/config

# Set default namespace
export KUBECTL_NAMESPACE=my-namespace

# Set output format
export KUBECTL_OUTPUT=yaml
```

### Aliases and Shortcuts

#### Common Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias ke='kubectl exec -it'

# Resource shortcuts
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
```

#### Bash Completion
```bash
# Enable bash completion
source <(kubectl completion bash)

# Add to ~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc

# Alias completion
complete -F __start_kubectl k
```

### Custom Output Formats

#### JSONPath
```bash
# Extract specific fields
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Complex JSONPath
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```

#### Go Templates
```bash
# Go template output
kubectl get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'

# Template with functions
kubectl get pods -o go-template='{{range .items}}{{.metadata.name | printf "%-20s"}} {{.status.phase}}{{"\n"}}{{end}}'
```

#### Custom Columns
```bash
# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

# From file
kubectl get pods -o custom-columns-file=columns.txt
```

## Plugins and Extensions

### kubectl Plugins

#### Plugin Discovery
```bash
# List available plugins
kubectl plugin list

# Plugin naming convention: kubectl-<plugin-name>
```

#### Popular Plugins
```bash
# Install krew (plugin manager)
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
tar zxvf krew-linux_amd64.tar.gz
./krew-linux_amd64 install krew

# Install plugins via krew
kubectl krew install ctx
kubectl krew install ns
kubectl krew install tree
kubectl krew install stern
```

#### Custom Plugin Example
```bash
#!/bin/bash
# kubectl-myplugin
echo "This is my custom kubectl plugin"
kubectl get pods "$@"

# Make executable and place in PATH
chmod +x kubectl-myplugin
sudo mv kubectl-myplugin /usr/local/bin/

# Use plugin
kubectl myplugin
```

### Kustomize Integration

#### Built-in Kustomize
```bash
# Apply kustomization
kubectl apply -k ./overlays/production/

# View kustomized output
kubectl kustomize ./overlays/production/

# Dry run with kustomize
kubectl apply -k ./overlays/production/ --dry-run=client
```

## Security and Authentication

### Authentication Methods

#### Certificate-based Authentication
```yaml
users:
- name: admin
  user:
    client-certificate: /path/to/admin.crt
    client-key: /path/to/admin.key
```

#### Token-based Authentication
```yaml
users:
- name: service-account
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9...
```

#### OIDC Authentication
```yaml
users:
- name: oidc-user
  user:
    auth-provider:
      name: oidc
      config:
        client-id: kubernetes
        client-secret: secret
        id-token: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9...
        idp-issuer-url: https://accounts.google.com
```

### RBAC Integration

#### Check Permissions
```bash
# Check if you can perform action
kubectl auth can-i create pods

# Check for specific user
kubectl auth can-i create pods --as=system:serviceaccount:default:my-sa

# Check in specific namespace
kubectl auth can-i create pods --namespace=production

# List allowed actions
kubectl auth can-i --list
```

#### Impersonation
```bash
# Impersonate user
kubectl get pods --as=john

# Impersonate service account
kubectl get pods --as=system:serviceaccount:default:my-sa

# Impersonate with groups
kubectl get pods --as=john --as-group=developers
```

## Performance and Optimization

### Client-side Caching

#### Cache Configuration
```bash
# Cache directory location
~/.kube/cache/

# Disable cache
kubectl get pods --cache-dir=""

# Custom cache directory
kubectl get pods --cache-dir=/tmp/kubectl-cache
```

### Request Optimization

#### Efficient Queries
```bash
# Use field selectors
kubectl get pods --field-selector=status.phase=Running

# Use label selectors
kubectl get pods -l app=nginx,version=v1

# Limit output
kubectl get pods --limit=10

# Use server-side filtering
kubectl get pods --chunk-size=500
```

#### Batch Operations
```bash
# Apply multiple files
kubectl apply -f file1.yaml -f file2.yaml -f file3.yaml

# Apply directory
kubectl apply -f ./manifests/ --recursive

# Delete multiple resources
kubectl delete pods pod1 pod2 pod3
```

## Troubleshooting kubectl

### Common Issues

#### Connection Problems
```bash
# Test connectivity
kubectl cluster-info

# Check kubeconfig
kubectl config view

# Verify certificates
openssl x509 -in ~/.kube/config -text -noout

# Debug API calls
kubectl get pods -v=8
```

#### Permission Issues
```bash
# Check current user
kubectl config current-context

# Verify permissions
kubectl auth can-i get pods

# Check RBAC
kubectl describe clusterrolebinding
kubectl describe rolebinding -n default
```

#### Resource Issues
```bash
# Check resource quotas
kubectl describe quota

# Check limit ranges
kubectl describe limitrange

# Check node resources
kubectl describe nodes
kubectl top nodes
```

### Debug Commands
```bash
# Verbose output levels
kubectl get pods -v=6  # API request/response headers
kubectl get pods -v=7  # API request/response bodies
kubectl get pods -v=8  # Full API request/response
kubectl get pods -v=9  # Raw API request/response

# Dry run modes
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server

# Explain resources
kubectl explain pod
kubectl explain pod.spec.containers
```

## Best Practices

### 1. Configuration Management
- Use version control for kubeconfig files
- Separate configs for different environments
- Use contexts to switch between clusters
- Implement proper RBAC policies

### 2. Resource Management
- Use declarative configuration (apply vs create)
- Implement proper labeling strategies
- Use namespaces for resource isolation
- Set resource requests and limits

### 3. Security
- Use least privilege access
- Regularly rotate credentials
- Enable audit logging
- Use network policies

### 4. Operations
- Implement proper monitoring and alerting
- Use structured logging
- Automate repetitive tasks
- Document operational procedures

## Integration with CI/CD

### GitOps Workflows
```bash
# Apply from Git repository
kubectl apply -f https://raw.githubusercontent.com/user/repo/main/deployment.yaml

# Validate before apply
kubectl apply --dry-run=server --validate=true -f deployment.yaml

# Wait for rollout
kubectl rollout status deployment/nginx --timeout=300s
```

### Automation Scripts
```bash
#!/bin/bash
# deployment script
set -e

echo "Deploying application..."
kubectl apply -f deployment.yaml

echo "Waiting for rollout..."
kubectl rollout status deployment/myapp --timeout=300s

echo "Verifying deployment..."
kubectl get pods -l app=myapp

echo "Deployment complete!"
```

## Conclusion

kubectl is essential for:
- Day-to-day Kubernetes cluster operations
- Application deployment and management
- Debugging and troubleshooting
- Automation and CI/CD integration

Mastering kubectl commands and configuration is crucial for effective Kubernetes administration and development workflows.