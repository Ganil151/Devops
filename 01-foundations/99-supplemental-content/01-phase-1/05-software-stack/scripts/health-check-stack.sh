#!/bin/bash

#############################################################################
# Script: health-check-stack.sh
# Description: Checks health of common stack services
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Stack Health Check"
echo "=================="

check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}[UP] $service${NC}"
    else
        echo -e "${RED}[DOWN] $service${NC}"
    fi
}

check_port() {
    local port=$1
    local name=$2
    if nc -z localhost "$port" 2>/dev/null; then
        echo -e "${GREEN}[OPEN] Port $port ($name)${NC}"
    else
        echo -e "${RED}[CLOSED] Port $port ($name)${NC}"
    fi
}

# 1. Services
echo -e "\nChecking Services..."
check_service ssh
check_service docker
check_service apache2
check_service nginx
check_service mysql

# 2. Ports
echo -e "\nChecking Critical Ports..."
check_port 22 "SSH"
check_port 80 "HTTP"
check_port 443 "HTTPS"
check_port 3306 "MySQL"
check_port 5432 "PostgreSQL"
check_port 27017 "MongoDB"

echo -e "\nHealth Check Complete."
