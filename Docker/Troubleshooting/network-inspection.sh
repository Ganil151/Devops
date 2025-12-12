#!/usr/bin/env bash

# Docker Network Inspection and Debugging Script
# Enhanced version of the original inspect-net-context.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_section() {
    echo -e "\n${BLUE}# $1${NC}"
    echo "=================================="
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running as root or with docker permissions
check_permissions() {
    if ! docker ps >/dev/null 2>&1; then
        print_error "Cannot connect to Docker daemon. Please check permissions."
        exit 1
    fi
}

# Display Docker network information
show_docker_networks() {
    print_section "Docker Networks"
    
    echo "Available Docker networks:"
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}\t{{.IPv4}}"
    
    echo -e "\nDetailed network information:"
    for network in $(docker network ls --format "{{.Name}}" | grep -v NETWORK); do
        echo -e "\n${YELLOW}Network: $network${NC}"
        docker network inspect "$network" --format "{{json .IPAM.Config}}" | jq -r '.[] | "  Subnet: \(.Subnet // "N/A"), Gateway: \(.Gateway // "N/A")"' 2>/dev/null || echo "  Unable to parse network details"
    done
}

# Display container network information
show_container_networks() {
    print_section "Container Network Information"
    
    local containers=$(docker ps --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        print_warning "No running containers found"
        return
    fi
    
    for container in $containers; do
        echo -e "\n${YELLOW}Container: $container${NC}"
        
        # Get container IP addresses
        docker inspect "$container" --format "{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}" | tr ' ' '\n' | grep -v '^$' | while read ip; do
            echo "  IP Address: $ip"
        done
        
        # Get network names
        docker inspect "$container" --format "{{range \$network, \$config := .NetworkSettings.Networks}}\$network {{end}}" | tr ' ' '\n' | grep -v '^$' | while read network; do
            echo "  Network: $network"
        done
        
        # Get port mappings
        local ports=$(docker port "$container" 2>/dev/null || echo "")
        if [ -n "$ports" ]; then
            echo "  Port mappings:"
            echo "$ports" | sed 's/^/    /'
        fi
    done
}

# Display host network devices
show_network_devices() {
    print_section "Host Network Devices"
    
    if command -v ip >/dev/null 2>&1; then
        ip link show | grep -E '^[0-9]+:' | while read line; do
            interface=$(echo "$line" | cut -d: -f2 | tr -d ' ')
            state=$(echo "$line" | grep -o 'state [A-Z]*' | cut -d' ' -f2)
            echo "  $interface: $state"
        done
    else
        print_warning "ip command not available, using ifconfig"
        ifconfig -s 2>/dev/null || print_error "Neither ip nor ifconfig available"
    fi
}

# Display routing table
show_route_table() {
    print_section "Host Route Table"
    
    if command -v ip >/dev/null 2>&1; then
        ip route show
    else
        print_warning "ip command not available, using route"
        route -n 2>/dev/null || print_error "Neither ip nor route command available"
    fi
}

# Display iptables rules (if accessible)
show_iptables_rules() {
    print_section "Iptables Rules (Docker-related)"
    
    if command -v iptables >/dev/null 2>&1; then
        if iptables -L >/dev/null 2>&1; then
            echo "Docker chain rules:"
            iptables -L DOCKER 2>/dev/null || print_warning "DOCKER chain not found"
            
            echo -e "\nDocker user chain rules:"
            iptables -L DOCKER-USER 2>/dev/null || print_warning "DOCKER-USER chain not found"
            
            echo -e "\nNAT rules for Docker:"
            iptables -t nat -L DOCKER 2>/dev/null || print_warning "Docker NAT rules not accessible"
        else
            print_warning "Cannot access iptables (permission denied)"
        fi
    else
        print_warning "iptables command not available"
    fi
}

# Test container connectivity
test_container_connectivity() {
    print_section "Container Connectivity Tests"
    
    local containers=$(docker ps --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        print_warning "No running containers to test"
        return
    fi
    
    for container in $containers; do
        echo -e "\n${YELLOW}Testing connectivity for: $container${NC}"
        
        # Test DNS resolution
        if docker exec "$container" nslookup google.com >/dev/null 2>&1; then
            print_success "DNS resolution working"
        else
            print_error "DNS resolution failed"
        fi
        
        # Test internet connectivity
        if docker exec "$container" ping -c 1 8.8.8.8 >/dev/null 2>&1; then
            print_success "Internet connectivity working"
        else
            print_error "Internet connectivity failed"
        fi
        
        # Test container-to-container connectivity (if multiple containers)
        local container_count=$(echo "$containers" | wc -l)
        if [ "$container_count" -gt 1 ]; then
            for target_container in $containers; do
                if [ "$container" != "$target_container" ]; then
                    local target_ip=$(docker inspect "$target_container" --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" | head -1)
                    if [ -n "$target_ip" ] && docker exec "$container" ping -c 1 "$target_ip" >/dev/null 2>&1; then
                        print_success "Can reach $target_container ($target_ip)"
                    else
                        print_error "Cannot reach $target_container ($target_ip)"
                    fi
                    break # Test only one other container
                fi
            done
        fi
    done
}

# Display Docker daemon network configuration
show_docker_daemon_config() {
    print_section "Docker Daemon Network Configuration"
    
    echo "Docker daemon info:"
    docker info --format "{{json .}}" | jq -r '
        "  Default Bridge: \(.DefaultBridge // "N/A")",
        "  Bridge Name: \(.BridgeName // "N/A")",
        "  IPv4 Forwarding: \(.IPv4Forwarding // "N/A")",
        "  Bridge IP: \(.BridgeNfIptables // "N/A")"
    ' 2>/dev/null || docker info | grep -E "(Bridge|IPv4|Network)" || print_warning "Unable to parse Docker daemon network info"
}

# Check for common network issues
check_network_issues() {
    print_section "Network Issue Detection"
    
    # Check for port conflicts
    echo "Checking for port conflicts:"
    local used_ports=$(docker ps --format "{{.Ports}}" | grep -o '0.0.0.0:[0-9]*' | cut -d: -f2 | sort | uniq -d)
    if [ -n "$used_ports" ]; then
        print_error "Duplicate port bindings detected: $used_ports"
    else
        print_success "No port conflicts detected"
    fi
    
    # Check for network connectivity issues
    echo -e "\nChecking Docker daemon connectivity:"
    if docker version >/dev/null 2>&1; then
        print_success "Docker daemon is accessible"
    else
        print_error "Cannot connect to Docker daemon"
    fi
    
    # Check for bridge network issues
    echo -e "\nChecking default bridge network:"
    if docker network inspect bridge >/dev/null 2>&1; then
        print_success "Default bridge network is available"
    else
        print_error "Default bridge network is not available"
    fi
}

# Generate network troubleshooting report
generate_report() {
    local report_file="docker-network-report-$(date +%Y%m%d-%H%M%S).txt"
    
    print_section "Generating Network Report"
    
    {
        echo "Docker Network Inspection Report"
        echo "Generated on: $(date)"
        echo "Host: $(hostname)"
        echo "Docker Version: $(docker version --format '{{.Server.Version}}' 2>/dev/null || echo 'Unknown')"
        echo "=================================="
        echo
    } > "$report_file"
    
    # Redirect all output to both console and file
    exec > >(tee -a "$report_file")
    
    print_success "Report will be saved to: $report_file"
}

# Display help information
show_help() {
    cat << EOF
Docker Network Inspection Script

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -r, --report        Generate a detailed report file
    -q, --quick         Run quick inspection (skip connectivity tests)
    -c, --containers    Show only container network information
    -n, --networks      Show only Docker network information
    -t, --test          Run connectivity tests only

EXAMPLES:
    $0                  Run full network inspection
    $0 -r               Generate detailed report
    $0 -q               Quick inspection without connectivity tests
    $0 -c               Show container network info only

EOF
}

# Main execution function
main() {
    local generate_report_flag=false
    local quick_mode=false
    local containers_only=false
    local networks_only=false
    local test_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -r|--report)
                generate_report_flag=true
                shift
                ;;
            -q|--quick)
                quick_mode=true
                shift
                ;;
            -c|--containers)
                containers_only=true
                shift
                ;;
            -n|--networks)
                networks_only=true
                shift
                ;;
            -t|--test)
                test_only=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Check permissions first
    check_permissions
    
    # Generate report if requested
    if [ "$generate_report_flag" = true ]; then
        generate_report
    fi
    
    echo "Docker Network Inspection Tool"
    echo "=============================="
    
    # Execute based on options
    if [ "$test_only" = true ]; then
        test_container_connectivity
    elif [ "$containers_only" = true ]; then
        show_container_networks
    elif [ "$networks_only" = true ]; then
        show_docker_networks
    else
        # Full inspection
        show_docker_daemon_config
        show_docker_networks
        show_container_networks
        show_network_devices
        show_route_table
        show_iptables_rules
        check_network_issues
        
        if [ "$quick_mode" = false ]; then
            test_container_connectivity
        fi
    fi
    
    echo -e "\n${GREEN}Network inspection completed!${NC}"
    
    if [ "$generate_report_flag" = true ]; then
        echo -e "Report saved to: ${YELLOW}docker-network-report-$(date +%Y%m%d)*.txt${NC}"
    fi
}

# Run main function with all arguments
main "$@"