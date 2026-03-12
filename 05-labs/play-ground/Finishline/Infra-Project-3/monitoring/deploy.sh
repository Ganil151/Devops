#!/bin/bash

# Monitoring Stack Deployment Script
# Deploys Prometheus + Grafana to EKS cluster

set -e

NAMESPACE="monitoring"
CLUSTER_NAME="${1:-finishline-eks-cluster}"

echo "=========================================="
echo "Deploying Monitoring Stack"
echo "Cluster: $CLUSTER_NAME"
echo "Namespace: $NAMESPACE"
echo "=========================================="

# Create namespace
echo "Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repositories
echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
echo "Installing Prometheus stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --values prometheus-values.yaml \
  --wait

# Apply alert rules
echo "Applying alert rules..."
kubectl apply -f prometheus-rules.yaml

# Wait for deployments
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/prometheus-operator -n $NAMESPACE --timeout=5m
kubectl rollout status deployment/grafana -n $NAMESPACE --timeout=5m

echo ""
echo "=========================================="
echo "Monitoring Stack Deployed Successfully!"
echo "=========================================="
echo ""
echo "Access Grafana:"
echo "  kubectl port-forward -n $NAMESPACE svc/grafana 3000:80"
echo "  URL: http://localhost:3000"
echo ""
echo "Get Grafana admin password:"
echo "  kubectl get secret -n $NAMESPACE grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
echo ""
echo "Access Prometheus:"
echo "  kubectl port-forward -n $NAMESPACE svc/prometheus-operated 9090:9090"
echo "  URL: http://localhost:9090"
echo ""
echo "View alert rules:"
echo "  kubectl get prometheusrule -n $NAMESPACE"
echo ""
