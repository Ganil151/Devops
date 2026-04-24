#!/bin/bash

# Health check function with return codes
check_service_health() {
    local service_name="$1"
    local timeout="${2:-30}"
    
    if systemctl is-active --quiet "$service_name"; then
        echo "✅ $service_name is running"
        return 0
    else
        echo "❌ $service_name is not running"
        return 1
    fi
}

# Resource monitoring with thresholds
check_system_resources() {
    local cpu_threshold="${1:-80}"
    local memory_threshold="${2:-85}"
    local disk_threshold="${3:-90}"
    
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    local alerts=()
    
    (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )) && alerts+=("CPU: ${cpu_usage}%")
    (( memory_usage > memory_threshold )) && alerts+=("Memory: ${memory_usage}%")
    (( disk_usage > disk_threshold )) && alerts+=("Disk: ${disk_usage}%")
    
    if [[ ${#alerts[@]} -gt 0 ]]; then
        echo "⚠️ Resource alerts: ${alerts[*]}"
        return 1
    else
        echo "✅ All resources within limits"
        return 0
    fi
}
