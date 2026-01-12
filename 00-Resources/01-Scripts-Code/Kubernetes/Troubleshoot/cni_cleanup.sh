#!/usr/bin/env bash

# --- Safety Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -o errexit
# Treat unset variables as an error.
set -o nounset
# Set the exit code of a pipeline to the status of the last command to exit with a non-zero status.
set -o pipefail

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

# --- Verification Function (Referenced by Cleanup) ---
# This is a simplified version of the verification function used for the final check.
verify_cni_config() {
    print_header "Verifying CNI Cleanup Status"
    echo ""

    print_info "Checking CNI configuration files on local filesystem..."
    ls -la /etc/cni/net.d/ 2>/dev/null || print_info "CNI config directory is clean."
    echo ""

    print_info "Checking Calico/Tigera CRDs remaining..."
    kubectl get crd | grep -E "calico|tigera" || print_success "No Calico/Tigera CRDs found."
    echo ""

    print_info "Checking Calico/Tigera namespaces remaining..."
    kubectl get ns | grep -E "calico|tigera" || print_success "No Calico/Tigera namespaces found."
    echo ""
}

# --- Main Cleanup Function ---
complete_cni_cleanup() {
    print_header "SECTION 2B: Complete CNI Cleanup (Calico/Flannel)"
    echo ""

    # Check for jq dependency
    if ! command -v jq &> /dev/null
    then
        print_error "The 'jq' command is required for force-deleting stuck namespaces. Please install it."
        return 1
    fi
    
    print_warning "This will completely remove Calico and Flannel from your cluster!"
    read -p "Are you sure you want to proceed? (yes/no) " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Cleanup cancelled"
        return
    fi

    print_info "Step 1: Deleting Calico/Tigera namespaces..."
    kubectl delete ns tigera-operator --ignore-not-found --timeout=30s &
    kubectl delete ns calico-system --ignore-not-found --timeout=30s &
    kubectl delete ns calico-apiserver --ignore-not-found --timeout=30s &
    kubectl delete ns kube-flannel --ignore-not-found --timeout=30s &
    wait
    echo ""

    print_info "Step 2: Force-deleting stuck namespaces if any (requires jq)..."
    # This step removes the finalizers from namespaces that are stuck in the Terminating state.
    for ns in tigera-operator calico-system calico-apiserver kube-flannel; do
        if kubectl get ns $ns &>/dev/null; then
            print_warning "Namespace $ns is stuck, force-deleting..."
            # Get namespace JSON, remove finalizers, save to /tmp, and replace/finalize via API
            kubectl get ns $ns -o json | jq 'del(.spec.finalizers)' > /tmp/ns-$ns.json 2>/dev/null
            kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f /tmp/ns-$ns.json 2>/dev/null || true
            rm -f /tmp/ns-$ns.json
        fi
    done
    echo ""
    
    print_info "Step 3: Deleting Calico/Tigera CRDs..."
    # Get all CRDs containing 'calico' or 'tigera' and delete them concurrently.
    kubectl get crd | grep -E "calico|tigera" | awk '{print $1}' | while read crd; do
        print_info "Deleting CRD: $crd"
        kubectl delete crd $crd --ignore-not-found --timeout=30s &
    done
    wait
    echo ""

    print_info "Step 4: Force-deleting stuck CRDs if any..."
    # Patch CRDs to remove finalizers and force delete the remaining ones.
    kubectl get crd | grep -E "calico|tigera" | awk '{print $1}' | while read crd; do
        print_warning "CRD $crd is stuck, force-deleting..."
        kubectl patch crd $crd -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
        kubectl delete crd $crd --ignore-not-found 2>/dev/null || true
    done
    wait # Wait for final CRD deletions
    echo ""

    print_info "Step 5: Cleaning CNI configuration files on the local filesystem."
    print_warning "Note: This only cleans the current node. You MUST run this step on all Worker Nodes too!"
    sudo rm -f /etc/cni/net.d/10-calico.conflist
    sudo rm -f /etc/cni/net.d/10-flannel.conflist
    sudo rm -f /etc/cni/net.d/calico-kubeconfig
    sudo rm -f /etc/cni/net.d/calico-tls
    ls -la /etc/cni/net.d/ 2>/dev/null || print_info "CNI config directory is now empty"
    echo ""

    print_info "Step 6: Deleting Calico/Flannel DaemonSets..."
    kubectl delete ds -n kube-system calico-node --ignore-not-found
    kubectl delete ds -n kube-system kube-flannel-ds --ignore-not-found
    echo ""

    print_info "Step 7: Waiting for cleanup to complete..."
    sleep 5
    echo ""

    print_success "CNI cleanup complete!"
    print_info "Verifying cleanup..."
    verify_cni_config
}

# --- Execution ---
complete_cni_cleanup