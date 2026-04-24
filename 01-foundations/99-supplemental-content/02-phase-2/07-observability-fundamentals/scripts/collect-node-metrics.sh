#!/bin/bash
# Node Metrics Collector
# Output: Prometheus-style format

echo "# HELP node_cpu_usage CPU usage in percent"
echo "# TYPE node_cpu_usage gauge"
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo "node_cpu_usage $CPU"

echo "# HELP node_memory_usage Memory usage in MB"
echo "# TYPE node_memory_usage gauge"
MEM=$(free -m | awk 'NR==2{print $3}')
echo "node_memory_usage $MEM"

echo "# HELP node_disk_usage Disk usage percent (root)"
echo "# TYPE node_disk_usage gauge"
DISK=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
echo "node_disk_usage $DISK"
