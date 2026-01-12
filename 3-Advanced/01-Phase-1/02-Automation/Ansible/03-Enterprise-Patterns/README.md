# Ansible Best Practices

Comprehensive guide to Ansible best practices for production-ready automation, maintainable code, and scalable infrastructure management.

## Project Organization

### Directory Structure

```bash
# Recommended project structure
ansible-project/
├── ansible.cfg                    # Ansible configuration
├── requirements.yml               # Galaxy roles and collections
├── site.yml                      # Main playbook
├── inventories/                   # Environment-specific inventories
│   ├── production/
│   │   ├── hosts.yml
│   │   ├── group_vars/
│   │   │   ├── all.yml
│   │   │   ├── webservers.yml
│   │   │   └── databases.yml
│   │   └── host_vars/
│   │       └── web1.example.com.yml
│   ├── staging/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── development/
│       ├── hosts.yml
│       └── group_vars/
├── group_vars/                    # Global group variables
│   ├── all.yml
│   └── vault.yml                  # Encrypted variables
├── host_vars/                     # Host-specific variables
├── roles/                         # Custom roles
│   ├── common/
│   ├── webserver/
│   └── database/
├── playbooks/                     # Specific playbooks
│   ├── webservers.yml
│   ├── databases.yml
│   └── monitoring.yml
├── files/                         # Static files
├── templates/                     # Jinja2 templates
├── vars/                          # Additional variables
├── vault/                         # Vault files
├── scripts/                       # Helper scripts
├── docs/                          # Documentation
└── tests/                         # Test playbooks
```

### Configuration Management

#### Ansible Configuration (ansible.cfg)

```ini
[defaults]
# Inventory
inventory = inventories/production/hosts.yml
host_key_checking = False
retry_files_enabled = False

# Performance
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
forks = 20
poll_interval = 15

# Output
stdout_callback = yaml
callback_whitelist = profile_tasks, timer
display_skipped_hosts = False
display_ok_hosts = False

# SSH
remote_user = ansible
private_key_file = ~/.ssh/ansible_key
timeout = 30

# Logging
log_path = logs/ansible.log

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml
```

## Inventory Management

### Environment Separation

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
    
    loadbalancers:
      hosts:
        lb1.prod.example.com:
          ansible_host: 10.0.3.10
      vars:
        environment: production
  
  vars:
    ansible_user: ansible
    ansible_ssh_private_key_file: ~/.ssh/production_key
    domain_name: example.com
```

### Dynamic Inventory Best Practices

```yaml
# aws_ec2.yml - AWS dynamic inventory
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
  # Group by instance type
  - key: instance_type
    prefix: type
  # Group by environment tag
  - key: tags.Environment
    prefix: env
  # Group by role tag
  - key: tags.Role
    prefix: role

hostnames:
  - tag:Name
  - dns-name

compose:
  ansible_host: public_ip_address
  ec2_state: ec2_state_name
  ec2_architecture: ec2_architecture
```

## Variable Management

### Variable Hierarchy and Naming

```yaml
# group_vars/all.yml - Global variables
---
# Application configuration
app_name: myapp
app_version: "{{ lookup('env', 'APP_VERSION') | default('1.0.0') }}"
app_environment: "{{ environment }}"

# Common packages
common_packages:
  - git
  - curl
  - wget
  - vim
  - htop

# Security settings
security_ssh_port: 22
security_fail2ban_enabled: true
security_firewall_enabled: true

# Monitoring
monitoring_enabled: true
log_retention_days: 30

# Backup settings
backup_enabled: true
backup_retention_days: 7
```

```yaml
# group_vars/webservers.yml - Web server specific variables
---
# Web server configuration
webserver_type: nginx
webserver_port: 80
webserver_ssl_port: 443
webserver_worker_processes: auto
webserver_worker_connections: 1024

# SSL configuration
ssl_enabled: true
ssl_certificate_path: /etc/ssl/certs
ssl_private_key_path: /etc/ssl/private

# Application deployment
app_deploy_path: /var/www/html
app_user: www-data
app_group: www-data

# Performance tuning
webserver_keepalive_timeout: 65
webserver_client_max_body_size: 64m
```

### Vault Management

```yaml
# group_vars/vault.yml - Encrypted variables
---
$ANSIBLE_VAULT;1.1;AES256
66386439653762391081743...

# When decrypted, contains:
vault_mysql_root_password: SuperSecretPassword123!
vault_app_database_password: AppDBPassword456!
vault_ssl_private_key: |
  -----BEGIN PRIVATE KEY-----
  MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...
  -----END PRIVATE KEY-----
```

### Variable Validation

```yaml
# roles/webserver/tasks/validate.yml
---
- name: Validate required variables
  assert:
    that:
      - webserver_type is defined
      - webserver_type in ['nginx', 'apache']
      - webserver_port is defined
      - webserver_port | int > 0
      - webserver_port | int < 65536
    fail_msg: "Invalid webserver configuration"
    success_msg: "Webserver configuration validated"

- name: Validate SSL configuration
  assert:
    that:
      - ssl_certificate_path is defined
      - ssl_private_key_path is defined
    fail_msg: "SSL configuration incomplete"
  when: ssl_enabled | default(false)
```

## Playbook Design

### Modular Playbook Structure

```yaml
# site.yml - Main orchestration playbook
---
- import_playbook: playbooks/common.yml
- import_playbook: playbooks/security.yml
- import_playbook: playbooks/webservers.yml
- import_playbook: playbooks/databases.yml
- import_playbook: playbooks/loadbalancers.yml
- import_playbook: playbooks/monitoring.yml
```

```yaml
# playbooks/webservers.yml - Web server deployment
---
- name: Configure web servers
  hosts: webservers
  become: yes
  serial: "{{ rolling_update_batch_size | default('25%') }}"
  max_fail_percentage: 10
  
  pre_tasks:
    - name: Validate environment
      include_tasks: tasks/validate_environment.yml
    
    - name: Remove from load balancer
      include_tasks: tasks/remove_from_lb.yml
      when: loadbalancer_integration | default(true)
  
  roles:
    - role: common
      tags: [common]
    
    - role: security
      tags: [security]
    
    - role: webserver
      tags: [webserver]
    
    - role: application
      tags: [application]
  
  post_tasks:
    - name: Verify application health
      include_tasks: tasks/health_check.yml
    
    - name: Add back to load balancer
      include_tasks: tasks/add_to_lb.yml
      when: loadbalancer_integration | default(true)
  
  handlers:
    - name: restart webserver
      service:
        name: "{{ webserver_service_name }}"
        state: restarted
      listen: "restart webserver"
```

### Error Handling and Recovery

```yaml
# Error handling best practices
---
- name: Deploy application with error handling
  hosts: webservers
  become: yes
  
  tasks:
    - name: Application deployment block
      block:
        - name: Stop application service
          service:
            name: myapp
            state: stopped
        
        - name: Backup current application
          archive:
            path: /opt/myapp
            dest: "/backup/myapp-{{ ansible_date_time.epoch }}.tar.gz"
        
        - name: Deploy new application version
          unarchive:
            src: "{{ app_package_url }}"
            dest: /opt/myapp
            remote_src: yes
            owner: myapp
            group: myapp
        
        - name: Start application service
          service:
            name: myapp
            state: started
        
        - name: Verify application health
          uri:
            url: "http://{{ ansible_default_ipv4.address }}:8080/health"
            method: GET
            status_code: 200
          retries: 5
          delay: 10
      
      rescue:
        - name: Rollback on failure
          debug:
            msg: "Deployment failed, initiating rollback"
        
        - name: Stop failed application
          service:
            name: myapp
            state: stopped
          ignore_errors: yes
        
        - name: Restore from backup
          unarchive:
            src: "/backup/myapp-{{ ansible_date_time.epoch }}.tar.gz"
            dest: /opt/
            remote_src: yes
        
        - name: Start restored application
          service:
            name: myapp
            state: started
        
        - name: Fail the play
          fail:
            msg: "Application deployment failed and was rolled back"
      
      always:
        - name: Clean up temporary files
          file:
            path: /tmp/deployment
            state: absent
```

## Role Development

### Role Structure and Standards

```bash
# roles/webserver/ - Standard role structure
roles/webserver/
├── README.md                      # Role documentation
├── meta/
│   └── main.yml                   # Role metadata and dependencies
├── defaults/
│   └── main.yml                   # Default variables
├── vars/
│   └── main.yml                   # Role variables
├── tasks/
│   ├── main.yml                   # Main task file
│   ├── install.yml                # Installation tasks
│   ├── configure.yml              # Configuration tasks
│   ├── security.yml               # Security hardening
│   └── validate.yml               # Validation tasks
├── handlers/
│   └── main.yml                   # Event handlers
├── templates/
│   ├── nginx.conf.j2              # Configuration templates
│   └── site.conf.j2
├── files/
│   ├── ssl_cert.pem               # Static files
│   └── custom_script.sh
└── tests/
    ├── inventory                  # Test inventory
    └── test.yml                   # Test playbook
```

### Role Best Practices

```yaml
# roles/webserver/meta/main.yml
---
galaxy_info:
  author: DevOps Team
  description: Production-ready web server configuration
  company: Example Corp
  license: MIT
  min_ansible_version: 2.9
  platforms:
    - name: EL
      versions:
        - 7
        - 8
    - name: Ubuntu
      versions:
        - 18.04
        - 20.04
  galaxy_tags:
    - webserver
    - nginx
    - apache

dependencies:
  - role: common
    vars:
      common_packages:
        - curl
        - wget
  - role: security
    when: security_hardening_enabled | default(true)

collections:
  - community.general
  - ansible.posix
```

```yaml
# roles/webserver/defaults/main.yml
---
# Web server configuration
webserver_type: nginx
webserver_version: latest
webserver_port: 80
webserver_ssl_port: 443
webserver_user: www-data
webserver_group: www-data

# Performance settings
webserver_worker_processes: auto
webserver_worker_connections: 1024
webserver_keepalive_timeout: 65
webserver_client_max_body_size: 64m

# SSL configuration
ssl_enabled: false
ssl_certificate_path: /etc/ssl/certs
ssl_private_key_path: /etc/ssl/private
ssl_protocols:
  - TLSv1.2
  - TLSv1.3

# Security settings
security_headers_enabled: true
security_server_tokens: false
security_hide_version: true

# Logging
access_log_enabled: true
error_log_enabled: true
log_level: warn
log_rotation_enabled: true
```

```yaml
# roles/webserver/tasks/main.yml
---
- name: Include OS-specific variables
  include_vars: "{{ ansible_os_family }}.yml"

- name: Validate configuration
  include_tasks: validate.yml
  tags: [validation]

- name: Install web server
  include_tasks: install.yml
  tags: [install]

- name: Configure web server
  include_tasks: configure.yml
  tags: [configure]

- name: Apply security hardening
  include_tasks: security.yml
  when: security_hardening_enabled | default(true)
  tags: [security]

- name: Start and enable web server
  service:
    name: "{{ webserver_service_name }}"
    state: started
    enabled: yes
  tags: [service]

- name: Verify web server is running
  uri:
    url: "http://{{ ansible_default_ipv4.address }}:{{ webserver_port }}"
    method: GET
    status_code: [200, 301, 302]
  retries: 3
  delay: 5
  tags: [verification]
```

## Security Best Practices

### Secrets Management

```yaml
# Vault usage best practices
---
- name: Secure database configuration
  hosts: databases
  become: yes
  vars:
    # Reference vault variables
    mysql_root_password: "{{ vault_mysql_root_password }}"
    app_db_password: "{{ vault_app_db_password }}"
  
  tasks:
    - name: Configure MySQL root password
      mysql_user:
        name: root
        password: "{{ mysql_root_password }}"
        login_unix_socket: /var/lib/mysql/mysql.sock
      no_log: true  # Prevent password logging
    
    - name: Create application database user
      mysql_user:
        name: appuser
        password: "{{ app_db_password }}"
        priv: "appdb.*:ALL"
        state: present
        login_user: root
        login_password: "{{ mysql_root_password }}"
      no_log: true
```

### SSH and Access Control

```yaml
# Security hardening playbook
---
- name: Harden SSH configuration
  hosts: all
  become: yes
  
  tasks:
    - name: Configure SSH security settings
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        backup: yes
      loop:
        - { regexp: '^#?PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^#?PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^#?Protocol', line: 'Protocol 2' }
        - { regexp: '^#?X11Forwarding', line: 'X11Forwarding no' }
        - { regexp: '^#?MaxAuthTries', line: 'MaxAuthTries 3' }
        - { regexp: '^#?ClientAliveInterval', line: 'ClientAliveInterval 300' }
        - { regexp: '^#?ClientAliveCountMax', line: 'ClientAliveCountMax 2' }
      notify: restart sshd
    
    - name: Create dedicated ansible user
      user:
        name: ansible
        shell: /bin/bash
        groups: wheel
        append: yes
        create_home: yes
    
    - name: Configure sudo for ansible user
      lineinfile:
        path: /etc/sudoers.d/ansible
        line: 'ansible ALL=(ALL) NOPASSWD: ALL'
        create: yes
        mode: '0440'
        validate: 'visudo -cf %s'
    
    - name: Install ansible user SSH key
      authorized_key:
        user: ansible
        key: "{{ lookup('file', '~/.ssh/ansible_key.pub') }}"
        state: present
  
  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted
```

## Performance Optimization

### Parallel Execution

```yaml
# Optimized playbook execution
---
- name: Deploy application across multiple servers
  hosts: webservers
  become: yes
  strategy: free  # Allow hosts to run independently
  serial: "30%"   # Process 30% of hosts at a time
  
  tasks:
    - name: Download application package
      get_url:
        url: "{{ app_package_url }}"
        dest: "/tmp/{{ app_package_name }}"
        mode: '0644'
      async: 300      # Run asynchronously
      poll: 0         # Don't wait for completion
      register: download_job
    
    - name: Install system packages
      package:
        name: "{{ item }}"
        state: present
      loop: "{{ required_packages }}"
      async: 180
      poll: 0
      register: package_job
    
    - name: Wait for download to complete
      async_status:
        jid: "{{ download_job.ansible_job_id }}"
      register: download_result
      until: download_result.finished
      retries: 30
      delay: 10
    
    - name: Wait for package installation
      async_status:
        jid: "{{ item.ansible_job_id }}"
      register: package_result
      until: package_result.finished
      retries: 18
      delay: 10
      loop: "{{ package_job.results }}"
```

### Fact Caching

```ini
# ansible.cfg - Enable fact caching
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400

# Or use Redis for distributed caching
fact_caching = redis
fact_caching_connection = redis://localhost:6379/0
```

## Testing and Validation

### Molecule Testing

```yaml
# molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: quay.io/ansible/molecule-ubuntu:18.04
    pre_build_image: true
provisioner:
  name: ansible
  config_options:
    defaults:
      callback_whitelist: profile_tasks,timer
verifier:
  name: ansible
```

```yaml
# molecule/default/converge.yml
---
- name: Converge
  hosts: all
  become: true
  tasks:
    - name: Include webserver role
      include_role:
        name: webserver
      vars:
        webserver_type: nginx
        ssl_enabled: false
```

```yaml
# molecule/default/verify.yml
---
- name: Verify
  hosts: all
  gather_facts: false
  tasks:
    - name: Check if nginx is running
      service:
        name: nginx
        state: started
      check_mode: yes
      register: nginx_status
    
    - name: Verify nginx is active
      assert:
        that:
          - nginx_status.state == "started"
        fail_msg: "Nginx service is not running"
    
    - name: Test HTTP response
      uri:
        url: http://localhost:80
        method: GET
        status_code: 200
      retries: 3
      delay: 5
```

### Integration Testing

```yaml
# tests/integration.yml
---
- name: Integration test suite
  hosts: all
  become: yes
  
  tasks:
    - name: Test web server response
      uri:
        url: "http://{{ ansible_default_ipv4.address }}"
        method: GET
        status_code: 200
        timeout: 10
      delegate_to: localhost
    
    - name: Test database connectivity
      mysql_db:
        name: testdb
        state: present
        login_host: "{{ ansible_default_ipv4.address }}"
        login_user: testuser
        login_password: testpass
      delegate_to: localhost
      when: "'databases' in group_names"
    
    - name: Test application health endpoint
      uri:
        url: "http://{{ ansible_default_ipv4.address }}:8080/health"
        method: GET
        status_code: 200
        return_content: yes
      register: health_check
      delegate_to: localhost
    
    - name: Verify health check response
      assert:
        that:
          - health_check.json.status == "healthy"
        fail_msg: "Application health check failed"
```

## Documentation and Maintenance

### Role Documentation Template

```markdown
# Webserver Role

## Description
Production-ready web server configuration role supporting Nginx and Apache.

## Requirements
- Ansible 2.9+
- Target OS: Ubuntu 18.04+, CentOS 7+

## Role Variables

### Required Variables
- `webserver_type`: Web server type (nginx/apache)
- `domain_name`: Primary domain name

### Optional Variables
- `ssl_enabled`: Enable SSL/TLS (default: false)
- `webserver_port`: HTTP port (default: 80)
- `webserver_ssl_port`: HTTPS port (default: 443)

## Dependencies
- common
- security (when security_hardening_enabled is true)

## Example Playbook
```yaml
- hosts: webservers
  roles:
    - role: webserver
      vars:
        webserver_type: nginx
        domain_name: example.com
        ssl_enabled: true
```

## Testing
```bash
molecule test
```

## License
MIT
```

### Change Management

```yaml
# Playbook versioning and change tracking
---
- name: Application deployment v2.1.0
  hosts: webservers
  become: yes
  vars:
    deployment_version: "2.1.0"
    deployment_timestamp: "{{ ansible_date_time.iso8601 }}"
    deployment_user: "{{ ansible_user_id }}"
  
  pre_tasks:
    - name: Log deployment start
      lineinfile:
        path: /var/log/deployments.log
        line: "{{ deployment_timestamp }} - Starting deployment {{ deployment_version }} by {{ deployment_user }}"
        create: yes
  
  tasks:
    - name: Deploy application
      # Deployment tasks here
      debug:
        msg: "Deploying version {{ deployment_version }}"
  
  post_tasks:
    - name: Log deployment completion
      lineinfile:
        path: /var/log/deployments.log
        line: "{{ deployment_timestamp }} - Completed deployment {{ deployment_version }} by {{ deployment_user }}"
    
    - name: Update deployment metadata
      copy:
        content: |
          version: {{ deployment_version }}
          timestamp: {{ deployment_timestamp }}
          user: {{ deployment_user }}
          commit: {{ lookup('env', 'GIT_COMMIT') | default('unknown') }}
        dest: /opt/app/.deployment_info
```

This comprehensive best practices guide ensures maintainable, secure, and scalable Ansible automation implementations.