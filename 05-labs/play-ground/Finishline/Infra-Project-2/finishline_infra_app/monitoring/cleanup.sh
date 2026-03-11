#!/bin/bash

# Monitoring Stack Cleanup Script
# Removes Prometheus + Grafana from EKS cluster

set -e

NAMESPACE="monitoring"

echo "=========================================="
echo "Removing Monitoring Stack"
echo "Namespace: $NAMESPACE"
echo "=========================================="

read -p "Are you sure you want to remove the monitoring stack? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
  echo "Cancelled."
  exit 0
fi

# Delete alert rules
echo "Deleting alert rules..."
kubectl delete prometheusrule -n $NAMESPACE --all || true

# Uninstall Helm releases
echo "Uninstalling Prometheus stack..."
helm uninstall prometheus -n $NAMESPACE || true

# Delete namespace
echo "Deleting namespace..."
kubectl delete namespace $NAMESPACE || true

echo ""
echo "=========================================="
echo "Monitoring Stack Removed Successfully!"
echo "=========================================="
