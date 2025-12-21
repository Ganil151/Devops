# Ansible Playbooks

Complete guide to Ansible playbook creation, structure, and advanced features for automation workflows.

## Playbook Basics

### What is a Playbook?

A playbook is a YAML file that defines a series of tasks to be executed on managed hosts. Playbooks are the foundation of Ansible automation, describing the desired state of your systems.

### Basic Playbook Structure

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
  
  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
```

## Playbook Components

### Play Definition
```yaml
---
- name: Configure web servers          # Play name (optional but recommended)
  hosts: webservers                   # Target hosts or groups
  become: yes                         # Privilege escalation
  become_user: root                   # User to become
  become_method: sudo                 # Escalation method
  gather_facts: yes                   # Collect system facts
  serial: 2                          # Process hosts in batches
  max_fail_percentage: 25            # Failure tolerance
  connection: ssh                     # Connection type
  remote_user: ansible               # SSH user
  
  vars:                              # Play variables
    app_name: myapp
    app_version: 1.0.0
  
  vars_files:                        # External variable files
    - vars/main.yml
    - vars/secrets.yml
  
  vars_prompt:                       # Interactive variables
    - name: app_version
      prompt: "Enter application version"
      private: no
  
  pre_tasks:                         # Tasks run before roles
    - name: Update package cache
      package:
        update_cache: yes
  
  roles:                             # Roles to apply
    - common
    - webserver
  
  tasks:                             # Main tasks
    - name: Deploy application
      copy:
        src: app.jar
        dest: /opt/app/
  
  post_tasks:                        # Tasks run after roles
    - name: Verify deployment
      uri:
        url: http://localhost:8080/health
  
  handlers:                          # Event handlers
    - name: restart service
      service:
        name: myapp
        state: restarted
```

### Task Structure
```yaml
- name: Task description             # Task name
  module_name:                      # Module to use
    parameter1: value1              # Module parameters
    parameter2: value2
  register: result_var              # Store task output
  when: condition                   # Conditional execution
  loop: "{{ list_var }}"           # Loop over items
  notify: handler_name              # Trigger handler
  tags:                            # Task tags
    - configuration
    - webserver
  become: yes                       # Task-level privilege escalation
  delegate_to: localhost            # Run on different host
  run_once: true                   # Run only once
  ignore_errors: yes               # Continue on failure
  changed_when: false              # Control change detection
  failed_when: result.rc != 0      # Custom failure conditions
```

## Variables and Facts

### Variable Types
```yaml
# Play variables
vars:
  app_name: myapp
  app_port: 8080
  
# List variables
packages:
  - git
  - curl
  - wget

# Dictionary variables
database:
  host: db.example.com
  port: 3306
  name: myapp_db

# Registered variables
- name: Get system uptime
  command: uptime
  register: uptime_result

- name: Display uptime
  debug:
    var: uptime_result.stdout
```

### Using Facts
```yaml
- name: Display system information
  debug:
    msg: |
      Hostname: {{ ansible_hostname }}
      OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
      IP: {{ ansible_default_ipv4.address }}
      Memory: {{ ansible_memtotal_mb }}MB
      CPU: {{ ansible_processor_cores }} cores

# Conditional based on facts
- name: Install package (RedHat family)
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"

- name: Install package (Debian family)
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"
```

## Control Flow

### Conditionals
```yaml
# Simple conditions
- name: Install nginx
  package:
    name: nginx
    state: present
  when: webserver_type == "nginx"

# Multiple conditions (AND)
- name: Configure SSL
  template:
    src: ssl.conf.j2
    dest: /etc/nginx/ssl.conf
  when:
    - ssl_enabled | default(false)
    - ssl_certificate is defined

# Multiple conditions (OR)
- name: Install web server
  package:
    name: "{{ item }}"
    state: present
  when: webserver_type == "apache" or webserver_type == "httpd"
  loop:
    - httpd
    - mod_ssl

# Complex conditions
- name: Configure firewall
  firewalld:
    service: http
    state: enabled
  when: 
    - ansible_os_family == "RedHat"
    - firewall_enabled | default(true)
    - not (development_mode | default(false))
```

### Loops
```yaml
# Simple loop
- name: Install packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - curl
    - wget

# Loop with dictionary
- name: Create users
  user:
    name: "{{ item.name }}"
    uid: "{{ item.uid }}"
    group: "{{ item.group }}"
  loop:
    - { name: alice, uid: 1001, group: users }
    - { name: bob, uid: 1002, group: users }

# Loop with variables
- name: Configure virtual hosts
  template:
    src: vhost.conf.j2
    dest: "/etc/nginx/sites-available/{{ item.name }}"
  loop: "{{ virtual_hosts }}"
  notify: reload nginx

# Loop with conditions
- name: Install development packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - nodejs
    - npm
    - python3-dev
  when: environment == "development"

# Loop with register
- name: Check service status
  service:
    name: "{{ item }}"
  register: service_results
  loop:
    - httpd
    - mysqld
    - sshd

- name: Display service status
  debug:
    msg: "{{ item.item }} is {{ item.state }}"
  loop: "{{ service_results.results }}"
```

### Error Handling
```yaml
# Block/rescue/always
- block:
    - name: Risky operation
      command: /bin/risky_command
    
    - name: Another risky operation
      shell: /bin/another_risky_command
  
  rescue:
    - name: Handle errors
      debug:
        msg: "Something went wrong, but we're handling it"
    
    - name: Cleanup on error
      file:
        path: /tmp/cleanup_file
        state: absent
  
  always:
    - name: Always run this
      debug:
        msg: "This always runs, regardless of success or failure"

# Ignore errors
- name: Optional task
  command: /bin/optional_command
  ignore_errors: yes

# Custom failure conditions
- name: Check application health
  uri:
    url: http://localhost:8080/health
  register: health_check
  failed_when: 
    - health_check.status != 200
    - "'healthy' not in health_check.content"

# Custom change conditions
- name: Check configuration
  command: /bin/check_config
  register: config_check
  changed_when: "'changed' in config_check.stdout"
```

## Advanced Playbook Features

### Multi-Play Playbooks
```yaml
---
# Play 1: Prepare all servers
- name: Prepare servers
  hosts: all
  become: yes
  
  tasks:
    - name: Update system packages
      package:
        name: "*"
        state: latest
    
    - name: Install common packages
      package:
        name: "{{ common_packages }}"
        state: present

# Play 2: Configure web servers
- name: Configure web servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install web server
      package:
        name: nginx
        state: present
    
    - name: Start web server
      service:
        name: nginx
        state: started
        enabled: yes

# Play 3: Configure databases
- name: Configure databases
  hosts: databases
  become: yes
  
  tasks:
    - name: Install database server
      package:
        name: mysql-server
        state: present
```

### Delegation and Local Actions
```yaml
# Delegate to specific host
- name: Update load balancer
  uri:
    url: "http://{{ load_balancer_host }}/api/update"
    method: POST
  delegate_to: "{{ load_balancer_host }}"

# Run on localhost
- name: Generate configuration
  template:
    src: config.j2
    dest: /tmp/config.txt
  delegate_to: localhost

# Run once across all hosts
- name: Create shared resource
  file:
    path: /shared/resource
    state: touch
  run_once: true
  delegate_to: "{{ groups['webservers'][0] }}"

# Local action (shorthand)
- name: Wait for service to start
  local_action:
    module: wait_for
    host: "{{ inventory_hostname }}"
    port: 80
    timeout: 300
```

### Serial Execution and Rolling Updates
```yaml
---
- name: Rolling update
  hosts: webservers
  become: yes
  serial: 1                    # Process one host at a time
  max_fail_percentage: 0       # Stop on any failure
  
  pre_tasks:
    - name: Remove from load balancer
      uri:
        url: "http://lb.example.com/remove/{{ inventory_hostname }}"
        method: POST
      delegate_to: localhost
  
  tasks:
    - name: Stop application
      service:
        name: myapp
        state: stopped
    
    - name: Deploy new version
      copy:
        src: app-v2.jar
        dest: /opt/app/app.jar
        backup: yes
    
    - name: Start application
      service:
        name: myapp
        state: started
    
    - name: Wait for application to be ready
      wait_for:
        port: 8080
        timeout: 60
  
  post_tasks:
    - name: Add back to load balancer
      uri:
        url: "http://lb.example.com/add/{{ inventory_hostname }}"
        method: POST
      delegate_to: localhost
```

### Include and Import
```yaml
# Import playbooks (static)
---
- import_playbook: common.yml
- import_playbook: webservers.yml
- import_playbook: databases.yml

# Include playbooks (dynamic)
---
- include: "{{ item }}"
  loop:
    - common.yml
    - webservers.yml

# Import tasks (static)
tasks:
  - import_tasks: tasks/install.yml
  - import_tasks: tasks/configure.yml

# Include tasks (dynamic)
tasks:
  - include_tasks: "tasks/{{ ansible_os_family }}.yml"
  - include_tasks: tasks/security.yml
    when: security_hardening | default(true)

# Include with variables
- include_tasks: tasks/create_user.yml
  vars:
    username: alice
    user_uid: 1001
  loop:
    - { username: alice, user_uid: 1001 }
    - { username: bob, user_uid: 1002 }
```

## Playbook Organization Patterns

### Site Playbook Pattern
```yaml
# site.yml - Main orchestration playbook
---
- import_playbook: common.yml
- import_playbook: webservers.yml
- import_playbook: databases.yml
- import_playbook: monitoring.yml

# common.yml - Common configuration
---
- name: Common configuration
  hosts: all
  become: yes
  roles:
    - common

# webservers.yml - Web server configuration
---
- name: Configure web servers
  hosts: webservers
  become: yes
  roles:
    - nginx
    - application
```

### Environment-Specific Playbooks
```yaml
# deploy-production.yml
---
- name: Deploy to production
  hosts: production
  become: yes
  vars:
    environment: production
    app_version: "{{ lookup('env', 'APP_VERSION') }}"
  
  pre_tasks:
    - name: Validate deployment
      assert:
        that:
          - app_version is defined
          - app_version != ""
        fail_msg: "APP_VERSION must be specified"
  
  roles:
    - deployment
  
  post_tasks:
    - name: Verify deployment
      uri:
        url: "http://{{ inventory_hostname }}/health"
        status_code: 200
```

### Task Organization
```yaml
# tasks/main.yml
---
- include_tasks: validate.yml
  tags: [validation]

- include_tasks: install.yml
  tags: [install]

- include_tasks: configure.yml
  tags: [configure]

- include_tasks: security.yml
  when: security_hardening | default(true)
  tags: [security]

- include_tasks: service.yml
  tags: [service]
```

## Testing and Validation

### Syntax Checking
```bash
# Check playbook syntax
ansible-playbook playbook.yml --syntax-check

# Check with specific inventory
ansible-playbook -i inventory.yml playbook.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbook.yml --check

# Show differences
ansible-playbook playbook.yml --check --diff
```

### Playbook Testing
```yaml
# test-playbook.yml
---
- name: Test playbook functionality
  hosts: all
  
  tasks:
    - name: Test connectivity
      ping:
    
    - name: Verify service is running
      service:
        name: nginx
        state: started
      check_mode: yes
      register: service_check
    
    - name: Assert service is running
      assert:
        that:
          - service_check.state == "started"
        fail_msg: "Nginx service is not running"
    
    - name: Test HTTP response
      uri:
        url: "http://{{ inventory_hostname }}"
        method: GET
        status_code: 200
      delegate_to: localhost
```

## Best Practices

### Playbook Structure
```yaml
# Use descriptive names
- name: Install and configure Nginx web server with SSL support

# Group related tasks
- block:
    - name: Install packages
      package:
        name: "{{ packages }}"
        state: present
    
    - name: Configure services
      template:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
      loop: "{{ config_files }}"
  tags: [installation]

# Use tags for organization
- name: Configure firewall
  firewalld:
    service: http
    state: enabled
  tags: [security, firewall]
```

### Error Handling
```yaml
# Validate inputs
- name: Validate required variables
  assert:
    that:
      - app_name is defined
      - app_version is defined
    fail_msg: "Required variables not defined"

# Use meaningful error messages
- name: Check disk space
  shell: df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
  register: disk_usage
  failed_when: disk_usage.stdout | int > 90
  changed_when: false
```

### Performance Optimization
```yaml
# Disable fact gathering when not needed
- name: Quick task execution
  hosts: all
  gather_facts: no
  
  tasks:
    - name: Simple command
      command: echo "Hello World"

# Use async for long-running tasks
- name: Long running update
  yum:
    name: "*"
    state: latest
  async: 300
  poll: 0
  register: update_job

# Batch operations
- name: Install multiple packages
  package:
    name: "{{ packages }}"
    state: present
  vars:
    packages:
      - git
      - curl
      - wget
```

This comprehensive playbook guide covers all aspects of creating effective Ansible automation workflows.