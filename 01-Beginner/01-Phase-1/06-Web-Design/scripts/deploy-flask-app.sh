#!/bin/bash

#############################################################################
# Script: deploy-flask-app.sh
# Description: Automated deployment for Flask applications with Gunicorn/Nginx
# Author: Senior DevOps Engineer
# Version: 1.0 (Golden Standard)
#############################################################################

set -e

APP_DIR=${1:-"/var/www/flask-app"}
REPO=${2:-""}
VENV_DIR="$APP_DIR/venv"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   FLASK APP DEPLOYER${NC}"
echo -e "${CYAN}========================================${NC}"

# 1. Install Dependencies
echo -e "\n${CYAN}[1/5] Installing System Dependencies...${NC}"
apt-get update
apt-get install -y python3-pip python3-venv nginx

# 2. Setup App Directory
echo -e "\n${CYAN}[2/5] Setting up Directory: $APP_DIR${NC}"
if [ ! -d "$APP_DIR" ]; then
    mkdir -p "$APP_DIR"
    chown -R $SUDO_USER:$SUDO_USER "$APP_DIR"
fi

if [ -n "$REPO" ]; then
    if [ -d "$APP_DIR/.git" ]; then
        cd "$APP_DIR" && git pull
    else
        git clone "$REPO" "$APP_DIR"
    fi
fi

# 3. Virtual Environment
echo -e "\n${CYAN}[3/5] Setup VirtualEnv...${NC}"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
pip install -r "$APP_DIR/requirements.txt" || echo "No requirements.txt found"

# 4. Gunicorn Setup
echo -e "\n${CYAN}[4/5] Install Gunicorn...${NC}"
pip install gunicorn

# 5. Service Creation
echo -e "\n${CYAN}[5/5] Creating Systemd Service...${NC}"
cat > /etc/systemd/system/flaskapp.service <<EOF
[Unit]
Description=Gunicorn instance to serve flask application
After=network.target

[Service]
User=$SUDO_USER
Group=www-data
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_DIR/bin"
ExecStart=$VENV_DIR/bin/gunicorn --workers 3 --bind unix:flaskapp.sock -m 007 wsgi:app

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flaskapp
systemctl restart flaskapp

echo -e "\n${GREEN}Deployment Complete!${NC}"
