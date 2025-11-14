#!/bin/bash
#
# Script to open common TCP ports permanently for a "worker" or "application"
# server in the 'public' zone using firewalld (CentOS 9/RHEL).

# --- Configuration ---
# Define the list of ports to open (TCP is the default protocol)
PORTS=(
    22/tcp      # SSH (Administrative access)
    80/tcp      # HTTP (General Web Traffic)
    443/tcp     # HTTPS (Secure Web Traffic)
    6443/tcp    # Kubernetes API Server (If worker needs to talk to Control Plane)
    8080/tcp    # Common Web Application/Proxy
    3306/tcp    # MySQL/MariaDB (Often used for client connections)
    8761/tcp    # Eureka/Service Discovery (Common microservice port)
    8888/tcp    # Common Web App/Proxy
    9000/tcp    # Common Web App
    9090/tcp    # Prometheus/Proxy
    9091/tcp    # Common Web App
    9100/tcp    # Node Exporter/Metrics (Monitoring)
    10250/tcp   # Kubelet API (Essential for Kubernetes worker nodes)
)
FIREWALL_ZONE="public"
# ---------------------

echo "Starting worker server port configuration script..."
echo "Target Zone: $FIREWALL_ZONE"
echo "Ports to open: ${PORTS[*]}"
echo "-----------------------------------"

# 1. Check for firewalld service status
if ! systemctl is-active --quiet firewalld; then
    echo "Error: firewalld service is not running or installed."
    echo "Please install and start firewalld (e.g., 'sudo dnf install firewalld' and 'sudo systemctl start firewalld')."
    exit 1
fi

# 2. Loop through the list of ports and add them permanently
for port in "${PORTS[@]}"; do
    echo "Attempting to add port $port..."
    # --permanent adds the rule to the configuration files
    # --add-port adds the port
    sudo firewall-cmd --zone="$FIREWALL_ZONE" --add-port="$port" --permanent

    # Check the exit status of the previous command
    if [ $? -eq 0 ]; then
        echo "Port $port added successfully (permanent)."
    else
        # This often happens if the port is already open, which is fine.
        echo "Warning: Could not add port $port. (It might already be open or the command failed for another reason)."
    fi
done

# 3. Reload firewalld to apply the permanent changes immediately
echo "-----------------------------------"
echo "Reloading firewalld to apply permanent changes..."
sudo firewall-cmd --reload

if [ $? -eq 0 ]; then
    echo "Firewall reloaded successfully. Changes are now active."
else
    echo "Error: Failed to reload firewalld. Please check the logs."
    exit 1
fi

# 4. Verification Step: Show the list of open ports in the target zone
echo "-----------------------------------"
echo "Verifying open ports in the '$FIREWALL_ZONE' zone:"
sudo firewall-cmd --list-ports --zone="$FIREWALL_ZONE"

echo "-----------------------------------"
echo "Script finished."