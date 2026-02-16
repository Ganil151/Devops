#!/bin/bash
# Nginx Reverse Proxy Setup Wizard
# Author: Senior DevOps Engineer

DOMAIN=$1
PORT=$2
CONF_DIR="/etc/nginx/sites-available"
ENABLED_DIR="/etc/nginx/sites-enabled"

if [ -z "$DOMAIN" ] || [ -z "$PORT" ]; then
    echo "Usage: $0 <domain> <backend-port>"
    exit 1
fi

CONFIG_FILE="$CONF_DIR/$DOMAIN"

echo "Creating Reverse Proxy for $DOMAIN -> localhost:$PORT"

cat > "$CONFIG_FILE" <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

echo "Config created at $CONFIG_FILE"

# Enable
ln -sf "$CONFIG_FILE" "$ENABLED_DIR/$DOMAIN"
echo "Symlink created in sites-enabled."

# Test
nginx -t

echo "Run 'systemctl reload nginx' to apply."
