# Shell Scripting Automation for DevOps and DevSecOps

## What is Shell Scripting?

Shell scripting is the practice of writing scripts using shell command language to automate tasks, manage systems, and orchestrate complex workflows. In Unix-like systems, shell scripts are executable text files containing a series of commands that the shell interpreter executes sequentially.

## Why Shell Scripting is Critical for DevOps

### 1. Automation Foundation
- **Repetitive Task Elimination**: Automates manual, error-prone processes
- **Consistency**: Ensures identical execution across environments
- **Efficiency**: Reduces time spent on routine operations
- **Scalability**: Handles operations across multiple systems simultaneously

### 2. Infrastructure Management
- **Server Provisioning**: Automated server setup and configuration
- **Package Management**: Automated software installation and updates
- **Service Management**: Starting, stopping, and monitoring services
- **Environment Configuration**: Setting up development, staging, and production environments

### 3. CI/CD Pipeline Integration
- **Build Automation**: Compiling, testing, and packaging applications
- **Deployment Scripts**: Automated application deployment processes
- **Testing Automation**: Running test suites and generating reports
- **Rollback Procedures**: Automated rollback mechanisms for failed deployments

### 4. Monitoring and Alerting
- **Health Checks**: Automated system and application monitoring
- **Log Analysis**: Processing and analyzing log files
- **Performance Monitoring**: Collecting and reporting system metrics
- **Incident Response**: Automated response to system alerts

## Shell Scripting Fundamentals

### Shell Types and Selection

#### Bash (Bourne Again Shell)
```bash
#!/bin/bash
# Most common shell for DevOps automation
# Available on virtually all Linux distributions
# Rich feature set with arrays, functions, and advanced scripting
```

#### Zsh (Z Shell)
```zsh
#!/bin/zsh
# Enhanced features and better interactive use
# Powerful completion system
# Advanced globbing and parameter expansion
```

#### POSIX Shell
```sh
#!/bin/sh
# Maximum portability across Unix-like systems
# Minimal feature set but universal compatibility
# Ideal for simple automation tasks
```

### Basic Script Structure

#### Script Header and Metadata
```bash
#!/bin/bash
#
# Script Name: deploy-application.sh
# Description: Automated application deployment script
# Author: DevOps Team
# Version: 1.2.0
# Created: 2024-01-15
# Modified: 2024-01-20
#
# Usage: ./deploy-application.sh <environment> <version>
# Example: ./deploy-application.sh production v2.1.0
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures
```

#### Variables and Configuration
```bash
# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/config.conf"
readonly LOG_FILE="/var/log/deployment.log"

# Application configuration
APP_NAME="myapp"
DEPLOY_USER="deploy"
DEPLOY_PATH="/opt/applications"
BACKUP_PATH="/opt/backups"

# Environment variables with defaults
ENVIRONMENT="${1:-staging}"
VERSION="${2:-latest}"
TIMEOUT="${TIMEOUT:-300}"
```

#### Functions and Modularity
```bash
# Logging function
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Error handling function
error_exit() {
    log "ERROR" "$1"
    exit "${2:-1}"
}

# Validation function
validate_environment() {
    local env="$1"
    case "$env" in
        development|staging|production)
            return 0
            ;;
        *)
            error_exit "Invalid environment: $env. Must be development, staging, or production."
            ;;
    esac
}
```

### Advanced Shell Scripting Techniques

#### Error Handling and Debugging
```bash
#!/bin/bash

# Comprehensive error handling
set -euo pipefail

# Trap for cleanup on exit
cleanup() {
    local exit_code=$?
    log "INFO" "Cleaning up temporary files..."
    rm -f /tmp/deploy_*
    if [ $exit_code -ne 0 ]; then
        log "ERROR" "Script failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

# Debug mode
if [[ "${DEBUG:-false}" == "true" ]]; then
    set -x  # Enable debug output
fi

# Function with error handling
deploy_application() {
    local version="$1"
    local environment="$2"
    
    log "INFO" "Starting deployment of $APP_NAME version $version to $environment"
    
    # Validate inputs
    [[ -n "$version" ]] || error_exit "Version parameter is required"
    [[ -n "$environment" ]] || error_exit "Environment parameter is required"
    
    # Check prerequisites
    command -v docker >/dev/null 2>&1 || error_exit "Docker is not installed"
    
    # Deployment logic with error checking
    if ! docker pull "$APP_NAME:$version"; then
        error_exit "Failed to pull Docker image $APP_NAME:$version"
    fi
    
    log "INFO" "Deployment completed successfully"
}
```

#### Configuration Management
```bash
# Configuration file parsing
load_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        error_exit "Configuration file not found: $config_file"
    fi
    
    # Source configuration file safely
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove quotes and export variable
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | sed 's/^["'\'']//' | sed 's/["'\'']$//')
        export "$key"="$value"
    done < "$config_file"
}

# Environment-specific configuration
setup_environment() {
    local env="$1"
    
    case "$env" in
        development)
            DB_HOST="dev-db.internal"
            REPLICAS=1
            RESOURCES_LIMIT="512Mi"
            ;;
        staging)
            DB_HOST="staging-db.internal"
            REPLICAS=2
            RESOURCES_LIMIT="1Gi"
            ;;
        production)
            DB_HOST="prod-db.internal"
            REPLICAS=5
            RESOURCES_LIMIT="2Gi"
            ;;
    esac
}
```

## DevOps Automation Scripts

### CI/CD Pipeline Scripts

#### Build Automation Script
```bash
#!/bin/bash
# build.sh - Automated build script

set -euo pipefail

# Configuration
readonly PROJECT_ROOT="$(git rev-parse --show-toplevel)"
readonly BUILD_DIR="${PROJECT_ROOT}/build"
readonly DIST_DIR="${PROJECT_ROOT}/dist"
readonly VERSION=$(git describe --tags --always --dirty)

# Build functions
clean_build() {
    log "INFO" "Cleaning previous build artifacts"
    rm -rf "$BUILD_DIR" "$DIST_DIR"
    mkdir -p "$BUILD_DIR" "$DIST_DIR"
}

run_tests() {
    log "INFO" "Running test suite"
    
    # Unit tests
    npm test || error_exit "Unit tests failed"
    
    # Integration tests
    npm run test:integration || error_exit "Integration tests failed"
    
    # Security tests
    npm audit --audit-level moderate || error_exit "Security audit failed"
    
    # Code quality checks
    npm run lint || error_exit "Linting failed"
    npm run type-check || error_exit "Type checking failed"
}

build_application() {
    log "INFO" "Building application version $VERSION"
    
    # Install dependencies
    npm ci --production
    
    # Build application
    npm run build
    
    # Create distribution package
    tar -czf "$DIST_DIR/app-$VERSION.tar.gz" -C "$BUILD_DIR" .
    
    log "INFO" "Build completed: $DIST_DIR/app-$VERSION.tar.gz"
}

# Main execution
main() {
    log "INFO" "Starting build process for version $VERSION"
    
    clean_build
    run_tests
    build_application
    
    log "INFO" "Build process completed successfully"
}

main "$@"
```

#### Deployment Automation Script
```bash
#!/bin/bash
# deploy.sh - Automated deployment script

set -euo pipefail

# Configuration
readonly ENVIRONMENTS=("development" "staging" "production")
readonly DEPLOY_TIMEOUT=600
readonly HEALTH_CHECK_TIMEOUT=300

# Deployment functions
validate_deployment() {
    local environment="$1"
    local version="$2"
    
    # Validate environment
    if [[ ! " ${ENVIRONMENTS[*]} " =~ " $environment " ]]; then
        error_exit "Invalid environment: $environment"
    fi
    
    # Validate version format
    if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error_exit "Invalid version format: $version (expected: vX.Y.Z)"
    fi
    
    # Check deployment prerequisites
    kubectl cluster-info >/dev/null || error_exit "Cannot connect to Kubernetes cluster"
    kubectl get namespace "$environment" >/dev/null || error_exit "Namespace $environment does not exist"
}

create_backup() {
    local environment="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    log "INFO" "Creating backup for $environment environment"
    
    # Backup current deployment
    kubectl get deployment "$APP_NAME" -n "$environment" -o yaml > \
        "$BACKUP_PATH/${APP_NAME}_${environment}_${timestamp}.yaml"
    
    # Backup database if applicable
    if [[ "$environment" == "production" ]]; then
        kubectl exec -n "$environment" deployment/database -- \
            pg_dump -U postgres myapp > \
            "$BACKUP_PATH/database_${environment}_${timestamp}.sql"
    fi
}

deploy_to_kubernetes() {
    local environment="$1"
    local version="$2"
    
    log "INFO" "Deploying $APP_NAME version $version to $environment"
    
    # Update deployment image
    kubectl set image deployment/"$APP_NAME" \
        "$APP_NAME"="$APP_NAME:$version" \
        -n "$environment"
    
    # Wait for rollout to complete
    if ! kubectl rollout status deployment/"$APP_NAME" \
         -n "$environment" --timeout="${DEPLOY_TIMEOUT}s"; then
        error_exit "Deployment rollout failed"
    fi
    
    log "INFO" "Deployment completed successfully"
}

run_health_checks() {
    local environment="$1"
    local start_time=$(date +%s)
    
    log "INFO" "Running health checks for $environment"
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ $elapsed -gt $HEALTH_CHECK_TIMEOUT ]]; then
            error_exit "Health check timeout after ${HEALTH_CHECK_TIMEOUT}s"
        fi
        
        # Check pod readiness
        local ready_pods=$(kubectl get pods -n "$environment" \
            -l app="$APP_NAME" \
            -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}')
        
        if [[ "$ready_pods" =~ ^(True[[:space:]]*)+$ ]]; then
            log "INFO" "All pods are ready"
            break
        fi
        
        log "INFO" "Waiting for pods to be ready... (${elapsed}s elapsed)"
        sleep 10
    done
    
    # Application-specific health check
    local health_url="https://${APP_NAME}-${environment}.example.com/health"
    if curl -f -s "$health_url" >/dev/null; then
        log "INFO" "Application health check passed"
    else
        error_exit "Application health check failed"
    fi
}

rollback_deployment() {
    local environment="$1"
    
    log "WARN" "Rolling back deployment in $environment"
    
    kubectl rollout undo deployment/"$APP_NAME" -n "$environment"
    kubectl rollout status deployment/"$APP_NAME" -n "$environment"
    
    log "INFO" "Rollback completed"
}

# Main deployment function
deploy() {
    local environment="$1"
    local version="$2"
    
    validate_deployment "$environment" "$version"
    create_backup "$environment"
    
    if deploy_to_kubernetes "$environment" "$version"; then
        if run_health_checks "$environment"; then
            log "INFO" "Deployment successful"
            return 0
        else
            log "ERROR" "Health checks failed, initiating rollback"
            rollback_deployment "$environment"
            return 1
        fi
    else
        log "ERROR" "Deployment failed, initiating rollback"
        rollback_deployment "$environment"
        return 1
    fi
}

# Main execution
main() {
    local environment="${1:-}"
    local version="${2:-}"
    
    if [[ -z "$environment" || -z "$version" ]]; then
        echo "Usage: $0 <environment> <version>"
        echo "Environments: ${ENVIRONMENTS[*]}"
        exit 1
    fi
    
    deploy "$environment" "$version"
}

main "$@"
```

### Infrastructure Automation Scripts

#### Server Provisioning Script
```bash
#!/bin/bash
# provision-server.sh - Automated server provisioning

set -euo pipefail

# Configuration
readonly SERVER_TYPES=("web" "database" "cache" "worker")
readonly SUPPORTED_OS=("ubuntu-20.04" "ubuntu-22.04" "centos-8")

# Provisioning functions
install_base_packages() {
    local os_type="$1"
    
    log "INFO" "Installing base packages for $os_type"
    
    case "$os_type" in
        ubuntu-*)
            apt-get update
            apt-get install -y \
                curl wget git vim htop \
                build-essential software-properties-common \
                apt-transport-https ca-certificates gnupg lsb-release
            ;;
        centos-*)
            yum update -y
            yum groupinstall -y "Development Tools"
            yum install -y \
                curl wget git vim htop \
                epel-release
            ;;
    esac
}

configure_security() {
    log "INFO" "Configuring security settings"
    
    # Configure SSH
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # Configure firewall
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    
    # Install fail2ban
    apt-get install -y fail2ban
    systemctl enable fail2ban
    systemctl start fail2ban
}

install_docker() {
    log "INFO" "Installing Docker"
    
    # Add Docker repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Configure Docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu
    
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

configure_monitoring() {
    log "INFO" "Setting up monitoring agents"
    
    # Install Node Exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
    tar xvfz node_exporter-1.4.0.linux-amd64.tar.gz
    cp node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin/
    
    # Create systemd service
    cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
Group=nogroup
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable node_exporter
    systemctl start node_exporter
}

# Server type specific configurations
configure_web_server() {
    log "INFO" "Configuring web server"
    
    # Install Nginx
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    
    # Configure firewall for web traffic
    ufw allow 'Nginx Full'
    
    # Install SSL certificate tools
    apt-get install -y certbot python3-certbot-nginx
}

configure_database_server() {
    log "INFO" "Configuring database server"
    
    # Install PostgreSQL
    apt-get install -y postgresql postgresql-contrib
    systemctl enable postgresql
    systemctl start postgresql
    
    # Configure PostgreSQL
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'secure_password';"
    
    # Configure firewall for database
    ufw allow from 10.0.0.0/8 to any port 5432
}

# Main provisioning function
provision_server() {
    local server_type="$1"
    local os_type="$2"
    
    log "INFO" "Starting server provisioning: $server_type on $os_type"
    
    install_base_packages "$os_type"
    configure_security
    install_docker
    configure_monitoring
    
    case "$server_type" in
        web)
            configure_web_server
            ;;
        database)
            configure_database_server
            ;;
        cache)
            # Redis installation and configuration
            apt-get install -y redis-server
            systemctl enable redis-server
            ;;
        worker)
            # Worker-specific configuration
            log "INFO" "Worker server configured with base setup"
            ;;
    esac
    
    log "INFO" "Server provisioning completed successfully"
}

# Main execution
main() {
    local server_type="${1:-}"
    local os_type="${2:-ubuntu-20.04}"
    
    if [[ -z "$server_type" ]]; then
        echo "Usage: $0 <server_type> [os_type]"
        echo "Server types: ${SERVER_TYPES[*]}"
        echo "OS types: ${SUPPORTED_OS[*]}"
        exit 1
    fi
    
    provision_server "$server_type" "$os_type"
}

main "$@"
```

### Monitoring and Maintenance Scripts

#### System Health Monitoring Script
```bash
#!/bin/bash
# system-monitor.sh - Comprehensive system monitoring

set -euo pipefail

# Configuration
readonly ALERT_EMAIL="devops@company.com"
readonly SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
readonly METRICS_FILE="/var/log/system-metrics.log"

# Thresholds
readonly CPU_THRESHOLD=80
readonly MEMORY_THRESHOLD=85
readonly DISK_THRESHOLD=90
readonly LOAD_THRESHOLD=5.0

# Monitoring functions
check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}  # Remove decimal part
    
    if [[ $cpu_usage -gt $CPU_THRESHOLD ]]; then
        send_alert "HIGH CPU" "CPU usage is ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)"
        return 1
    fi
    
    log_metric "cpu_usage" "$cpu_usage"
    return 0
}

check_memory_usage() {
    local memory_info=$(free | grep Mem)
    local total=$(echo "$memory_info" | awk '{print $2}')
    local used=$(echo "$memory_info" | awk '{print $3}')
    local memory_usage=$((used * 100 / total))
    
    if [[ $memory_usage -gt $MEMORY_THRESHOLD ]]; then
        send_alert "HIGH MEMORY" "Memory usage is ${memory_usage}% (threshold: ${MEMORY_THRESHOLD}%)"
        return 1
    fi
    
    log_metric "memory_usage" "$memory_usage"
    return 0
}

check_disk_usage() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    if [[ $disk_usage -gt $DISK_THRESHOLD ]]; then
        send_alert "HIGH DISK" "Disk usage is ${disk_usage}% (threshold: ${DISK_THRESHOLD}%)"
        return 1
    fi
    
    log_metric "disk_usage" "$disk_usage"
    return 0
}

check_load_average() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    
    if (( $(echo "$load_avg > $LOAD_THRESHOLD" | bc -l) )); then
        send_alert "HIGH LOAD" "Load average is $load_avg (threshold: $LOAD_THRESHOLD)"
        return 1
    fi
    
    log_metric "load_average" "$load_avg"
    return 0
}

check_services() {
    local critical_services=("nginx" "docker" "ssh")
    local failed_services=()
    
    for service in "${critical_services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            failed_services+=("$service")
        fi
    done
    
    if [[ ${#failed_services[@]} -gt 0 ]]; then
        send_alert "SERVICE DOWN" "Failed services: ${failed_services[*]}"
        return 1
    fi
    
    return 0
}

check_network_connectivity() {
    local test_hosts=("8.8.8.8" "google.com")
    
    for host in "${test_hosts[@]}"; do
        if ! ping -c 1 -W 5 "$host" >/dev/null 2>&1; then
            send_alert "NETWORK ISSUE" "Cannot reach $host"
            return 1
        fi
    done
    
    return 0
}

# Alerting functions
send_alert() {
    local alert_type="$1"
    local message="$2"
    local hostname=$(hostname)
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    log "ALERT" "[$alert_type] $message"
    
    # Send email alert
    if command -v mail >/dev/null 2>&1; then
        echo "Alert from $hostname at $timestamp: [$alert_type] $message" | \
            mail -s "System Alert: $alert_type on $hostname" "$ALERT_EMAIL"
    fi
    
    # Send Slack notification
    if [[ -n "$SLACK_WEBHOOK" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"🚨 Alert from $hostname: [$alert_type] $message\"}" \
            "$SLACK_WEBHOOK" 2>/dev/null || true
    fi
}

log_metric() {
    local metric_name="$1"
    local metric_value="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "$timestamp,$metric_name,$metric_value" >> "$METRICS_FILE"
}

# Main monitoring function
run_monitoring() {
    log "INFO" "Starting system monitoring check"
    
    local alerts=0
    
    check_cpu_usage || ((alerts++))
    check_memory_usage || ((alerts++))
    check_disk_usage || ((alerts++))
    check_load_average || ((alerts++))
    check_services || ((alerts++))
    check_network_connectivity || ((alerts++))
    
    if [[ $alerts -eq 0 ]]; then
        log "INFO" "All system checks passed"
    else
        log "WARN" "$alerts alert(s) generated"
    fi
    
    return $alerts
}

# Main execution
main() {
    run_monitoring
}

main "$@"
```

## DevSecOps Integration with Shell Scripting

### Security Automation Scripts

#### Security Scanning Script
```bash
#!/bin/bash
# security-scan.sh - Automated security scanning

set -euo pipefail

# Configuration
readonly SCAN_RESULTS_DIR="/opt/security-scans"
readonly REPORT_EMAIL="security@company.com"

# Security scanning functions
scan_vulnerabilities() {
    log "INFO" "Running vulnerability scan"
    
    # Update vulnerability database
    if command -v nmap >/dev/null 2>&1; then
        nmap --script vuln localhost > "$SCAN_RESULTS_DIR/vuln-scan-$(date +%Y%m%d).txt"
    fi
    
    # Scan for rootkits
    if command -v rkhunter >/dev/null 2>&1; then
        rkhunter --check --sk > "$SCAN_RESULTS_DIR/rootkit-scan-$(date +%Y%m%d).txt"
    fi
    
    # Check for malware
    if command -v clamscan >/dev/null 2>&1; then
        clamscan -r /home /opt > "$SCAN_RESULTS_DIR/malware-scan-$(date +%Y%m%d).txt"
    fi
}

audit_system_configuration() {
    log "INFO" "Auditing system configuration"
    
    # Check file permissions
    find /etc -type f -perm /o+w > "$SCAN_RESULTS_DIR/world-writable-files.txt"
    
    # Check for SUID/SGID files
    find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null > \
        "$SCAN_RESULTS_DIR/suid-sgid-files.txt"
    
    # Check password policies
    grep -E '^(password|auth)' /etc/pam.d/common-password > \
        "$SCAN_RESULTS_DIR/password-policy.txt"
}

check_network_security() {
    log "INFO" "Checking network security"
    
    # Check open ports
    ss -tuln > "$SCAN_RESULTS_DIR/open-ports.txt"
    
    # Check firewall rules
    iptables -L -n > "$SCAN_RESULTS_DIR/firewall-rules.txt"
    
    # Check for suspicious network connections
    netstat -an | grep ESTABLISHED > "$SCAN_RESULTS_DIR/network-connections.txt"
}

# Main security scan function
run_security_scan() {
    log "INFO" "Starting comprehensive security scan"
    
    mkdir -p "$SCAN_RESULTS_DIR"
    
    scan_vulnerabilities
    audit_system_configuration
    check_network_security
    
    # Generate summary report
    generate_security_report
    
    log "INFO" "Security scan completed"
}

generate_security_report() {
    local report_file="$SCAN_RESULTS_DIR/security-report-$(date +%Y%m%d).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Security Scan Report - $(date)</title>
</head>
<body>
    <h1>Security Scan Report</h1>
    <p>Generated on: $(date)</p>
    <p>Hostname: $(hostname)</p>
    
    <h2>Scan Results</h2>
    <ul>
        <li>Vulnerability Scan: $(wc -l < "$SCAN_RESULTS_DIR/vuln-scan-$(date +%Y%m%d).txt") findings</li>
        <li>World-writable files: $(wc -l < "$SCAN_RESULTS_DIR/world-writable-files.txt") files</li>
        <li>SUID/SGID files: $(wc -l < "$SCAN_RESULTS_DIR/suid-sgid-files.txt") files</li>
    </ul>
</body>
</html>
EOF
    
    # Email the report
    if command -v mail >/dev/null 2>&1; then
        mail -s "Security Scan Report - $(hostname)" -a "$report_file" \
            "$REPORT_EMAIL" < /dev/null
    fi
}

# Main execution
main() {
    run_security_scan
}

main "$@"
```

### Compliance and Audit Scripts

#### Compliance Checker Script
```bash
#!/bin/bash
# compliance-check.sh - Automated compliance checking

set -euo pipefail

# Compliance standards
readonly STANDARDS=("CIS" "PCI-DSS" "SOX" "GDPR")

# CIS (Center for Internet Security) checks
check_cis_compliance() {
    log "INFO" "Running CIS compliance checks"
    
    local violations=0
    
    # CIS 1.1.1.1 - Ensure mounting of cramfs filesystems is disabled
    if ! grep -q "install cramfs /bin/true" /etc/modprobe.d/*; then
        log "VIOLATION" "CIS 1.1.1.1: cramfs filesystem not disabled"
        ((violations++))
    fi
    
    # CIS 2.2.1.1 - Ensure time synchronization is in use
    if ! systemctl is-enabled ntp >/dev/null 2>&1 && \
       ! systemctl is-enabled chrony >/dev/null 2>&1; then
        log "VIOLATION" "CIS 2.2.1.1: Time synchronization not configured"
        ((violations++))
    fi
    
    # CIS 5.2.5 - Ensure SSH X11 forwarding is disabled
    if ! grep -q "^X11Forwarding no" /etc/ssh/sshd_config; then
        log "VIOLATION" "CIS 5.2.5: SSH X11 forwarding not disabled"
        ((violations++))
    fi
    
    return $violations
}

# PCI-DSS compliance checks
check_pci_compliance() {
    log "INFO" "Running PCI-DSS compliance checks"
    
    local violations=0
    
    # PCI-DSS 2.2 - Remove unnecessary services
    local unnecessary_services=("telnet" "rsh" "rlogin")
    for service in "${unnecessary_services[@]}"; do
        if systemctl is-enabled "$service" >/dev/null 2>&1; then
            log "VIOLATION" "PCI-DSS 2.2: Unnecessary service enabled: $service"
            ((violations++))
        fi
    done
    
    # PCI-DSS 8.2.3 - Strong password requirements
    if ! grep -q "minlen=8" /etc/pam.d/common-password; then
        log "VIOLATION" "PCI-DSS 8.2.3: Minimum password length not enforced"
        ((violations++))
    fi
    
    return $violations
}

# Generate compliance report
generate_compliance_report() {
    local total_violations="$1"
    local report_file="/tmp/compliance-report-$(date +%Y%m%d).json"
    
    cat > "$report_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "hostname": "$(hostname)",
    "total_violations": $total_violations,
    "standards_checked": $(printf '%s\n' "${STANDARDS[@]}" | jq -R . | jq -s .),
    "status": "$([ $total_violations -eq 0 ] && echo "COMPLIANT" || echo "NON_COMPLIANT")"
}
EOF
    
    log "INFO" "Compliance report generated: $report_file"
}

# Main compliance check function
run_compliance_check() {
    log "INFO" "Starting compliance checks"
    
    local total_violations=0
    
    check_cis_compliance
    total_violations=$((total_violations + $?))
    
    check_pci_compliance
    total_violations=$((total_violations + $?))
    
    generate_compliance_report "$total_violations"
    
    if [[ $total_violations -eq 0 ]]; then
        log "INFO" "All compliance checks passed"
    else
        log "WARN" "$total_violations compliance violations found"
    fi
    
    return $total_violations
}

# Main execution
main() {
    run_compliance_check
}

main "$@"
```

## Advanced Automation Patterns

### Parallel Processing and Job Management

#### Parallel Execution Script
```bash
#!/bin/bash
# parallel-tasks.sh - Parallel task execution

set -euo pipefail

# Configuration
readonly MAX_JOBS=4
readonly JOB_TIMEOUT=300

# Job management functions
run_parallel_jobs() {
    local jobs=("$@")
    local pids=()
    local job_count=0
    
    for job in "${jobs[@]}"; do
        # Limit concurrent jobs
        while [[ ${#pids[@]} -ge $MAX_JOBS ]]; do
            wait_for_job_completion pids
        done
        
        # Start job in background
        log "INFO" "Starting job: $job"
        $job &
        local pid=$!
        pids+=("$pid")
        
        ((job_count++))
    done
    
    # Wait for all remaining jobs
    for pid in "${pids[@]}"; do
        if wait "$pid"; then
            log "INFO" "Job $pid completed successfully"
        else
            log "ERROR" "Job $pid failed"
        fi
    done
    
    log "INFO" "All $job_count jobs completed"
}

wait_for_job_completion() {
    local -n pid_array=$1
    local new_pids=()
    
    for pid in "${pid_array[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            new_pids+=("$pid")
        else
            wait "$pid"
        fi
    done
    
    pid_array=("${new_pids[@]}")
}

# Example job functions
backup_database() {
    local db_name="$1"
    log "INFO" "Backing up database: $db_name"
    sleep $((RANDOM % 10 + 5))  # Simulate work
    log "INFO" "Database backup completed: $db_name"
}

deploy_service() {
    local service_name="$1"
    log "INFO" "Deploying service: $service_name"
    sleep $((RANDOM % 15 + 10))  # Simulate work
    log "INFO" "Service deployment completed: $service_name"
}

# Main execution
main() {
    local tasks=(
        "backup_database production"
        "backup_database staging"
        "deploy_service web-api"
        "deploy_service worker"
        "deploy_service cache"
    )
    
    run_parallel_jobs "${tasks[@]}"
}

main "$@"
```

### Configuration Management and Templating

#### Template Processing Script
```bash
#!/bin/bash
# template-processor.sh - Configuration template processing

set -euo pipefail

# Template processing functions
process_template() {
    local template_file="$1"
    local output_file="$2"
    local config_file="$3"
    
    log "INFO" "Processing template: $template_file"
    
    # Load configuration variables
    source "$config_file"
    
    # Process template with variable substitution
    envsubst < "$template_file" > "$output_file"
    
    log "INFO" "Template processed: $output_file"
}

validate_template_variables() {
    local template_file="$1"
    local config_file="$2"
    
    # Extract variables from template
    local template_vars=$(grep -oE '\$\{[A-Z_]+\}' "$template_file" | sort -u)
    
    # Load configuration
    source "$config_file"
    
    # Check if all variables are defined
    local missing_vars=()
    for var in $template_vars; do
        local var_name=${var//[\$\{\}]/}
        if [[ -z "${!var_name:-}" ]]; then
            missing_vars+=("$var_name")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        error_exit "Missing template variables: ${missing_vars[*]}"
    fi
}

# Example: Nginx configuration template processing
process_nginx_config() {
    local environment="$1"
    local template_dir="templates"
    local config_dir="configs"
    local config_file="environments/${environment}.conf"
    
    # Validate template variables
    validate_template_variables "$template_dir/nginx.conf.template" "$config_file"
    
    # Process template
    process_template \
        "$template_dir/nginx.conf.template" \
        "$config_dir/nginx-${environment}.conf" \
        "$config_file"
    
    # Validate generated configuration
    nginx -t -c "$config_dir/nginx-${environment}.conf"
}

# Main execution
main() {
    local environment="${1:-development}"
    
    process_nginx_config "$environment"
}

main "$@"
```

## Best Practices and Guidelines

### Script Quality and Maintainability

#### Code Quality Checklist
```bash
#!/bin/bash
# Script quality guidelines and best practices

# 1. Always use strict error handling
set -euo pipefail

# 2. Use readonly for constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Validate input parameters
validate_inputs() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: $SCRIPT_NAME <param1> <param2>"
        exit 1
    fi
}

# 4. Use functions for reusability
log_with_timestamp() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 5. Handle cleanup properly
cleanup() {
    local exit_code=$?
    # Cleanup temporary files, connections, etc.
    rm -f /tmp/script_temp_*
    exit $exit_code
}
trap cleanup EXIT

# 6. Use meaningful variable names
readonly DATABASE_CONNECTION_STRING="postgresql://user:pass@host:5432/db"
readonly MAX_RETRY_ATTEMPTS=3
readonly TIMEOUT_SECONDS=30

# 7. Quote variables to prevent word splitting
process_file() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        log_with_timestamp "Processing file: $file_path"
    fi
}

# 8. Use arrays for lists
readonly SUPPORTED_ENVIRONMENTS=("dev" "staging" "prod")

# 9. Implement proper error handling
safe_command() {
    local command="$1"
    if ! $command; then
        log_with_timestamp "ERROR: Command failed: $command"
        return 1
    fi
}

# 10. Document functions and complex logic
# Function: deploy_application
# Purpose: Deploys application to specified environment
# Parameters:
#   $1 - environment (dev/staging/prod)
#   $2 - version (semantic version string)
# Returns: 0 on success, 1 on failure
deploy_application() {
    local environment="$1"
    local version="$2"
    
    # Implementation here
}
```

### Testing and Validation

#### Script Testing Framework
```bash
#!/bin/bash
# test-framework.sh - Simple testing framework for shell scripts

set -euo pipefail

# Test framework variables
readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -i TESTS_RUN=0
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0

# Test framework functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        ((TESTS_PASSED++))
        echo "✓ PASS: $message"
    else
        ((TESTS_FAILED++))
        echo "✗ FAIL: $message"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
    fi
}

assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command should succeed}"
    
    ((TESTS_RUN++))
    
    if $command >/dev/null 2>&1; then
        ((TESTS_PASSED++))
        echo "✓ PASS: $message"
    else
        ((TESTS_FAILED++))
        echo "✗ FAIL: $message"
        echo "  Command: $command"
    fi
}

assert_file_exists() {
    local file_path="$1"
    local message="${2:-File should exist}"
    
    ((TESTS_RUN++))
    
    if [[ -f "$file_path" ]]; then
        ((TESTS_PASSED++))
        echo "✓ PASS: $message"
    else
        ((TESTS_FAILED++))
        echo "✗ FAIL: $message"
        echo "  File: $file_path"
    fi
}

# Test runner
run_tests() {
    echo "Running tests..."
    echo "=================="
    
    # Run test functions
    test_string_functions
    test_file_operations
    test_deployment_functions
    
    echo "=================="
    echo "Tests run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "All tests passed! ✓"
        return 0
    else
        echo "Some tests failed! ✗"
        return 1
    fi
}

# Example test functions
test_string_functions() {
    echo "Testing string functions..."
    
    # Test string manipulation
    local result=$(echo "hello world" | tr '[:lower:]' '[:upper:]')
    assert_equals "HELLO WORLD" "$result" "String uppercase conversion"
    
    # Test string length
    local test_string="test"
    assert_equals "4" "${#test_string}" "String length calculation"
}

test_file_operations() {
    echo "Testing file operations..."
    
    # Create test file
    local test_file="/tmp/test_file_$$"
    echo "test content" > "$test_file"
    
    assert_file_exists "$test_file" "Test file creation"
    
    # Test file content
    local content=$(cat "$test_file")
    assert_equals "test content" "$content" "File content verification"
    
    # Cleanup
    rm -f "$test_file"
}

test_deployment_functions() {
    echo "Testing deployment functions..."
    
    # Test environment validation
    assert_command_succeeds "validate_environment development" "Development environment validation"
    
    # Test version format validation
    assert_command_succeeds "validate_version v1.2.3" "Version format validation"
}

# Main execution
main() {
    run_tests
}

main "$@"
```

## Conclusion

Shell scripting is the backbone of DevOps and DevSecOps automation, providing the foundation for:

### Critical DevOps Capabilities
1. **Infrastructure Automation**: Server provisioning, configuration management, and environment setup
2. **CI/CD Pipeline Integration**: Build automation, testing, deployment, and rollback procedures
3. **Monitoring and Alerting**: System health checks, performance monitoring, and incident response
4. **Security Automation**: Vulnerability scanning, compliance checking, and security hardening

### DevSecOps Integration
1. **Security by Design**: Automated security checks integrated into development workflows
2. **Compliance Automation**: Continuous compliance monitoring and reporting
3. **Incident Response**: Automated security incident detection and response
4. **Audit Trail**: Comprehensive logging and audit capabilities

### Key Benefits
- **Consistency**: Eliminates human error through standardized processes
- **Scalability**: Manages operations across hundreds or thousands of systems
- **Efficiency**: Reduces manual effort and accelerates delivery cycles
- **Reliability**: Provides predictable, repeatable operations
- **Cost Reduction**: Minimizes operational overhead and resource waste

### Best Practices Summary
1. **Error Handling**: Always use `set -euo pipefail` and proper error checking
2. **Modularity**: Write reusable functions and maintain clean code structure
3. **Documentation**: Include comprehensive comments and usage instructions
4. **Testing**: Implement automated testing for critical scripts
5. **Security**: Follow security best practices and validate all inputs
6. **Monitoring**: Include logging and monitoring capabilities in all scripts

Shell scripting mastery is essential for DevOps professionals, enabling the automation that makes modern software delivery possible. As infrastructure becomes more complex and deployment frequencies increase, the ability to create robust, maintainable automation scripts becomes increasingly valuable for organizational success.