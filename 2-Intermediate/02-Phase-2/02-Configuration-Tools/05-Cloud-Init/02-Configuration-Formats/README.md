# Configuration Formats

## Cloud-Config (YAML)

The most common format for Cloud-Init configuration:

```yaml
#cloud-config
# This is a cloud-config file

# Basic system configuration
hostname: my-server
fqdn: my-server.example.com
timezone: UTC

# Package management
package_update: true
package_upgrade: true
packages:
  - nginx
  - git
  - curl

# User management
users:
  - name: admin
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E...

# File creation
write_files:
  - path: /etc/motd
    content: |
      Welcome to the server!
      Configured with Cloud-Init
    permissions: '0644'

# Commands to run
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
```

## Shell Scripts

Execute shell commands during boot:

```bash
#!/bin/bash
# This is a shell script

# Update system
apt-get update
apt-get upgrade -y

# Install packages
apt-get install -y nginx docker.io

# Configure services
systemctl enable nginx
systemctl start nginx
systemctl enable docker
systemctl start docker

# Create directories
mkdir -p /opt/app
chown ubuntu:ubuntu /opt/app

echo "Setup completed at $(date)" >> /var/log/setup.log
```

## MIME Multi-Part

Combine multiple configuration types:

```
Content-Type: multipart/mixed; boundary="===============1234567890=="
MIME-Version: 1.0

--===============1234567890==
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0

#cloud-config
packages:
  - nginx

--===============1234567890==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0

#!/bin/bash
echo "Custom script execution"
systemctl start nginx

--===============1234567890==--
```

## Include Files

Reference external configurations:

```yaml
#cloud-config
#include
- http://example.com/cloud-config.yml
- file:///etc/cloud/additional-config.yml
```