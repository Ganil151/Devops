#!/bin/bash

set -eou pipefail 

check_services_health() {
	local service_name="$1"
	local timeout="${2:-30}"

	if systemctl is-active --quiet "$service_name"; then
		echo "$service_name is running"
		return 0 
	else
		echo "$service_name is not running"
		return 1
	fi
}

check_system_resources() {
	local cpu_threshold="${1:-80}"
	local memory_threshold="${2:-85}"
	local disk_threshold="${3:-90}"

	local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
	local memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
	local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)

	local alert=()

	(( cpu_usage > cpu_threshold )) && alert+=("CPU usage is at ${cpu_usage}%")
	(( memory_usage > memory_threshold )) && alert+=("Memory usage is at ${memory_usage}%")
	(( disk_usage > disk_threshold )) && alert+=("Disk usage is at ${disk_usage}%")

	if [[ ${#alert[@]} -gt 0 ]]; then
		echo "Resource Alerts: ${alert[*]}"
		return 1
	else
		echo "All system resources are within acceptable limits."
		return 0
	fi
}



