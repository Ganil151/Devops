#!/bin/bash

# ==============================================================================
# Script: boilerplate_config_drift_detector.sh
# Description: Compares active configuration against baseline
# DevOps Context: Compliance validation and drift detection
# ==============================================================================

set -euo pipefail

readonly BASELINE_FILE="${1:?Error: Baseline configuration file required}"
readonly ACTIVE_FILE="${2:?Error: Active configuration file required}"
readonly DIFF_FILE="config_drift_$(date +%Y%m%d_%H%M%S).diff"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Validate files exist
validate_files() {
    for file in "$BASELINE_FILE" "$ACTIVE_FILE"; do
        if [ ! -f "$file" ]; then
            log "ERROR" "File not found: $file"
            exit 1
        fi
    done
}

# Detect drift
detect_drift() {
    log "INFO" "Comparing configurations..."
    
    if diff -u "$BASELINE_FILE" "$ACTIVE_FILE" > "$DIFF_FILE"; then
        log "INFO" "✓ No configuration drift detected"
        rm "$DIFF_FILE"
        return 0
    else
        log "WARN" "⚠ Configuration drift detected!"
        log "INFO" "Drift report saved: $DIFF_FILE"
        
        echo "╔════════════════════════════════════════╗"
        echo "║   Configuration Drift Detected        ║"
        echo "╚════════════════════════════════════════╝"
        cat "$DIFF_FILE"
        
        return 1
    fi
}

main() {
    log "INFO" "Configuration Drift Detector"
    log "INFO" "  Baseline: $BASELINE_FILE"
    log "INFO" "  Active: $ACTIVE_FILE"
    
    validate_files
    detect_drift
}

main "$@"
