# 🚀 Global Microservices Mesh - Deployment Guide

This guide provides step-by-step instructions for deploying the Global Microservices Mesh showcase project.

---

## 📋 Prerequisites

Before starting the deployment, ensure you have the following tools installed and configured:

### Required Tools

- **AWS CLI** (v2.x+) - Configured with appropriate credentials
- **Terraform** (v1.0+)
- **kubectl** (v1.24+)
- **Helm** (v3.x+)
- **ArgoCD CLI** (v2.x+)
- **Docker** (for local testing)
- **Jenkins** (configured with shared library)

### AWS Requirements

- AWS Account with appropriate permissions
- IAM user/role with EKS, VPC, and EC2 permissions
- AWS credentials configured (`aws configure`)

### Verification Commands

```bash
# Verify tool installations
terraform version
kubectl version --client
helm version
argocd version
aws --version
docker --version
```

---

## 🏗️ Deployment Phases

### Phase 1: Infrastructure Provisioning

#### Step 1.1: Initialize Terraform

```bash
cd C:\Users\Ganil\Documents\Devops\8-Porjects-Showcase\Global-Microservices-Mesh\infra

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt
```

#### Step 1.2: Plan Infrastructure

```bash
# Review the execution plan
terraform plan -out=tfplan

# Optional: Save plan to file for review
terraform show -json tfplan > plan.json
```

#### Step 1.3: Apply Infrastructure

```bash
# Deploy the infrastructure
terraform apply tfplan

# Note: This will create:
# - VPC with public/private subnets
# - EKS cluster with worker nodes
# - Istio service mesh components
```

**Expected Duration**: 15-20 minutes

#### Step 1.4: Configure kubectl

```bash
# Update kubeconfig to access the new EKS cluster
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>

# Verify cluster access
kubectl get nodes
kubectl get namespaces
```

---

### Phase 2: Service Mesh Verification

#### Step 2.1: Verify Istio Installation

```bash
# Check Istio system namespace
kubectl get pods -n istio-system

# Verify Istio components
kubectl get svc -n istio-system

# Check Istio ingress gateway
kubectl get pods -n istio-ingress
kubectl get svc -n istio-ingress
```

#### Step 2.2: Enable Istio Injection

```bash
# Verify namespace labels
kubectl get namespace istio-ingress -o yaml

# Should see: istio-injection: enabled
```

---

### Phase 3: ArgoCD Setup

#### Step 3.1: Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

#### Step 3.2: Access ArgoCD UI

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# Username: admin
# Password: <from above command>
```

#### Step 3.3: Deploy ArgoCD Application

```bash
# Apply the ArgoCD application manifest
kubectl apply -f C:\Users\Ganil\Documents\Devops\8-Porjects-Showcase\Global-Microservices-Mesh\gitops\argocd-app.yaml

# Verify application creation
argocd app list

# Sync the application
argocd app sync global-mesh-showcase

# Wait for sync to complete
argocd app wait global-mesh-showcase
```

---

### Phase 4: CI/CD Pipeline Setup

#### Step 4.1: Configure Jenkins

1. **Install Required Plugins**:
   - Kubernetes Plugin
   - Docker Pipeline Plugin
   - AWS Steps Plugin
   - ArgoCD Plugin

2. **Configure Credentials**:
   - AWS credentials
   - Docker registry credentials
   - GitHub/Git credentials
   - ArgoCD credentials

3. **Load Shared Library**:
   - Configure Jenkins shared library pointing to your repository

#### Step 4.2: Create Jenkins Pipeline

```bash
# In Jenkins UI:
# 1. New Item → Pipeline
# 2. Name: global-microservices-mesh
# 3. Pipeline → Definition: Pipeline script from SCM
# 4. SCM: Git
# 5. Repository URL: <your-repo-url>
# 6. Script Path: 8-Porjects-Showcase/Global-Microservices-Mesh/Jenkinsfile
```

#### Step 4.3: Run Initial Pipeline

```bash
# Trigger the pipeline manually or via webhook
# The pipeline will:
# 1. Lint Terraform code
# 2. Run security scans (Trivy, Checkov)
# 3. Sync with ArgoCD
# 4. Wait for deployment completion
```

---

### Phase 5: Security & Observability

#### Step 5.1: Install Monitoring Stack

```bash
# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Install Kiali (Istio Dashboard)
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Access Kiali
kubectl port-forward svc/kiali -n istio-system 20001:20001
```

#### Step 5.2: Configure Vault (Optional)

```bash
# Install HashiCorp Vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault -n vault --create-namespace

# Initialize and unseal Vault
kubectl exec -n vault vault-0 -- vault operator init
kubectl exec -n vault vault-0 -- vault operator unseal <unseal-key>
```

---

## 🔍 Verification & Testing

### Verify Deployment

```bash
# Check all pods are running
kubectl get pods --all-namespaces

# Verify Istio sidecar injection
kubectl get pods -n istio-ingress -o jsonpath='{.items[*].spec.containers[*].name}'

# Check service mesh connectivity
kubectl exec -n istio-ingress <pod-name> -c istio-proxy -- pilot-agent request GET stats | grep cluster_manager
```

### Test Application

```bash
# Get ingress gateway external IP
kubectl get svc -n istio-ingress istio-ingressgateway

# Test application endpoint
curl http://<EXTERNAL-IP>/
```

### Monitor Logs

```bash
# View Istio proxy logs
kubectl logs -n istio-ingress <pod-name> -c istio-proxy

# View application logs
kubectl logs -n istio-ingress <pod-name> -c <app-container>
```

---

## 🛠️ Troubleshooting

### Common Issues

#### Issue 1: EKS Cluster Creation Fails

```bash
# Check AWS quotas
aws service-quotas list-service-quotas --service-code eks

# Verify IAM permissions
aws sts get-caller-identity
```

#### Issue 2: Istio Pods Not Starting

```bash
# Check events
kubectl describe pod <pod-name> -n istio-system

# Verify Helm releases
helm list -n istio-system
```

#### Issue 3: ArgoCD Sync Fails

```bash
# Check application status
argocd app get global-mesh-showcase

# View sync logs
argocd app logs global-mesh-showcase
```

---

## 🧹 Cleanup

### Destroy Infrastructure

```bash
# Delete ArgoCD application
kubectl delete -f C:\Users\Ganil\Documents\Devops\8-Porjects-Showcase\Global-Microservices-Mesh\gitops\argocd-app.yaml

# Destroy Terraform resources
cd C:\Users\Ganil\Documents\Devops\8-Porjects-Showcase\Global-Microservices-Mesh\infra
terraform destroy

# Confirm destruction
# Type: yes
```

---

## 📊 Success Criteria

- ✅ EKS cluster is running with 2+ worker nodes
- ✅ Istio control plane is healthy (all pods running)
- ✅ Istio ingress gateway has external IP
- ✅ ArgoCD is syncing applications automatically
- ✅ Jenkins pipeline runs successfully
- ✅ Security scans pass (no CRITICAL vulnerabilities)
- ✅ Monitoring dashboards are accessible
- ✅ Application is accessible via ingress gateway

---

## 📚 Next Steps

1. **Deploy Sample Application**: Deploy Spring PetClinic microservices
2. **Configure mTLS**: Enable strict mTLS across the mesh
3. **Set Up Circuit Breakers**: Implement resilience patterns
4. **Create Dashboards**: Build custom Grafana dashboards
5. **Implement GitOps**: Automate deployments via Git commits

---

## 🔗 Related Documentation

- [Terraform Modules](readme.md)
- [Jenkins Blueprints](readme.md)
- [Service Mesh Guide](readme.md)
- [Istio Documentation](https://istio.io/latest/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

---

**Deployment Philosophy**: *"Production-grade infrastructure isn't built in a day—it's architected, tested, and refined iteratively."*
