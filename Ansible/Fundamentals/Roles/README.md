# Ansible Roles

Complete guide to Ansible role development, organization, and best practices for reusable automation components.

## Role Basics

### What are Roles?

Roles are a way to organize playbooks and other files in a structured manner. They provide a framework for fully independent, or interdependent collections of variables, tasks, files, templates, and modules.

### Role Benefits
- **Reusability**: Use across multiple playbooks and projects
- **Organization**: Structured file layout for maintainability
- **Sharing**: Easy distribution via Ansible Galaxy
- **Modularity**: Independent components that can be combined
- **Testing**: Isolated testing of specific functionality

## Role Structure

### Standard Role Directory Layout
```bash
roles/
└── webserver/
    ├── README.md              # Role documentation
    ├── meta/
    │   └── main.yml          # Role metadata and dependencies
    ├── defaults/
    │   └── main.yml          # Default variables (lowest precedence)
    ├── vars/
    │   └── main.yml          # Role variables (higher precedence)
    ├── tasks/
    │   ├── main.yml          # Main task file
    │   ├── install.yml       # Installation tasks
    │   ├── configure.yml     # Configuration tasks
    │   └── service.yml       # Service management tasks
    ├── handlers/
    │   └── main.yml          # Event handlers
    ├── templates/
    │   ├── nginx.conf.j2     # Jinja2 templates
    │   └── site.conf.j2
    ├── files/
    │   ├── ssl_cert.pem      # Static files
    │   └── custom_script.sh
    ├── library/              # Custom modules (optional)
    ├── module_utils/         # Custom module utilities (optional)
    └── tests/
        ├── inventory         # Test inventory
        └── test.yml          # Test playbook
```

### Role Creation
```bash
# Create role structure manually
mkdir -p roles/webserver/{tasks,handlers,templates,files,vars,defaults,meta,tests}

# Create role using ansible-galaxy
ansible-galaxy init webserver

# Create role in specific directory
ansible-galaxy init --init-path roles/ webserver
```

## Role Components

### Tasks (tasks/main.yml)
```yaml
---
# Main task file - entry point for role execution
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

- name: Manage web server service
  include_tasks: service.yml
  tags: [service]

- name: Setup SSL certificates
  include_tasks: ssl.yml
  when: ssl_enabled | default(false)
  tags: [ssl]
```

### Task Organization
```yaml
# tasks/install.yml
---
- name: Install web server packages (RedHat)
  yum:
    name: "{{ webserver_packages_redhat }}"
    state: present
  when: ansible_os_family == "RedHat"

- name: Install web server packages (Debian)
  apt:
    name: "{{ webserver_packages_debian }}"
    state: present
    update_cache: yes
  when: ansible_os_family == "Debian"

- name: Create web server user
  user:
    name: "{{ webserver_user }}"
    group: "{{ webserver_group }}"
    system: yes
    shell: /sbin/nologin
    home: "{{ webserver_home }}"
    create_home: no

# tasks/configure.yml
---
- name: Create configuration directories
  file:
    path: "{{ item }}"
    state: directory
    owner: root
    group: root
    mode: '0755'
  loop:
    - "{{ webserver_conf_dir }}"
    - "{{ webserver_conf_dir }}/sites-available"
    - "{{ webserver_conf_dir }}/sites-enabled"

- name: Configure main web server configuration
  template:
    src: nginx.conf.j2
    dest: "{{ webserver_conf_dir }}/nginx.conf"
    owner: root
    group: root
    mode: '0644'
    backup: yes
  notify: restart webserver

- name: Configure virtual hosts
  template:
    src: site.conf.j2
    dest: "{{ webserver_conf_dir }}/sites-available/{{ item.name }}"
    owner: root
    group: root
    mode: '0644'
  loop: "{{ virtual_hosts }}"
  notify: reload webserver

- name: Enable virtual hosts
  file:
    src: "{{ webserver_conf_dir }}/sites-available/{{ item.name }}"
    dest: "{{ webserver_conf_dir }}/sites-enabled/{{ item.name }}"
    state: link
  loop: "{{ virtual_hosts }}"
  when: item.enabled | default(true)
  notify: reload webserver
```

### Variables (defaults/main.yml)
```yaml
---
# Default variables for webserver role
# These can be overridden by higher precedence variables

# Web server configuration
webserver_type: nginx
webserver_version: latest
webserver_user: www-data
webserver_group: www-data
webserver_home: /var/www

# Service configuration
webserver_service_name: nginx
webserver_service_enabled: true
webserver_service_state: started

# Network configuration
webserver_port: 80
webserver_ssl_port: 443
webserver_bind_address: "0.0.0.0"

# Performance settings
webserver_worker_processes: auto
webserver_worker_connections: 1024
webserver_keepalive_timeout: 65
webserver_client_max_body_size: 64m

# Directory paths
webserver_conf_dir: /etc/nginx
webserver_log_dir: /var/log/nginx
webserver_pid_file: /var/run/nginx.pid

# SSL configuration
ssl_enabled: false
ssl_certificate_path: /etc/ssl/certs
ssl_private_key_path: /etc/ssl/private
ssl_protocols:
  - TLSv1.2
  - TLSv1.3

# Virtual hosts
virtual_hosts:
  - name: default
    server_name: "_"
    document_root: /var/www/html
    enabled: true

# Security settings
security_headers_enabled: true
security_server_tokens: false
security_hide_version: true

# Logging
access_log_enabled: true
error_log_enabled: true
log_level: warn
```

### OS-Specific Variables (vars/RedHat.yml)
```yaml
---
# RedHat family specific variables
webserver_packages_redhat:
  - nginx
  - nginx-mod-http-ssl

webserver_service_name: nginx
webserver_conf_dir: /etc/nginx
webserver_log_dir: /var/log/nginx
webserver_user: nginx
webserver_group: nginx

# Package manager specific
package_manager: yum
```

### Handlers (handlers/main.yml)
```yaml
---
# Event handlers for webserver role
- name: restart webserver
  service:
    name: "{{ webserver_service_name }}"
    state: restarted
  listen: "restart webserver"

- name: reload webserver
  service:
    name: "{{ webserver_service_name }}"
    state: reloaded
  listen: "reload webserver"

- name: start webserver
  service:
    name: "{{ webserver_service_name }}"
    state: started
  listen: "start webserver"

- name: stop webserver
  service:
    name: "{{ webserver_service_name }}"
    state: stopped
  listen: "stop webserver"

- name: restart firewall
  service:
    name: firewalld
    state: restarted
  when: ansible_os_family == "RedHat"
```

### Templates (templates/nginx.conf.j2)
```jinja2
# Nginx configuration template
user {{ webserver_user }};
worker_processes {{ webserver_worker_processes }};
error_log {{ webserver_log_dir }}/error.log {{ log_level }};
pid {{ webserver_pid_file }};

events {
    worker_connections {{ webserver_worker_connections }};
    use epoll;
    multi_accept on;
}

http {
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout {{ webserver_keepalive_timeout }};
    types_hash_max_size 2048;
    client_max_body_size {{ webserver_client_max_body_size }};

    {% if security_server_tokens %}
    server_tokens off;
    {% endif %}

    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    {% if access_log_enabled %}
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log {{ webserver_log_dir }}/access.log main;
    {% else %}
    access_log off;
    {% endif %}

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Security headers
    {% if security_headers_enabled %}
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    {% endif %}

    # Virtual host configurations
    include {{ webserver_conf_dir }}/sites-enabled/*;
}
```

### Virtual Host Template (templates/site.conf.j2)
```jinja2
# Virtual host configuration for {{ item.name }}
server {
    listen {{ webserver_port }}{% if item.default | default(false) %} default_server{% endif %};
    {% if ssl_enabled %}
    listen {{ webserver_ssl_port }} ssl{% if item.default | default(false) %} default_server{% endif %};
    {% endif %}
    
    server_name {{ item.server_name | default('_') }};
    root {{ item.document_root | default('/var/www/html') }};
    index {{ item.index_files | default(['index.html', 'index.htm']) | join(' ') }};

    {% if ssl_enabled %}
    # SSL configuration
    ssl_certificate {{ ssl_certificate_path }}/{{ item.ssl_cert | default('server.crt') }};
    ssl_certificate_key {{ ssl_private_key_path }}/{{ item.ssl_key | default('server.key') }};
    ssl_protocols {{ ssl_protocols | join(' ') }};
    ssl_ciphers ECDHE+AESGCM:ECDHE+AES256:ECDHE+AES128:!aNULL:!MD5:!DSS;
    ssl_prefer_server_ciphers on;
    {% endif %}

    # Document root
    location / {
        try_files $uri $uri/ =404;
        {% if item.auth_basic | default(false) %}
        auth_basic "{{ item.auth_basic_realm | default('Restricted Area') }}";
        auth_basic_user_file {{ item.auth_basic_file | default('/etc/nginx/.htpasswd') }};
        {% endif %}
    }

    {% if item.php_enabled | default(false) %}
    # PHP configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }
    {% endif %}

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security
    location ~ /\. {
        deny all;
    }

    {% if item.custom_locations is defined %}
    {% for location in item.custom_locations %}
    # Custom location: {{ location.path }}
    location {{ location.path }} {
        {{ location.config | indent(8) }}
    }
    {% endfor %}
    {% endif %}
}

{% if ssl_enabled and item.redirect_http | default(true) %}
# HTTP to HTTPS redirect
server {
    listen {{ webserver_port }};
    server_name {{ item.server_name | default('_') }};
    return 301 https://$server_name$request_uri;
}
{% endif %}
```

### Role Metadata (meta/main.yml)
```yaml
---
galaxy_info:
  author: DevOps Team
  description: Production-ready web server configuration role
  company: Example Corp
  license: MIT
  min_ansible_version: 2.9
  
  platforms:
    - name: EL
      versions:
        - 7
        - 8
        - 9
    - name: Ubuntu
      versions:
        - 18.04
        - 20.04
        - 22.04
    - name: Debian
      versions:
        - 10
        - 11
  
  galaxy_tags:
    - webserver
    - nginx
    - apache
    - web
    - http
    - ssl

# Role dependencies
dependencies:
  - role: common
    vars:
      common_packages:
        - curl
        - wget
  
  - role: firewall
    when: firewall_enabled | default(true)
    vars:
      firewall_rules:
        - port: "{{ webserver_port }}"
          protocol: tcp
        - port: "{{ webserver_ssl_port }}"
          protocol: tcp
          when: "{{ ssl_enabled }}"

# Collections required by this role
collections:
  - community.general
  - ansible.posix
```

## Using Roles

### In Playbooks
```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  roles:
    # Simple role inclusion
    - common
    - webserver
    
    # Role with variables
    - role: webserver
      vars:
        webserver_type: nginx
        ssl_enabled: true
        virtual_hosts:
          - name: example.com
            server_name: example.com
            document_root: /var/www/example.com
    
    # Conditional role
    - role: monitoring
      when: monitoring_enabled | default(true)
    
    # Role with tags
    - role: security
      tags: [security, hardening]

# Alternative syntax
- name: Configure web servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Apply common configuration
      include_role:
        name: common
    
    - name: Configure web server
      include_role:
        name: webserver
      vars:
        ssl_enabled: true
    
    - name: Apply security hardening
      import_role:
        name: security
      when: security_hardening | default(true)
```

### Role Variables Override
```yaml
# Playbook level
- hosts: webservers
  vars:
    webserver_port: 8080
    ssl_enabled: true
  roles:
    - webserver

# Group variables (group_vars/webservers.yml)
---
webserver_type: nginx
webserver_worker_processes: 4
virtual_hosts:
  - name: api
    server_name: api.example.com
    document_root: /var/www/api

# Host variables (host_vars/web1.example.com.yml)
---
webserver_worker_processes: 8
webserver_worker_connections: 2048
```

## Advanced Role Features

### Role Dependencies
```yaml
# meta/main.yml
dependencies:
  # Simple dependency
  - common
  
  # Dependency with variables
  - role: database
    vars:
      db_name: myapp
      db_user: myapp_user
  
  # Conditional dependency
  - role: ssl_certificates
    when: ssl_enabled | default(false)
  
  # Dependency with tags
  - role: monitoring
    tags: [monitoring]
```

### Dynamic Role Inclusion
```yaml
# Include roles based on variables
- name: Configure web server
  include_role:
    name: "{{ webserver_type }}"
  vars:
    webserver_config: "{{ webserver_configs[webserver_type] }}"

# Include roles from list
- name: Apply security roles
  include_role:
    name: "{{ item }}"
  loop: "{{ security_roles }}"
  when: security_enabled | default(true)
```

### Role Testing
```yaml
# tests/test.yml
---
- hosts: localhost
  remote_user: root
  roles:
    - webserver
  
  post_tasks:
    - name: Test web server is running
      uri:
        url: http://localhost
        method: GET
        status_code: 200
    
    - name: Test SSL configuration
      uri:
        url: https://localhost
        method: GET
        status_code: 200
        validate_certs: no
      when: ssl_enabled | default(false)
```

## Role Development Best Practices

### Variable Naming
```yaml
# Use role prefix for variables
webserver_port: 80
webserver_ssl_enabled: false
webserver_config_dir: /etc/nginx

# Use descriptive names
webserver_worker_processes: auto
webserver_client_max_body_size: 64m
webserver_keepalive_timeout: 65

# Group related variables
webserver_ssl:
  enabled: false
  certificate_path: /etc/ssl/certs
  private_key_path: /etc/ssl/private
  protocols:
    - TLSv1.2
    - TLSv1.3
```

### Task Organization
```yaml
# Use include_tasks for modularity
- name: Install packages
  include_tasks: install.yml
  tags: [install]

- name: Configure service
  include_tasks: configure.yml
  tags: [configure]

# Use blocks for error handling
- name: Configure SSL
  block:
    - name: Copy SSL certificate
      copy:
        src: "{{ ssl_certificate }}"
        dest: "{{ ssl_certificate_path }}"
    
    - name: Copy SSL private key
      copy:
        src: "{{ ssl_private_key }}"
        dest: "{{ ssl_private_key_path }}"
        mode: '0600'
  
  rescue:
    - name: Disable SSL on error
      set_fact:
        ssl_enabled: false
    
    - name: Log SSL configuration error
      debug:
        msg: "SSL configuration failed, disabling SSL"
  
  when: ssl_enabled | default(false)
```

### Documentation
```markdown
# Role: webserver

## Description
Configures and manages web server (Nginx/Apache) with SSL support.

## Requirements
- Ansible 2.9+
- Target OS: Ubuntu 18.04+, CentOS 7+

## Role Variables

### Required Variables
- `webserver_type`: Web server type (nginx/apache)

### Optional Variables
- `ssl_enabled`: Enable SSL/TLS (default: false)
- `webserver_port`: HTTP port (default: 80)

## Dependencies
- common
- firewall (optional)

## Example Playbook
```yaml
- hosts: webservers
  roles:
    - role: webserver
      vars:
        webserver_type: nginx
        ssl_enabled: true
```

## License
MIT
```

### Testing with Molecule
```yaml
# molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: ubuntu:20.04
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible

# molecule/default/converge.yml
---
- name: Converge
  hosts: all
  become: true
  roles:
    - role: webserver
      vars:
        webserver_type: nginx
        ssl_enabled: false

# molecule/default/verify.yml
---
- name: Verify
  hosts: all
  tasks:
    - name: Check nginx is running
      service:
        name: nginx
        state: started
      check_mode: yes
      register: nginx_status
    
    - name: Verify nginx status
      assert:
        that:
          - nginx_status.state == "started"
```

This comprehensive role guide covers all aspects of creating maintainable, reusable Ansible automation components.