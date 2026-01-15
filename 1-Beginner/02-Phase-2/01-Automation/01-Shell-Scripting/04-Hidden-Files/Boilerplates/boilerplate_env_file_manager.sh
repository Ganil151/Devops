#!/bin/bash

# ==============================================================================
# Script: boilerplate_env_file_manager.sh
# Description:  Safely manages .env files with validation
# DevOps Context: Secret management and configuration validation
# ==============================================================================

set -euo pipefail

readonly ENV_FILE=".env"
readonly ENV_TEMPLATE=".env.template"
readonly ENV_EXAMPLE=".env.example"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Create template
create_template() {
    cat > "$ENV_TEMPLATE" <<'EOF'
# Application Settings
APP_NAME=myapp
APP_ENV=development
APP_PORT=3000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=${APP_NAME}_db
DB_USER=appuser
DB_PASSWORD=REQUIRED

# AWS Credentials (DO NOT COMMIT)
AWS_ACCESS_KEY_ID=REQUIRED
AWS_SECRET_ACCESS_KEY=REQUIRED
AWS_REGION=us-east-1

# API Keys (DO NOT COMMIT)
API_KEY=REQUIRED
EOF
    
    log "INFO" "✓ Template created: $ENV_TEMPLATE"
}

# Validate required variables
validate_env() {
    local missing=0
    local required_vars=("DB_PASSWORD" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "API_KEY")
    
    log "INFO" "Validating environment variables..."
    
    for var in "${required_vars[@]}"; do
        value=$(grep "^$var=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-)
        
        if [[ -z "$value" || "$value" == "REQUIRED" ]]; then
            log "ERROR" "Missing or unset: $var"
            missing=1
        fi
    done
    
    if [ $missing -eq 1 ]; then
        log "ERROR" "❌ Validation failed. Please set all required variables."
        return 1
    fi
    
    log "INFO" "✓  All required variables are set"
    return 0
}

# Check for sensitive data
check_git_safety() {
    if [ -f ".gitignore" ]; then
        if ! grep -q "^\.env$" .gitignore; then
            log "WARN" ".env is NOT in .gitignore!"
            log "WARN" "Adding .env to .gitignore..."
            echo ".env" >> .gitignore
        else
            log "INFO" "✓ .env is safely ignored by git"
        fi
    else
        log "WARN" "No .gitignore found. Creating..."
        echo ".env" > .gitignore
    fi
}

# Main
main() {
    log "INFO" "Environment File Manager"
    
    if [ ! -f "$ENV_FILE" ]; then
        log "WARN" ".env not found"
        
        if [ -f "$ENV_TEMPLATE" ]; then
            log "INFO" "Copying from template..."
            cp "$ENV_TEMPLATE" "$ENV_FILE"
        else
            create_template
            cp "$ENV_TEMPLATE" "$ENV_FILE"
        fi
        
        log "INFO" "✓ .env created. CONFIGURE IT BEFORE USE!"
        exit 0
    fi
    
    validate_env
    check_git_safety
    
    log "INFO" "✓ Environment configuration is ready"
}

main "$@"
