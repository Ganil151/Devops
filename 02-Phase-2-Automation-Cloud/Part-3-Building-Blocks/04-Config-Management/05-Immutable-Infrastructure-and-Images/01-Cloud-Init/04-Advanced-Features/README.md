# Advanced Features

## Network Configuration

### Static IP and Advanced Networking

```yaml
#cloud-config

# Network configuration (Netplan format)
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
        search:
          - example.com
          - internal.local

# VLAN configuration
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
  vlans:
    vlan100:
      id: 100
      link: eth0
      addresses:
        - 10.0.100.10/24
    vlan200:
      id: 200
      link: eth0
      addresses:
        - 10.0.200.10/24

# Bonded interfaces
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
    eth1:
      dhcp4: false
  bonds:
    bond0:
      interfaces:
        - eth0
        - eth1
      parameters:
        mode: 802.3ad
        lacp-rate: fast
        mii-monitor-interval: 100
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
```

## Custom Cloud-Init Modules

### Writing Custom Modules

```python
# /etc/cloud/cloud.cfg.d/99-custom-modules.cfg
cloud_config_modules:
  - custom_app_deploy

# /usr/lib/python3/dist-packages/cloudinit/config/cc_custom_app_deploy.py
"""
Custom Cloud-Init module for application deployment
"""

from cloudinit import log as logging
from cloudinit.settings import PER_INSTANCE
import subprocess
import os

LOG = logging.getLogger(__name__)
frequency = PER_INSTANCE

def handle(name, cfg, cloud, log, args):
    """
    Deploy custom application based on configuration
    """
    app_config = cfg.get('custom_app_deploy', {})
    
    if not app_config:
        log.debug("No custom_app_deploy configuration found")
        return
    
    app_name = app_config.get('name')
    app_version = app_config.get('version', 'latest')
    app_source = app_config.get('source')
    app_path = app_config.get('path', '/opt/app')
    
    if not app_name or not app_source:
        log.error("Application name and source are required")
        return
    
    log.info(f"Deploying {app_name} version {app_version}")
    
    try:
        # Create application directory
        os.makedirs(app_path, exist_ok=True)
        
        # Download application
        if app_source.startswith('git+'):
            repo_url = app_source[4:]  # Remove 'git+' prefix
            subprocess.run(['git', 'clone', repo_url, app_path], check=True)
        elif app_source.startswith('http'):
            subprocess.run(['wget', '-O', f'{app_path}/app.tar.gz', app_source], check=True)
            subprocess.run(['tar', '-xzf', f'{app_path}/app.tar.gz', '-C', app_path], check=True)
        
        # Set permissions
        subprocess.run(['chown', '-R', 'app:app', app_path], check=True)
        
        log.info(f"Successfully deployed {app_name}")
        
    except subprocess.CalledProcessError as e:
        log.error(f"Failed to deploy {app_name}: {e}")
    except Exception as e:
        log.error(f"Unexpected error deploying {app_name}: {e}")
```

### Using Custom Module

```yaml
#cloud-config

# Custom application deployment
custom_app_deploy:
  name: myapp
  version: v1.2.3
  source: git+https://github.com/company/myapp.git
  path: /opt/myapp

# Create application user
users:
  - name: app
    system: true
    home: /opt/myapp
    shell: /bin/bash
```

## Debugging and Troubleshooting

### Debug Configuration

```yaml
#cloud-config

# Enable debug logging
debug:
  verbose: true

# Custom logging configuration
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-debug.cfg
    content: |
      # Debug configuration
      datasource_list: ['Ec2', 'None']
      
      # Logging configuration
      def_log_file: /var/log/cloud-init.log
      log_cfgs:
        - [handlers, keys, consoleHandler, cloudLogHandler]
        - [handler_consoleHandler, level, DEBUG]
        - [handler_cloudLogHandler, level, DEBUG]
    permissions: '0644'

# Debug commands
runcmd:
  - echo "Cloud-Init debug information" > /var/log/debug-info.log
  - cloud-init query --all >> /var/log/debug-info.log
  - cloud-init status --long >> /var/log/debug-info.log
```

### Troubleshooting Commands

```bash
# Check cloud-init status
cloud-init status --long

# View logs
sudo tail -f /var/log/cloud-init.log
sudo tail -f /var/log/cloud-init-output.log

# Query configuration
cloud-init query --all
cloud-init query userdata
cloud-init query metadata

# Validate configuration
cloud-init schema --config-file /path/to/config.yml

# Clean and re-run (for testing)
sudo cloud-init clean --logs
sudo cloud-init init --local
sudo cloud-init init
sudo cloud-init modules --mode config
sudo cloud-init modules --mode final
```

## Enterprise Patterns

### Multi-Environment Configuration

```yaml
#cloud-config

# Environment-specific configuration
{% if environment == "production" %}
packages:
  - nginx
  - postgresql-12
  - redis-server
  - monitoring-agent

write_files:
  - path: /etc/environment
    content: |
      ENVIRONMENT=production
      LOG_LEVEL=warn
      DATABASE_POOL_SIZE=20
    permissions: '0644'

{% elif environment == "staging" %}
packages:
  - nginx
  - postgresql-12
  - redis-server

write_files:
  - path: /etc/environment
    content: |
      ENVIRONMENT=staging
      LOG_LEVEL=info
      DATABASE_POOL_SIZE=10
    permissions: '0644'

{% else %}
packages:
  - nginx
  - postgresql-12

write_files:
  - path: /etc/environment
    content: |
      ENVIRONMENT=development
      LOG_LEVEL=debug
      DATABASE_POOL_SIZE=5
    permissions: '0644'
{% endif %}
```

### Configuration Management Integration

```yaml
#cloud-config

# Bootstrap configuration management
packages:
  - python3-pip
  - git

runcmd:
  # Install Ansible
  - pip3 install ansible

  # Clone configuration repository
  - git clone https://github.com/company/ansible-configs.git /opt/ansible

  # Run Ansible playbook
  - cd /opt/ansible && ansible-playbook -i inventory/production site.yml --connection=local

  # Install configuration management agent
  - curl -L https://omnitruck.chef.io/install.sh | sudo bash
  - mkdir -p /etc/chef
  - echo 'chef_server_url "https://chef.company.com"' > /etc/chef/client.rb
  - echo 'validation_client_name "company-validator"' >> /etc/chef/client.rb

# Schedule regular configuration runs
write_files:
  - path: /etc/cron.d/config-management
    content: |
      # Run configuration management every 30 minutes
      */30 * * * * root /usr/bin/chef-client
    permissions: '0644'
```