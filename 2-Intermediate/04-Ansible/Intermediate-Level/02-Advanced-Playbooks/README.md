# Advanced Ansible Playbooks

Comprehensive guide to advanced playbook techniques, patterns, and strategies for complex automation scenarios.

## Advanced Playbook Structure

### Multi-Environment Playbooks
```yaml
# site.yml - Main orchestration playbook
---
- import_playbook: playbooks/common.yml
- import_playbook: playbooks/security.yml
- import_playbook: playbooks/webservers.yml
- import_playbook: playbooks/databases.yml
- import_playbook: playbooks/monitoring.yml
- import_playbook: playbooks/backup.yml

# Environment-specific execution
ansible-playbook -i inventories/production site.yml --tags production
ansible-playbook -i inventories/staging site.yml --tags staging
```

### Dynamic Playbook Inclusion
```yaml
# Dynamic playbook selection
---
- name: Dynamic environment setup
  hosts: localhost
  gather_facts: no
  vars:
    environment_playbooks:
      development: dev-setup.yml
      staging: staging-setup.yml
      production: prod-setup.yml
  
  tasks:
    - name: Include environment-specific playbook
      include: "{{ environment_playbooks[target_environment] }}"
      when: target_environment in environment_playbooks

# Conditional playbook imports
---
- import_playbook: database-setup.yml
  when: setup_database | default(true)

- import_playbook: cache-setup.yml
  when: setup_cache | default(false)

- import_playbook: monitoring-setup.yml
  when: setup_monitoring | default(true)
```

## Advanced Control Flow

### Complex Conditionals
```yaml
# Multi-condition logic
- name: Install web server based on OS and requirements
  package:
    name: "{{ item }}"
    state: present
  loop:
    - "{{ 'httpd' if ansible_os_family == 'RedHat' else 'apache2' }}"
    - "{{ 'mod_ssl' if ssl_required and ansible_os_family == 'RedHat' else 'apache2-ssl-dev' if ssl_required else omit }}"
  when: 
    - webserver_required | default(true)
    - item != omit

# Nested conditionals with complex logic
- name: Configure firewall rules
  firewalld:
    service: "{{ item.service }}"
    port: "{{ item.port }}"
    protocol: "{{ item.protocol | default('tcp') }}"
    state: enabled
    permanent: yes
    immediate: yes
  loop: "{{ firewall_rules }}"
  when:
    - firewall_enabled | default(true)
    - (item.environment is undefined) or (item.environment == current_environment)
    - (item.condition is undefined) or (item.condition | bool)
```

### Advanced Loops
```yaml
# Nested loops with subelements
- name: Create users with SSH keys
  authorized_key:
    user: "{{ item.0.name }}"
    key: "{{ item.1 }}"
    state: present
  loop: "{{ users | subelements('ssh_keys', skip_missing=True) }}"
  when: item.0.state | default('present') == 'present'

# Loop with complex data structures
- name: Configure virtual hosts
  template:
    src: "{{ item.template | default('vhost.conf.j2') }}"
    dest: "/etc/{{ webserver_type }}/sites-available/{{ item.name }}"
  loop: "{{ virtual_hosts }}"
  loop_control:
    loop_var: vhost
    index_var: vhost_index
    label: "{{ vhost.name }}"
  notify: reload webserver

# Conditional loops with until
- name: Wait for service to be ready
  uri:
    url: "http://{{ item }}:{{ app_port }}/health"
    method: GET
    status_code: 200
  register: health_check
  until: health_check.status == 200
  retries: 30
  delay: 10
  loop: "{{ groups['webservers'] }}"
  when: verify_deployment | default(true)
```

### Error Handling Strategies
```yaml
# Comprehensive error handling with recovery
- name: Application deployment with rollback
  block:
    - name: Stop application services
      service:
        name: "{{ item }}"
        state: stopped
      loop: "{{ app_services }}"
      register: stop_services
    
    - name: Create deployment backup
      archive:
        path: "{{ app_path }}"
        dest: "{{ backup_path }}/{{ app_name }}-{{ ansible_date_time.epoch }}.tar.gz"
        format: gz
      register: backup_result
    
    - name: Deploy new application version
      unarchive:
        src: "{{ deployment_package }}"
        dest: "{{ app_path }}"
        remote_src: "{{ deployment_remote | default(false) }}"
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        backup: yes
      register: deployment_result
    
    - name: Update configuration files
      template:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        backup: yes
      loop: "{{ config_templates }}"
      register: config_update
    
    - name: Start application services
      service:
        name: "{{ item }}"
        state: started
      loop: "{{ app_services }}"
    
    - name: Verify deployment
      uri:
        url: "{{ health_check_url }}"
        method: GET
        status_code: 200
        timeout: 30
      retries: 10
      delay: 15
      register: health_verification
  
  rescue:
    - name: Log deployment failure
      debug:
        msg: "Deployment failed: {{ ansible_failed_result.msg }}"
    
    - name: Stop failed services
      service:
        name: "{{ item }}"
        state: stopped
      loop: "{{ app_services }}"
      ignore_errors: yes
    
    - name: Restore from backup
      unarchive:
        src: "{{ backup_result.dest }}"
        dest: "{{ app_path | dirname }}"
        remote_src: yes
      when: backup_result is succeeded
    
    - name: Restore configuration files
      copy:
        src: "{{ item.backup_file }}"
        dest: "{{ item.dest }}"
        remote_src: yes
      loop: "{{ config_update.results }}"
      when: 
        - config_update is defined
        - item.backup_file is defined
    
    - name: Start restored services
      service:
        name: "{{ item }}"
        state: started
      loop: "{{ app_services }}"
    
    - name: Fail deployment
      fail:
        msg: "Deployment failed and rollback completed"
  
  always:
    - name: Clean up temporary files
      file:
        path: "{{ item }}"
        state: absent
      loop:
        - "{{ temp_deployment_dir | default('/tmp/deployment') }}"
        - "{{ temp_config_dir | default('/tmp/config') }}"
      ignore_errors: yes
    
    - name: Send deployment notification
      uri:
        url: "{{ notification_webhook }}"
        method: POST
        body_format: json
        body:
          status: "{{ 'success' if health_verification is succeeded else 'failed' }}"
          server: "{{ inventory_hostname }}"
          timestamp: "{{ ansible_date_time.iso8601 }}"
      delegate_to: localhost
      when: notification_webhook is defined
```

## Advanced Task Patterns

### Parallel Execution Strategies
```yaml
# Async task execution with coordination
- name: Long-running operations in parallel
  hosts: webservers
  serial: 0  # Run on all hosts simultaneously
  
  tasks:
    - name: Start package updates
      yum:
        name: "*"
        state: latest
      async: 1800  # 30 minutes timeout
      poll: 0      # Fire and forget
      register: update_job
    
    - name: Start log rotation
      command: logrotate -f /etc/logrotate.conf
      async: 300
      poll: 0
      register: logrotate_job
    
    - name: Wait for package updates
      async_status:
        jid: "{{ update_job.ansible_job_id }}"
      register: update_result
      until: update_result.finished
      retries: 60
      delay: 30
    
    - name: Wait for log rotation
      async_status:
        jid: "{{ logrotate_job.ansible_job_id }}"
      register: logrotate_result
      until: logrotate_result.finished
      retries: 10
      delay: 30
    
    - name: Verify all operations completed
      debug:
        msg: "All operations completed successfully"
      when: 
        - update_result.finished
        - logrotate_result.finished
```

### Rolling Updates with Health Checks
```yaml
# Rolling update with load balancer integration
- name: Rolling application update
  hosts: webservers
  serial: 1
  max_fail_percentage: 0
  
  pre_tasks:
    - name: Remove server from load balancer
      uri:
        url: "{{ load_balancer_api }}/remove"
        method: POST
        body_format: json
        body:
          server: "{{ inventory_hostname }}"
          pool: "{{ lb_pool_name }}"
      delegate_to: localhost
      register: lb_removal
    
    - name: Wait for connection draining
      pause:
        seconds: "{{ connection_drain_time | default(30) }}"
    
    - name: Verify server removed from load balancer
      uri:
        url: "{{ load_balancer_api }}/status/{{ inventory_hostname }}"
        method: GET
      delegate_to: localhost
      register: lb_status
      failed_when: lb_status.json.status != 'removed'
  
  tasks:
    - name: Stop application
      service:
        name: "{{ app_service_name }}"
        state: stopped
    
    - name: Deploy new version
      copy:
        src: "{{ new_app_version_path }}"
        dest: "{{ app_deployment_path }}"
        backup: yes
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
    
    - name: Update configuration
      template:
        src: app.conf.j2
        dest: "{{ app_config_path }}"
        backup: yes
      notify: restart application
    
    - name: Start application
      service:
        name: "{{ app_service_name }}"
        state: started
    
    - name: Wait for application startup
      wait_for:
        port: "{{ app_port }}"
        host: "{{ ansible_default_ipv4.address }}"
        timeout: 120
    
    - name: Health check
      uri:
        url: "http://{{ ansible_default_ipv4.address }}:{{ app_port }}/health"
        method: GET
        status_code: 200
      register: health_check
      retries: 10
      delay: 15
  
  post_tasks:
    - name: Add server back to load balancer
      uri:
        url: "{{ load_balancer_api }}/add"
        method: POST
        body_format: json
        body:
          server: "{{ inventory_hostname }}"
          pool: "{{ lb_pool_name }}"
      delegate_to: localhost
      when: health_check is succeeded
    
    - name: Verify server active in load balancer
      uri:
        url: "{{ load_balancer_api }}/status/{{ inventory_hostname }}"
        method: GET
      delegate_to: localhost
      register: lb_final_status
      retries: 5
      delay: 10
      until: lb_final_status.json.status == 'active'
```

### Dynamic Inventory Management
```yaml
# Dynamic host management during playbook execution
- name: Dynamic infrastructure scaling
  hosts: localhost
  gather_facts: no
  
  tasks:
    - name: Get current load metrics
      uri:
        url: "{{ monitoring_api }}/metrics/load"
        method: GET
      register: load_metrics
    
    - name: Calculate required instances
      set_fact:
        required_instances: "{{ (load_metrics.json.avg_load / target_load_per_instance) | round(0, 'ceil') | int }}"
        current_instances: "{{ groups['webservers'] | length }}"
    
    - name: Scale up instances if needed
      include_tasks: tasks/scale_up.yml
      when: required_instances > current_instances
      vars:
        instances_to_add: "{{ required_instances - current_instances }}"
    
    - name: Scale down instances if needed
      include_tasks: tasks/scale_down.yml
      when: required_instances < current_instances
      vars:
        instances_to_remove: "{{ current_instances - required_instances }}"
    
    - name: Refresh inventory
      meta: refresh_inventory
    
    - name: Update load balancer configuration
      template:
        src: lb_config.j2
        dest: /etc/loadbalancer/config.conf
      delegate_to: "{{ item }}"
      loop: "{{ groups['loadbalancers'] }}"
      notify: reload load balancer
```

## Advanced Variable Techniques

### Complex Variable Manipulation
```yaml
# Advanced variable processing
- name: Process complex configuration data
  hosts: all
  vars:
    raw_config:
      databases:
        - name: app_db
          host: db1.example.com
          port: 3306
          users:
            - name: app_user
              privileges: ["SELECT", "INSERT", "UPDATE"]
            - name: readonly_user
              privileges: ["SELECT"]
        - name: cache_db
          host: cache1.example.com
          port: 6379
  
  tasks:
    - name: Transform configuration data
      set_fact:
        processed_config: |
          {%- set result = {} -%}
          {%- for db in raw_config.databases -%}
            {%- set db_config = {} -%}
            {%- set _ = db_config.update({
              'connection_string': db.host + ':' + (db.port | string),
              'user_count': db.users | length,
              'privilege_matrix': {}
            }) -%}
            {%- for user in db.users -%}
              {%- set _ = db_config.privilege_matrix.update({
                user.name: user.privileges | join(',')
              }) -%}
            {%- endfor -%}
            {%- set _ = result.update({db.name: db_config}) -%}
          {%- endfor -%}
          {{ result }}
    
    - name: Use processed configuration
      debug:
        var: processed_config
```

### Conditional Variable Loading
```yaml
# Environment-specific variable loading
- name: Load environment variables
  hosts: all
  
  tasks:
    - name: Load base variables
      include_vars: "vars/base.yml"
    
    - name: Load OS-specific variables
      include_vars: "vars/{{ ansible_os_family | lower }}.yml"
    
    - name: Load environment-specific variables
      include_vars: "vars/{{ environment }}.yml"
      when: environment is defined
    
    - name: Load host-specific variables
      include_vars: "vars/hosts/{{ inventory_hostname }}.yml"
      ignore_errors: yes
    
    - name: Load role-specific variables
      include_vars: "vars/roles/{{ server_role }}.yml"
      when: server_role is defined
    
    - name: Merge configuration dictionaries
      set_fact:
        final_config: "{{ base_config | combine(os_config | default({})) | combine(env_config | default({})) | combine(host_config | default({})) | combine(role_config | default({})) }}"
```

## Advanced Delegation and Coordination

### Cross-Host Communication
```yaml
# Coordinate actions across multiple hosts
- name: Database cluster setup
  hosts: database_cluster
  serial: 1
  
  tasks:
    - name: Initialize first node as master
      block:
        - name: Configure as master
          template:
            src: mysql_master.cnf.j2
            dest: /etc/mysql/mysql.conf.d/replication.cnf
        
        - name: Start MySQL service
          service:
            name: mysql
            state: started
        
        - name: Create replication user
          mysql_user:
            name: replication_user
            password: "{{ replication_password }}"
            priv: "*.*:REPLICATION SLAVE"
            host: "%"
        
        - name: Get master status
          mysql_replication:
            mode: getmaster
          register: master_status
        
        - name: Store master information
          set_fact:
            master_host: "{{ inventory_hostname }}"
            master_log_file: "{{ master_status.File }}"
            master_log_pos: "{{ master_status.Position }}"
          delegate_to: "{{ item }}"
          delegate_facts: yes
          loop: "{{ groups['database_cluster'] }}"
      when: inventory_hostname == groups['database_cluster'][0]
    
    - name: Configure slave nodes
      block:
        - name: Configure as slave
          template:
            src: mysql_slave.cnf.j2
            dest: /etc/mysql/mysql.conf.d/replication.cnf
        
        - name: Start MySQL service
          service:
            name: mysql
            state: started
        
        - name: Configure replication
          mysql_replication:
            mode: changemaster
            master_host: "{{ hostvars[groups['database_cluster'][0]]['master_host'] }}"
            master_user: replication_user
            master_password: "{{ replication_password }}"
            master_log_file: "{{ hostvars[groups['database_cluster'][0]]['master_log_file'] }}"
            master_log_pos: "{{ hostvars[groups['database_cluster'][0]]['master_log_pos'] }}"
        
        - name: Start replication
          mysql_replication:
            mode: startslave
      when: inventory_hostname != groups['database_cluster'][0]
```

### Orchestrated Deployments
```yaml
# Multi-tier application deployment
- name: Orchestrated application deployment
  hosts: localhost
  gather_facts: no
  
  tasks:
    - name: Deploy database tier
      include: deploy_database.yml
      delegate_to: "{{ item }}"
      loop: "{{ groups['databases'] }}"
      run_once: true
    
    - name: Wait for database readiness
      wait_for:
        host: "{{ item }}"
        port: 3306
        timeout: 300
      loop: "{{ groups['databases'] }}"
    
    - name: Deploy application tier
      include: deploy_application.yml
      delegate_to: "{{ item }}"
      loop: "{{ groups['webservers'] }}"
    
    - name: Configure load balancers
      include: configure_loadbalancer.yml
      delegate_to: "{{ item }}"
      loop: "{{ groups['loadbalancers'] }}"
    
    - name: Run integration tests
      include: integration_tests.yml
      run_once: true
    
    - name: Enable traffic
      uri:
        url: "{{ load_balancer_api }}/enable"
        method: POST
      delegate_to: "{{ groups['loadbalancers'][0] }}"
```

## Performance Optimization

### Efficient Task Execution
```yaml
# Optimized playbook execution
- name: High-performance deployment
  hosts: webservers
  strategy: free  # Allow hosts to run independently
  gather_facts: no  # Skip fact gathering if not needed
  
  tasks:
    - name: Gather minimal facts
      setup:
        gather_subset:
          - "!all"
          - "network"
          - "hardware"
      when: facts_needed | default(false)
    
    - name: Batch package installation
      package:
        name: "{{ packages }}"
        state: present
      vars:
        packages:
          - nginx
          - python3
          - git
          - curl
    
    - name: Parallel file operations
      copy:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
      loop: "{{ file_operations }}"
      async: 300
      poll: 0
      register: file_jobs
    
    - name: Wait for file operations
      async_status:
        jid: "{{ item.ansible_job_id }}"
      register: file_results
      until: file_results.finished
      retries: 30
      delay: 10
      loop: "{{ file_jobs.results }}"
```

### Caching and Optimization
```yaml
# Implement caching for expensive operations
- name: Cached operations
  hosts: all
  
  tasks:
    - name: Check if expensive operation already done
      stat:
        path: /var/cache/ansible/expensive_operation.done
      register: operation_cache
    
    - name: Perform expensive operation
      block:
        - name: Download large file
          get_url:
            url: "{{ large_file_url }}"
            dest: /tmp/large_file.tar.gz
        
        - name: Process large file
          command: process_large_file.sh /tmp/large_file.tar.gz
        
        - name: Mark operation as complete
          file:
            path: /var/cache/ansible/expensive_operation.done
            state: touch
      when: not operation_cache.stat.exists
    
    - name: Use cached result
      debug:
        msg: "Using cached result of expensive operation"
      when: operation_cache.stat.exists
```

This comprehensive guide covers advanced Ansible playbook techniques for complex automation scenarios and enterprise-scale deployments.