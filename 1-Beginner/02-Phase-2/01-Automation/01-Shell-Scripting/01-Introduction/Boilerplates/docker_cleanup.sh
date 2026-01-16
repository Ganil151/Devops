#!/bin/bash

# ==============================================================================
# Script: docker_cleanup.sh
# Description: Removes dangling Docker images and stopped containers
# DevOps Context: CI/CD runner maintenance to prevent disk space issues
# Schedule: Run daily via cron - 0 2 * * * /path/to/script
# ==============================================================================

set -euo pipefail

# Constants
readonly LOG_FILE="/var/log/docker_cleanup.log"

# Logging function
log() {
    local message="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" | tee -a "$LOG_FILE"
}

# Check if Docker is running
check_docker() {
    if ! command -v docker &> /dev/null; then
        log "ERROR: Docker is not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log "ERROR: Docker daemon is not running"
        exit 1
    fi
}

# Remove stopped containers
cleanup_containers() {
    log "INFO: Removing stopped containers..."
    local stopped_count
    stopped_count=$(docker ps -aq -f status=exited | wc -l)
    
    if [ "$stopped_count" -eq 0 ]; then
        log "INFO: No stopped containers to remove"
    else
        docker rm $(docker ps -aq -f status=exited) 2>/dev/null || true
        log "INFO: Removed $stopped_count stopped container(s)"
    fi
}

# Remove dangling images
cleanup_images() {
    log "INFO: Removing dangling images..."
    local dangling_count
    dangling_count=$(docker images -qf "dangling=true" | wc -l)
    
    if [ "$dangling_count" -eq 0 ]; then
        log "INFO: No dangling images to remove"
    else
        docker rmi $(docker images -qf "dangling=true") 2>/dev/null || true
        log "INFO: Removed $dangling_count dangling image(s)"
    fi
}

# Remove unused volumes
cleanup_volumes() {
    log "INFO: Removing unused volumes..."
    docker volume prune -f &> /dev/null
    log "INFO: Volume cleanup completed"
}

# Display disk space saved
show_savings() {
    log "INFO: Running docker system df to show space usage..."
    docker system df
}

# Main cleanup function
main() {
    log "========================================"
    log "Starting Docker cleanup process"
    log "========================================"
    
    check_docker
    cleanup_containers
    cleanup_images
    cleanup_volumes
    show_savings
    
    log "========================================"
    log "Docker cleanup completed successfully"
    log "========================================"
}

main "$@"
