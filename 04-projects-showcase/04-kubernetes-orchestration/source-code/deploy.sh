#!/bin/bash

# Global Microservices Mesh - Automated Deployment Script
# This script automates the deployment of the Global Microservices Mesh showcase project

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="global-microservices-mesh"
AWS_REGION="us-east-1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${SCRIPT_DIR}/infra"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check required tools
    command -v terraform >/dev/null 2>&1 || missing_tools+=("terraform")
    command -v kubectl >/dev/null 2>&1 || missing_tools+=("kubectl")
    command -v helm >/dev/null 2>&1 || missing_tools+=("helm")
    command -v aws >/dev/null 2>&1 || missing_tools+=("aws-cli")
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install missing tools before proceeding."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS credentials not configured or invalid"
        print_info "Run 'aws configure' to set up your credentials"
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_info "Deploying infrastructure with Terraform..."
    
    cd "${INFRA_DIR}"
    
    # Initialize Terraform
    print_info "Initializing Terraform..."
    terraform init
    
    # Validate configuration
    print_info "Validating Terraform configuration..."
    terraform validate
    
    # Format code
    terraform fmt
    
    # Plan deployment
    print_info "Creating Terraform plan..."
    terraform plan -out=tfplan
    
    # Ask for confirmation
    read -p "Do you want to apply this plan? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_warning "Deployment cancelled by user"
        exit 0
    fi
    
    # Apply infrastructure
    print_info "Applying Terraform configuration..."
    terraform apply tfplan
    
    print_success "Infrastructure deployed successfully!"
    
    cd "${SCRIPT_DIR}"
}

# Function to configure kubectl
configure_kubectl() {
    print_info "Configuring kubectl..."
    
    # Get cluster name from Terraform output
    cd "${INFRA_DIR}"
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "${PROJECT_NAME}-cluster")
    cd "${SCRIPT_DIR}"
    
    # Update kubeconfig
    aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"
    
    # Verify connection
    if kubectl get nodes >/dev/null 2>&1; then
        print_success "kubectl configured successfully!"
        kubectl get nodes
    else
        print_error "Failed to connect to cluster"
        exit 1
    fi
}

# Function to verify Istio installation
verify_istio() {
    print_info "Verifying Istio installation..."
    
    # Wait for Istio pods to be ready
    print_info "Waiting for Istio system pods..."
    kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=300s || true
    
    # Check Istio components
    print_info "Istio system pods:"
    kubectl get pods -n istio-system
    
    print_info "Istio ingress pods:"
    kubectl get pods -n istio-ingress
    
    print_success "Istio verification complete!"
}

# Function to install ArgoCD
install_argocd() {
    print_info "Installing ArgoCD..."
    
    # Create namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Install ArgoCD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for ArgoCD to be ready
    print_info "Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
    
    # Get admin password
    print_info "Retrieving ArgoCD admin password..."
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    print_success "ArgoCD installed successfully!"
    print_info "ArgoCD Admin Password: ${ARGOCD_PASSWORD}"
    print_info "To access ArgoCD UI, run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

# Function to deploy application with ArgoCD
deploy_application() {
    print_info "Deploying application with ArgoCD..."
    
    # Apply ArgoCD application manifest
    kubectl apply -f "${SCRIPT_DIR}/gitops/argocd-app.yaml"
    
    print_success "ArgoCD application created!"
    print_info "Application will sync automatically"
}

# Function to install monitoring
install_monitoring() {
    print_info "Installing monitoring stack..."
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install Prometheus
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        -n monitoring \
        --wait
    
    # Install Kiali
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml
    
    print_success "Monitoring stack installed!"
    print_info "To access Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    print_info "To access Kiali: kubectl port-forward -n istio-system svc/kiali 20001:20001"
}

# Function to display deployment summary
display_summary() {
    print_success "🎉 Deployment Complete!"
    echo ""
    echo "=========================================="
    echo "  Global Microservices Mesh Deployment"
    echo "=========================================="
    echo ""
    echo "📊 Cluster Information:"
    kubectl cluster-info
    echo ""
    echo "🔧 Access Points:"
    echo "  - ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "  - Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    echo "  - Kiali: kubectl port-forward -n istio-system svc/kiali 20001:20001"
    echo ""
    echo "📝 Next Steps:"
    echo "  1. Access ArgoCD UI and verify application sync"
    echo "  2. Deploy sample microservices application"
    echo "  3. Configure mTLS and circuit breakers"
    echo "  4. Set up custom monitoring dashboards"
    echo ""
    echo "📚 Documentation: ${SCRIPT_DIR}/DEPLOYMENT_GUIDE.md"
    echo "=========================================="
}

# Main deployment flow
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║  Global Microservices Mesh Deployment ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    # Step 1: Check prerequisites
    check_prerequisites
    
    # Step 2: Deploy infrastructure
    deploy_infrastructure
    
    # Step 3: Configure kubectl
    configure_kubectl
    
    # Step 4: Verify Istio
    verify_istio
    
    # Step 5: Install ArgoCD
    read -p "Install ArgoCD? (yes/no): " install_argo
    if [ "$install_argo" = "yes" ]; then
        install_argocd
        deploy_application
    fi
    
    # Step 6: Install monitoring
    read -p "Install monitoring stack (Prometheus, Grafana, Kiali)? (yes/no): " install_mon
    if [ "$install_mon" = "yes" ]; then
        install_monitoring
    fi
    
    # Display summary
    display_summary
}

# Run main function
main "$@"
