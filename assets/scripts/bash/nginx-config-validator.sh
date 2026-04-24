#!/bin/bash
# Nginx Config Validator & Reloader
# Author: Senior DevOps Engineer

NGINX_CONF="/etc/nginx/nginx.conf"

echo "Validating Nginx Configuration..."

if ! command -v nginx &> /dev/null; then
    echo "Error: Nginx not installed."
    exit 1
fi

# Syntax Check
if nginx -t; then
    echo -e "\n[OK] Syntax is valid."
    
    read -p "Do you want to reload Nginx? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl reload nginx
        echo "Nginx Reloaded."
    fi
else
    echo -e "\n[FAIL] Syntax error detected. See details above."
    exit 1
fi
