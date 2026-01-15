#!/bin/bash

# ==============================================================================
# Script: boilerplate_security_audit.sh
# Description: Scans codebase for hardcoded secrets (API keys, passwords)
# DevOps Context: Pre-commit security validation
# ==============================================================================

set -euo pipefail

readonly SCAN_DIR="${1:-.}"
readonly REPORT_FILE="security_audit_$(date +%Y%m%d_%H%M%S).txt"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Patterns to search for
declare -A PATTERNS=(
    ["AWS_ACCESS_KEY"]="AKIA[0-9A-Z]{16}"
    ["API_KEY"]="api[_-]?key[\"']?\s*[:=]\s*[\"'][^\"']{20,}"
    ["PASSWORD"]="password[\"']?\s*[:=]\s*[\"'][^\"']{8,}"
    ["PRIVATE_KEY"]="-----BEGIN (RSA |EC )?PRIVATE KEY-----"
    ["JWT_TOKEN"]="eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}"
)

# Scan files
scan_secrets() {
    log "INFO" "Scanning directory: $SCAN_DIR"
    
    local findings=0
    
    {
        echo "╔════════════════════════════════════════╗"
        echo "║   Security Audit Report                ║"
        echo "╠════════════════════════════════════════╣"
        echo "║ Directory: $SCAN_DIR"
        echo "║ Date: $(date)"
        echo "╚════════════════════════════════════════╝"
        echo ""
    } > "$REPORT_FILE"
    
    for pattern_name in "${!PATTERNS[@]}"; do
        pattern="${PATTERNS[$pattern_name]}"
        
        log "INFO" "Searching for: $pattern_name"
        
        local matches
        matches=$(grep -r -i -E "$pattern" "$SCAN_DIR" \
            --exclude-dir={.git,node_modules,.terraform,venv} \
            --exclude="*.{log,png,jpg,svg}" \
            2>/dev/null || true)
        
        if [ -n "$matches" ]; then
            {
                echo "=== $pattern_name DETECTED ==="
                echo "$matches"
                echo ""
            } >> "$REPORT_FILE"
            findings=$((findings + 1))
        fi
    done
    
    if [ $findings -eq 0 ]; then
        echo "✓ No secrets detected" >> "$REPORT_FILE"
        log "INFO" "✓ No secrets found"
    else
        log "WARN" "⚠ $findings potential secrets detected!"
    fi
    
    log "INFO" "Report saved: $REPORT_FILE"
}

main() {
    log "INFO" "Starting security audit"
    scan_secrets
    log "INFO" "✓  Audit complete"
}

main "$@"
