#!usr/bin/env bash

# Define functions for checking changes
check_new_user(){
    local new_user=$(awk -F: '$3 == 0 {print $1}' /etc/passwd | sort)
    local old_user=$(cat users.txt)

    if [[ "$(comm -13 <(echo "$new_users") <(echo "$old_users"))"]]; then
    echo "New user(s) detected:"
    echo "$(comm -13 <(echo "$new_users") <(echo "$old_users"))" >> user.txt
    echo "$(comm -13 <(echo "$new_users") <(echo "$old_users"))"
    fi
}

check_new_ports(){
    local current_ports=$(nmap -sT -oG - localhost | awk '{print $2}')
    local old_ports=$(cat ports.txt)

    if [[ "$(comm -13 <(echo "$current_ports") <(echo "$old_ports"))"]]; then
    echo "New ports(s) detected:"
    echo "$(comm -13 <(echo "$current_ports") <(echo "$old_ports"))" >> ports.txt
    echo "$(comm -13 <(echo "$current_ports") <(echo "$old_ports"))"
    fi
}

check_new_apps(){
    local current_apps=$(ps aux | awk '{print $11}' | sort | uniq)
    local old_apps=$(cat apps.txt)

    if [[ "$comm -13 <(echo "$current_apps") <(echo "$old_apps")" ]]; then
    echo "New application(s) detected:"
    echo "$(comm -13 <(echo "$current_apps") <(echo "$old_apps"))" >> apps.txt
    echo "$(comm -13 <(echo "$current_apps") <(echo "$old_apps"))"
    fi
}

check_new_network_access(){
    # Implement logic to check for new network connections (e.g., using netstat/iptables)
    # Example (simplified):
    local current_connections=$(netstat -tunlp | awk '{print $5}' | sort | uniq)
    local old_connections=$(cat connections.txt)

    if [[ "$(comm -13 <(echo "$current_connections") <(echo "$old_connections"))"]];
    echo "New network access detected:"
    echo "$(comm -13 <(echo "$current_connections") <(echo "$old_connections"))" >> connections.txt
    echo "$(comm -13 <(echo "$current_connections") <(echo "old_connections"))"
}

# Create initial files to store previous states
touch users.txt ports.txt apps.txt connections.txt

# Main loop 
while true; do 
  check_new_user
  check_new_ports
  check_new_apps
  check_new_networks_access
  sleep 60 # Check every 60 seconds
done