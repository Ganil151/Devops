#!/bin/bash

echo "=== User Account Activity Monitor ==="

# Function to check user activity in system logs
check_logins(){
    echo "=== Recent Logins ==="
    last | grep "$1" || echo "No recent logins found for user $1."
}

# Function to check sudo command usage 
check_sudo_usage(){
    echo "=== Sudo Command Usage ==="
    if [ -f /var/log/auth.log ]; then 
        grep "$1" /var/log/auth.log | grep sudo || echo "No sudo usage found for user $1."
    else
        echo "Warning: /var/log/auth.log not found."
    fi
}

# Function to stop monitoring user's home directory changes 
stop_monitoring(){
    if command -v auditctl >/dev/null 2>&1; then
        auditctl -d /home/"$1" || echo "Error: Failed to stop monitoring home directory."
    else
        echo "Error: auditctl command not found. Please install auditd."
    fi
}

# Function to monitor all open ports
monitor_all_ports(){
    echo "=== All Open Ports ==="
    if command -v nmap >/dev/null 2>&1; then
        nmap -sT -oG - localhost || echo "Error: Failed to run nmap. Is it installed?"
    else
        echo "Error: nmap command not found. Please install nmap."
    fi
}

# Function to monitor network connections (requires netstat command)
monitor_network_connections(){
    echo "=== Network Connections ==="
    if command -v netstat >/dev/null 2>&1; then
        netstat -tunlp | grep "$1" || echo "No network connections found for user $1."
    else
        echo "Error: netstat command not found. Please install net-tools."
    fi
}

# Get username from user input with validation
read -p "Enter username: " username

# Validate username input
if [ -z "$username" ]; then
    echo "Error: No username provided. Exiting."
    exit 1
fi

# Check user activity
check_logins "$username"
check_sudo_usage "$username"

# Monitor all open ports
monitor_all_ports "$username"

# Monitor network connections
monitor_network_connections "$username"

# Start monitoring home directory changes
monitor_home_directory "$username"

# Optional: Uncomment below block for continuous monitoring
# while true; do
#     clear  # Clear the screen for better readability
#     echo "=== User Account Activity Monitoring ==="
#     check_logins "$username"
#     check_sudo_usage "$username"
#     monitor_all_ports
#     monitor_network_connections "$username"
#     sleep 5 # Check every 5 seconds
# done

# Stop monitoring (optional)
# stop_monitoring "$username"

