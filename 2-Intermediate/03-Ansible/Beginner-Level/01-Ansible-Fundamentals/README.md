# Ansible Fundamentals

Complete guide to Ansible basics, architecture, and core concepts for automation and configuration management.

## What is Ansible?

Ansible is an open-source automation platform that simplifies complex configuration management, application deployment, intraservice orchestration, and provisioning. It uses a simple, human-readable language (YAML) and operates over SSH without requiring agents on target systems.

### Key Benefits

- **Agentless**: No software installation required on managed nodes
- **Simple**: Uses YAML syntax that's easy to read and write
- **Powerful**: Handles complex multi-tier deployments
- **Flexible**: Works with existing infrastructure
- **Secure**: Uses SSH and requires no additional ports
- **Efficient**: Parallel execution across multiple systems

## Ansible Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Ansible Architecture                      │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   Control   │    │  Inventory  │    │   Managed   │    │
│  │    Node     │◄──►│             │◄──►│    Nodes    │    │
│  │             │    │             │    │             │    │
│  │ • Playbooks │    │ • Hosts     │    │ • Target    │    │
│  │ • Modules   │    │ • Groups    │    │   Systems   │    │
│  │ • Plugins   │    │ • Variables │    │ • SSH Access│    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
│         │                   │                   │          │
│         └───────────────────┼───────────────────┘          │
│                             │                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Communication Flow                     │   │
│  │  1. Read Playbook & Inventory                      │   │
│  │  2. Generate Python Scripts                        │   │
│  │  3. Copy Scripts to Managed Nodes                  │   │
│  │  4. Execute Scripts via SSH                        │   │
│  │  5. Return Results to Control Node                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Control Node
- **Ansible Engine**: Core automation engine
- **Playbooks**: YAML files defining automation tasks
- **Inventory**: List of managed systems
- **Modules**: Reusable automation units
- **Plugins**: Extend Ansible functionality

### Managed Nodes
- **Target Systems**: Servers, network devices, cloud instances
- **SSH Access**: Primary communication method
- **Python**: Required for most modules
- **No Agent**: No Ansible software installation needed

===

## Installation

### System Requirements

#### Control Node Requirements
```bash
# Supported Operating Systems
- Red Hat Enterprise Linux (RHEL) 8+
- CentOS 8+
- Fedora 35+
- Ubuntu 18.04+
- Debian 10+
- macOS 10.15+

# Python Requirements
- Python 3.8+ (recommended)
- Python 2.7 (deprecated)
```

#### Managed Node Requirements
```bash
# Operating Systems
- Most Unix-like systems (Linux, BSD, macOS)
- Windows (with PowerShell 3.0+)

# Dependencies
- Python 2.7 or 3.5+ (for most modules)
- SSH server (for Unix-like systems)
- WinRM (for Windows systems)
```

### Installation Methods

#### Package Manager Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible -y

# RHEL/CentOS/Fedora
sudo dnf install ansible -y
# or
sudo yum install ansible -y

# macOS (using Homebrew)
brew install ansible

# Verify installation
ansible --version
```

#### Python pip Installation

```bash
# Install pip if not available
sudo apt install python3-pip -y  # Ubuntu/Debian
sudo dnf install python3-pip -y  # RHEL/CentOS/Fedora

# Install Ansible
pip3 install ansible

# Install specific version
pip3 install ansible==6.7.0

# Upgrade Ansible
pip3 install --upgrade ansible

# Install with additional collections
pip3 install ansible[azure,aws,gcp]
```

#### Source Installation

```bash
# Clone repository
git clone https://github.com/ansible/ansible.git
cd ansible

# Install from source
pip3 install -e .

# Set up environment
source ./hacking/env-setup

# Verify installation
ansible --version
```

### Post-Installation Configuration

#### Create Configuration File

```bash
# Create ansible.cfg in project directory
cat > ansible.cfg << EOF
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
callback_whitelist = profile_tasks, timer
stdout_callback = yaml
remote_user = ec2-user
private_key_file = ~/.ssh/id_rsa

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
```

#### SSH Key Setup

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_key

# Copy public key to managed nodes
ssh-copy-id -i ~/.ssh/ansible_key.pub user@target-host

# Test SSH connection
ssh -i ~/.ssh/ansible_key user@target-host
```

---

## Core Concepts

### Inventory

Inventory defines the hosts and groups that Ansible manages.

#### Static Inventory (INI Format)

```ini
# inventory/hosts.ini
[webservers]
web1.example.com ansible_host=192.168.1.10
web2.example.com ansible_host=192.168.1.11

[databases]
db1.example.com ansible_host=192.168.1.20
db2.example.com ansible_host=192.168.1.21

[monitoring]
monitor.example.com ansible_host=192.168.1.30

[production:children]
webservers
databases
monitoring

[webservers:vars]
http_port=80
max_clients=200

[databases:vars]
mysql_port=3306
mysql_root_password=secret

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/ansible_key
```

#### Static Inventory (YAML Format)

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
        mysql_root_password: secret
    
    monitoring:
      hosts:
        monitor.example.com:
          ansible_host: 192.168.1.30
    
    production:
      children:
        webservers:
        databases:
        monitoring:
  
  vars:
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ~/.ssh/ansible_key
```

### Ad-Hoc Commands

Quick, one-time tasks without writing playbooks.

```bash
# Basic connectivity test
ansible all -m ping

# Run shell commands
ansible all -a "uptime"
ansible webservers -a "systemctl status httpd"

# Use specific modules
ansible all -m setup                    # Gather facts
ansible all -m shell -a "df -h"        # Shell command
ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"  # Copy file

# Package management
ansible webservers -m yum -a "name=httpd state=present" --become
ansible databases -m apt -a "name=mysql-server state=present" --become

# Service management
ansible webservers -m service -a "name=httpd state=started" --become
ansible databases -m service -a "name=mysql state=restarted" --become

# File operations
ansible all -m file -a "path=/tmp/test state=directory mode=0755" --become
ansible all -m file -a "path=/tmp/test.txt state=touch" --become

# User management
ansible all -m user -a "name=testuser state=present" --become
ansible all -m user -a "name=testuser state=absent remove=yes" --become
```

### Modules

Modules are the units of work in Ansible. Each module performs a specific task.

#### Core System Modules

```bash
# File and directory operations
ansible all -m file -a "path=/opt/app state=directory owner=app group=app mode=0755"
ansible all -m copy -a "src=app.conf dest=/etc/app/app.conf backup=yes"
ansible all -m template -a "src=config.j2 dest=/etc/app/config.ini"

# Package management
ansible all -m package -a "name=git state=present"  # Generic package module
ansible all -m yum -a "name=httpd state=latest"     # RHEL/CentOS
ansible all -m apt -a "name=apache2 state=present update_cache=yes"  # Debian/Ubuntu

# Service management
ansible all -m service -a "name=httpd state=started enabled=yes"
ansible all -m systemd -a "name=nginx state=reloaded daemon_reload=yes"

# User and group management
ansible all -m user -a "name=appuser uid=1001 group=appgroup shell=/bin/bash"
ansible all -m group -a "name=appgroup gid=1001 state=present"

# Command execution
ansible all -m command -a "ls -la /tmp"              # Simple commands
ansible all -m shell -a "ps aux | grep nginx"       # Shell features
ansible all -m script -a "/path/to/local/script.sh" # Run local script
```

#### Cloud Modules

```bash
# AWS EC2
ansible localhost -m ec2_instance -a "name=web-server image_id=ami-12345 instance_type=t3.micro"

# Azure
ansible localhost -m azure_rm_virtualmachine -a "name=vm1 resource_group=mygroup"

# Google Cloud
ansible localhost -m gcp_compute_instance -a "name=instance-1 zone=us-central1-a"
```

### Variables

Variables make playbooks flexible and reusable.

#### Variable Types

```yaml
# Global variables (group_vars/all.yml)
---
app_name: myapp
app_version: 1.0.0
environment: production

# Group variables (group_vars/webservers.yml)
---
http_port: 80
https_port: 443
max_clients: 200

# Host variables (host_vars/web1.example.com.yml)
---
server_id: 1
local_ip: 192.168.1.10

# Playbook variables
---
- name: Deploy application
  hosts: webservers
  vars:
    app_port: 8080
    app_user: webapp
  tasks:
    - name: Create app user
      user:
        name: "{{ app_user }}"
        state: present
```

#### Variable Precedence (highest to lowest)

```bash
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

---

### Facts

Facts are system information automatically gathered by Ansible.

```bash
# Gather all facts
ansible all -m setup

# Filter facts
ansible all -m setup -a "filter=ansible_distribution*"
ansible all -m setup -a "filter=ansible_memory*"
ansible all -m setup -a "filter=ansible_interfaces"

# Disable fact gathering in playbook
---
- name: Playbook without facts
  hosts: all
  gather_facts: no
  tasks:
    - name: Simple task
      debug:
        msg: "No facts gathered"

# Custom facts
# Create /etc/ansible/facts.d/custom.fact on managed node
#!/bin/bash
echo '{"custom_fact": "custom_value"}'

# Access custom facts
ansible all -m setup -a "filter=ansible_local"
```

### Playbooks

Playbooks are YAML files that define automation workflows.

#### Basic Playbook Structure

```yaml
---
- name: Basic web server setup
  hosts: webservers
  become: yes
  gather_facts: yes
  
  vars:
    http_port: 80
    max_clients: 200
  
  tasks:
    - name: Install Apache
      package:
        name: httpd
        state: present
    
    - name: Start Apache service
      service:
        name: httpd
        state: started
        enabled: yes
    
    - name: Configure Apache
      template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: restart apache
    
    - name: Open firewall for HTTP
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes
  
  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
```

#### Multi-Play Playbook

```yaml
---
# Play 1: Setup database servers
- name: Configure database servers
  hosts: databases
  become: yes
  
  tasks:
    - name: Install MySQL
      package:
        name: mysql-server
        state: present
    
    - name: Start MySQL service
      service:
        name: mysqld
        state: started
        enabled: yes

# Play 2: Setup web servers
- name: Configure web servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install Apache
      package:
        name: httpd
        state: present
    
    - name: Start Apache service
      service:
        name: httpd
        state: started
        enabled: yes

# Play 3: Deploy application
- name: Deploy application
  hosts: webservers
  become: yes
  
  tasks:
    - name: Copy application files
      copy:
        src: app/
        dest: /var/www/html/
        owner: apache
        group: apache
```

### Handlers

Handlers are tasks that run when notified by other tasks.

```yaml
---
- name: Web server configuration
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install Apache
      package:
        name: httpd
        state: present
    
    - name: Configure Apache main config
      template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify:
        - restart apache
        - check apache status
    
    - name: Configure virtual host
      template:
        src: vhost.conf.j2
        dest: /etc/httpd/conf.d/vhost.conf
      notify: restart apache
  
  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
    
    - name: check apache status
      command: systemctl status httpd
      register: apache_status
    
    - name: display status
      debug:
        var: apache_status.stdout
```

## Basic Workflow

### 1. Project Setup

```bash
# Create project structure
mkdir ansible-project
cd ansible-project

# Create directory structure
mkdir -p {inventory,group_vars,host_vars,roles,playbooks}

# Create basic files
touch ansible.cfg
touch inventory/hosts.yml
touch playbooks/site.yml
```

### 2. Inventory Configuration

```yaml
# inventory/hosts.yml
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
        web2:
          ansible_host: 192.168.1.11
    
    databases:
      hosts:
        db1:
          ansible_host: 192.168.1.20
  
  vars:
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### 3. Variable Definition

```yaml
# group_vars/all.yml
---
app_name: myapp
app_version: 1.0.0
environment: production

# group_vars/webservers.yml
---
http_port: 80
document_root: /var/www/html

# group_vars/databases.yml
---
mysql_port: 3306
mysql_root_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  66386439653762391081743...
```

### 4. Playbook Creation

```yaml
# playbooks/site.yml
---
- import_playbook: webservers.yml
- import_playbook: databases.yml

# playbooks/webservers.yml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install web server
      package:
        name: httpd
        state: present
    
    - name: Start web server
      service:
        name: httpd
        state: started
        enabled: yes
```

### 5. Execution

```bash
# Test connectivity
ansible all -m ping

# Run playbook
ansible-playbook playbooks/site.yml

# Dry run
ansible-playbook playbooks/site.yml --check

# Verbose output
ansible-playbook playbooks/site.yml -v
```

## Best Practices

### Playbook Organization

```bash
# Recommended directory structure
ansible-project/
├── ansible.cfg
├── inventory/
│   ├── production/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── staging/
│       ├── hosts.yml
│       └── group_vars/
├── group_vars/
│   ├── all.yml
│   └── webservers.yml
├── host_vars/
├── roles/
├── playbooks/
│   ├── site.yml
│   ├── webservers.yml
│   └── databases.yml
└── files/
```

### Naming Conventions

```yaml
# Use descriptive names
- name: Install and configure Apache web server
  package:
    name: httpd
    state: present

# Use consistent variable naming
app_name: myapp
app_version: 1.0.0
app_port: 8080

# Use tags for organization
- name: Install packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - httpd
    - mod_ssl
  tags:
    - packages
    - webserver
```

### Error Handling

```yaml
# Use failed_when and changed_when
- name: Check if service is running
  command: systemctl is-active httpd
  register: service_status
  failed_when: service_status.rc not in [0, 3]
  changed_when: false

# Use ignore_errors sparingly
- name: Optional task
  command: some_command_that_might_fail
  ignore_errors: yes

# Use block/rescue for error handling
- block:
    - name: Risky task
      command: risky_command
  rescue:
    - name: Handle error
      debug:
        msg: "Task failed, but continuing"
```

This comprehensive guide covers the fundamental concepts needed to get started with Ansible automation and configuration management.