# System Configuration

## User Management

### Creating Users and Groups

```yaml
#cloud-config

# Create users
users:
  - name: developer
    groups: sudo, docker, developers
    shell: /bin/bash
    home: /home/developer
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$rounds=4096$salt$hash...  # encrypted password
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E... developer@company.com
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... developer@laptop

  - name: service-account
    system: true
    home: /var/lib/service-account
    shell: /bin/false
    groups: service-group

# Create groups
groups:
  - developers
  - service-group: [service-account]
```

## Package Management

### Installing and Configuring Packages

```yaml
#cloud-config

# Update package database
package_update: true

# Upgrade all packages
package_upgrade: true

# Reboot if required after upgrade
package_reboot_if_required: true

# Install packages
packages:
  - nginx
  - postgresql
  - redis-server
  - nodejs
  - npm
  - python3-pip
  - docker.io
  - git
  - curl
  - wget
  - vim
  - htop

# Configure package repositories
apt:
  sources:
    docker:
      source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable"
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
    nodejs:
      source: "deb https://deb.nodesource.com/node_16.x $RELEASE main"
      keyid: 68576280
```

## File and Directory Management

### Creating Files and Directories

```yaml
#cloud-config

write_files:
  # Nginx configuration
  - path: /etc/nginx/sites-available/myapp
    content: |
      server {
          listen 80;
          server_name myapp.example.com;
          
          location / {
              proxy_pass http://localhost:3000;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
          }
      }
    permissions: '0644'
    owner: root:root

  # Application configuration
  - path: /opt/app/config.json
    content: |
      {
        "database": {
          "host": "localhost",
          "port": 5432,
          "name": "myapp"
        },
        "redis": {
          "host": "localhost",
          "port": 6379
        }
      }
    permissions: '0600'
    owner: app:app

  # Systemd service file
  - path: /etc/systemd/system/myapp.service
    content: |
      [Unit]
      Description=My Application
      After=network.target postgresql.service redis.service
      
      [Service]
      Type=simple
      User=app
      WorkingDirectory=/opt/app
      ExecStart=/usr/bin/node server.js
      Restart=always
      RestartSec=10
      
      [Install]
      WantedBy=multi-user.target
    permissions: '0644'

  # Environment file
  - path: /opt/app/.env
    content: |
      NODE_ENV=production
      PORT=3000
      DATABASE_URL=postgresql://user:pass@localhost/myapp
      REDIS_URL=redis://localhost:6379
    permissions: '0600'
    owner: app:app

# Create directories
runcmd:
  - mkdir -p /opt/app/logs
  - mkdir -p /var/lib/myapp
  - chown -R app:app /opt/app
  - chown -R app:app /var/lib/myapp
```

## Service Management

### Configuring and Starting Services

```yaml
#cloud-config

# Services to enable/disable
services:
  enabled:
    - nginx
    - postgresql
    - redis-server
    - docker
  disabled:
    - apache2

# Commands to configure services
runcmd:
  # Configure PostgreSQL
  - sudo -u postgres createdb myapp
  - sudo -u postgres createuser --createdb myapp_user
  - sudo -u postgres psql -c "ALTER USER myapp_user PASSWORD 'secure_password';"
  
  # Configure Nginx
  - ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
  - rm -f /etc/nginx/sites-enabled/default
  - nginx -t && systemctl reload nginx
  
  # Configure application service
  - systemctl daemon-reload
  - systemctl enable myapp
  - systemctl start myapp
  
  # Configure Docker
  - usermod -aG docker ubuntu
  - systemctl enable docker
  - systemctl start docker
```

## SSH Configuration

### SSH Keys and Security

```yaml
#cloud-config

# SSH configuration
ssh_pwauth: false
disable_root: true

# SSH keys for users
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2E... admin@company.com
  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... backup@company.com

# SSH daemon configuration
write_files:
  - path: /etc/ssh/sshd_config.d/99-custom.conf
    content: |
      # Custom SSH configuration
      PermitRootLogin no
      PasswordAuthentication no
      PubkeyAuthentication yes
      AuthorizedKeysFile .ssh/authorized_keys
      
      # Security settings
      Protocol 2
      MaxAuthTries 3
      ClientAliveInterval 300
      ClientAliveCountMax 2
      
      # Allowed users
      AllowUsers ubuntu developer admin
    permissions: '0644'

runcmd:
  - systemctl restart sshd
```