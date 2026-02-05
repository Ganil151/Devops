#!/bin/bash

sudo kubeadm reset -f
sudo systemctl stop kubelet
sudo systemctl stop containerd

# remove state
sudo rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /var/lib/cni /etc/cni/net.d

# ensure containerd configured properly
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# re-run init
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# set kubectl
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

