#!/bin/bash

#############################################################################
# Script: springboot-health-check.sh
# Description: Checks SpringBoot Actuator Endpoints
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

URL=${1:-"http://localhost:8080"}
ENDPOINT="$URL/actuator/health"

echo "Checking SpringBoot Health at $ENDPOINT..."

response=$(curl -s -o /dev/null -w "%{http_code}" "$ENDPOINT")

if [ "$response" == "200" ]; then
    echo -e "\n\033[0;32m[UP] Service is Healthy (HTTP 200)\033[0m"
    # Optional: Print JSON
    curl -s "$ENDPOINT" | grep "status"
else
    echo -e "\n\033[0;31m[DOWN] Service Unhealthy (HTTP $response)\033[0m"
    exit 1
fi
