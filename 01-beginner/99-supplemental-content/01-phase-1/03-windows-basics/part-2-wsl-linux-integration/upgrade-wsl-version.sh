#!/bin/bash

# ==============================================================================
# Script Name: upgrade-wsl-version.sh
# Description: Configures WSL Ubuntu to allow upgrades to any latest release 
#              and initiates the upgrade process.
# Author: Antigravity AI
# ==============================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Preparing to upgrade WSL Ubuntu to the latest release...${NC}"

# 1. Update the Update Manager configuration
# Set Prompt=normal to allow upgrading to non-LTS releases (e.g., 24.10 -> 25.04)
echo -e "${GREEN}>>> Configuring /etc/update-manager/release-upgrades to 'Prompt=normal'...${NC}"
sudo sed -i 's/^Prompt=.*/Prompt=normal/' /etc/update-manager/release-upgrades

# 2. Update current system packages
echo -e "${GREEN}>>> Ensuring current packages are up to date...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y

# 3. Initiate the distribution upgrade
echo -e "${GREEN}>>> Starting do-release-upgrade...${NC}"
echo -e "${BLUE}NOTE: This process is interactive. Please follow the on-screen prompts.${NC}"
echo -e "${BLUE}If you are on WSL, ignore warnings about being in a SSH session if they appear.${NC}"

# Using -d (development) can sometimes be necessary if the release is very new,
# but for standard latest versions, we'll start with the standard command.
# If no new version is found, it will notify you.
sudo do-release-upgrade

echo -e "${GREEN}>>> Upgrade process initiated/complete. If a reboot was requested, close your WSL terminal and run 'wsl --shutdown' in PowerShell.${NC}"
