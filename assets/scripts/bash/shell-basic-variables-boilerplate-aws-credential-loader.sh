#!/bin/bash

# ==============================================================================
# Script: boilerplate_aws_credential_loader.sh
# Description: Loads AWS credentials from profiles for multi-account automation
# DevOps Context: Multi-account AWS automation
# ==============================================================================

set -euo pipefail

readonly AWS_PROFILE="${1:-default}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2"
}

# Load credentials
load_credentials() {
    log "INFO" "Loading AWS credentials for profile: $AWS_PROFILE"
    
    # Export AWS profile
    export AWS_PROFILE="$AWS_PROFILE"
    
    # Verify credentials
    if aws sts get-caller-identity &> /dev/null; then
        local account_id=$(aws sts get-caller-identity --query Account --output text)
        local user_arn=$(aws sts get-caller-identity --query Arn --output text)
        
        log "INFO" "Account: $account_id"
        log "INFO" "User/Role: $user_arn"
        log "INFO" "✓ Credentials loaded successfully"
        
        # Export for child processes
        export AWS_DEFAULT_REGION="${AWS_REGION:-us-east-1}"
        
        echo "export AWS_PROFILE=$AWS_PROFILE"
        echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
    else
        log "ERROR" "Failed to load credentials for profile: $AWS_PROFILE"
        exit 1
    fi
}

main() {
    load_credentials
    log "INFO" "Environment ready for AWS operations"
}

main "$@"
