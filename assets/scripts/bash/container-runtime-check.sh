#!/bin/bash
# Container Runtime Security Check

echo "Checking Running Containers..."

# Get list of running containers
CONTAINERS=$(docker ps -q)

if [ -z "$CONTAINERS" ]; then
    echo "No running containers."
    exit 0
fi

echo "Found $(echo "$CONTAINERS" | wc -l) containers."

for id in $CONTAINERS; do
    NAME=$(docker inspect --format '{{.Name}}' $id | cut -c2-)
    PRIVILEGED=$(docker inspect --format '{{.HostConfig.Privileged}}' $id)
    PID_MODE=$(docker inspect --format '{{.HostConfig.PidMode}}' $id)
    
    echo -n "Container $NAME ($id): "
    
    if [ "$PRIVILEGED" == "true" ]; then
        echo -e "\033[0;31m[RISK] Privileged Mode Detected!\033[0m"
    elif [ "$PID_MODE" == "host" ]; then
        echo -e "\033[0;31m[RISK] Host PID Mode Detected!\033[0m"
    else
        echo -e "\033[0;32m[OK]\033[0m"
    fi
done
