#!/usr/bin/env bash

# --- Color and Logging Functions ---
# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE}  $1 ${NC}"
    echo -e "${BLUE}===================================================${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# --- Main Verification Function ---

verify_cni_config() {
    print_header "Verifying CNI Configuration"
    echo ""

    # 1. Check CNI configuration files directory
    print_info "Checking CNI configuration files directory (/etc/cni/net.d)..."
    if [ -d "/etc/cni/net.d" ]; then
        ls -la /etc/cni/net.d/
        echo ""

        # Check for conflicting CNI configs (using .conflist extension)
        print_info "Checking for multiple CNI configuration files (potential conflict)..."
        # Check if any .conflist files exist
        if ls /etc/cni/net.d/*.conflist &>/dev/null; then
            CNI_COUNT=$(ls /etc/cni/net.d/*.conflist 2>/dev/null | wc -l)
            if [ "$CNI_COUNT" -gt 1 ]; then
                print_warning "Multiple CNI configurations found ($CNI_COUNT files)! This can cause conflicts."
                ls /etc/cni/net.d/*.conflist
            else
                print_success "Single CNI configuration found."
            fi
        else
            print_warning "No CNI configuration files (.conflist) found in /etc/cni/net.d/"
        fi
    else
        print_error "/etc/cni/net.d directory does not exist! CNI is likely not installed correctly."
    fi
    echo ""

    # 2. Check Calico/Tigera Custom Resource Definitions (CRDs)
    print_info "Checking Calico/Tigera CRDs (Custom Resource Definitions)..."
    if ! kubectl get crd | grep -E "calico|tigera"; then
        print_info "No Calico/Tigera CRDs found."
    fi
    echo ""

    # 3. Check Calico-related namespaces
    print_info "Checking Calico/Tigera related namespaces..."
    if ! kubectl get ns | grep -E "calico|tigera"; then
        print_info "No Calico/Tigera namespaces found."
    fi
    echo ""

    # 4. Check status of CNI-related pods in kube-system
    print_header "Checking CNI Pod Status (kube-system)"
    kubectl get pods -n kube-system -o wide | grep -E "calico|kube-flannel|aws-node|tigera" || print_info "No common CNI pods found."
}

# Execute the main function
verify_cni_config