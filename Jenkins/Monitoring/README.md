# Jenkins Monitoring

Comprehensive monitoring, alerting, and performance optimization for Jenkins infrastructure.

## System Monitoring

### Jenkins Metrics
```bash
# Built-in monitoring endpoints
http://jenkins-server:8080/metrics/currentUser/
http://jenkins-server:8080/metrics/healthcheck/
http://jenkins-server:8080/computer/api/json

# System information
http://jenkins-server:8080/systemInfo
http://jenkins-server:8080/manage/system-properties
```

### Performance Metrics
```groovy
// Groovy script for system metrics
def jenkins = Jenkins.instance

println "=== Jenkins System Metrics ==="
println "Version: ${jenkins.getVersion()}"
println "Uptime: ${jenkins.getUptime()}"
println "Total Jobs: ${jenkins.getAllItems().size()}"
println "Active Executors: ${jenkins.getComputers().sum { it.getExecutors().size() }}"
println "Queue Length: ${jenkins.getQueue().getItems().length}"

// Memory usage
def runtime = Runtime.getRuntime()
println "Memory Used: ${(runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024} MB"
println "Memory Total: ${runtime.totalMemory() / 1024 / 1024} MB"
println "Memory Max: ${runtime.maxMemory() / 1024 / 1024} MB"
```

### Node Monitoring
```bash
#!/bin/bash
# monitor-jenkins-nodes.sh

JENKINS_URL="http://localhost:8080"
JENKINS_CLI="java -jar jenkins-cli.jar -s $JENKINS_URL"

echo "Jenkins Node Status Report"
echo "========================="

# Get node information
$JENKINS_CLI get-node master | grep -E "(displayName|offline|temporarilyOffline)"

# Check all nodes
for node in $($JENKINS_CLI list-nodes); do
    echo "Node: $node"
    $JENKINS_CLI get-node "$node" | grep -E "(offline|temporarilyOffline|numExecutors)"
    echo "---"
done
```

## Prometheus Integration

### Prometheus Plugin Setup
```bash
# Install Prometheus plugin
jenkins-cli install-plugin prometheus

# Configure metrics endpoint
# Navigate to Manage Jenkins > Configure System > Prometheus
# Enable: Collect metrics for Prometheus
# Path: /prometheus/
```

### Prometheus Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'jenkins'
    static_configs:
      - targets: ['jenkins-server:8080']
    metrics_path: '/prometheus/'
    scrape_interval: 30s
```

### Jenkins Metrics Dashboard
```yaml
# docker-compose.yml for monitoring stack
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana

volumes:
  grafana-storage:
```

## Log Monitoring

### Centralized Logging
```bash
# Configure Jenkins logging
# Manage Jenkins > System Log > Log Recorders

# Create log recorder for builds
Name: Build Logs
Loggers:
  - hudson.model.Run: ALL
  - hudson.model.AbstractBuild: ALL
```

### ELK Stack Integration
```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/lib/jenkins/logs/*.log
  fields:
    service: jenkins
    environment: production

output.elasticsearch:
  hosts: ["elasticsearch:9200"]

setup.kibana:
  host: "kibana:5601"
```

### Log Analysis Script
```bash
#!/bin/bash
# analyze-jenkins-logs.sh

LOG_DIR="/var/lib/jenkins/logs"
REPORT_FILE="/tmp/jenkins-log-report-$(date +%Y%m%d).txt"

{
    echo "Jenkins Log Analysis Report - $(date)"
    echo "===================================="
    
    echo -e "\nBuild Failures (last 24h):"
    find "$LOG_DIR" -name "*.log" -mtime -1 -exec grep -l "BUILD FAILED\|FAILURE" {} \; | wc -l
    
    echo -e "\nError Summary:"
    find "$LOG_DIR" -name "*.log" -mtime -1 -exec grep -h "ERROR" {} \; | \
    awk '{print $NF}' | sort | uniq -c | sort -nr | head -10
    
    echo -e "\nWarning Summary:"
    find "$LOG_DIR" -name "*.log" -mtime -1 -exec grep -h "WARNING" {} \; | \
    awk '{print $NF}' | sort | uniq -c | sort -nr | head -10
    
    echo -e "\nBuild Duration Analysis:"
    grep "Finished:" "$LOG_DIR"/*.log | grep "$(date '+%Y-%m-%d')" | \
    awk '{print $(NF-1)}' | sort -n | tail -10
    
} > "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"
```

## Health Checks

### Automated Health Monitoring
```bash
#!/bin/bash
# jenkins-health-check.sh

JENKINS_URL="http://localhost:8080"
ALERT_EMAIL="admin@example.com"
THRESHOLD_QUEUE=10
THRESHOLD_MEMORY=80

# Check Jenkins availability
check_availability() {
    if curl -s -f "$JENKINS_URL/login" > /dev/null; then
        echo "✓ Jenkins is accessible"
        return 0
    else
        echo "✗ Jenkins is not accessible"
        return 1
    fi
}

# Check build queue
check_queue() {
    local queue_size=$(curl -s "$JENKINS_URL/queue/api/json" | jq '.items | length')
    
    if [[ "$queue_size" -gt "$THRESHOLD_QUEUE" ]]; then
        echo "✗ Build queue too long: $queue_size items"
        return 1
    else
        echo "✓ Build queue normal: $queue_size items"
        return 0
    fi
}

# Check memory usage
check_memory() {
    local memory_script='
    def runtime = Runtime.getRuntime()
    def used = (runtime.totalMemory() - runtime.freeMemory()) / 1024 / 1024
    def total = runtime.totalMemory() / 1024 / 1024
    def percentage = (used / total) * 100
    println percentage.round(2)
    '
    
    local memory_usage=$(echo "$memory_script" | jenkins-cli groovy = 2>/dev/null)
    
    if (( $(echo "$memory_usage > $THRESHOLD_MEMORY" | bc -l) )); then
        echo "✗ High memory usage: ${memory_usage}%"
        return 1
    else
        echo "✓ Memory usage normal: ${memory_usage}%"
        return 0
    fi
}

# Main health check
main() {
    local issues=()
    
    if ! check_availability; then
        issues+=("Jenkins not accessible")
    fi
    
    if ! check_queue; then
        issues+=("Build queue overloaded")
    fi
    
    if ! check_memory; then
        issues+=("High memory usage")
    fi
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        {
            echo "Jenkins Health Alert"
            echo "==================="
            printf '%s\n' "${issues[@]}"
            echo "Time: $(date)"
        } | mail -s "Jenkins Health Alert" "$ALERT_EMAIL"
        
        exit 1
    else
        echo "✓ All health checks passed"
        exit 0
    fi
}

main
```

## Performance Optimization

### Build Performance Monitoring
```groovy
// Pipeline performance monitoring
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                script {
                    def startTime = System.currentTimeMillis()
                    
                    // Build steps here
                    sh 'make build'
                    
                    def duration = System.currentTimeMillis() - startTime
                    echo "Build duration: ${duration}ms"
                    
                    // Alert if build takes too long
                    if (duration > 300000) { // 5 minutes
                        slackSend channel: '#alerts',
                                 color: 'warning',
                                 message: "Slow build detected: ${env.JOB_NAME} took ${duration/1000}s"
                    }
                }
            }
        }
    }
}
```

### Resource Usage Optimization
```bash
#!/bin/bash
# optimize-jenkins-performance.sh

JENKINS_HOME="/var/lib/jenkins"

echo "Jenkins Performance Optimization"
echo "==============================="

# Clean old builds
echo "Cleaning old builds..."
find "$JENKINS_HOME/jobs" -name "builds" -type d | while read builds_dir; do
    find "$builds_dir" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null
done

# Clean workspace
echo "Cleaning workspaces..."
find "$JENKINS_HOME/workspace" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null

# Optimize logs
echo "Rotating logs..."
find "$JENKINS_HOME/logs" -name "*.log" -size +100M -exec gzip {} \;
find "$JENKINS_HOME/logs" -name "*.gz" -mtime +30 -delete

# Database optimization (if using H2)
echo "Optimizing database..."
java -cp "$JENKINS_HOME/war/WEB-INF/lib/h2*.jar" org.h2.tools.Defrag \
     -dir "$JENKINS_HOME" -db jenkins

echo "Optimization completed"
```

This comprehensive Jenkins monitoring guide provides enterprise-grade observability and performance management capabilities.