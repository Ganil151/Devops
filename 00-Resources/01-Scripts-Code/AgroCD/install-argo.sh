#!/bin/bash

set -e 

sudo apt update 

echo "Installing ArgoCD using HELM..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

Install ARGOCD using HELM
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update