#!/bin/bash

# boilerplate_server_inventory_scanner.sh - Asset discovery

set -euo pipefail

readonly IP_RANGE="192.168.1"
readonly OUTPUT_FILE="server_inventory.csv"

echo "Hostname,IP,SSH_Status" > "$OUTPUT_FILE"

for i in {1..254}; do
    ip="${IP_RANGE}.${i}"
    
    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        hostname=$(nslookup "$ip" 2>/dev/null | grep 'name =' | awk '{print $4}' | sed 's/\.$//')
        
        if nc -z -w 1 "$ip" 22 &> /dev/null; then
            ssh_status="OPEN"
        else
            ssh_status="CLOSED"
        fi
        
        echo "${hostname:-unknown},$ip,$ssh_status" >> "$OUTPUT_FILE"
        echo "✓ Found: $ip"
    fi
done

echo "✓ Inventory saved: $OUTPUT_FILE"
