#!/bin/bash

echo "Enter target IP address or hostname:"
read target_ip

echo "=== Open Ports on $target_ip ==="
nc -zv $target_ip 1-1023 2>1 | grep succeeded

# Adjust the port range (1-1023) based on your requirements