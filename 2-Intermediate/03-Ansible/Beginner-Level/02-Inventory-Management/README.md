# Ansible Inventory Management

Complete guide to Ansible inventory management, including static and dynamic inventories, host patterns, and variable organization.

## Inventory Basics

### What is Inventory?

Inventory is a list of managed nodes (hosts) that Ansible can connect to and manage. It defines:
- Host addresses and connection details
- Host groupings for organized management
- Variables for hosts and groups
- Connection parameters and credentials

### Inventory Formats

#### INI Format
```ini
# inventory/hosts.ini
[webservers]
web1.example.com ansible_host=192.168.1.10
web2.example.com ansible_host=192.168.1.11

[databases]
db1.example.com ansible_host=192.168.1.20
db2.example.com ansible_host=192.168.1.21

[production:children]
webservers
databases

[webservers:vars]
http_port=80
max_clients=200

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

#### YAML Format
```yaml
# inventory/hosts.yml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
          ansible_host: 192.168.1.10
        web2.example.com:
          ansible_host: 192.168.1.11
      vars:
        http_port: 80
        max_clients: 200
    
    databases:
      hosts:
        db1.example.com:
          ansible_host: 192.168.1.20
        db2.example.com:
          ansible_host: 192.168.1.21
      vars:
        mysql_port: 3306
    
    production:
      children:
        webservers:
        databases:
  
  vars:
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

## Host Patterns and Groups

### Basic Host Patterns
```bash
# Target all hosts
ansible all -m ping

# Target specific group
ansible webservers -m ping

# Target specific host
ansible web1.example.com -m ping

# Target multiple groups
ansible webservers:databases -m ping

# Exclude hosts/groups
ansible all:!databases -m ping

# Intersection of groups
ansible webservers:&production -m ping

# Range patterns
ansible web[1:3].example.com -m ping
ansible 192.168.1.[10:20] -m ping
```

### Advanced Patterns
```bash
# Regex patterns
ansible ~web.*\.example\.com -m ping

# Combine patterns
ansible webservers:&production:!web3.example.com -m ping

# Use variables in patterns
ansible "group_{{ environment }}" -m ping
```

## Dynamic Inventory

### AWS EC2 Dynamic Inventory
```yaml
# aws_ec2.yml
plugin: aws_ec2
regions:
  - us-east-1
  - us-west-2

filters:
  instance-state-name: running
  tag:Environment: 
    - production
    - staging

keyed_groups:
  - key: tags.Environment
    prefix: env
  - key: tags.Role
    prefix: role
  - key: instance_type
    prefix: type

hostnames:
  - tag:Name
  - dns-name

compose:
  ansible_host: public_ip_address
```

### Azure Dynamic Inventory
```yaml
# azure_rm.yml
plugin: azure_rm
include_vm_resource_groups:
  - myresourcegroup

auth_source: auto
keyed_groups:
  - key: tags.environment
    prefix: env
  - key: tags.role
    prefix: role

hostnames:
  - name
  - public_ipv4_addresses
```

### Custom Dynamic Inventory Script
```python
#!/usr/bin/env python3
# inventory.py
import json
import sys

def get_inventory():
    inventory = {
        'webservers': {
            'hosts': ['web1.example.com', 'web2.example.com'],
            'vars': {
                'http_port': 80,
                'max_clients': 200
            }
        },
        'databases': {
            'hosts': ['db1.example.com'],
            'vars': {
                'mysql_port': 3306
            }
        },
        '_meta': {
            'hostvars': {
                'web1.example.com': {
                    'ansible_host': '192.168.1.10'
                },
                'web2.example.com': {
                    'ansible_host': '192.168.1.11'
                },
                'db1.example.com': {
                    'ansible_host': '192.168.1.20'
                }
            }
        }
    }
    return inventory

if __name__ == '__main__':
    print(json.dumps(get_inventory(), indent=2))
```

## Variable Management

### Variable Hierarchy
```bash
# Variable precedence (highest to lowest)
1. Extra vars (-e in command line)
2. Task vars (only for the task)
3. Block vars (only for tasks in block)
4. Role and include vars
5. Play vars_files
6. Play vars_prompt
7. Play vars
8. Set_facts / registered vars
9. Host facts / cached set_facts
10. Playbook host_vars/*
11. Playbook group_vars/*
12. Inventory host_vars/*
13. Inventory group_vars/*
14. Inventory vars
15. Role defaults
```

### Group Variables
```yaml
# group_vars/all.yml
---
ntp_server: pool.ntp.org
timezone: UTC
common_packages:
  - git
  - curl
  - wget

# group_vars/webservers.yml
---
http_port: 80
https_port: 443
document_root: /var/www/html
ssl_enabled: true

# group_vars/databases.yml
---
mysql_port: 3306
mysql_max_connections: 200
backup_enabled: true
```

### Host Variables
```yaml
# host_vars/web1.example.com.yml
---
server_id: 1
local_ip: 192.168.1.10
cpu_cores: 4
memory_gb: 8

# host_vars/db1.example.com.yml
---
server_id: 1
mysql_server_id: 1
replication_role: master
```

## Environment-Specific Inventories

### Directory Structure
```bash
inventories/
├── production/
│   ├── hosts.yml
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── webservers.yml
│   │   └── databases.yml
│   └── host_vars/
├── staging/
│   ├── hosts.yml
│   └── group_vars/
└── development/
    ├── hosts.yml
    └── group_vars/
```

### Production Inventory
```yaml
# inventories/production/hosts.yml
all:
  children:
    webservers:
      hosts:
        web1.prod.example.com:
          ansible_host: 10.0.1.10
        web2.prod.example.com:
          ansible_host: 10.0.1.11
      vars:
        environment: production
        http_port: 80
        https_port: 443
    
    databases:
      hosts:
        db1.prod.example.com:
          ansible_host: 10.0.2.10
          mysql_server_id: 1
        db2.prod.example.com:
          ansible_host: 10.0.2.11
          mysql_server_id: 2
      vars:
        environment: production
        mysql_port: 3306
  
  vars:
    ansible_user: ansible
    domain_name: example.com
```

### Staging Inventory
```yaml
# inventories/staging/hosts.yml
all:
  children:
    webservers:
      hosts:
        web1.staging.example.com:
          ansible_host: 10.1.1.10
      vars:
        environment: staging
        http_port: 8080
    
    databases:
      hosts:
        db1.staging.example.com:
          ansible_host: 10.1.2.10
      vars:
        environment: staging
        mysql_port: 3306
  
  vars:
    ansible_user: ansible
    domain_name: staging.example.com
```

## Inventory Validation and Testing

### Inventory Commands
```bash
# List all hosts
ansible-inventory -i inventory.yml --list

# Show inventory graph
ansible-inventory -i inventory.yml --graph

# Show specific host variables
ansible-inventory -i inventory.yml --host web1.example.com

# Validate inventory syntax
ansible-inventory -i inventory.yml --list > /dev/null

# Show hosts in specific group
ansible webservers --list-hosts

# Show all groups
ansible localhost -m debug -a "var=groups"
```

### Inventory Testing Playbook
```yaml
# test-inventory.yml
---
- name: Test inventory configuration
  hosts: all
  gather_facts: no
  
  tasks:
    - name: Test connectivity
      ping:
      register: ping_result
    
    - name: Display host information
      debug:
        msg: |
          Host: {{ inventory_hostname }}
          Groups: {{ group_names }}
          IP: {{ ansible_host | default('N/A') }}
          Environment: {{ environment | default('N/A') }}
    
    - name: Verify required variables
      assert:
        that:
          - ansible_user is defined
          - environment is defined
        fail_msg: "Required variables not defined"
        success_msg: "All required variables present"
```

## Best Practices

### Security
```yaml
# Use vault for sensitive data
ansible_ssh_pass: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  66386439653762391081743...

# Separate credentials by environment
# group_vars/production/vault.yml (encrypted)
vault_mysql_password: supersecret123
vault_api_key: abc123def456

# Reference vault variables
mysql_password: "{{ vault_mysql_password }}"
api_key: "{{ vault_api_key }}"
```

### Organization
```bash
# Use consistent naming
- Environment prefixes: prod-, staging-, dev-
- Role-based grouping: webservers, databases, loadbalancers
- Location-based grouping: us-east, us-west, europe

# Group hierarchy
all:
  children:
    production:
      children:
        prod_webservers:
        prod_databases:
    staging:
      children:
        staging_webservers:
        staging_databases:
```

### Performance
```ini
# ansible.cfg optimizations
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
host_key_checking = False
forks = 20

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

This comprehensive inventory guide covers all aspects of Ansible inventory management for scalable infrastructure automation.