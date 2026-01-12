#!/usr/bin/env bash
set -euo pipefail

# Usage: ./bootstrap-k3s.sh [REGISTRY_PASSWORD_OPTIONAL]
# If running from Jenkins, run via ssh ec2-user@<ip> 'bash -s' < bootstrap-k3s.sh

REGISTRY_PORT=5000
REGISTRY_CONTAINER_NAME="local-registry"
K3S_VERSION="stable"  # or a specific version like "v1.27.7+k3s1"

echo "--- Bootstrap started on $(hostname) ---"

# --- install extra packages
sudo yum -y makecache || true
sudo yum -y install -y curl grep awk tar gzip util-linux iproute || true

# --- Docker install (Amazon Linux / RHEL style)
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing docker..."
  sudo yum install -y docker || true
  sudo systemctl enable --now docker
  echo "Docker installed"
else
  echo "Docker already installed"
  sudo systemctl enable --now docker
fi

# Add ec2-user to docker group so docker commands work without sudo
sudo usermod -aG docker "${SUDO_USER:-$USER}" || true

# Wait a bit and ensure docker socket is present
sleep 3
if ! docker info >/dev/null 2>&1; then
  echo "Warning: docker info failed. Will continue, but ensure docker daemon is healthy."
fi

# --- run a small local registry (idempotent)
if ! docker ps --format '{{.Names}}' | grep -q "^${REGISTRY_CONTAINER_NAME}\$"; then
  echo "Starting local registry on :${REGISTRY_PORT}"
  docker run -d --restart=always --name ${REGISTRY_CONTAINER_NAME} -p ${REGISTRY_PORT}:5000 registry:2 || true
else
  echo "Local registry already running"
fi

# --- create a registry mirror for k3s (so images can be pulled by short name)
# create registries.yaml for containerd used by k3s (if required)
REGISTRIES_DIR="/etc/rancher/k3s"
sudo mkdir -p ${REGISTRIES_DIR}
sudo tee ${REGISTRIES_DIR}/registries.yaml >/dev/null <<EOF
mirrors:
  "localhost:${REGISTRY_PORT}":
    endpoint:
      - "http://localhost:${REGISTRY_PORT}"
EOF

# --- install k3s (single node)
if ! command -v k3s >/dev/null 2>&1; then
  echo "Installing k3s..."
  # Use k3s install script and tell it to use our registries config if present
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" K3S_CHANNEL=${K3S_VERSION} sh -s - || {
    echo "k3s install failed - exiting"
    exit 1
  }
  echo "k3s installed"
else
  echo "k3s already installed"
fi

# Ensure k3s systemd service is running
sudo systemctl enable --now k3s

# copy kubeconfig into a friendly place for ec2-user and set perms
K3S_KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
USER_KUBEDIR="/home/${SUDO_USER:-$USER}/.kube"
sudo mkdir -p "${USER_KUBEDIR}"
sudo cp "${K3S_KUBECONFIG}" "${USER_KUBEDIR}/config"
sudo chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} "${USER_KUBEDIR}"
sudo chmod 644 "${USER_KUBEDIR}/config"

echo "Kubeconfig written to ${USER_KUBEDIR}/config (mode 644)."

# --- install helm (client) if missing
if ! command -v helm >/dev/null 2>&1; then
  echo "Installing helm client..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "helm already installed"
fi

# --- Allow ec2-user to use docker without logout/login in script
# We'll source group changes for current shell by running newgrp in background (best-effort)
if ! groups | grep -q docker; then
  echo "Refreshing group membership for docker (requires exec in interactive shell for full effect)"
  newgrp docker <<'NGROUP'
echo "group refreshed (subshell)"
NGROUP
fi

echo "Bootstrap done. You can test kubectl: sudo -u ${SUDO_USER:-$USER} kubectl get nodes --kubeconfig ${USER_KUBEDIR}/config"
echo "Also test docker: docker ps"
