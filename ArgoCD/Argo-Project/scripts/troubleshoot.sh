#!/bin/bash

# ArgoCD Troubleshooting Script
# Based on README.md Troubleshooting Section

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Main menu
show_menu() {
    print_header "ArgoCD Troubleshooting Menu"
    echo "1. Troubleshoot ImagePullBackOff / ErrImagePull"
    echo "2. Troubleshoot Unauthorized / Authentication Errors"
    echo "3. Troubleshoot ArgoCD Application Degraded/Progressing Health"
    echo "4. Troubleshoot Secret Creation Issues"
    echo "5. Troubleshoot Deployment Wrong Image Reference"
    echo "6. General Debugging Commands"
    echo "7. Exit"
    echo ""
}

# Issue 1: ImagePullBackOff
troubleshoot_image_pull() {
    print_header "Troubleshooting ImagePullBackOff / ErrImagePull"
    
    read -p "Enter namespace to check: " namespace
    
    print_info "Checking pod status in namespace: $namespace"
    kubectl get pods -n "$namespace"
    
    echo ""
    read -p "Enter pod name to describe: " pod_name
    
    print_info "Describing pod: $pod_name"
    kubectl describe pod "$pod_name" -n "$namespace"
    
    echo ""
    print_warning "Common solutions:"
    echo "1. Check if image exists locally:"
    echo "   docker images"
    echo ""
    echo "2. Tag and push the image if missing:"
    read -p "Do you want to tag and push an image? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        read -p "Enter local image (e.g., nginx:1.29.4): " local_image
        read -p "Enter registry/repo:tag (e.g., ganil151/nginx:v0.1.0): " registry_image
        
        print_info "Tagging image..."
        docker tag "$local_image" "$registry_image"
        
        print_info "Pushing image..."
        docker push "$registry_image"
        
        print_success "Image tagged and pushed successfully!"
    fi
    
    echo ""
    print_info "Remember to verify the image name in deployment.yaml matches what's in the registry"
}

# Issue 2: Authentication errors
troubleshoot_auth() {
    print_header "Troubleshooting Authentication Errors"
    
    read -p "Enter Docker Hub username: " username
    
    print_info "Testing Docker Hub login..."
    docker login --username "$username"
    
    echo ""
    read -p "Enter namespace for secret: " namespace
    read -p "Enter secret name (default: dockerconfigjson): " secret_name
    secret_name=${secret_name:-dockerconfigjson}
    
    print_info "Checking if secret exists..."
    if kubectl get secret "$secret_name" -n "$namespace" &> /dev/null; then
        print_warning "Secret exists. Do you want to delete and recreate it?"
        read -p "(y/n): " answer
        if [[ "$answer" == "y" ]]; then
            kubectl delete secret "$secret_name" -n "$namespace"
            print_success "Secret deleted"
        fi
    fi
    
    read -p "Create new secret? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        read -p "Enter Docker password: " -s password
        echo ""
        read -p "Enter email: " email
        
        print_info "Creating Docker registry secret..."
        kubectl create secret docker-registry "$secret_name" \
            --docker-server=https://index.docker.io/v1/ \
            --docker-username="$username" \
            --docker-password="$password" \
            --docker-email="$email" \
            -n "$namespace"
        
        print_success "Secret created successfully!"
        
        print_info "Verifying secret..."
        kubectl get secret "$secret_name" -n "$namespace" -o yaml
    fi
}

# Issue 3: ArgoCD Application Health
troubleshoot_argocd_health() {
    print_header "Troubleshooting ArgoCD Application Health"
    
    read -p "Enter application namespace: " app_namespace
    
    print_info "Checking pod status..."
    kubectl get pods -n "$app_namespace"
    
    echo ""
    read -p "Enter pod name to describe (or press Enter to skip): " pod_name
    if [[ -n "$pod_name" ]]; then
        kubectl describe pod "$pod_name" -n "$app_namespace"
    fi
    
    echo ""
    print_info "Checking ArgoCD applications..."
    kubectl get applications -n argocd
    
    echo ""
    read -p "Enter ArgoCD application name to describe: " app_name
    if [[ -n "$app_name" ]]; then
        kubectl describe application "$app_name" -n argocd
    fi
    
    echo ""
    read -p "Force restart deployment? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        read -p "Enter deployment name: " deployment_name
        kubectl rollout restart deployment/"$deployment_name" -n "$app_namespace"
        print_success "Deployment restarted"
    fi
    
    echo ""
    print_info "Verifying Git repository status..."
    echo "Recent commits:"
    git log --oneline -5
}

# Issue 4: Secret Creation
troubleshoot_secret() {
    print_header "Troubleshooting Secret Creation"
    
    echo "Choose secret creation method:"
    echo "1. kubectl create secret (recommended)"
    echo "2. Manual base64 encoding"
    echo "3. Verify existing secret"
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            read -p "Enter secret name: " secret_name
            read -p "Enter namespace: " namespace
            read -p "Enter registry URL (default: https://index.docker.io/v1/): " registry
            registry=${registry:-https://index.docker.io/v1/}
            read -p "Enter username: " username
            read -p "Enter password: " -s password
            echo ""
            read -p "Enter email: " email
            
            kubectl create secret docker-registry "$secret_name" \
                --docker-server="$registry" \
                --docker-username="$username" \
                --docker-password="$password" \
                --docker-email="$email" \
                -n "$namespace"
            
            print_success "Secret created successfully!"
            ;;
        2)
            read -p "Enter registry URL: " registry
            read -p "Enter username: " username
            read -p "Enter password: " password
            read -p "Enter email: " email
            
            print_info "Generating base64 encoded config..."
            encoded=$(echo "{\"auths\":{\"$registry\":{\"username\":\"$username\",\"password\":\"$password\",\"email\":\"$email\"}}}" | base64 -w 0)
            echo ""
            print_success "Base64 encoded config:"
            echo "$encoded"
            echo ""
            print_info "Use this in your secret.yaml under data:.dockerconfigjson"
            ;;
        3)
            read -p "Enter secret name: " secret_name
            read -p "Enter namespace: " namespace
            
            print_info "Retrieving secret..."
            kubectl get secret "$secret_name" -n "$namespace" -o yaml
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Issue 5: Wrong Image Reference
troubleshoot_wrong_image() {
    print_header "Troubleshooting Wrong Image Reference"
    
    echo "Choose action:"
    echo "1. Tag and push correct image"
    echo "2. Show deployment image reference"
    read -p "Enter choice (1-2): " choice
    
    case $choice in
        1)
            read -p "Enter source image (e.g., ganil151/nginx:v0.1.0): " source_image
            read -p "Enter target image (e.g., ganil151/nginx-private:v0.1.1): " target_image
            
            print_info "Tagging image..."
            docker tag "$source_image" "$target_image"
            
            print_info "Pushing image..."
            docker push "$target_image"
            
            print_success "Image tagged and pushed successfully!"
            ;;
        2)
            read -p "Enter deployment name: " deployment_name
            read -p "Enter namespace: " namespace
            
            print_info "Getting deployment image..."
            kubectl get deployment "$deployment_name" -n "$namespace" -o jsonpath='{.spec.template.spec.containers[*].image}'
            echo ""
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# General debugging
general_debugging() {
    print_header "General Debugging Commands"
    
    read -p "Enter namespace: " namespace
    
    echo ""
    print_info "1. All resources in namespace"
    kubectl get all -n "$namespace"
    
    echo ""
    print_info "2. Recent events"
    kubectl get events -n "$namespace" --sort-by=.metadata.creationTimestamp
    
    echo ""
    read -p "Enter ArgoCD application name (or press Enter to skip): " app_name
    if [[ -n "$app_name" ]]; then
        print_info "3. ArgoCD application details"
        kubectl get application "$app_name" -n argocd -o yaml
    fi
    
    echo ""
    read -p "Enter pod name to view logs (or press Enter to skip): " pod_name
    if [[ -n "$pod_name" ]]; then
        print_info "4. Pod logs"
        kubectl logs "$pod_name" -n "$namespace"
    fi
    
    echo ""
    print_info "5. Service accounts"
    kubectl get serviceaccounts -n "$namespace"
}

# Main loop
main() {
    while true; do
        show_menu
        read -p "Enter your choice (1-7): " choice
        
        case $choice in
            1) troubleshoot_image_pull ;;
            2) troubleshoot_auth ;;
            3) troubleshoot_argocd_health ;;
            4) troubleshoot_secret ;;
            5) troubleshoot_wrong_image ;;
            6) general_debugging ;;
            7) 
                print_success "Exiting troubleshooting script. Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please select 1-7."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to return to menu..."
    done
}

# Run main
main
