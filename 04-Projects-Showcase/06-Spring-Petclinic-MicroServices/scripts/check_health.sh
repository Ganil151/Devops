#!/bin/bash
# 🏥 Microservices Health & Connectivity Checker
# Role: Automated post-deployment validation

set -e

NAMESPACE="petclinic"
SERVICES=("api-gateway" "customers-service" "vets-service" "visits-service" "genai-service")

echo "🔍 Starting post-launch health check in namespace: $NAMESPACE"

for svc in "${SERVICES[@]}"; do
    echo -n "Checking $svc... "
    STATUS=$(kubectl get pods -n $NAMESPACE -l app=$svc -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Not Found")
    
    if [ "$STATUS" == "Running" ]; then
        echo "✅ [Running]"
    else
        echo "❌ [$STATUS]"
        ERROR_FOUND=1
    fi
done

if [ "$ERROR_FOUND" == "1" ]; then
    echo "⚠️  One or more services are not healthy. Check logs with 'kubectl logs'."
    exit 1
else
    echo "🚀 All services are operational!"
fi
