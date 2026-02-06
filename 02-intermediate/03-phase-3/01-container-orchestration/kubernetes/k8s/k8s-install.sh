#!/bin/bash

# Script to install Containerd and Kubernetes components on AWS Linux 2023 (AL2023)

set -e

echo "--- 1. System Setup and Package Update (using yum) ---"
sudo yum update -y
sudo yum install -y vim git bash-completion

# --- 2. Disable Swap and Firewall (Mandatory K8s Requirements) ---
echo "Disabling Swap permanently..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Disabling firewall (assuming AWS Security Groups handle network control)..."
# AWS Linux 2023 uses firewalld by default, but it's often simpler to manage
# security groups in AWS. We'll ensure the firewall is stopped for simplicity.
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# --- 3. Install Container Runtime (Containerd) ---
echo "Installing containerd..."
# AL2023 is designed to work with containers. We install it via yum.
sudo yum install -y containerd

echo "Enabling kernel modules for networking..."
# Add necessary kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Enable required sysctl parameters
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Configure containerd
echo "Configuring and starting containerd..."
# Ensure the default config is generated and start the service
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

# Change the default SystemdCgroup value to true to use systemd as the cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart containerd to apply changes
sudo systemctl restart containerd
sudo systemctl enable containerd --now

# --- 4. Install Kubernetes Tools (kubelet, kubeadm, kubectl) ---
echo "Adding Kubernetes repository..."
# Add the Kubernetes repository
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

echo "Installing kubelet, kubeadm, and kubectl..."
# Install the components, ignoring dependency checks if needed
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable and start kubelet (it will be in a waiting loop until configured by kubeadm)
echo "Enabling and starting kubelet..."
sudo systemctl enable --now kubelet

echo "--- Installation Complete ---"
echo "Next Steps:"
echo "1. On the Master-Server: Run 'sudo kubeadm init --pod-network-cidr=<CIDR>' (e.g., 10.244.0.0/16 for Flannel)."
echo "2. On the Worker-Server: Use the 'kubeadm join' command output by the Master-Server."

# Verify installation (client only)
kubectl version --client --short