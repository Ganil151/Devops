#!/bin/bash

# ==============================================================================
# Script: boilerplate_docker_compose_templater.sh
# Description: Generates docker-compose.yml from templates with variable substitution
# DevOps Context: Environment-specific container deployments
# ==============================================================================

set -euo pipefail

readonly TEMPLATE_FILE="${1:-docker-compose.template.yml}"
readonly OUTPUT_FILE="docker-compose.yml"
readonly ENV_FILE=".env"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Load environment variables
load_env() {
    if [ ! -f "$ENV_FILE" ]; then
        log "ERROR" ".env file not found. Creating template..."
        create_env_template
        exit 1
    fi
    
    log "INFO" "Loading environment variables from $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
}

# Create .env template
create_env_template() {
    cat > "$ENV_FILE" <<'EOF'
# Application Configuration
APP_PORT=8080
APP_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=changeme

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
EOF
    
    log "INFO" "✓ Template .env created. Please configure it."
}

# Create template if missing
create_compose_template() {
    cat > "$TEMPLATE_FILE" <<'EOF'
version: '3.8'

services:
  app:
    image: myapp:latest
    container_name: myapp-${APP_ENV}
    ports:
      - "${APP_PORT}:8080"
    environment:
      - APP_ENV=${APP_ENV}
      - DB_HOST=${DB_HOST}
      - DB_PORT=${DB_PORT}
      - DB_NAME=${DB_NAME}
    depends_on:
      - database
      - redis

  database:
    image: postgres:14
    container_name: postgres-${APP_ENV}
    environment:
      - POSTGRES_DB=${DB_NAME}
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    ports:
      - "${DB_PORT}:5432"
    volumes:
      - db_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    container_name: redis-${APP_ENV}
    ports:
      - "${REDIS_PORT}:6379"

volumes:
  db_data:
EOF
    
    log "INFO" "✓ Template docker-compose created"
}

# Substitute variables
generate_compose() {
    log "INFO" "Generating $OUTPUT_FILE from template..."
    
    if [ ! -f "$TEMPLATE_FILE" ]; then
        log "WARN" "Template not found. Creating default..."
        create_compose_template
    fi
    
    # Use envsubst for variable substitution
    if command -v envsubst &> /dev/null; then
        envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
    else
        # Fallback: manual substitution
        cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
        for var in $(grep -o '\${[^}]*}' "$TEMPLATE_FILE" | sed 's/[${}]//g' | sort -u); do
            value="${!var:-}"
            sed -i "s|\${$var}|$value|g" "$OUTPUT_FILE"
        done
    fi
    
    log "INFO" "✓ Docker Compose file generated: $OUTPUT_FILE"
}

main() {
    log "INFO" "Docker Compose Template Generator"
    load_env
    generate_compose
    log "INFO" "✓ Ready! Run: docker-compose up -d"
}

main "$@"
