#!/bin/bash
#===============================================================================
# Jumphost User Data Script - Install Tools
# This script runs on the bastion host EC2 instance on first boot
# Installs common tools needed for infrastructure management
#
# Usage: This script is executed via user_data in the EC2 instance
#        It will be base64 encoded and passed to the instance
#
# Exit Codes:
#   0 - Success
#   1 - Critical failure (system not ready)
#   2 - Partial failure (some tools failed to install)
#===============================================================================

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="jumphost-install-tools"
readonly SCRIPT_VERSION="1.1.0"
readonly LOG_FILE="/var/log/${SCRIPT_NAME}.log"
readonly SIGNAL_FILE="/var/log/${SCRIPT_NAME}.complete"
readonly BOOT_WAIT_SECONDS=60
readonly MAX_RETRIES=3
readonly RETRY_DELAY=5

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
INSTALL_SUCCESS=0
INSTALL_FAILED=0

# Trap errors and log them
trap 'log_error "Script failed at line $LINENO with exit code $?"' ERR
trap 'cleanup' EXIT

JUMPHOST_NAME=$(hostname)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unknown")

# Log function - logs to both stdout and file
log_info() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "${LOG_FILE}"
}

log_warn() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1"
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "${LOG_FILE}"
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "${LOG_FILE}"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1" | tee -a "${LOG_FILE}"
}

# Cleanup function
cleanup() {
    log_info "Performing cleanup..."
    rm -f /tmp/awscliv2.zip /tmp/aws /tmp/kubectl /tmp/eksctl /tmp/terragrunt /tmp/yq 2>/dev/null || true
    rm -rf /tmp/aws /tmp/helm 2>/dev/null || true
}

# Wait for system to be ready
wait_for_system_ready() {
    log_info "Waiting ${BOOT_WAIT_SECONDS} seconds for system to boot and stabilize..."
    sleep "${BOOT_WAIT_SECONDS}"
    
    log_info "Checking system readiness..."
    
    # Wait for network
    local retry=0
    while ! ping -c 1 8.8.8.8 &>/dev/null && [ $retry -lt 10 ]; do
        log_warn "Network not ready, waiting... (attempt $((retry + 1))/10)"
        sleep 5
        ((retry++))
    done
    
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        log_error "Network not available after waiting"
        return 1
    fi
    
    log_info "System is ready. Instance ID: ${INSTANCE_ID}"
    return 0
}

# Function to retry a command
retry_command() {
    local cmd="$1"
    local description="$2"
    local retry=0
    
    while [ $retry -lt "${MAX_RETRIES}" ]; do
        log_info "Attempting: ${description} (attempt $((retry + 1))/${MAX_RETRIES})"
        if eval "${cmd}"; then
            return 0
        fi
        ((retry++))
        if [ $retry -lt "${MAX_RETRIES}" ]; then
            log_warn "Failed, retrying in ${RETRY_DELAY} seconds..."
            sleep "${RETRY_DELAY}"
        fi
    done
    
    log_error "Failed after ${MAX_RETRIES} attempts: ${description}"
    return 1
}

# Function to check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Function to install with error handling
install_tool() {
    local tool_name="$1"
    local install_cmd="$2"
    local check_cmd="$3"
    
    log_info "Installing ${tool_name}..."
    
    if eval "${check_cmd}" &>/dev/null; then
        log_info "${tool_name} already installed, skipping"
        ((INSTALL_SUCCESS++))
        return 0
    fi
    
    if eval "${install_cmd}"; then
        if eval "${check_cmd}" &>/dev/null; then
            log_info "${tool_name} installed successfully"
            ((INSTALL_SUCCESS++))
            return 0
        else
            log_error "${tool_name} installation verification failed"
            ((INSTALL_FAILED++))
            return 1
        fi
    else
        log_error "${tool_name} installation failed"
        ((INSTALL_FAILED++))
        return 1
    fi
}

log_info "=============================================="
log_info "${SCRIPT_NAME} v${SCRIPT_VERSION}"
log_info "Jumphost: ${JUMPHOST_NAME}"
log_info "Instance: ${INSTANCE_ID}"
log_info "=============================================="

# Wait for system to be ready
if ! wait_for_system_ready; then
    log_error "System not ready, exiting"
    exit 1
fi

log_info "Starting tool installation..."

#===============================================================================
# Update system packages
#===============================================================================
log_info "Updating system packages..."
if sudo yum update -y; then
    log_info "System packages updated successfully"
else
    log_warn "System packages update failed, continuing..."
fi

#===============================================================================
# Install AWS CLI v2
#===============================================================================
install_tool "AWS CLI v2" \
    "curl -s 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/tmp/awscliv2.zip' && unzip -q /tmp/awscliv2.zip -d /tmp && sudo /tmp/aws/install --update" \
    "command -v aws && aws --version &>/dev/null"

log_info "AWS CLI: $(aws --version 2>&1 | head -1 || echo 'N/A')"

#===============================================================================
# Install Terraform
#===============================================================================
install_tool "Terraform" \
    "sudo yum install -y yum-utils && sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && sudo yum install -y terraform" \
    "command -v terraform"

log_info "Terraform: $(terraform --version 2>&1 | head -1 || echo 'N/A')"

#===============================================================================
# Install kubectl
#===============================================================================
install_tool "kubectl" \
    "KUBECTL_VERSION=\$(curl -sL https://dl.k8s.io/release/stable.txt 2>/dev/null || echo 'v1.35.0') && curl -sLO 'https://dl.k8s.io/release/\${KUBECTL_VERSION}/bin/linux/amd64/kubectl' && chmod +x kubectl && sudo mv kubectl /usr/local/bin/" \
    "command -v kubectl"

log_info "kubectl: $(kubectl version --client --short 2>&1 || kubectl version --client 2>&1 | head -1 || echo 'N/A')"

#===============================================================================
# Install Helm
#===============================================================================
install_tool "Helm" \
    "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash" \
    "command -v helm"

log_info "Helm: $(helm version --short 2>&1 || echo 'N/A')"

#===============================================================================
# Install eksctl
#===============================================================================
install_tool "eksctl" \
    "curl -sL 'https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz' | tar xz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin/" \
    "command -v eksctl"

log_info "eksctl: $(eksctl version 2>&1 | head -1 || echo 'N/A')"

#===============================================================================
# Install aws-iam-authenticator
#===============================================================================
install_tool "aws-iam-authenticator" \
    "curl -sL -o /tmp/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest/download/aws-iam-authenticator && chmod +x /tmp/aws-iam-authenticator && sudo mv /tmp/aws-iam-authenticator /usr/local/bin/" \
    "command -v aws-iam-authenticator"

log_info "aws-iam-authenticator: $(aws-iam-authenticator version 2>&1 | head -1 || echo 'N/A')"

#===============================================================================
# Install Terragrunt
#===============================================================================
install_tool "Terragrunt" \
    "curl -sL https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64 -o /tmp/terragrunt && chmod +x /tmp/terragrunt && sudo mv /tmp/terragrunt /usr/local/bin/" \
    "command -v terragrunt"

log_info "Terragrunt: $(terragrunt --version 2>&1 || echo 'N/A')"

#===============================================================================
# Install Git
#===============================================================================
install_tool "Git" \
    "sudo yum install -y git" \
    "command -v git"

log_info "Git: $(git --version 2>&1 || echo 'N/A')"

#===============================================================================
# Install jq (JSON processor)
#===============================================================================
install_tool "jq" \
    "sudo yum install -y jq" \
    "command -v jq"

log_info "jq: $(jq --version 2>&1 || echo 'N/A')"

#===============================================================================
# Install yq (YAML processor)
#===============================================================================
install_tool "yq" \
    "curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq" \
    "command -v yq"

log_info "yq: $(yq --version 2>&1 || echo 'N/A')"

#===============================================================================
# Install Python and pip
#===============================================================================
install_tool "Python3" \
    "sudo yum install -y python3 python3-pip" \
    "command -v python3"

log_info "Python: $(python3 --version 2>&1 || echo 'N/A')"

#===============================================================================
# Install Docker (optional - for container management)
#===============================================================================
log_info "Installing Docker..."
if ! command -v docker &>/dev/null; then
    if sudo amazon-linux-extras install -y docker && \
       sudo systemctl start docker && \
       sudo systemctl enable docker && \
       sudo usermod -a -G docker ec2-user; then
        log_info "Docker installed successfully: $(docker --version 2>&1)"
        ((INSTALL_SUCCESS++))
    else
        log_warn "Docker installation failed"
        ((INSTALL_FAILED++))
    fi
else
    log_info "Docker already installed: $(docker --version 2>&1)"
    ((INSTALL_SUCCESS++))
fi

#===============================================================================
# Install CloudWatch Agent (optional)
#===============================================================================
log_info "Installing CloudWatch Agent..."
if ! command -v amazon-cloudwatch-agent-ctl &>/dev/null; then
    if sudo yum install -y amazon-cloudwatch-agent; then
        log_info "CloudWatch Agent installed successfully"
        ((INSTALL_SUCCESS++))
    else
        log_warn "CloudWatch Agent installation failed"
        ((INSTALL_FAILED++))
    fi
else
    log_info "CloudWatch Agent already installed"
    ((INSTALL_SUCCESS++))
fi

#===============================================================================
# Configure AWS SSM Session Manager
#===============================================================================
log_info "Checking SSM Session Manager support..."
if command -v amazon-ssm-agent &>/dev/null; then
    if sudo systemctl enable amazon-ssm-agent && \
       sudo systemctl start amazon-ssm-agent; then
        log_info "SSM Agent configured and started"
        ((INSTALL_SUCCESS++))
    else
        log_warn "SSM Agent configuration failed"
        ((INSTALL_FAILED++))
    fi
else
    log_warn "SSM Agent not installed - install for session manager access"
    ((INSTALL_FAILED++))
fi

#===============================================================================
# Final cleanup
#===============================================================================
log_info "Cleaning up yum cache..."
sudo yum clean all || true

#===============================================================================
# Create signal file to indicate completion
#===============================================================================
echo "Completed at $(date)" > "${SIGNAL_FILE}"
echo "Success: ${INSTALL_SUCCESS}" >> "${SIGNAL_FILE}"
echo "Failed: ${INSTALL_FAILED}" >> "${SIGNAL_FILE}"

#===============================================================================
# Summary
#===============================================================================
echo ""
log_info "=============================================="
log_info "Jumphost tools installation complete!"
log_info "=============================================="
echo ""
log_info "Installation Summary:"
log_info "  - Successful: ${INSTALL_SUCCESS}"
log_info "  - Failed:     ${INSTALL_FAILED}"
echo ""
log_info "Installed tools:"
echo "  - AWS CLI:          $(aws --version 2>&1 | head -1 || echo 'N/A')"
echo "  - Terraform:        $(terraform --version 2>&1 | head -1 || echo 'N/A')"
echo "  - Terragrunt:       $(terragrunt --version 2>&1 || echo 'N/A')"
echo "  - kubectl:          $(kubectl version --client --short 2>&1 || kubectl version --client 2>&1 | head -1 || echo 'N/A')"
echo "  - Helm:             $(helm version --short 2>&1 || echo 'N/A')"
echo "  - eksctl:           $(eksctl version 2>&1 | head -1 || echo 'N/A')"
echo "  - aws-iam-auth:     $(aws-iam-authenticator version 2>&1 | head -1 || echo 'N/A')"
echo "  - Git:              $(git --version 2>&1 || echo 'N/A')"
echo "  - jq:               $(jq --version 2>&1 || echo 'N/A')"
echo "  - yq:               $(yq --version 2>&1 || echo 'N/A')"
echo "  - Python:           $(python3 --version 2>&1 || echo 'N/A')"
echo "  - Docker:           $(docker --version 2>&1 || echo 'N/A')"
echo ""
log_info "Log file: ${LOG_FILE}"
log_info "Signal file: ${SIGNAL_FILE}"
echo ""

# Exit with appropriate code
if [ "${INSTALL_FAILED}" -gt 0 ]; then
    log_warn "Some installations failed. Check ${LOG_FILE} for details."
    exit 2
fi

log_info "Jumphost is ready for use!"
exit 0
