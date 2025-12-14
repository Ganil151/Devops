# Ansible Loops and Conditionals

Advanced guide to loops, conditionals, and control flow in Ansible for complex automation scenarios.

## Loop Fundamentals

### Basic Loop Syntax
```yaml
# Simple loop with list
- name: Install packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - curl
    - wget
    - vim

# Loop with variables
- name: Install packages from variable
  package:
    name: "{{ item }}"
    state: present
  loop: "{{ packages_list }}"
```

### Loop Types and Patterns

#### Standard Loops
```yaml
# Loop over simple list
- name: Create directories
  file:
    path: "/opt/{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - app1
    - app2
    - app3

# Loop over dictionary list
- name: Create users
  user:
    name: "{{ item.name }}"
    uid: "{{ item.uid }}"
    group: "{{ item.group }}"
    shell: "{{ item.shell | default('/bin/bash') }}"
  loop:
    - { name: alice, uid: 1001, group: users }
    - { name: bob, uid: 1002, group: users, shell: /bin/zsh }
    - { name: charlie, uid: 1003, group: admin }

# Loop over range
- name: Create numbered directories
  file:
    path: "/tmp/dir{{ item }}"
    state: directory
  loop: "{{ range(1, 6) | list }}"  # Creates dir1 through dir5
```

#### Dictionary Loops
```yaml
# Loop over dictionary items
- name: Configure services
  service:
    name: "{{ item.key }}"
    state: "{{ item.value.state }}"
    enabled: "{{ item.value.enabled }}"
  loop: "{{ services | dict2items }}"
  vars:
    services:
      nginx:
        state: started
        enabled: yes
      mysql:
        state: started
        enabled: yes
      redis:
        state: stopped
        enabled: no

# Loop over nested dictionaries
- name: Configure database connections
  template:
    src: db_config.j2
    dest: "/etc/{{ item.key }}/database.conf"
  loop: "{{ databases | dict2items }}"
  vars:
    databases:
      app1:
        host: db1.example.com
        port: 3306
        name: app1_db
      app2:
        host: db2.example.com
        port: 5432
        name: app2_db
```

### Advanced Loop Techniques

#### Nested Loops with subelements
```yaml
# Loop over users and their SSH keys
- name: Add SSH keys for users
  authorized_key:
    user: "{{ item.0.name }}"
    key: "{{ item.1 }}"
    state: present
  loop: "{{ users | subelements('ssh_keys', skip_missing=True) }}"
  vars:
    users:
      - name: alice
        ssh_keys:
          - "ssh-rsa AAAAB3NzaC1yc2E... alice@laptop"
          - "ssh-rsa AAAAB3NzaC1yc2E... alice@desktop"
      - name: bob
        ssh_keys:
          - "ssh-rsa AAAAB3NzaC1yc2E... bob@laptop"
      - name: charlie  # No ssh_keys defined

# Loop over groups and their members
- name: Add users to groups
  user:
    name: "{{ item.1 }}"
    groups: "{{ item.0.name }}"
    append: yes
  loop: "{{ groups | subelements('members') }}"
  vars:
    groups:
      - name: developers
        members:
          - alice
          - bob
      - name: admins
        members:
          - charlie
          - alice
```

#### Product Loops
```yaml
# Cartesian product of two lists
- name: Configure firewall rules for all combinations
  firewalld:
    port: "{{ item.0 }}/{{ item.1 }}"
    permanent: yes
    state: enabled
  loop: "{{ ports | product(protocols) | list }}"
  vars:
    ports: [80, 443, 8080]
    protocols: [tcp, udp]

# Complex product with conditions
- name: Deploy applications to environments
  template:
    src: "{{ item.0.template }}"
    dest: "/etc/{{ item.1 }}/{{ item.0.name }}.conf"
  loop: "{{ applications | product(environments) | list }}"
  when: item.0.deploy_to_all or item.1 in item.0.environments
  vars:
    applications:
      - name: webapp
        template: webapp.conf.j2
        deploy_to_all: false
        environments: [production, staging]
      - name: api
        template: api.conf.j2
        deploy_to_all: true
    environments: [development, staging, production]
```

### Loop Control

#### Loop Variables and Control
```yaml
# Using loop_control for custom variables
- name: Process items with custom loop variable
  debug:
    msg: "Processing {{ app.name }} version {{ app.version }}"
  loop: "{{ applications }}"
  loop_control:
    loop_var: app
    index_var: app_index
    label: "{{ app.name }}"  # Cleaner output
  vars:
    applications:
      - name: webapp
        version: 1.0.0
      - name: api
        version: 2.1.0

# Pause between loop iterations
- name: Deploy with delays
  service:
    name: "{{ item }}"
    state: restarted
  loop: "{{ services }}"
  loop_control:
    pause: 30  # 30 second pause between iterations

# Extended loop information
- name: Loop with extended info
  debug:
    msg: |
      Item {{ loop_index }} of {{ loop_length }}: {{ item }}
      First: {{ loop_first }}, Last: {{ loop_last }}
      Previous: {{ loop_previtem | default('N/A') }}
      Next: {{ loop_nextitem | default('N/A') }}
  loop: "{{ ['a', 'b', 'c', 'd'] }}"
  loop_control:
    extended: yes
    index_var: loop_index
    loop_var: item
```

## Conditional Fundamentals

### Basic Conditionals
```yaml
# Simple when condition
- name: Install development packages
  package:
    name: "{{ dev_packages }}"
    state: present
  when: environment == "development"

# Multiple conditions (AND)
- name: Configure SSL
  template:
    src: ssl.conf.j2
    dest: /etc/nginx/ssl.conf
  when:
    - ssl_enabled | default(false)
    - ssl_certificate is defined
    - ssl_private_key is defined

# Multiple conditions (OR)
- name: Install web server
  package:
    name: "{{ web_server_package }}"
    state: present
  when: web_server_type == "nginx" or web_server_type == "apache"
```

### Advanced Conditionals

#### Complex Boolean Logic
```yaml
# Complex conditional expressions
- name: Configure firewall
  firewalld:
    service: "{{ item }}"
    state: enabled
    permanent: yes
  loop: "{{ firewall_services }}"
  when: >
    firewall_enabled | default(true) and
    (environment == "production" or security_hardening | default(false)) and
    not (development_mode | default(false))

# Conditional with calculations
- name: Allocate memory based on system resources
  lineinfile:
    path: /etc/myapp/config.conf
    regexp: '^memory_limit'
    line: "memory_limit = {{ calculated_memory }}M"
  vars:
    calculated_memory: "{{ (ansible_memtotal_mb * 0.7) | int }}"
  when: 
    - ansible_memtotal_mb is defined
    - ansible_memtotal_mb | int > 1024
    - calculated_memory | int > 512
```

#### Fact-Based Conditionals
```yaml
# OS-specific conditionals
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

# Version-specific conditionals
- name: Configure systemd service (RHEL 7+)
  systemd:
    name: myapp
    state: started
    enabled: yes
    daemon_reload: yes
  when: 
    - ansible_os_family == "RedHat"
    - ansible_distribution_major_version | int >= 7

# Architecture-specific conditionals
- name: Install 64-bit specific package
  package:
    name: "{{ item }}"
    state: present
  loop: "{{ x64_packages }}"
  when: ansible_architecture == "x86_64"
```

### Variable Testing

#### Existence and Type Testing
```yaml
# Test variable existence
- name: Configure database if defined
  template:
    src: database.conf.j2
    dest: /etc/app/database.conf
  when: database_config is defined

# Test variable type
- name: Process list variable
  debug:
    msg: "Processing {{ item }}"
  loop: "{{ my_variable }}"
  when: my_variable is iterable and my_variable is not string

# Test for empty values
- name: Skip if list is empty
  debug:
    msg: "List has items"
  when: 
    - my_list is defined
    - my_list | length > 0

# Test for specific values
- name: Configure production settings
  template:
    src: prod.conf.j2
    dest: /etc/app/config.conf
  when: 
    - environment is defined
    - environment in ['production', 'prod']
```

#### String and Numeric Testing
```yaml
# String testing
- name: Configure SSL if certificate path provided
  template:
    src: ssl.conf.j2
    dest: /etc/nginx/ssl.conf
  when: 
    - ssl_cert_path is defined
    - ssl_cert_path | length > 0
    - ssl_cert_path is match("^/.*\\.crt$")

# Numeric testing
- name: Configure memory settings
  lineinfile:
    path: /etc/app/config.conf
    regexp: '^max_memory'
    line: "max_memory = {{ max_memory }}"
  when:
    - max_memory is defined
    - max_memory | int > 0
    - max_memory | int <= ansible_memtotal_mb

# Version comparison
- name: Install modern configuration
  template:
    src: modern.conf.j2
    dest: /etc/app/config.conf
  when: app_version is version('2.0.0', '>=')
```

## Combined Loops and Conditionals

### Conditional Loops
```yaml
# Loop with item-specific conditions
- name: Install optional packages
  package:
    name: "{{ item.name }}"
    state: present
  loop: "{{ packages }}"
  when: 
    - item.install | default(true)
    - item.os_family | default('all') in ['all', ansible_os_family]
  vars:
    packages:
      - name: git
        install: true
      - name: docker
        install: "{{ docker_enabled | default(false) }}"
      - name: httpd
        os_family: RedHat
      - name: apache2
        os_family: Debian

# Environment-specific loops
- name: Deploy environment-specific configurations
  template:
    src: "{{ item.template }}"
    dest: "{{ item.dest }}"
  loop: "{{ configurations }}"
  when: 
    - item.environments is undefined or environment in item.environments
    - item.condition | default(true)
  vars:
    configurations:
      - template: base.conf.j2
        dest: /etc/app/base.conf
      - template: ssl.conf.j2
        dest: /etc/app/ssl.conf
        environments: [production, staging]
        condition: "{{ ssl_enabled | default(false) }}"
      - template: debug.conf.j2
        dest: /etc/app/debug.conf
        environments: [development]
```

### Nested Conditionals in Loops
```yaml
# Complex nested logic
- name: Configure services based on multiple conditions
  block:
    - name: Configure web services
      template:
        src: "{{ item.template }}"
        dest: "/etc/{{ item.name }}/{{ item.config_file }}"
      loop: "{{ web_services }}"
      when: 
        - item.enabled | default(true)
        - web_tier_enabled | default(true)
      notify: "restart {{ item.name }}"
    
    - name: Configure database services
      template:
        src: "{{ item.template }}"
        dest: "/etc/{{ item.name }}/{{ item.config_file }}"
      loop: "{{ database_services }}"
      when:
        - item.enabled | default(true)
        - database_tier_enabled | default(true)
        - item.environment | default('all') in ['all', environment]
  when: service_configuration_enabled | default(true)
```

## Advanced Patterns

### Dynamic Conditional Logic
```yaml
# Build conditions dynamically
- name: Set dynamic conditions
  set_fact:
    install_conditions: |
      {%- set conditions = [] -%}
      {%- if environment == 'production' -%}
        {%- set _ = conditions.append('production_ready') -%}
      {%- endif -%}
      {%- if security_hardening | default(false) -%}
        {%- set _ = conditions.append('security_approved') -%}
      {%- endif -%}
      {%- if performance_optimized | default(false) -%}
        {%- set _ = conditions.append('performance_tested') -%}
      {%- endif -%}
      {{ conditions }}

- name: Install packages based on dynamic conditions
  package:
    name: "{{ item.name }}"
    state: present
  loop: "{{ packages }}"
  when: 
    - item.required_conditions | default([]) | length == 0 or
      (item.required_conditions | intersect(install_conditions) | length > 0)
```

### Conditional Includes
```yaml
# Conditional task inclusion
- name: Include OS-specific tasks
  include_tasks: "{{ ansible_os_family | lower }}.yml"
  when: ansible_os_family in ['RedHat', 'Debian', 'Suse']

- name: Include environment-specific tasks
  include_tasks: "{{ environment }}.yml"
  when: 
    - environment is defined
    - environment in ['development', 'staging', 'production']

# Loop over conditional includes
- name: Include role-specific configurations
  include_tasks: "roles/{{ item }}.yml"
  loop: "{{ server_roles }}"
  when: 
    - server_roles is defined
    - item in available_roles
  vars:
    available_roles: [webserver, database, cache, monitoring]
```

### Error Handling with Conditionals
```yaml
# Conditional error handling
- name: Operation with conditional recovery
  block:
    - name: Primary operation
      command: primary_command
      register: primary_result
      failed_when: 
        - primary_result.rc != 0
        - primary_result.rc != 2  # Warning code acceptable
    
    - name: Secondary operation if primary succeeded
      command: secondary_command
      when: primary_result.rc == 0
    
    - name: Warning handling
      debug:
        msg: "Primary operation completed with warnings"
      when: primary_result.rc == 2
  
  rescue:
    - name: Conditional recovery based on error type
      block:
        - name: Network-related recovery
          command: network_recovery_command
          when: "'network' in ansible_failed_result.msg | lower"
        
        - name: Permission-related recovery
          command: permission_recovery_command
          when: "'permission' in ansible_failed_result.msg | lower"
        
        - name: Generic recovery
          command: generic_recovery_command
          when: 
            - "'network' not in ansible_failed_result.msg | lower"
            - "'permission' not in ansible_failed_result.msg | lower"
```

## Performance Optimization

### Efficient Conditionals
```yaml
# Cache expensive condition evaluations
- name: Cache complex condition
  set_fact:
    should_install_package: >-
      {{
        (environment == 'production' and security_level == 'high') or
        (environment == 'staging' and testing_enabled | default(false)) or
        (environment == 'development')
      }}

- name: Use cached condition
  package:
    name: "{{ item }}"
    state: present
  loop: "{{ packages }}"
  when: should_install_package

# Optimize loop conditions
- name: Efficient loop with pre-filtering
  package:
    name: "{{ item.name }}"
    state: present
  loop: "{{ packages | selectattr('install', 'equalto', true) | list }}"
  # More efficient than checking item.install in when clause
```

### Conditional Optimization
```yaml
# Use early exit patterns
- name: Early exit optimization
  block:
    - name: Check prerequisites
      fail:
        msg: "Prerequisites not met"
      when: not prerequisites_met

    - name: Skip expensive operations
      meta: end_play
      when: skip_deployment | default(false)
    
    - name: Continue with expensive operations
      include_tasks: expensive_operations.yml
```

## Best Practices

### Readable Conditionals
```yaml
# Use descriptive variable names for complex conditions
- name: Set readable condition variables
  set_fact:
    is_production_environment: "{{ environment == 'production' }}"
    has_ssl_certificate: "{{ ssl_cert_path is defined and ssl_cert_path | length > 0 }}"
    requires_security_hardening: "{{ security_level | default('medium') in ['high', 'maximum'] }}"

- name: Use readable conditions
  template:
    src: secure.conf.j2
    dest: /etc/app/config.conf
  when: 
    - is_production_environment
    - has_ssl_certificate
    - requires_security_hardening

# Break complex conditions into multiple tasks
- name: Check security requirements
  set_fact:
    security_check_passed: true
  when:
    - ssl_enabled | default(false)
    - firewall_enabled | default(false)
    - audit_logging_enabled | default(false)

- name: Apply security configuration
  template:
    src: security.conf.j2
    dest: /etc/security/config.conf
  when: security_check_passed | default(false)
```

### Loop Optimization
```yaml
# Batch operations when possible
- name: Efficient package installation
  package:
    name: "{{ packages | selectattr('install', 'equalto', true) | map(attribute='name') | list }}"
    state: present
  # Better than looping over individual packages

# Use appropriate loop types
- name: Use dict2items for dictionary operations
  lineinfile:
    path: /etc/app/config.conf
    regexp: "^{{ item.key }}="
    line: "{{ item.key }}={{ item.value }}"
  loop: "{{ app_config | dict2items }}"
  # More efficient than iterating over keys and values separately
```

This comprehensive guide covers advanced loop and conditional patterns for creating sophisticated Ansible automation workflows.