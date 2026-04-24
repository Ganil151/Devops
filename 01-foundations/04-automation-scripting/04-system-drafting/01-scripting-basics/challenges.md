# 📜 Finally Scripting - Hands-On Challenges

## 📚 **Challenge Overview**
Master shell script creation through 10 progressive challenges that build real-world automation tools.

---

## 🟢 **BEGINNER CHALLENGES (1-3)**

### **Challenge 1: Your First Script**
**Scenario**: Create a system information script for server documentation.

**Task**:
```bash
# Create your first script
cat > ~/first_script.sh << 'EOF'
#!/bin/bash
echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Current Date: $(date)"
echo "Uptime: $(uptime)"
echo "Disk Usage:"
df -h | head -5
EOF

chmod +x ~/first_script.sh
./first_script.sh
```

**Expected Output**:
```
=== System Information ===
Hostname: devops-server
Current User: user
Current Date: Fri Jan 11 10:00:00 UTC 2026
Uptime: 10:00:01 up 1 day, 2:34, 1 user, load average: 0.1, 0.2, 0.3
Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G  5.5G   14G  30% /
```

**Real-World Application**: System information scripts are essential for server monitoring and documentation.

---

### **Challenge 2: Script with Variables**
**Scenario**: Create a backup script that uses variables for flexibility.

**Task**:
```bash
cat > ~/backup_script.sh << 'EOF'
#!/bin/bash

# Variables
SOURCE_DIR="$HOME/Documents"
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$DATE.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create backup
echo "Creating backup of $SOURCE_DIR..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" "$SOURCE_DIR" 2>/dev/null || echo "Backup created (simulated)"

echo "Backup completed: $BACKUP_DIR/$BACKUP_NAME"
ls -lh "$BACKUP_DIR" 2>/dev/null || echo "Backup directory contents would be listed here"
EOF

chmod +x ~/backup_script.sh
./backup_script.sh
```

**Expected Output**:
```
Creating backup of /home/user/Documents...
Backup completed: /home/user/backups/backup_20260111_100000.tar.gz
```

**Real-World Application**: Backup scripts with variables allow easy customization for different environments.

---

### **Challenge 3: User Input and Validation**
**Scenario**: Create an interactive deployment script that validates user input.

**Task**:
```bash
cat > ~/deploy_interactive.sh << 'EOF'
#!/bin/bash

echo "=== Application Deployment Script ==="

# Get application name
read -p "Enter application name: " APP_NAME
if [[ -z "$APP_NAME" ]]; then
    echo "Error: Application name cannot be empty"
    exit 1
fi

# Get environment
echo "Available environments:"
echo "1) development"
echo "2) staging"
echo "3) production"
read -p "Select environment (1-3): " ENV_CHOICE

case $ENV_CHOICE in
    1) ENVIRONMENT="development" ;;
    2) ENVIRONMENT="staging" ;;
    3) ENVIRONMENT="production" ;;
    *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# Confirmation for production
if [[ "$ENVIRONMENT" == "production" ]]; then
    read -p "WARNING: Deploying to PRODUCTION. Continue? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Deployment cancelled."
        exit 0
    fi
fi

echo "Deploying $APP_NAME to $ENVIRONMENT environment..."
echo "Deployment completed successfully!"
EOF

chmod +x ~/deploy_interactive.sh
echo -e "myapp\n2\n" | ./deploy_interactive.sh
```

**Expected Output**:
```
=== Application Deployment Script ===
Enter application name: Available environments:
1) development
2) staging
3) production
Select environment (1-3): Deploying myapp to staging environment...
Deployment completed successfully!
```

**Real-World Application**: Interactive scripts with validation prevent deployment errors and ensure proper confirmation for critical operations.

---

## 🟡 **INTERMEDIATE CHALLENGES (4-6)**

### **Challenge 4: Functions and Error Handling**
**Scenario**: Create a modular script with functions for log management.

**Task**:
```bash
cat > ~/log_manager.sh << 'EOF'
#!/bin/bash

# Global variables
LOG_DIR="/var/log"
SCRIPT_NAME=$(basename "$0")

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR" "This script must be run as root for log access"
        return 1
    fi
    return 0
}

# Function to analyze log files
analyze_logs() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        log_message "ERROR" "Log file $log_file not found"
        return 1
    fi
    
    log_message "INFO" "Analyzing $log_file"
    
    # Simulate log analysis
    echo "Log Analysis Results:"
    echo "- Total lines: $(wc -l < "$log_file" 2>/dev/null || echo "N/A")"
    echo "- Error count: $(grep -c -i error "$log_file" 2>/dev/null || echo "0")"
    echo "- Warning count: $(grep -c -i warning "$log_file" 2>/dev/null || echo "0")"
    
    return 0
}

# Function to rotate logs
rotate_logs() {
    local log_file="$1"
    local max_size="$2"
    
    if [[ ! -f "$log_file" ]]; then
        log_message "WARNING" "Log file $log_file not found for rotation"
        return 1
    fi
    
    local file_size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo "0")
    
    if [[ $file_size -gt $max_size ]]; then
        log_message "INFO" "Rotating $log_file (size: $file_size bytes)"
        # Simulate rotation
        echo "Log rotated: $log_file -> $log_file.1"
        return 0
    else
        log_message "INFO" "Log rotation not needed for $log_file"
        return 0
    fi
}

# Main execution
main() {
    log_message "INFO" "Starting $SCRIPT_NAME"
    
    # Create test log file for demonstration
    TEST_LOG="/tmp/test.log"
    echo "2026-01-11 10:00:01 INFO Application started" > "$TEST_LOG"
    echo "2026-01-11 10:00:02 ERROR Database connection failed" >> "$TEST_LOG"
    echo "2026-01-11 10:00:03 WARNING High memory usage detected" >> "$TEST_LOG"
    
    # Analyze the test log
    if analyze_logs "$TEST_LOG"; then
        log_message "INFO" "Log analysis completed successfully"
    else
        log_message "ERROR" "Log analysis failed"
        exit 1
    fi
    
    # Test log rotation
    rotate_logs "$TEST_LOG" 1000
    
    log_message "INFO" "$SCRIPT_NAME completed"
}

# Run main function
main "$@"
EOF

chmod +x ~/log_manager.sh
./log_manager.sh
```

**Expected Output**:
```
[2026-01-11 10:00:00] [INFO] Starting log_manager.sh
[2026-01-11 10:00:00] [INFO] Analyzing /tmp/test.log
Log Analysis Results:
- Total lines: 3
- Error count: 1
- Warning count: 1
[2026-01-11 10:00:00] [INFO] Log analysis completed successfully
[2026-01-11 10:00:00] [INFO] Log rotation not needed for /tmp/test.log
[2026-01-11 10:00:00] [INFO] log_manager.sh completed
```

**Real-World Application**: Modular scripts with functions and error handling are essential for maintainable automation in production environments.

---

### **Challenge 5: Configuration File Processing**
**Scenario**: Create a script that reads configuration files and manages application settings.

**Task**:
```bash
# Create configuration file
cat > ~/app.conf << 'EOF'
# Application Configuration
APP_NAME=MyWebApp
APP_VERSION=1.2.3
APP_PORT=8080
APP_ENV=production
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=myapp_db
LOG_LEVEL=INFO
MAX_CONNECTIONS=100
ENABLE_SSL=true
EOF

# Create configuration processor script
cat > ~/config_processor.sh << 'EOF'
#!/bin/bash

CONFIG_FILE="$HOME/app.conf"
PROCESSED_CONFIG="/tmp/processed_config.sh"

# Function to validate configuration
validate_config() {
    local errors=0
    
    echo "=== Configuration Validation ==="
    
    # Check required variables
    local required_vars=("APP_NAME" "APP_VERSION" "APP_PORT" "DATABASE_HOST")
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "ERROR: Required variable $var is not set"
            ((errors++))
        else
            echo "✓ $var is set to: ${!var}"
        fi
    done
    
    # Validate port number
    if [[ -n "$APP_PORT" ]] && ! [[ "$APP_PORT" =~ ^[0-9]+$ ]]; then
        echo "ERROR: APP_PORT must be a number"
        ((errors++))
    fi
    
    # Validate boolean values
    if [[ -n "$ENABLE_SSL" ]] && [[ "$ENABLE_SSL" != "true" && "$ENABLE_SSL" != "false" ]]; then
        echo "ERROR: ENABLE_SSL must be true or false"
        ((errors++))
    fi
    
    return $errors
}

# Function to process configuration
process_config() {
    echo "=== Processing Configuration ==="
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "ERROR: Configuration file $CONFIG_FILE not found"
        return 1
    fi
    
    # Source the configuration file
    source "$CONFIG_FILE"
    
    # Validate configuration
    if ! validate_config; then
        echo "Configuration validation failed"
        return 1
    fi
    
    # Generate processed configuration
    cat > "$PROCESSED_CONFIG" << EOF
#!/bin/bash
# Processed configuration - Generated on $(date)

export APP_NAME="$APP_NAME"
export APP_VERSION="$APP_VERSION"
export APP_PORT="$APP_PORT"
export APP_ENV="$APP_ENV"
export DATABASE_URL="postgresql://$DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME"
export LOG_LEVEL="$LOG_LEVEL"
export MAX_CONNECTIONS="$MAX_CONNECTIONS"
export ENABLE_SSL="$ENABLE_SSL"

# Derived configurations
if [[ "$APP_ENV" == "production" ]]; then
    export DEBUG_MODE="false"
    export LOG_FILE="/var/log/\$APP_NAME.log"
else
    export DEBUG_MODE="true"
    export LOG_FILE="/tmp/\$APP_NAME.log"
fi

echo "Configuration loaded for \$APP_NAME v\$APP_VERSION"
EOF
    
    chmod +x "$PROCESSED_CONFIG"
    echo "Processed configuration saved to: $PROCESSED_CONFIG"
    
    return 0
}

# Function to display configuration summary
show_summary() {
    echo "=== Configuration Summary ==="
    echo "Application: $APP_NAME v$APP_VERSION"
    echo "Environment: $APP_ENV"
    echo "Port: $APP_PORT"
    echo "Database: $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME"
    echo "SSL Enabled: $ENABLE_SSL"
    echo "Max Connections: $MAX_CONNECTIONS"
}

# Main execution
main() {
    echo "=== Application Configuration Processor ==="
    
    if process_config; then
        show_summary
        echo ""
        echo "Testing processed configuration:"
        source "$PROCESSED_CONFIG"
    else
        echo "Configuration processing failed"
        exit 1
    fi
}

main "$@"
EOF

chmod +x ~/config_processor.sh
./config_processor.sh
```

**Expected Output**:
```
=== Application Configuration Processor ===
=== Processing Configuration ===
=== Configuration Validation ===
✓ APP_NAME is set to: MyWebApp
✓ APP_VERSION is set to: 1.2.3
✓ APP_PORT is set to: 8080
✓ DATABASE_HOST is set to: localhost
Processed configuration saved to: /tmp/processed_config.sh
=== Configuration Summary ===
Application: MyWebApp v1.2.3
Environment: production
Port: 8080
Database: localhost:5432/myapp_db
SSL Enabled: true
Max Connections: 100

Testing processed configuration:
Configuration loaded for MyWebApp v1.2.3
```

**Real-World Application**: Configuration processing scripts enable environment-specific deployments and centralized configuration management.

---

### **Challenge 6: Service Management Script**
**Scenario**: Create a comprehensive service management script for application lifecycle.

**Task**:
```bash
cat > ~/service_manager.sh << 'EOF'
#!/bin/bash

SERVICE_NAME="myapp"
PID_FILE="/tmp/$SERVICE_NAME.pid"
LOG_FILE="/tmp/$SERVICE_NAME.log"
CONFIG_FILE="$HOME/app.conf"

# Function to start service
start_service() {
    echo "Starting $SERVICE_NAME..."
    
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Service is already running (PID: $pid)"
            return 1
        else
            echo "Removing stale PID file"
            rm -f "$PID_FILE"
        fi
    fi
    
    # Simulate service startup
    echo "Service startup simulation - would start actual service here"
    echo $$ > "$PID_FILE"
    echo "$(date): Service started" >> "$LOG_FILE"
    echo "Service started successfully (PID: $$)"
    
    return 0
}

# Function to stop service
stop_service() {
    echo "Stopping $SERVICE_NAME..."
    
    if [[ ! -f "$PID_FILE" ]]; then
        echo "Service is not running (no PID file found)"
        return 1
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "Service is not running (process not found)"
        rm -f "$PID_FILE"
        return 1
    fi
    
    # Simulate service shutdown
    echo "Service shutdown simulation - would stop actual service here"
    rm -f "$PID_FILE"
    echo "$(date): Service stopped" >> "$LOG_FILE"
    echo "Service stopped successfully"
    
    return 0
}

# Function to check service status
check_status() {
    echo "Checking $SERVICE_NAME status..."
    
    if [[ ! -f "$PID_FILE" ]]; then
        echo "Status: STOPPED (no PID file)"
        return 1
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if kill -0 "$pid" 2>/dev/null; then
        echo "Status: RUNNING (PID: $pid)"
        echo "Uptime: $(ps -o etime= -p $pid 2>/dev/null | tr -d ' ' || echo 'N/A')"
        return 0
    else
        echo "Status: STOPPED (process not found)"
        rm -f "$PID_FILE"
        return 1
    fi
}

# Function to restart service
restart_service() {
    echo "Restarting $SERVICE_NAME..."
    stop_service
    sleep 2
    start_service
}

# Function to show logs
show_logs() {
    local lines="${1:-20}"
    echo "Showing last $lines lines of $SERVICE_NAME logs:"
    
    if [[ -f "$LOG_FILE" ]]; then
        tail -n "$lines" "$LOG_FILE"
    else
        echo "No log file found at $LOG_FILE"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 {start|stop|restart|status|logs [lines]}"
    echo ""
    echo "Commands:"
    echo "  start    - Start the service"
    echo "  stop     - Stop the service"
    echo "  restart  - Restart the service"
    echo "  status   - Check service status"
    echo "  logs     - Show service logs (default: 20 lines)"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs 50"
}

# Main execution
main() {
    local command="$1"
    
    case "$command" in
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        restart)
            restart_service
            ;;
        status)
            check_status
            ;;
        logs)
            show_logs "$2"
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
EOF

chmod +x ~/service_manager.sh

# Test the service manager
echo "Testing service manager:"
./service_manager.sh start
./service_manager.sh status
./service_manager.sh logs
./service_manager.sh stop
```

**Expected Output**:
```
Testing service manager:
Starting myapp...
Service startup simulation - would start actual service here
Service started successfully (PID: 12345)
Checking myapp status...
Status: RUNNING (PID: 12345)
Showing last 20 lines of myapp logs:
Fri Jan 11 10:00:00 UTC 2026: Service started
Stopping myapp...
Service shutdown simulation - would stop actual service here
Service stopped successfully
```

**Real-World Application**: Service management scripts provide standardized interfaces for application lifecycle management in production environments.

---

## 🔴 **ADVANCED CHALLENGES (7-8)**

### **Challenge 7: Multi-Server Deployment Script**
**Scenario**: Create a script that deploys applications across multiple servers with rollback capability.

**Task**:
```bash
cat > ~/multi_deploy.sh << 'EOF'
#!/bin/bash

# Configuration
SERVERS=("server1.example.com" "server2.example.com" "server3.example.com")
APP_NAME="myapp"
APP_VERSION="$1"
DEPLOY_USER="deploy"
DEPLOY_PATH="/opt/$APP_NAME"
BACKUP_PATH="/opt/backups"
LOG_FILE="/tmp/deployment_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Function to execute command on remote server
remote_exec() {
    local server="$1"
    local command="$2"
    
    log "Executing on $server: $command"
    
    # Simulate SSH execution
    echo "SSH simulation: ssh $DEPLOY_USER@$server '$command'"
    
    # For demonstration, simulate success/failure
    if [[ "$server" == "server2.example.com" && "$command" == *"deploy"* ]]; then
        log "ERROR: Deployment failed on $server"
        return 1
    else
        log "SUCCESS: Command completed on $server"
        return 0
    fi
}

# Function to backup current version
backup_version() {
    local server="$1"
    
    log "Creating backup on $server"
    
    local backup_cmd="mkdir -p $BACKUP_PATH && cp -r $DEPLOY_PATH $BACKUP_PATH/${APP_NAME}_$(date +%Y%m%d_%H%M%S)"
    
    if remote_exec "$server" "$backup_cmd"; then
        log "Backup created successfully on $server"
        return 0
    else
        log "ERROR: Backup failed on $server"
        return 1
    fi
}

# Function to deploy application
deploy_app() {
    local server="$1"
    local version="$2"
    
    log "Deploying $APP_NAME v$version to $server"
    
    local deploy_cmd="cd $DEPLOY_PATH && ./deploy.sh $version"
    
    if remote_exec "$server" "$deploy_cmd"; then
        log "Deployment successful on $server"
        return 0
    else
        log "ERROR: Deployment failed on $server"
        return 1
    fi
}

# Function to rollback deployment
rollback_deployment() {
    local server="$1"
    
    log "Rolling back deployment on $server"
    
    local rollback_cmd="cd $BACKUP_PATH && cp -r \$(ls -t | head -1)/* $DEPLOY_PATH/"
    
    if remote_exec "$server" "$rollback_cmd"; then
        log "Rollback successful on $server"
        return 0
    else
        log "ERROR: Rollback failed on $server"
        return 1
    fi
}

# Function to verify deployment
verify_deployment() {
    local server="$1"
    
    log "Verifying deployment on $server"
    
    local verify_cmd="curl -f http://$server:8080/health || systemctl is-active $APP_NAME"
    
    if remote_exec "$server" "$verify_cmd"; then
        log "Verification successful on $server"
        return 0
    else
        log "ERROR: Verification failed on $server"
        return 1
    fi
}

# Main deployment function
main_deploy() {
    local version="$1"
    local failed_servers=()
    local successful_servers=()
    
    if [[ -z "$version" ]]; then
        echo "Usage: $0 <version>"
        echo "Example: $0 1.2.3"
        exit 1
    fi
    
    log "Starting deployment of $APP_NAME v$version to ${#SERVERS[@]} servers"
    
    # Phase 1: Backup current version on all servers
    log "Phase 1: Creating backups"
    for server in "${SERVERS[@]}"; do
        if ! backup_version "$server"; then
            log "ERROR: Backup failed on $server, aborting deployment"
            exit 1
        fi
    done
    
    # Phase 2: Deploy to all servers
    log "Phase 2: Deploying application"
    for server in "${SERVERS[@]}"; do
        if deploy_app "$server" "$version"; then
            successful_servers+=("$server")
        else
            failed_servers+=("$server")
        fi
    done
    
    # Phase 3: Verify deployments
    log "Phase 3: Verifying deployments"
    for server in "${successful_servers[@]}"; do
        if ! verify_deployment "$server"; then
            log "Verification failed on $server, adding to failed list"
            failed_servers+=("$server")
            successful_servers=("${successful_servers[@]/$server}")
        fi
    done
    
    # Phase 4: Handle failures
    if [[ ${#failed_servers[@]} -gt 0 ]]; then
        log "Deployment failed on servers: ${failed_servers[*]}"
        log "Rolling back failed servers..."
        
        for server in "${failed_servers[@]}"; do
            rollback_deployment "$server"
        done
        
        log "Deployment completed with failures. Check logs: $LOG_FILE"
        exit 1
    else
        log "Deployment successful on all servers!"
        log "Deployment log: $LOG_FILE"
        exit 0
    fi
}

# Execute main function
main_deploy "$@"
EOF

chmod +x ~/multi_deploy.sh
./multi_deploy.sh 1.2.3
```

**Expected Output**:
```
[2026-01-11 10:00:00] Starting deployment of myapp v1.2.3 to 3 servers
[2026-01-11 10:00:00] Phase 1: Creating backups
[2026-01-11 10:00:00] Creating backup on server1.example.com
[2026-01-11 10:00:00] SUCCESS: Command completed on server1.example.com
[2026-01-11 10:00:00] Phase 2: Deploying application
[2026-01-11 10:00:00] ERROR: Deployment failed on server2.example.com
[2026-01-11 10:00:00] Deployment failed on servers: server2.example.com
[2026-01-11 10:00:00] Rolling back failed servers...
[2026-01-11 10:00:00] Deployment completed with failures. Check logs: /tmp/deployment_20260111_100000.log
```

**Real-World Application**: Multi-server deployment scripts with rollback capabilities are essential for maintaining high availability during application updates.

---

### **Challenge 8: Infrastructure Monitoring Script**
**Scenario**: Create a comprehensive monitoring script that checks system health and sends alerts.

**Task**:
```bash
cat > ~/infrastructure_monitor.sh << 'EOF'
#!/bin/bash

# Configuration
ALERT_EMAIL="admin@example.com"
LOG_FILE="/tmp/monitoring_$(date +%Y%m%d).log"
ALERT_LOG="/tmp/alerts_$(date +%Y%m%d).log"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
LOAD_THRESHOLD=2.0

# Monitoring functions
check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d',' -f1)
    cpu_usage=${cpu_usage%.*}  # Remove decimal part
    
    echo "CPU Usage: ${cpu_usage}%"
    
    if [[ $cpu_usage -gt $CPU_THRESHOLD ]]; then
        send_alert "HIGH CPU USAGE" "CPU usage is at ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)"
        return 1
    fi
    
    return 0
}

check_memory_usage() {
    local memory_info=$(free | grep Mem)
    local total=$(echo $memory_info | awk '{print $2}')
    local used=$(echo $memory_info | awk '{print $3}')
    local memory_usage=$((used * 100 / total))
    
    echo "Memory Usage: ${memory_usage}%"
    
    if [[ $memory_usage -gt $MEMORY_THRESHOLD ]]; then
        send_alert "HIGH MEMORY USAGE" "Memory usage is at ${memory_usage}% (threshold: ${MEMORY_THRESHOLD}%)"
        return 1
    fi
    
    return 0
}

check_disk_usage() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    echo "Disk Usage: ${disk_usage}%"
    
    if [[ $disk_usage -gt $DISK_THRESHOLD ]]; then
        send_alert "HIGH DISK USAGE" "Disk usage is at ${disk_usage}% (threshold: ${DISK_THRESHOLD}%)"
        return 1
    fi
    
    return 0
}

check_load_average() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | cut -d',' -f1)
    
    echo "Load Average: $load_avg"
    
    # Compare load average (simplified comparison)
    if (( $(echo "$load_avg > $LOAD_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        send_alert "HIGH LOAD AVERAGE" "Load average is $load_avg (threshold: $LOAD_THRESHOLD)"
        return 1
    fi
    
    return 0
}

check_services() {
    local services=("ssh" "cron")
    local failed_services=()
    
    echo "Checking critical services..."
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "✓ $service is running"
        else
            echo "✗ $service is not running"
            failed_services+=("$service")
        fi
    done
    
    if [[ ${#failed_services[@]} -gt 0 ]]; then
        send_alert "SERVICE FAILURE" "Services not running: ${failed_services[*]}"
        return 1
    fi
    
    return 0
}

check_network_connectivity() {
    local test_hosts=("8.8.8.8" "google.com")
    local failed_hosts=()
    
    echo "Checking network connectivity..."
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 5 "$host" >/dev/null 2>&1; then
            echo "✓ $host is reachable"
        else
            echo "✗ $host is not reachable"
            failed_hosts+=("$host")
        fi
    done
    
    if [[ ${#failed_hosts[@]} -gt 0 ]]; then
        send_alert "NETWORK CONNECTIVITY" "Cannot reach: ${failed_hosts[*]}"
        return 1
    fi
    
    return 0
}

send_alert() {
    local alert_type="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local alert_msg="[$timestamp] ALERT: $alert_type - $message"
    
    echo "$alert_msg" | tee -a "$ALERT_LOG"
    
    # Simulate email sending
    echo "Simulating email to $ALERT_EMAIL:"
    echo "Subject: [ALERT] $alert_type"
    echo "Body: $message"
    echo "Timestamp: $timestamp"
    echo "---"
}

generate_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat << EOF
=== INFRASTRUCTURE MONITORING REPORT ===
Generated: $timestamp
Hostname: $(hostname)
Uptime: $(uptime)

=== SYSTEM METRICS ===
$(check_cpu_usage)
$(check_memory_usage)
$(check_disk_usage)
$(check_load_average)

=== SERVICE STATUS ===
$(check_services)

=== NETWORK STATUS ===
$(check_network_connectivity)

=== RECENT ALERTS ===
$(tail -5 "$ALERT_LOG" 2>/dev/null || echo "No recent alerts")

Report saved to: $LOG_FILE
EOF
}

# Main monitoring function
main() {
    local mode="${1:-check}"
    local issues=0
    
    case "$mode" in
        "check")
            echo "=== Infrastructure Health Check ==="
            echo "Timestamp: $(date)"
            echo ""
            
            check_cpu_usage || ((issues++))
            check_memory_usage || ((issues++))
            check_disk_usage || ((issues++))
            check_load_average || ((issues++))
            check_services || ((issues++))
            check_network_connectivity || ((issues++))
            
            echo ""
            if [[ $issues -eq 0 ]]; then
                echo "✓ All systems healthy"
            else
                echo "⚠ $issues issues detected"
            fi
            ;;
        "report")
            generate_report | tee "$LOG_FILE"
            ;;
        "alerts")
            echo "=== Recent Alerts ==="
            if [[ -f "$ALERT_LOG" ]]; then
                cat "$ALERT_LOG"
            else
                echo "No alerts found"
            fi
            ;;
        *)
            echo "Usage: $0 {check|report|alerts}"
            echo ""
            echo "Commands:"
            echo "  check   - Perform health check"
            echo "  report  - Generate detailed report"
            echo "  alerts  - Show recent alerts"
            exit 1
            ;;
    esac
}

main "$@"
EOF

chmod +x ~/infrastructure_monitor.sh
./infrastructure_monitor.sh check
```

**Expected Output**:
```
=== Infrastructure Health Check ===
Timestamp: Fri Jan 11 10:00:00 UTC 2026

CPU Usage: 15%
Memory Usage: 45%
Disk Usage: 25%
Load Average: 0.5
Checking critical services...
✓ ssh is running
✓ cron is running
Checking network connectivity...
✓ 8.8.8.8 is reachable
✓ google.com is reachable

✓ All systems healthy
```

**Real-World Application**: Infrastructure monitoring scripts provide automated health checks and alerting for production systems, enabling proactive issue resolution.

---

## 🏆 **CHALLENGE CHALLENGES (9-10)**

### **Challenge 9: CI/CD Pipeline Script**
**Scenario**: Create a complete CI/CD pipeline script that builds, tests, and deploys applications.

**Task**:
```bash
cat > ~/cicd_pipeline.sh << 'EOF'
#!/bin/bash

# Pipeline configuration
PROJECT_NAME="myapp"
BUILD_DIR="/tmp/build_$$"
ARTIFACT_DIR="/tmp/artifacts"
TEST_RESULTS_DIR="/tmp/test_results"
DOCKER_REGISTRY="registry.example.com"
ENVIRONMENTS=("development" "staging" "production")

# Pipeline functions
setup_environment() {
    echo "=== Setting up build environment ==="
    
    mkdir -p "$BUILD_DIR" "$ARTIFACT_DIR" "$TEST_RESULTS_DIR"
    
    echo "Build directory: $BUILD_DIR"
    echo "Artifact directory: $ARTIFACT_DIR"
    echo "Test results directory: $TEST_RESULTS_DIR"
    
    return 0
}

checkout_code() {
    local branch="${1:-main}"
    
    echo "=== Checking out code ==="
    echo "Branch: $branch"
    
    # Simulate git checkout
    echo "Simulating: git clone -b $branch https://github.com/company/$PROJECT_NAME.git $BUILD_DIR"
    
    # Create mock project structure
    mkdir -p "$BUILD_DIR"/{src,tests,config}
    echo "console.log('Hello World');" > "$BUILD_DIR/src/app.js"
    echo "test('should work', () => { expect(true).toBe(true); });" > "$BUILD_DIR/tests/app.test.js"
    echo '{"name": "myapp", "version": "1.0.0"}' > "$BUILD_DIR/package.json"
    
    echo "Code checkout completed"
    return 0
}

run_tests() {
    echo "=== Running tests ==="
    
    cd "$BUILD_DIR" || return 1
    
    # Simulate test execution
    echo "Running unit tests..."
    echo "✓ app.test.js - 5 tests passed"
    
    echo "Running integration tests..."
    echo "✓ integration.test.js - 3 tests passed"
    
    echo "Running security tests..."
    echo "✓ No security vulnerabilities found"
    
    # Generate test report
    cat > "$TEST_RESULTS_DIR/test_report.xml" << 'TESTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<testsuites tests="8" failures="0" errors="0">
  <testsuite name="unit" tests="5" failures="0" errors="0"/>
  <testsuite name="integration" tests="3" failures="0" errors="0"/>
</testsuites>
TESTEOF
    
    echo "All tests passed!"
    return 0
}

build_application() {
    echo "=== Building application ==="
    
    cd "$BUILD_DIR" || return 1
    
    # Simulate build process
    echo "Installing dependencies..."
    echo "Simulating: npm install"
    
    echo "Building application..."
    echo "Simulating: npm run build"
    
    echo "Creating distribution package..."
    tar -czf "$ARTIFACT_DIR/${PROJECT_NAME}-$(date +%Y%m%d-%H%M%S).tar.gz" -C "$BUILD_DIR" .
    
    echo "Build completed successfully"
    return 0
}

build_docker_image() {
    local version="$1"
    
    echo "=== Building Docker image ==="
    
    # Create Dockerfile
    cat > "$BUILD_DIR/Dockerfile" << 'DOCKEREOF'
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "src/app.js"]
DOCKEREOF
    
    echo "Building Docker image: $PROJECT_NAME:$version"
    echo "Simulating: docker build -t $PROJECT_NAME:$version ."
    
    echo "Tagging for registry: $DOCKER_REGISTRY/$PROJECT_NAME:$version"
    echo "Simulating: docker tag $PROJECT_NAME:$version $DOCKER_REGISTRY/$PROJECT_NAME:$version"
    
    echo "Docker image built successfully"
    return 0
}

deploy_to_environment() {
    local environment="$1"
    local version="$2"
    
    echo "=== Deploying to $environment ==="
    
    case "$environment" in
        "development")
            echo "Deploying to development cluster..."
            echo "Simulating: kubectl apply -f k8s/dev/ --namespace=dev"
            ;;
        "staging")
            echo "Deploying to staging cluster..."
            echo "Simulating: kubectl apply -f k8s/staging/ --namespace=staging"
            echo "Running smoke tests..."
            echo "✓ Smoke tests passed"
            ;;
        "production")
            echo "Deploying to production cluster..."
            echo "Simulating: kubectl apply -f k8s/prod/ --namespace=prod"
            echo "Performing health checks..."
            echo "✓ Health checks passed"
            echo "Updating load balancer..."
            echo "✓ Load balancer updated"
            ;;
    esac
    
    echo "Deployment to $environment completed"
    return 0
}

cleanup() {
    echo "=== Cleaning up ==="
    
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
        echo "Build directory cleaned"
    fi
    
    echo "Cleanup completed"
}

# Main pipeline execution
run_pipeline() {
    local branch="${1:-main}"
    local target_env="${2:-development}"
    local version="$(date +%Y%m%d-%H%M%S)"
    
    echo "=== CI/CD Pipeline Started ==="
    echo "Project: $PROJECT_NAME"
    echo "Branch: $branch"
    echo "Target Environment: $target_env"
    echo "Version: $version"
    echo "Timestamp: $(date)"
    echo ""
    
    # Pipeline stages
    if ! setup_environment; then
        echo "❌ Environment setup failed"
        exit 1
    fi
    
    if ! checkout_code "$branch"; then
        echo "❌ Code checkout failed"
        cleanup
        exit 1
    fi
    
    if ! run_tests; then
        echo "❌ Tests failed"
        cleanup
        exit 1
    fi
    
    if ! build_application; then
        echo "❌ Build failed"
        cleanup
        exit 1
    fi
    
    if ! build_docker_image "$version"; then
        echo "❌ Docker build failed"
        cleanup
        exit 1
    fi
    
    if ! deploy_to_environment "$target_env" "$version"; then
        echo "❌ Deployment failed"
        cleanup
        exit 1
    fi
    
    cleanup
    
    echo ""
    echo "=== Pipeline Completed Successfully ==="
    echo "✅ All stages passed"
    echo "🚀 $PROJECT_NAME v$version deployed to $target_env"
    echo "📊 Test results: $TEST_RESULTS_DIR/test_report.xml"
    echo "📦 Artifacts: $ARTIFACT_DIR/"
}

# Usage function
show_usage() {
    echo "Usage: $0 [branch] [environment]"
    echo ""
    echo "Parameters:"
    echo "  branch      - Git branch to build (default: main)"
    echo "  environment - Target environment (default: development)"
    echo ""
    echo "Available environments: ${ENVIRONMENTS[*]}"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build main branch, deploy to development"
    echo "  $0 feature/new-ui     # Build feature branch, deploy to development"
    echo "  $0 main staging       # Build main branch, deploy to staging"
    echo "  $0 release/v1.2 production  # Build release branch, deploy to production"
}

# Main execution
case "$1" in
    "-h"|"--help"|"help")
        show_usage
        ;;
    *)
        run_pipeline "$1" "$2"
        ;;
esac
EOF

chmod +x ~/cicd_pipeline.sh
./cicd_pipeline.sh main development
```

**Expected Output**:
```
=== CI/CD Pipeline Started ===
Project: myapp
Branch: main
Target Environment: development
Version: 20260111-100000
Timestamp: Fri Jan 11 10:00:00 UTC 2026

=== Setting up build environment ===
Build directory: /tmp/build_12345
Artifact directory: /tmp/artifacts
Test results directory: /tmp/test_results
=== Checking out code ===
Branch: main
Code checkout completed
=== Running tests ===
Running unit tests...
✓ app.test.js - 5 tests passed
All tests passed!
=== Building application ===
Building application...
Build completed successfully
=== Building Docker image ===
Building Docker image: myapp:20260111-100000
Docker image built successfully
=== Deploying to development ===
Deploying to development cluster...
Deployment to development completed
=== Cleaning up ===
Build directory cleaned
Cleanup completed

=== Pipeline Completed Successfully ===
✅ All stages passed
🚀 myapp v20260111-100000 deployed to development
```

**Real-World Application**: Complete CI/CD pipeline scripts automate the entire software delivery process from code commit to production deployment.

---

### **Challenge 10: Enterprise Automation Framework**
**Scenario**: Create a comprehensive automation framework that can execute multiple types of operations with logging, error handling, and reporting.

**Task**:
```bash
cat > ~/automation_framework.sh << 'EOF'
#!/bin/bash

# Framework configuration
FRAMEWORK_VERSION="1.0.0"
CONFIG_DIR="$HOME/.automation"
LOG_DIR="$CONFIG_DIR/logs"
TASK_DIR="$CONFIG_DIR/tasks"
REPORT_DIR="$CONFIG_DIR/reports"

# Initialize framework
init_framework() {
    echo "Initializing Automation Framework v$FRAMEWORK_VERSION"
    
    mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$TASK_DIR" "$REPORT_DIR"
    
    # Create default configuration
    cat > "$CONFIG_DIR/config.yaml" << 'YAMLEOF'
framework:
  version: 1.0.0
  log_level: INFO
  max_parallel_tasks: 5
  timeout: 300

notifications:
  email: admin@example.com
  slack_webhook: https://hooks.slack.com/services/...

environments:
  development:
    servers: ["dev1.example.com", "dev2.example.com"]
  staging:
    servers: ["stage1.example.com", "stage2.example.com"]
  production:
    servers: ["prod1.example.com", "prod2.example.com", "prod3.example.com"]
YAMLEOF
    
    echo "Framework initialized at $CONFIG_DIR"
}

# Logging system
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/automation_$(date +%Y%m%d).log"
    
    echo "[$timestamp] [$level] $message" | tee -a "$log_file"
}

# Task execution engine
execute_task() {
    local task_name="$1"
    local environment="$2"
    local task_file="$TASK_DIR/$task_name.sh"
    
    log "INFO" "Starting task: $task_name in $environment"
    
    if [[ ! -f "$task_file" ]]; then
        log "ERROR" "Task file not found: $task_file"
        return 1
    fi
    
    # Set environment variables
    export AUTOMATION_ENV="$environment"
    export AUTOMATION_TASK="$task_name"
    export AUTOMATION_LOG_DIR="$LOG_DIR"
    
    # Execute task with timeout
    if timeout 300 bash "$task_file"; then
        log "INFO" "Task completed successfully: $task_name"
        return 0
    else
        log "ERROR" "Task failed or timed out: $task_name"
        return 1
    fi
}

# Parallel task execution
execute_parallel_tasks() {
    local tasks=("$@")
    local pids=()
    local results=()
    
    log "INFO" "Starting ${#tasks[@]} tasks in parallel"
    
    for task in "${tasks[@]}"; do
        execute_task "$task" "$AUTOMATION_ENV" &
        pids+=($!)
    done
    
    # Wait for all tasks to complete
    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            results+=("${tasks[$i]}:SUCCESS")
        else
            results+=("${tasks[$i]}:FAILED")
        fi
    done
    
    # Report results
    log "INFO" "Parallel execution completed"
    for result in "${results[@]}"; do
        log "INFO" "Result: $result"
    done
}

# Report generation
generate_report() {
    local report_type="$1"
    local report_file="$REPORT_DIR/report_$(date +%Y%m%d_%H%M%S).html"
    
    log "INFO" "Generating $report_type report"
    
    cat > "$report_file" << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Automation Framework Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
        .success { color: green; }
        .error { color: red; }
        .warning { color: orange; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Automation Framework Report</h1>
        <p>Generated: $(date)</p>
        <p>Framework Version: $FRAMEWORK_VERSION</p>
    </div>
    
    <h2>Execution Summary</h2>
    <table>
        <tr><th>Metric</th><th>Value</th></tr>
        <tr><td>Total Tasks Executed</td><td>$(grep -c "Starting task:" "$LOG_DIR"/automation_*.log 2>/dev/null || echo "0")</td></tr>
        <tr><td>Successful Tasks</td><td class="success">$(grep -c "Task completed successfully:" "$LOG_DIR"/automation_*.log 2>/dev/null || echo "0")</td></tr>
        <tr><td>Failed Tasks</td><td class="error">$(grep -c "Task failed or timed out:" "$LOG_DIR"/automation_*.log 2>/dev/null || echo "0")</td></tr>
    </table>
    
    <h2>Recent Log Entries</h2>
    <pre>$(tail -20 "$LOG_DIR"/automation_*.log 2>/dev/null || echo "No log entries found")</pre>
    
    <h2>System Information</h2>
    <table>
        <tr><th>Property</th><th>Value</th></tr>
        <tr><td>Hostname</td><td>$(hostname)</td></tr>
        <tr><td>Uptime</td><td>$(uptime)</td></tr>
        <tr><td>Disk Usage</td><td>$(df -h / | tail -1 | awk '{print $5}')</td></tr>
    </table>
</body>
</html>
HTMLEOF
    
    log "INFO" "Report generated: $report_file"
    echo "$report_file"
}

# Task templates
create_task_template() {
    local task_name="$1"
    local task_file="$TASK_DIR/$task_name.sh"
    
    cat > "$task_file" << 'TASKEOF'
#!/bin/bash
# Automation Task Template
# Task: TASK_NAME
# Environment: $AUTOMATION_ENV

set -euo pipefail

# Task-specific logging
task_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$AUTOMATION_TASK] $1"
}

# Main task execution
main() {
    task_log "Starting task execution"
    
    # Add your task logic here
    task_log "Performing task operations..."
    
    # Example operations
    case "$AUTOMATION_ENV" in
        "development")
            task_log "Running in development mode"
            # Development-specific logic
            ;;
        "staging")
            task_log "Running in staging mode"
            # Staging-specific logic
            ;;
        "production")
            task_log "Running in production mode"
            # Production-specific logic
            ;;
    esac
    
    task_log "Task completed successfully"
}

# Execute main function
main "$@"
TASKEOF
    
    chmod +x "$task_file"
    log "INFO" "Task template created: $task_file"
}

# Main framework interface
main() {
    local command="$1"
    shift
    
    case "$command" in
        "init")
            init_framework
            ;;
        "task")
            local task_name="$1"
            local environment="${2:-development}"
            execute_task "$task_name" "$environment"
            ;;
        "parallel")
            local environment="$1"
            shift
            export AUTOMATION_ENV="$environment"
            execute_parallel_tasks "$@"
            ;;
        "report")
            local report_type="${1:-summary}"
            generate_report "$report_type"
            ;;
        "create-task")
            local task_name="$1"
            create_task_template "$task_name"
            ;;
        "status")
            echo "=== Automation Framework Status ==="
            echo "Version: $FRAMEWORK_VERSION"
            echo "Config Directory: $CONFIG_DIR"
            echo "Available Tasks: $(ls -1 "$TASK_DIR"/*.sh 2>/dev/null | wc -l || echo "0")"
            echo "Log Files: $(ls -1 "$LOG_DIR"/*.log 2>/dev/null | wc -l || echo "0")"
            echo "Reports: $(ls -1 "$REPORT_DIR"/*.html 2>/dev/null | wc -l || echo "0")"
            ;;
        *)
            echo "Automation Framework v$FRAMEWORK_VERSION"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  init                    - Initialize framework"
            echo "  task <name> [env]       - Execute single task"
            echo "  parallel <env> <tasks>  - Execute multiple tasks in parallel"
            echo "  report [type]           - Generate execution report"
            echo "  create-task <name>      - Create new task template"
            echo "  status                  - Show framework status"
            echo ""
            echo "Examples:"
            echo "  $0 init"
            echo "  $0 create-task deploy-app"
            echo "  $0 task deploy-app production"
            echo "  $0 parallel staging task1 task2 task3"
            echo "  $0 report summary"
            ;;
    esac
}

# Execute main function
main "$@"
EOF

chmod +x ~/automation_framework.sh

# Test the framework
echo "Testing Automation Framework:"
./automation_framework.sh init
./automation_framework.sh create-task sample-task
./automation_framework.sh status
```

**Expected Output**:
```
Testing Automation Framework:
Initializing Automation Framework v1.0.0
Framework initialized at /home/user/.automation
[2026-01-11 10:00:00] [INFO] Task template created: /home/user/.automation/tasks/sample-task.sh
=== Automation Framework Status ===
Version: 1.0.0
Config Directory: /home/user/.automation
Available Tasks: 1
Log Files: 1
Reports: 0
```

**Real-World Application**: Enterprise automation frameworks provide standardized, scalable solutions for managing complex operational tasks across multiple environments with comprehensive logging, reporting, and error handling.

---

## 🎯 **FINAL VERIFICATION CHECKLIST**

After completing all challenges, verify your shell scripting mastery:

### **Core Scripting Skills**
- [ ] Can create executable scripts with proper shebang
- [ ] Understands variable usage and scope
- [ ] Can implement user input and validation
- [ ] Masters functions and modular design
- [ ] Implements comprehensive error handling

### **Advanced Automation**
- [ ] Can create configuration-driven scripts
- [ ] Implements service management patterns
- [ ] Builds multi-server deployment automation
- [ ] Creates monitoring and alerting systems
- [ ] Develops CI/CD pipeline automation

### **Enterprise Patterns**
- [ ] Implements logging and audit trails
- [ ] Creates reusable automation frameworks
- [ ] Handles parallel execution and coordination
- [ ] Generates reports and documentation
- [ ] Follows security and compliance practices

---

## 🔗 **NEXT STEPS**

Continue to: **[User Input](readme.md)** →

**Prerequisites for Next Module**:
- Solid understanding of script structure and execution
- Experience with variables and functions
- Basic error handling knowledge

**Related Advanced Topics**:
- **[Advanced Bash Automation](readme.md)**
- **[Python for DevOps](readme.md)**
- **[Infrastructure as Code](readme.md)**

**Real-World Applications**:
- Server provisioning and configuration
- Application deployment automation
- System monitoring and maintenance
- CI/CD pipeline implementation
- Infrastructure management and scaling