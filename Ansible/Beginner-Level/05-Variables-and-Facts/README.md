# Ansible Variables and Facts

Complete guide to Ansible variables, facts, and data management for flexible and dynamic automation.

## Variable Fundamentals

### What are Variables?

Variables in Ansible store data that can be used throughout playbooks, roles, and templates. They make automation flexible and reusable by allowing the same code to work with different values.

### Variable Types

#### Simple Variables
```yaml
# String variables
app_name: myapp
server_name: web01.example.com
environment: production

# Numeric variables
http_port: 80
max_connections: 1000
timeout: 30

# Boolean variables
ssl_enabled: true
debug_mode: false
backup_enabled: yes
```

#### List Variables
```yaml
# Simple list
packages:
  - git
  - curl
  - wget
  - vim

# List of dictionaries
users:
  - name: alice
    uid: 1001
    groups: [sudo, docker]
  - name: bob
    uid: 1002
    groups: [users]

# Nested lists
firewall_rules:
  - port: 80
    protocol: tcp
    source: any
  - port: 443
    protocol: tcp
    source: any
```

#### Dictionary Variables
```yaml
# Simple dictionary
database:
  host: db.example.com
  port: 3306
  name: myapp_db
  user: dbuser

# Nested dictionary
application:
  name: myapp
  version: 1.0.0
  config:
    port: 8080
    workers: 4
    logging:
      level: info
      file: /var/log/myapp.log
```

## Variable Definition Locations

### Playbook Variables
```yaml
---
- name: Deploy application
  hosts: webservers
  vars:
    app_name: myapp
    app_version: 1.0.0
    app_port: 8080
  
  tasks:
    - name: Display app info
      debug:
        msg: "Deploying {{ app_name }} version {{ app_version }} on port {{ app_port }}"
```

### Variable Files
```yaml
# vars/main.yml
---
app_name: myapp
app_version: 1.0.0
database_host: db.example.com

# Playbook using vars_files
---
- name: Deploy application
  hosts: webservers
  vars_files:
    - vars/main.yml
    - vars/secrets.yml
  
  tasks:
    - name: Configure application
      template:
        src: app.conf.j2
        dest: /etc/{{ app_name }}/app.conf
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
max_clients: 200

# group_vars/databases.yml
---
mysql_port: 3306
mysql_max_connections: 200
backup_enabled: true
```

### Host Variables
```yaml
# host_vars/web01.example.com.yml
---
server_id: 1
local_ip: 192.168.1.10
cpu_cores: 4
memory_gb: 8

# host_vars/db01.example.com.yml
---
server_id: 1
mysql_server_id: 1
replication_role: master
```

### Inventory Variables
```yaml
# inventory.yml
all:
  children:
    webservers:
      hosts:
        web01.example.com:
          ansible_host: 192.168.1.10
          server_role: primary
        web02.example.com:
          ansible_host: 192.168.1.11
          server_role: secondary
      vars:
        http_port: 80
        environment: production
    
    databases:
      hosts:
        db01.example.com:
          ansible_host: 192.168.1.20
          mysql_server_id: 1
      vars:
        mysql_port: 3306
  
  vars:
    ansible_user: ansible
    domain_name: example.com
```

## Variable Precedence

### Precedence Order (Highest to Lowest)
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

### Precedence Examples
```yaml
# Command line extra vars (highest precedence)
ansible-playbook playbook.yml -e "app_version=2.0.0"

# Task vars
- name: Install package
  package:
    name: nginx
    state: present
  vars:
    package_name: nginx  # Only available in this task

# Block vars
- block:
    - name: Task 1
      debug:
        msg: "{{ block_var }}"
    
    - name: Task 2
      debug:
        msg: "{{ block_var }}"
  vars:
    block_var: "Available in all block tasks"

# Play vars (lower precedence)
- name: Deploy app
  hosts: all
  vars:
    app_version: 1.0.0  # Can be overridden by higher precedence
```

## Variable Usage

### Basic Variable Substitution
```yaml
# Simple substitution
- name: Create user {{ username }}
  user:
    name: "{{ username }}"
    home: "/home/{{ username }}"
    shell: /bin/bash

# In file paths
- name: Copy configuration
  copy:
    src: "{{ app_name }}.conf"
    dest: "/etc/{{ app_name }}/{{ app_name }}.conf"

# In conditionals
- name: Install development packages
  package:
    name: "{{ dev_packages }}"
    state: present
  when: environment == "development"
```

### List and Dictionary Access
```yaml
# Accessing list items
- name: Install first package
  package:
    name: "{{ packages[0] }}"
    state: present

# Loop through list
- name: Install all packages
  package:
    name: "{{ item }}"
    state: present
  loop: "{{ packages }}"

# Dictionary access
- name: Configure database
  template:
    src: db.conf.j2
    dest: /etc/db.conf
  vars:
    db_host: "{{ database.host }}"
    db_port: "{{ database.port }}"
    db_name: "{{ database.name }}"

# Alternative dictionary syntax
- name: Display database info
  debug:
    msg: "Database: {{ database['name'] }} on {{ database['host'] }}"
```

### Variable Filters
```yaml
# String filters
- name: Display uppercase name
  debug:
    msg: "{{ app_name | upper }}"

- name: Display default value
  debug:
    msg: "{{ undefined_var | default('default_value') }}"

# List filters
- name: Display first item
  debug:
    msg: "{{ packages | first }}"

- name: Display list length
  debug:
    msg: "Package count: {{ packages | length }}"

# Dictionary filters
- name: Display dictionary keys
  debug:
    msg: "{{ database | list }}"

# JSON filters
- name: Parse JSON string
  set_fact:
    parsed_data: "{{ json_string | from_json }}"
```

## Facts

### What are Facts?

Facts are system information automatically gathered by Ansible from managed nodes. They provide details about hardware, operating system, network configuration, and more.

### Gathering Facts
```yaml
# Facts are gathered by default
- name: Display system info
  hosts: all
  tasks:
    - name: Show hostname
      debug:
        msg: "Hostname: {{ ansible_hostname }}"

# Disable fact gathering
- name: Quick tasks without facts
  hosts: all
  gather_facts: no
  tasks:
    - name: Simple command
      command: echo "Hello"

# Gather facts manually
- name: Manual fact gathering
  hosts: all
  gather_facts: no
  tasks:
    - name: Gather facts now
      setup:
    
    - name: Use facts
      debug:
        msg: "OS: {{ ansible_distribution }}"
```

### Common System Facts
```yaml
# System information
- name: Display system facts
  debug:
    msg: |
      Hostname: {{ ansible_hostname }}
      FQDN: {{ ansible_fqdn }}
      OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
      Kernel: {{ ansible_kernel }}
      Architecture: {{ ansible_architecture }}
      
      # Hardware information
      CPU Cores: {{ ansible_processor_cores }}
      Memory: {{ ansible_memtotal_mb }}MB
      
      # Network information
      IP Address: {{ ansible_default_ipv4.address }}
      Gateway: {{ ansible_default_ipv4.gateway }}
      
      # Storage information
      Disk Space: {{ ansible_mounts }}
```

### Network Facts
```yaml
# Network interface information
- name: Display network facts
  debug:
    msg: |
      All interfaces: {{ ansible_interfaces }}
      Default IPv4: {{ ansible_default_ipv4 }}
      Default IPv6: {{ ansible_default_ipv6 }}
      
      # Specific interface
      eth0 IP: {{ ansible_eth0.ipv4.address }}
      eth0 MAC: {{ ansible_eth0.macaddress }}

# DNS information
- name: Display DNS facts
  debug:
    msg: |
      DNS servers: {{ ansible_dns.nameservers }}
      Search domains: {{ ansible_dns.search }}
```

### Custom Facts

#### Local Facts Directory
```bash
# Create facts directory on managed node
sudo mkdir -p /etc/ansible/facts.d

# Create custom fact file
sudo cat > /etc/ansible/facts.d/custom.fact << 'EOF'
#!/bin/bash
echo '{"custom_fact": "custom_value", "app_version": "1.0.0"}'
EOF

sudo chmod +x /etc/ansible/facts.d/custom.fact
```

#### Using Custom Facts
```yaml
# Access custom facts
- name: Display custom facts
  debug:
    msg: |
      Custom fact: {{ ansible_local.custom.custom_fact }}
      App version: {{ ansible_local.custom.app_version }}

# Create custom facts in playbook
- name: Create custom fact
  copy:
    content: |
      #!/bin/bash
      echo '{"deployment_date": "'$(date)'", "deployed_by": "'$USER'"}'
    dest: /etc/ansible/facts.d/deployment.fact
    mode: '0755'
  
- name: Refresh facts
  setup:
  
- name: Use new custom fact
  debug:
    msg: "Deployed on {{ ansible_local.deployment.deployment_date }}"
```

## Advanced Variable Techniques

### Registered Variables
```yaml
# Register command output
- name: Check disk usage
  command: df -h /
  register: disk_usage

- name: Display disk usage
  debug:
    msg: "Disk usage: {{ disk_usage.stdout }}"

# Register with conditions
- name: Check service status
  command: systemctl is-active nginx
  register: nginx_status
  failed_when: false
  changed_when: false

- name: Start service if not running
  service:
    name: nginx
    state: started
  when: nginx_status.stdout != "active"
```

### Set Facts
```yaml
# Set simple fact
- name: Set application fact
  set_fact:
    app_full_name: "{{ app_name }}-{{ app_version }}"

# Set complex fact
- name: Set server info
  set_fact:
    server_info:
      name: "{{ inventory_hostname }}"
      ip: "{{ ansible_default_ipv4.address }}"
      role: "{{ server_role | default('unknown') }}"
      environment: "{{ environment }}"

# Conditional fact setting
- name: Set environment-specific facts
  set_fact:
    db_host: "{{ production_db_host }}"
    cache_enabled: true
  when: environment == "production"

- name: Set development facts
  set_fact:
    db_host: "localhost"
    cache_enabled: false
  when: environment == "development"
```

### Variable Prompts
```yaml
# Interactive variable input
- name: Deploy application
  hosts: webservers
  vars_prompt:
    - name: app_version
      prompt: "Enter application version"
      private: no
    
    - name: db_password
      prompt: "Enter database password"
      private: yes
      encrypt: "sha512_crypt"
      confirm: yes
  
  tasks:
    - name: Deploy version {{ app_version }}
      debug:
        msg: "Deploying version {{ app_version }}"
```

### Environment Variables
```yaml
# Access environment variables
- name: Use environment variable
  debug:
    msg: "Home directory: {{ lookup('env', 'HOME') }}"

# Set environment variables for tasks
- name: Run command with environment
  command: echo $CUSTOM_VAR
  environment:
    CUSTOM_VAR: "Hello World"
    PATH: "{{ ansible_env.PATH }}:/custom/path"

# Use environment in templates
- name: Generate config with environment
  template:
    src: app.conf.j2
    dest: /etc/app.conf
  environment:
    APP_ENV: "{{ environment }}"
```

## Variable Validation

### Assert Module
```yaml
# Validate required variables
- name: Validate configuration
  assert:
    that:
      - app_name is defined
      - app_version is defined
      - app_port is defined
      - app_port | int > 0
      - app_port | int < 65536
    fail_msg: "Required variables not properly defined"
    success_msg: "Configuration validated successfully"

# Validate variable types
- name: Validate variable types
  assert:
    that:
      - packages is iterable
      - database is mapping
      - ssl_enabled is boolean
    fail_msg: "Variable types are incorrect"
```

### Variable Testing
```yaml
# Test variable existence
- name: Check if variable is defined
  debug:
    msg: "Variable is defined"
  when: my_variable is defined

- name: Check if variable is undefined
  debug:
    msg: "Variable is not defined"
  when: my_variable is undefined

# Test variable values
- name: Check if list is empty
  debug:
    msg: "List is empty"
  when: my_list | length == 0

- name: Check if string contains value
  debug:
    msg: "String contains 'test'"
  when: "'test' in my_string"
```

## Best Practices

### Naming Conventions
```yaml
# Use descriptive names
app_name: myapp                    # Good
n: myapp                          # Bad

# Use consistent prefixes
mysql_host: db.example.com
mysql_port: 3306
mysql_user: dbuser

# Use snake_case
max_connections: 100              # Good
maxConnections: 100               # Avoid
```

### Variable Organization
```yaml
# Group related variables
database:
  host: db.example.com
  port: 3306
  name: myapp_db
  user: dbuser

# Use meaningful defaults
http_port: "{{ custom_http_port | default(80) }}"
ssl_enabled: "{{ custom_ssl_enabled | default(false) }}"

# Environment-specific variables
# group_vars/production.yml
environment: production
debug_mode: false
log_level: warn

# group_vars/development.yml
environment: development
debug_mode: true
log_level: debug
```

### Security Considerations
```yaml
# Use vault for sensitive data
database_password: "{{ vault_database_password }}"
api_key: "{{ vault_api_key }}"

# Avoid logging sensitive variables
- name: Configure database
  mysql_user:
    name: "{{ db_user }}"
    password: "{{ db_password }}"
    state: present
  no_log: true

# Use separate files for secrets
vars_files:
  - vars/main.yml
  - vars/vault.yml  # Encrypted with ansible-vault
```

This comprehensive guide covers all aspects of Ansible variables and facts for creating flexible and maintainable automation.