#!/bin/bash

# ==============================================================================
# Script: boilerplate_cicd_runner.sh
# Description: Full CI/CD pipeline - Lint → Build → Test → Deploy
# DevOps Context: GitLab/Jenkins integration
# ==============================================================================

set -euo pipefail

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$1] $2"
}

# Stage 1: Lint
run_lint() {
    log "STAGE" "1/4: Running linters..."
    
    shellcheck *.sh || log "WARN" "ShellCheck warnings found"
    
    log "INFO" "✓ Lint complete"
}

# Stage 2: Build
run_build() {
    log "STAGE" "2/4: Building application..."
    
    docker build -t myapp:latest .
    
    log "INFO" "✓ Build complete"
}

# Stage 3: Test
run_test() {
    log "STAGE" "3/4: Running tests..."
    
    docker run --rm myapp:latest npm test || {
        log "ERROR" "Tests failed"
        return 1
    }
    
    log "INFO" "✓ Tests passed"
}

# Stage 4: Deploy
run_deploy() {
    log "STAGE" "4/4: Deploying application..."
    
    docker-compose up -d
    
    log "INFO" "✓ Deployment complete"
}

# Main pipeline
main() {
    log "INFO" "========================================"
    log "INFO" "Starting CI/CD Pipeline"
    log "INFO" "========================================"
    
    run_lint
    run_build
    run_test
    run_deploy
    
    log "INFO" "========================================"
    log "INFO" "✓ Pipeline completed successfully!"
    log "INFO" "========================================"
}

main "$@"
