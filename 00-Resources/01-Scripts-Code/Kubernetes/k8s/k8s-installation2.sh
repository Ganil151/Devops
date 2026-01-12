#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration ---
CLUSTER_NAME="petclinic-cluster"
# Define the desired Kubernetes version for the kind cluster.
# You can fetch the latest stable version dynamically if needed.
# Example: K8S_VERSION="v1.32.0" # Replace with the latest desired version
# For now, kind will use its default latest stable version unless specified.
# K8S_VERSION="v1.32.0" # Uncomment and set if you want a specific version

# --- Error Handling and Logging ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

cleanup() {
    log_info "Script finished or interrupted. Performing cleanup if necessary..."
    # Add any cleanup logic here if needed, e.g., removing temporary files
}

# Set up trap to call cleanup function on script exit or interruption
trap cleanup EXIT

# --- Validation Functions ---
validate_docker() {
    log_info "Validating Docker installation..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running or accessible."
        exit 1
    fi
    log_info "Docker is installed and running."
}

check_latest_kind_version() {
    log_info "Fetching the latest kind release version..."
    # Use GitHub API to get the latest release tag
    LATEST_KIND_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$LATEST_KIND_VERSION" ]; then
        log_error "Failed to fetch the latest kind version from GitHub API."
        exit 1
    fi
    log_info "Latest kind version found: $LATEST_KIND_VERSION"
    echo "$LATEST_KIND_VERSION" # Return the version
}

check_installed_kind_version() {
    if command -v kind &> /dev/null; then
        INSTALLED_KIND_VERSION=$(kind version)
        echo "$INSTALLED_KIND_VERSION" # Return the version string
    else
        echo "not_installed" # Return status
    fi
}

install_or_update_kind() {
    local latest_version=$1
    local install_dir="/usr/local/bin"
    local kind_binary="$install_dir/kind"

    log_info "Checking if kind needs installation or update..."

    local installed_status
    installed_status=$(check_installed_kind_version)

    if [ "$installed_status" == "not_installed" ]; then
        log_info "kind is not installed. Installing latest version ($latest_version)..."
    elif echo "$installed_status" | grep -q "$latest_version"; then
        log_info "kind is already installed and up-to-date ($installed_status). Skipping installation."
        return 0 # Exit function successfully
    else
        log_info "kind is installed but not the latest ($installed_status vs $latest_version). Updating..."
    fi

    # Download the latest kind binary
    log_info "Downloading kind binary for Linux AMD64..."
    curl -Lo "$kind_binary" "https://kind.sigs.k8s.io/dl/${latest_version}/kind-linux-amd64"

    # Make the binary executable
    chmod +x "$kind_binary"

    log_info "kind installed/updated successfully to $kind_binary (Version: $latest_version)."
}

create_kind_cluster() {
    log_info "Checking for existing kind cluster named '$CLUSTER_NAME'..."
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        log_info "Cluster '$CLUSTER_NAME' already exists. Deleting it before creating a new one..."
        kind delete cluster --name "$CLUSTER_NAME" || {
            log_error "Failed to delete existing cluster '$CLUSTER_NAME'."
            exit 1
        }
    fi

    log_info "Creating a new kind cluster named '$CLUSTER_NAME'..."

    CREATE_CMD="kind create cluster --name \"$CLUSTER_NAME\""
    if [ -n "${K8S_VERSION:-}" ]; then
        CREATE_CMD="$CREATE_CMD --image=kindest/node:${K8S_VERSION}"
    fi

    # Execute the create command
    $CREATE_CMD || {
        log_error "Failed to create kind cluster '$CLUSTER_NAME'. Check Docker logs and kind output above."
        exit 1
    }

    log_info "kind cluster '$CLUSTER_NAME' created successfully."
}

# --- Main Execution ---
main() {
    log_info "Starting K8s setup process..."

    # 1. Validate prerequisites
    validate_docker

    # 2. Check for latest kind version
    LATEST_KIND_VERSION=$(check_latest_kind_version)

    # 3. Install or update kind
    install_or_update_kind "$LATEST_KIND_VERSION"

    # 4. Create the kind cluster
    create_kind_cluster

    # 5. Optional: Validate cluster is ready
    log_info "Validating cluster readiness..."
    # The kind create command usually waits for the control plane to be ready.
    # We can run a simple kubectl command to double-check.
    export KUBECONFIG="$(kind get kubeconfig-path --name="$CLUSTER_NAME")"
    if kubectl cluster-info &> /dev/null; then
        log_info "Kubernetes cluster '$CLUSTER_NAME' is ready and accessible via kubectl."
    else
        log_error "Failed to access the Kubernetes cluster '$CLUSTER_NAME' using kubectl."
        exit 1
    fi

    log_info "K8s setup completed successfully. Cluster name: $CLUSTER_NAME"
    log_info "KUBECONFIG is set to: $KUBECONFIG"
    echo "You can now use kubectl to interact with the cluster."
    # Example deployment command (requires k8s manifests):
    # kubectl apply -f /path/to/your/petclinic-k8s-manifests/
}

# Run the main function
main "$@"