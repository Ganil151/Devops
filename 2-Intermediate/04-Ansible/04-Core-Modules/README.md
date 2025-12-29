# Ansible Core Modules

Essential guide to Ansible's core modules for system administration, file management, and basic automation tasks.

## Module Basics

### What are Modules?

Modules are discrete units of code that Ansible executes on managed nodes. Each module performs a specific task and returns structured data about what was accomplished.

### Module Categories
- **System**: User, group, service management
- **Files**: File operations, templates, archives
- **Commands**: Shell commands and scripts
- **Packaging**: Package installation and management
- **Net Tools**: Network utilities and testing

## System Modules

### User Management

#### user Module
```yaml
# Create user
- name: Create application user
  user:
    name: appuser
    uid: 1001
    group: appgroup
    shell: /bin/bash
    home: /home/appuser
    create_home: yes
    state: present

# Modify existing user
- name: Update user shell
  user:
    name: appuser
    shell: /bin/zsh
    append: yes
    groups: sudo,docker

# Remove user
- name: Remove user
  user:
    name: olduser
    state: absent
    remove: yes
    force: yes
```

#### group Module
```yaml
# Create group
- name: Create application group
  group:
    name: appgroup
    gid: 1001
    state: present

# System group
- name: Create system group
  group:
    name: sysgroup
    system: yes
    state: present
```

### Service Management

#### service Module
```yaml
# Start and enable service
- name: Start and enable nginx
  service:
    name: nginx
    state: started
    enabled: yes

# Restart service
- name: Restart apache
  service:
    name: httpd
    state: restarted

# Stop and disable service
- name: Stop and disable service
  service:
    name: unnecessary-service
    state: stopped
    enabled: no
```

#### systemd Module
```yaml
# Systemd specific operations
- name: Reload systemd and start service
  systemd:
    name: myapp
    state: started
    enabled: yes
    daemon_reload: yes

# User service
- name: Start user service
  systemd:
    name: user-app
    state: started
    scope: user
    
# Mask service
- name: Mask service
  systemd:
    name: unwanted-service
    masked: yes
```

## File Modules

### file Module
```yaml
# Create directory
- name: Create application directory
  file:
    path: /opt/myapp
    state: directory
    owner: appuser
    group: appgroup
    mode: '0755'

# Create file
- name: Create empty file
  file:
    path: /tmp/testfile
    state: touch
    owner: root
    group: root
    mode: '0644'

# Create symbolic link
- name: Create symlink
  file:
    src: /opt/myapp/current
    dest: /opt/myapp/app
    state: link

# Remove file/directory
- name: Remove temporary files
  file:
    path: /tmp/cleanup
    state: absent

# Set permissions recursively
- name: Set directory permissions
  file:
    path: /var/www/html
    owner: www-data
    group: www-data
    mode: '0755'
    recurse: yes
```

### copy Module
```yaml
# Copy file from control node
- name: Copy configuration file
  copy:
    src: /local/path/config.conf
    dest: /etc/myapp/config.conf
    owner: root
    group: root
    mode: '0644'
    backup: yes

# Copy with content
- name: Create file with content
  copy:
    content: |
      # Configuration file
      server_name = myserver
      port = 8080
    dest: /etc/myapp/server.conf
    owner: appuser
    group: appgroup
    mode: '0600'

# Copy directory
- name: Copy application files
  copy:
    src: /local/app/
    dest: /opt/myapp/
    owner: appuser
    group: appgroup
    mode: preserve
```

### template Module
```yaml
# Basic template
- name: Generate configuration from template
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
  notify: restart nginx

# Template with variables
- name: Generate app config
  template:
    src: app.conf.j2
    dest: /etc/myapp/app.conf
    owner: appuser
    group: appgroup
    mode: '0600'
  vars:
    app_port: 8080
    app_workers: 4
```

### fetch Module
```yaml
# Fetch file from remote host
- name: Fetch log files
  fetch:
    src: /var/log/myapp.log
    dest: /local/logs/{{ inventory_hostname }}/
    flat: yes

# Fetch with validation
- name: Fetch configuration backup
  fetch:
    src: /etc/myapp/config.conf
    dest: /backup/configs/
    validate_checksum: yes
```

## Command Modules

### command Module
```yaml
# Simple command
- name: Check disk usage
  command: df -h
  register: disk_usage

# Command with arguments
- name: Create backup
  command: tar -czf /backup/app-{{ ansible_date_time.epoch }}.tar.gz /opt/myapp
  args:
    creates: /backup/app-{{ ansible_date_time.epoch }}.tar.gz

# Command with working directory
- name: Run application script
  command: ./deploy.sh
  args:
    chdir: /opt/myapp/scripts
    creates: /opt/myapp/deployed.flag
```

### shell Module
```yaml
# Shell command with pipes
- name: Find large files
  shell: find /var/log -name "*.log" -size +100M | head -10
  register: large_files

# Command with environment variables
- name: Run with environment
  shell: echo $CUSTOM_VAR
  environment:
    CUSTOM_VAR: "Hello World"

# Multi-line shell command
- name: Complex shell operation
  shell: |
    if [ -f /etc/myapp/config.conf ]; then
      echo "Config exists"
    else
      echo "Config missing"
    fi
  register: config_check
```

### script Module
```yaml
# Run local script on remote host
- name: Execute deployment script
  script: /local/scripts/deploy.sh
  args:
    creates: /opt/myapp/deployed

# Script with arguments
- name: Run maintenance script
  script: /local/scripts/maintenance.sh {{ app_name }} {{ app_version }}
```

## Package Modules

### package Module (Generic)
```yaml
# Install package (works across distributions)
- name: Install git
  package:
    name: git
    state: present

# Install multiple packages
- name: Install development tools
  package:
    name:
      - git
      - curl
      - wget
      - vim
    state: present

# Remove package
- name: Remove unnecessary package
  package:
    name: telnet
    state: absent
```

### yum Module (RHEL/CentOS)
```yaml
# Install package
- name: Install Apache
  yum:
    name: httpd
    state: present

# Install specific version
- name: Install specific Python version
  yum:
    name: python3-3.8.0
    state: present

# Install from URL
- name: Install RPM from URL
  yum:
    name: https://example.com/package.rpm
    state: present

# Update all packages
- name: Update all packages
  yum:
    name: "*"
    state: latest
```

### apt Module (Debian/Ubuntu)
```yaml
# Update cache and install
- name: Install nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

# Install multiple packages
- name: Install LAMP stack
  apt:
    name:
      - apache2
      - mysql-server
      - php
      - libapache2-mod-php
    state: present

# Install .deb package
- name: Install local deb package
  apt:
    deb: /tmp/package.deb
    state: present
```

### pip Module (Python packages)
```yaml
# Install Python package
- name: Install Flask
  pip:
    name: flask
    state: present

# Install specific version
- name: Install Django
  pip:
    name: django==3.2.0
    state: present

# Install from requirements file
- name: Install from requirements
  pip:
    requirements: /opt/myapp/requirements.txt
    virtualenv: /opt/myapp/venv
```

## Network and Utility Modules

### uri Module
```yaml
# HTTP GET request
- name: Check service health
  uri:
    url: http://localhost:8080/health
    method: GET
    status_code: 200
  register: health_check

# POST request with data
- name: Send notification
  uri:
    url: https://api.example.com/notify
    method: POST
    body_format: json
    body:
      message: "Deployment completed"
      server: "{{ inventory_hostname }}"
    headers:
      Authorization: "Bearer {{ api_token }}"

# Download file
- name: Download application
  uri:
    url: https://releases.example.com/app-1.0.0.tar.gz
    dest: /tmp/app-1.0.0.tar.gz
    creates: /tmp/app-1.0.0.tar.gz
```

### get_url Module
```yaml
# Download file
- name: Download application archive
  get_url:
    url: https://github.com/user/repo/archive/v1.0.0.tar.gz
    dest: /tmp/app-v1.0.0.tar.gz
    mode: '0644'
    checksum: sha256:abc123...

# Download with authentication
- name: Download private file
  get_url:
    url: https://private.example.com/file.zip
    dest: /tmp/file.zip
    username: "{{ download_user }}"
    password: "{{ download_pass }}"
```

### wait_for Module
```yaml
# Wait for port to be available
- name: Wait for service to start
  wait_for:
    port: 8080
    host: localhost
    timeout: 300

# Wait for file to exist
- name: Wait for deployment flag
  wait_for:
    path: /opt/myapp/deployed.flag
    timeout: 600

# Wait for string in file
- name: Wait for service ready
  wait_for:
    path: /var/log/myapp.log
    search_regex: "Service started successfully"
    timeout: 120
```

## Archive and Compression

### unarchive Module
```yaml
# Extract archive from control node
- name: Extract application
  unarchive:
    src: /local/app-1.0.0.tar.gz
    dest: /opt/myapp
    owner: appuser
    group: appgroup

# Extract remote archive
- name: Extract downloaded archive
  unarchive:
    src: /tmp/app-1.0.0.tar.gz
    dest: /opt/myapp
    remote_src: yes
    creates: /opt/myapp/bin/app

# Extract specific files
- name: Extract configuration only
  unarchive:
    src: /tmp/backup.tar.gz
    dest: /etc/
    remote_src: yes
    include:
      - "*/config/*"
```

### archive Module
```yaml
# Create archive
- name: Create backup archive
  archive:
    path: /opt/myapp
    dest: /backup/myapp-{{ ansible_date_time.epoch }}.tar.gz
    format: gz

# Create archive with exclusions
- name: Backup excluding logs
  archive:
    path: /opt/myapp
    dest: /backup/myapp-clean.tar.gz
    exclude_path:
      - /opt/myapp/logs
      - /opt/myapp/tmp
```

## Module Usage Patterns

### Error Handling
```yaml
# Handle module failures
- name: Install package with error handling
  package:
    name: some-package
    state: present
  register: install_result
  failed_when: 
    - install_result.failed
    - "'No package' not in install_result.msg"

# Ignore errors for optional tasks
- name: Optional configuration
  copy:
    src: optional-config.conf
    dest: /etc/optional.conf
  ignore_errors: yes
```

### Conditional Execution
```yaml
# Run module based on conditions
- name: Install development packages
  package:
    name: "{{ dev_packages }}"
    state: present
  when: 
    - environment == "development"
    - dev_packages is defined

# OS-specific modules
- name: Install package (RedHat)
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"

- name: Install package (Debian)
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"
```

### Using Register
```yaml
# Capture module output
- name: Check service status
  command: systemctl is-active nginx
  register: nginx_status
  failed_when: false
  changed_when: false

- name: Display service status
  debug:
    msg: "Nginx is {{ nginx_status.stdout }}"

# Use registered variables in conditions
- name: Start service if not running
  service:
    name: nginx
    state: started
  when: nginx_status.stdout != "active"
```

## Best Practices

### Module Selection
```yaml
# Prefer specific modules over command/shell
# Good
- name: Create user
  user:
    name: appuser
    state: present

# Avoid
- name: Create user
  command: useradd appuser

# Use appropriate module parameters
- name: Copy file with proper ownership
  copy:
    src: config.conf
    dest: /etc/app/config.conf
    owner: appuser
    group: appgroup
    mode: '0644'
    backup: yes
```

### Idempotency
```yaml
# Ensure idempotent operations
- name: Ensure directory exists
  file:
    path: /opt/myapp
    state: directory
    # This is idempotent - won't change if directory exists

# Use creates/removes for command modules
- name: Extract archive
  command: tar -xzf /tmp/app.tar.gz -C /opt/
  args:
    creates: /opt/app/bin/app
```

### Performance
```yaml
# Batch operations when possible
- name: Install multiple packages
  package:
    name:
      - git
      - curl
      - wget
    state: present
  # Better than multiple individual package tasks

# Use appropriate module features
- name: Copy directory efficiently
  copy:
    src: /local/app/
    dest: /opt/myapp/
    # Copies entire directory in one operation
```

This comprehensive guide covers the essential Ansible core modules needed for basic system administration and automation tasks.