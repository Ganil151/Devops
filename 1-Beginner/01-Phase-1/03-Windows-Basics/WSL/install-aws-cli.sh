#!/bin/bash

# ==============================================================================
# Script Name: install-aws-cli.sh
# Description: Installs or updates the AWS CLI v2 on WSL Ubuntu 25.04.
# Author: Antigravity AI
# ==============================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Starting AWS CLI v2 Installation...${NC}"

# 1. Install prerequisites
echo -e "${GREEN}>>> Installing prerequisites (unzip, curl)...${NC}"
sudo apt update && sudo apt install -y unzip curl

# 2. Download the AWS CLI bundle
echo -e "${GREEN}>>> Downloading AWS CLI v2 installer...${NC}"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# 3. Extract the installer
echo -e "${GREEN}>>> Extracting files...${NC}"
unzip -q awscliv2.zip

# 4. Run the installer
echo -e "${GREEN}>>> Running installation script...${NC}"
# Use --update flag in case it's already installed
sudo ./aws/install --update

# 5. Cleanup
echo -e "${GREEN}>>> Cleaning up temporary files...${NC}"
rm -rf aws/
rm awscliv2.zip

# 6. Verify installation
echo -e "${BLUE}>>> AWS CLI installed successfully!${NC}"
aws --version
