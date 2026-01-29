# Global Microservices Mesh - PowerShell Deployment Script
# This script automates the deployment of the Global Microservices Mesh showcase project on Windows

param(
    [string]$AwsRegion = "us-east-1",
    [string]$ProjectName = "global-microservices-mesh",
    [switch]$SkipArgoCD,
    [switch]$SkipMonitoring
)

# Configuration
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Join-Path $ScriptDir "infra"

# Color output functions
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    $missingTools = @()
    
    # Check required tools
    $tools = @{
        "terraform" = "Terraform"
        "kubectl" = "kubectl"
        "helm" = "Helm"
        "aws" = "AWS CLI"
    }
    
    foreach ($tool in $tools.Keys) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            $missingTools += $tools[$tool]
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-Error "Missing required tools: $($missingTools -join ', ')"
        Write-Info "Please install missing tools before proceeding."
        exit 1
    }
    
    # Check AWS credentials
    try {
        aws sts get-caller-identity | Out-Null
    }
    catch {
        Write-Error "AWS credentials not configured or invalid"
        Write-Info "Run 'aws configure' to set up your credentials"
        exit 1
    }
    
    Write-Success "All prerequisites met!"
}

# Function to deploy infrastructure
function Deploy-Infrastructure {
    Write-Info "Deploying infrastructure with Terraform..."
    
    Push-Location $InfraDir
    
    try {
        # Initialize Terraform
        Write-Info "Initializing Terraform..."
        terraform init
        
        # Validate configuration
        Write-Info "Validating Terraform configuration..."
        terraform validate
        
        # Format code
        terraform fmt
        
        # Plan deployment
        Write-Info "Creating Terraform plan..."
        terraform plan -out=tfplan
        
        # Ask for confirmation
        $confirm = Read-Host "Do you want to apply this plan? (yes/no)"
        if ($confirm -ne "yes") {
            Write-Warning "Deployment cancelled by user"
            exit 0
        }
        
        # Apply infrastructure
        Write-Info "Applying Terraform configuration..."
        terraform apply tfplan
        
        Write-Success "Infrastructure deployed successfully!"
    }
    finally {
        Pop-Location
    }
}

# Function to configure kubectl
function Set-KubectlConfig {
    Write-Info "Configuring kubectl..."
    
    # Get cluster name from Terraform output
    Push-Location $InfraDir
    try {
        $clusterName = terraform output -raw cluster_name 2>$null
        if (-not $clusterName) {
            $clusterName = "$ProjectName-cluster"
        }
    }
    finally {
        Pop-Location
    }
    
    # Update kubeconfig
    aws eks update-kubeconfig --region $AwsRegion --name $clusterName
    
    # Verify connection
    try {
        kubectl get nodes
        Write-Success "kubectl configured successfully!"
    }
    catch {
        Write-Error "Failed to connect to cluster"
        exit 1
    }
}

# Function to verify Istio installation
function Test-IstioInstallation {
    Write-Info "Verifying Istio installation..."
    
    # Wait for Istio pods to be ready
    Write-Info "Waiting for Istio system pods..."
    kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=300s
    
    # Check Istio components
    Write-Info "Istio system pods:"
    kubectl get pods -n istio-system
    
    Write-Info "Istio ingress pods:"
    kubectl get pods -n istio-ingress
    
    Write-Success "Istio verification complete!"
}

# Function to install ArgoCD
function Install-ArgoCD {
    Write-Info "Installing ArgoCD..."
    
    # Create namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Install ArgoCD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for ArgoCD to be ready
    Write-Info "Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
    
    # Get admin password
    Write-Info "Retrieving ArgoCD admin password..."
    $passwordBase64 = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
    $password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($passwordBase64))
    
    Write-Success "ArgoCD installed successfully!"
    Write-Info "ArgoCD Admin Password: $password"
    Write-Info "To access ArgoCD UI, run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
    
    return $password
}

# Function to deploy application with ArgoCD
function Deploy-Application {
    Write-Info "Deploying application with ArgoCD..."
    
    # Apply ArgoCD application manifest
    $appManifest = Join-Path $ScriptDir "gitops\argocd-app.yaml"
    kubectl apply -f $appManifest
    
    Write-Success "ArgoCD application created!"
    Write-Info "Application will sync automatically"
}

# Function to install monitoring
function Install-Monitoring {
    Write-Info "Installing monitoring stack..."
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install Prometheus
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
        -n monitoring `
        --wait
    
    # Install Kiali
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml
    
    Write-Success "Monitoring stack installed!"
    Write-Info "To access Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    Write-Info "To access Kiali: kubectl port-forward -n istio-system svc/kiali 20001:20001"
}

# Function to display deployment summary
function Show-DeploymentSummary {
    param([string]$ArgoCDPassword = "")
    
    Write-Success "🎉 Deployment Complete!"
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  Global Microservices Mesh Deployment" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📊 Cluster Information:" -ForegroundColor Yellow
    kubectl cluster-info
    Write-Host ""
    Write-Host "🔧 Access Points:" -ForegroundColor Yellow
    if (-not $SkipArgoCD) {
        Write-Host "  - ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
        Write-Host "    Username: admin"
        Write-Host "    Password: $ArgoCDPassword"
    }
    if (-not $SkipMonitoring) {
        Write-Host "  - Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
        Write-Host "  - Kiali: kubectl port-forward -n istio-system svc/kiali 20001:20001"
    }
    Write-Host ""
    Write-Host "📝 Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Access ArgoCD UI and verify application sync"
    Write-Host "  2. Deploy sample microservices application"
    Write-Host "  3. Configure mTLS and circuit breakers"
    Write-Host "  4. Set up custom monitoring dashboards"
    Write-Host ""
    Write-Host "📚 Documentation: $ScriptDir\DEPLOYMENT_GUIDE.md"
    Write-Host "==========================================" -ForegroundColor Cyan
}

# Main deployment flow
function Main {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Global Microservices Mesh Deployment ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $argoCDPassword = ""
    
    try {
        # Step 1: Check prerequisites
        Test-Prerequisites
        
        # Step 2: Deploy infrastructure
        Deploy-Infrastructure
        
        # Step 3: Configure kubectl
        Set-KubectlConfig
        
        # Step 4: Verify Istio
        Test-IstioInstallation
        
        # Step 5: Install ArgoCD
        if (-not $SkipArgoCD) {
            $installArgo = Read-Host "Install ArgoCD? (yes/no)"
            if ($installArgo -eq "yes") {
                $argoCDPassword = Install-ArgoCD
                Deploy-Application
            }
        }
        
        # Step 6: Install monitoring
        if (-not $SkipMonitoring) {
            $installMon = Read-Host "Install monitoring stack (Prometheus, Grafana, Kiali)? (yes/no)"
            if ($installMon -eq "yes") {
                Install-Monitoring
            }
        }
        
        # Display summary
        Show-DeploymentSummary -ArgoCDPassword $argoCDPassword
    }
    catch {
        Write-Error "Deployment failed: $_"
        Write-Info "Check the logs above for details"
        exit 1
    }
}

# Run main function
Main
