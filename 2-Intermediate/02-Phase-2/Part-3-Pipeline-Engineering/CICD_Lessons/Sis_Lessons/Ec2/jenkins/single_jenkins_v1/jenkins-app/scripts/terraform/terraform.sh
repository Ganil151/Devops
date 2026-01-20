#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Function to install Terraform
install_terraform() {
  echo "Installing Terraform..."

  # Define the Terraform version to install (optional: fetch the latest version dynamically)
  TERRAFORM_VERSION="1.5.7"  # Replace with the desired version or leave blank to fetch the latest

  # Fetch the latest Terraform version if not explicitly defined
  if [ -z "$TERRAFORM_VERSION" ]; then
    echo "Fetching the latest Terraform version..."
    TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r '.current_version')
    echo "Latest Terraform version: $TERRAFORM_VERSION"
  fi

  # Define the download URL for Terraform
  TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

  # Create a temporary directory for downloading Terraform
  TEMP_DIR=$(mktemp -d)
  echo "Downloading Terraform to temporary directory: $TEMP_DIR"

  # Download Terraform binary
  echo "Downloading Terraform version $TERRAFORM_VERSION..."
  wget -q "$TERRAFORM_URL" -O "$TEMP_DIR/terraform.zip"

  # Unzip the Terraform binary
  echo "Unzipping Terraform binary..."
  unzip -q "$TEMP_DIR/terraform.zip" -d /usr/local/bin

  # Verify the installation
  echo "Verifying Terraform installation..."
  if terraform --version; then
    echo "Terraform installed successfully!"
  else
    echo "Failed to install Terraform."
    exit 1
  fi

  # Clean up temporary files
  echo "Cleaning up temporary files..."
  rm -rf "$TEMP_DIR"
}

# Main execution
install_terraform