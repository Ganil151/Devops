#!/bin/bash
set -euo pipefail

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

install_dependencies() {
  log "Installing dependencies..."
  sudo yum update -y
  sudo yum install -y yum-utils
}

install_terraform() {
  log "Installing Terraform..."
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum -y install terraform

  # Verify Terraform installation
  if ! command -v terraform &> /dev/null; then
    log "Terraform installation failed."
    exit 1
  fi
}

change_hostname() {
  log "Changing hostname..."
  sudo hostnamectl set-hostname "terraform-server"
}

configure_terraform() {
  log "Configuring Terraform project..."
  mkdir -p ~/jenkins
  chmod 700 ~/jenkins
  cd ~/jenkins
  mv ./scripts/modules/*.tf ~/jenkins/
}

init_terraform() {
  log "Initializing Terraform..."
  terraform init
}

plan_terraform() {
  log "Planning Terraform changes..."
  terraform plan
}

apply_terraform() {
  log "Applying Terraform changes..."
  terraform apply -auto-approve
}

# Main Execution
install_dependencies
install_terraform
change_hostname
configure_terraform
init_terraform
plan_terraform
apply_terraform

log "Terraform setup complete. Run:"
log "cd ~/jenkins && terraform init && terraform plan"