#!/bin/bash
# Description: Automates the deployment of a Docker Stack
# Usage: ./deploy-docker-stack.sh <stack_name> <compose_file>

STACK_NAME=$1
COMPOSE_FILE=${2:-"docker-compose.yml"}

set -e

if [ -z "$STACK_NAME" ]; then
    echo "Usage: $0 <stack_name> [compose_file]"
    exit 1
fi

log() {
    echo "[Docker-Deploy] $1"
}

# 1. Pre-Check
if ! docker info > /dev/null 2>&1; then
    log "Error: Docker daemon is not running."
    exit 1
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    log "Error: Compose file '$COMPOSE_FILE' not found."
    exit 1
fi

# 2. Network Check
NET_NAME="${STACK_NAME}_net"
if ! docker network ls | grep -q "$NET_NAME"; then
    log "Creating network: $NET_NAME"
    docker network create --driver overlay "$NET_NAME" 2>/dev/null || docker network create "$NET_NAME"
else
    log "Network $NET_NAME already exists."
fi

# 3. Deploy
log "Deploying Stack: $STACK_NAME from $COMPOSE_FILE..."
if docker info | grep -q "Swarm: active"; then
    docker stack deploy -c "$COMPOSE_FILE" "$STACK_NAME"
else
    log "Swarm not active. Using docker-compose up -d..."
    docker compose -f "$COMPOSE_FILE" -p "$STACK_NAME" up -d
fi

# 4. Health Wait
log "Waiting for services to stabilize..."
sleep 5
docker compose -f "$COMPOSE_FILE" -p "$STACK_NAME" ps

log "Deployment sequence finished."
