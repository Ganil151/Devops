#!/bin/bash
# Description: Automated Helm Canary Deployment with Rollback Logic
# Usage: ./deploy-helm-canary.sh <release_name> <chart_path> <canary_weight>

RELEASE_NAME=$1
CHART_PATH=$2
WEIGHT=${3:-"10"} # Percent of traffic to canary

if [ -z "$RELEASE_NAME" ] || [ -z "$CHART_PATH" ]; then
    echo "Usage: $0 <release_name> <chart_path> [weight]"
    exit 1
fi

log() {
    echo "[CANARY-OPS] $1"
}

# 1. Initiate Canary
log "Deploying Canary release for $RELEASE_NAME at $WEIGHT% weight..."
helm upgrade --install "$RELEASE_NAME-canary" "$CHART_PATH" \
    --set service.weight="$WEIGHT" \
    --set replicaCount=1 \
    --wait

# 2. Health Monitoring (Simulated)
log "Monitoring canary health for 30s..."
T=0
while [ $T -lt 30 ]; do
    # check for 5xx errors from ingress (mock)
    ERRORS=$(kubectl get pods -l app="$RELEASE_NAME-canary" -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' | awk '{s+=$1} END {print s}')
    
    if [ "$ERRORS" -gt 0 ]; then
        log "CRITICAL: Restarts detected. Rolling back!"
        helm rollback "$RELEASE_NAME-canary"
        exit 1
    fi
    sleep 5
    ((T+=5))
done

# 3. Promote
log "Canary Healthy. Promoting to Full Release..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" \
    --set service.weight="100" \
    --wait

log "Removing Canary..."
helm uninstall "$RELEASE_NAME-canary"
log "Deployment Successful."
