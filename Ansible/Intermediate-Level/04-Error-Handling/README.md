# Ansible Error Handling

Comprehensive guide to error handling, debugging, and resilient automation in Ansible playbooks and roles.

## Error Handling Fundamentals

### Understanding Ansible Errors

#### Types of Errors
```yaml
# Syntax errors (caught before execution)
- name: Syntax error example
  debug:
    msg: "{{ undefined_variable }"  # Missing closing brace

# Runtime errors (caught during execution)
- name: Runtime error example
  command: /nonexistent/command
  # Will fail with "No such file or directory"

# Logic errors (unexpected behavior)
- name: Logic error example
  file:
    path: /tmp/test
    state: directory
  when: create_file  # Should be create_directory
```

#### Default Error Behavior
```yaml
# By default, Ansible stops execution on first error
- name: This will fail
  command: /bin/false
  # Playbook stops here

- name: This won't execute
  debug:
    msg: "This task is skipped due to previous failure"
```

## Basic Error Handling

### ignore_errors
```yaml
# Continue execution despite errors
- name: Optional task that might fail
  command: some_unreliable_command
  ignore_errors: yes

- name: This will still execute
  debug:
    msg: "Execution continues even if previous task failed"

# Conditional ignore_errors
- name: Ignore errors in development only
  command: risky_development_command
  ignore_errors: "{{ environment == 'development' }}"
```

### failed_when
```yaml
# Custom failure conditions
- name: Check service status
  command: systemctl is-active nginx
  register: nginx_status
  failed_when: 
    - nginx_status.rc != 0
    - "'inactive' not in nginx_status.stdout"

# Multiple failure conditions
- name: Validate configuration
  command: validate_config.sh
  register: validation
  failed_when:
    - validation.rc != 0
    - validation.rc != 2  # Warning code is acceptable
    - "'CRITICAL' in validation.stderr"

# Never fail
- name: Information gathering task
  command: ps aux
  register: process_list
  failed_when: false
```

### changed_when
```yaml
# Control change detection
- name: Check if reboot is required
  command: needs-restarting -r
  register: reboot_check
  changed_when: reboot_check.rc == 1
  failed_when: reboot_check.rc not in [0, 1]

# Complex change conditions
- name: Update configuration
  template:
    src: config.j2
    dest: /etc/app/config.conf
  register: config_update
  changed_when: 
    - config_update is changed
    - not (dry_run | default(false))
```

## Advanced Error Handling

### Block/Rescue/Always
```yaml
# Comprehensive error handling structure
- name: Application deployment with error handling
  block:
    - name: Stop application service
      service:
        name: myapp
        state: stopped
    
    - name: Backup current version
      archive:
        path: /opt/myapp
        dest: "/backup/myapp-{{ ansible_date_time.epoch }}.tar.gz"
      register: backup_result
    
    - name: Deploy new version
      unarchive:
        src: "{{ deployment_package }}"
        dest: /opt/myapp
        remote_src: yes
      register: deployment_result
    
    - name: Start application service
      service:
        name: myapp
        state: started
    
    - name: Verify deployment
      uri:
        url: http://localhost:8080/health
        status_code: 200
      retries: 5
      delay: 10
  
  rescue:
    - name: Log deployment failure
      debug:
        msg: "Deployment failed: {{ ansible_failed_result.msg }}"
    
    - name: Stop failed service
      service:
        name: myapp
        state: stopped
      ignore_errors: yes
    
    - name: Restore from backup
      unarchive:
        src: "{{ backup_result.dest }}"
        dest: /opt/
        remote_src: yes
      when: backup_result is succeeded
    
    - name: Start restored service
      service:
        name: myapp
        state: started
    
    - name: Send failure notification
      mail:
        to: admin@example.com
        subject: "Deployment Failed on {{ inventory_hostname }}"
        body: "Deployment failed and rollback completed"
      delegate_to: localhost
    
    - name: Fail the play
      fail:
        msg: "Deployment failed, rollback completed"
  
  always:
    - name: Clean up temporary files
      file:
        path: "{{ item }}"
        state: absent
      loop:
        - /tmp/deployment
        - /tmp/backup_temp
      ignore_errors: yes
    
    - name: Log deployment attempt
      lineinfile:
        path: /var/log/deployments.log
        line: "{{ ansible_date_time.iso8601 }} - Deployment attempt on {{ inventory_hostname }}"
        create: yes
```

### Nested Error Handling
```yaml
# Multiple levels of error handling
- name: Complex operation with nested error handling
  block:
    - name: Database operations
      block:
        - name: Create database backup
          mysql_db:
            name: myapp
            state: dump
            target: "/backup/db-{{ ansible_date_time.epoch }}.sql"
        
        - name: Apply database migrations
          command: python manage.py migrate
          args:
            chdir: /opt/myapp
      
      rescue:
        - name: Handle database errors
          debug:
            msg: "Database operation failed, attempting recovery"
        
        - name: Restore database from backup
          mysql_db:
            name: myapp
            state: import
            target: "{{ latest_backup }}"
          vars:
            latest_backup: "{{ ansible_env.HOME }}/backup/latest.sql"
    
    - name: Application operations
      block:
        - name: Update application code
          git:
            repo: https://github.com/company/myapp.git
            dest: /opt/myapp
            version: "{{ app_version }}"
        
        - name: Install dependencies
          pip:
            requirements: /opt/myapp/requirements.txt
            virtualenv: /opt/myapp/venv
      
      rescue:
        - name: Handle application errors
          debug:
            msg: "Application update failed"
        
        - name: Revert to previous version
          git:
            repo: https://github.com/company/myapp.git
            dest: /opt/myapp
            version: "{{ previous_version }}"
  
  rescue:
    - name: Handle overall failure
      fail:
        msg: "Complete operation failed, manual intervention required"
```

## Retry Mechanisms

### Task Retries
```yaml
# Basic retry mechanism
- name: Download file with retries
  get_url:
    url: "{{ download_url }}"
    dest: /tmp/download.tar.gz
  retries: 3
  delay: 5
  register: download_result
  until: download_result is succeeded

# Complex retry conditions
- name: Wait for service to be ready
  uri:
    url: "http://{{ inventory_hostname }}:8080/health"
    method: GET
  register: health_check
  retries: 30
  delay: 10
  until: 
    - health_check.status == 200
    - health_check.json.status == "healthy"
  failed_when: false

# Retry with exponential backoff
- name: API call with exponential backoff
  uri:
    url: "{{ api_endpoint }}"
    method: POST
    body_format: json
    body: "{{ api_payload }}"
  register: api_result
  retries: 5
  delay: "{{ 2 ** (ansible_loop.index0) }}"  # 1, 2, 4, 8, 16 seconds
  until: api_result.status in [200, 201]
  loop: "{{ range(5) }}"
  loop_control:
    loop_var: ansible_loop
```

### Custom Retry Logic
```yaml
# Implement custom retry with different strategies
- name: Custom retry implementation
  block:
    - name: Attempt operation
      uri:
        url: "{{ service_url }}"
        method: GET
      register: service_check
      failed_when: false
    
    - name: Check if retry needed
      set_fact:
        retry_needed: "{{ service_check.status != 200 }}"
        retry_count: "{{ retry_count | default(0) | int + 1 }}"
    
    - name: Wait before retry
      pause:
        seconds: "{{ retry_delay | default(5) }}"
      when: retry_needed and retry_count < max_retries
    
    - name: Retry operation
      include_tasks: retry_operation.yml
      when: retry_needed and retry_count < max_retries
    
    - name: Fail if max retries exceeded
      fail:
        msg: "Operation failed after {{ max_retries }} attempts"
      when: retry_needed and retry_count >= max_retries
```

## Debugging and Troubleshooting

### Debug Module Usage
```yaml
# Basic debugging
- name: Debug variable values
  debug:
    var: my_variable

- name: Debug with custom message
  debug:
    msg: "Current environment: {{ environment }}, Debug mode: {{ debug_mode }}"

# Conditional debugging
- name: Debug only in verbose mode
  debug:
    var: complex_data_structure
  when: ansible_verbosity >= 2

# Debug registered variables
- name: Execute command
  command: df -h
  register: disk_usage

- name: Debug command output
  debug:
    msg: |
      Command: {{ disk_usage.cmd }}
      Return code: {{ disk_usage.rc }}
      Stdout: {{ disk_usage.stdout }}
      Stderr: {{ disk_usage.stderr }}
```

### Verbose Output Control
```yaml
# Control verbosity levels
- name: Detailed operation
  command: complex_operation.sh
  register: operation_result

- name: Show basic info (verbosity 0)
  debug:
    msg: "Operation completed"

- name: Show detailed info (verbosity 1+)
  debug:
    msg: "Operation result: {{ operation_result.stdout }}"
  when: ansible_verbosity >= 1

- name: Show debug info (verbosity 2+)
  debug:
    var: operation_result
  when: ansible_verbosity >= 2
```

### Error Information Gathering
```yaml
# Comprehensive error information
- name: Gather system information on failure
  block:
    - name: Risky operation
      command: risky_command
  
  rescue:
    - name: Gather error context
      set_fact:
        error_context:
          failed_task: "{{ ansible_failed_task.name }}"
          error_message: "{{ ansible_failed_result.msg }}"
          timestamp: "{{ ansible_date_time.iso8601 }}"
          host: "{{ inventory_hostname }}"
          user: "{{ ansible_user_id }}"
    
    - name: Collect system state
      setup:
        gather_subset:
          - hardware
          - network
          - virtual
    
    - name: Get process information
      command: ps aux
      register: process_info
    
    - name: Get disk usage
      command: df -h
      register: disk_info
    
    - name: Get memory usage
      command: free -h
      register: memory_info
    
    - name: Create error report
      template:
        src: error_report.j2
        dest: "/tmp/error_report_{{ ansible_date_time.epoch }}.txt"
      delegate_to: localhost
    
    - name: Send error report
      mail:
        to: "{{ admin_email }}"
        subject: "Ansible Error on {{ inventory_hostname }}"
        attach: "/tmp/error_report_{{ ansible_date_time.epoch }}.txt"
      delegate_to: localhost
```

## Validation and Testing

### Pre-task Validation
```yaml
# Validate environment before execution
- name: Pre-execution validation
  block:
    - name: Check required variables
      assert:
        that:
          - app_name is defined
          - app_version is defined
          - deployment_path is defined
        fail_msg: "Required variables not defined"
    
    - name: Validate disk space
      shell: df {{ deployment_path }} | awk 'NR==2 {print $4}'
      register: available_space
      failed_when: available_space.stdout | int < required_space_mb
    
    - name: Check service dependencies
      service:
        name: "{{ item }}"
      register: service_check
      failed_when: service_check.status.ActiveState != "active"
      loop: "{{ required_services }}"
    
    - name: Validate network connectivity
      uri:
        url: "{{ item }}"
        method: HEAD
        timeout: 10
      loop: "{{ required_endpoints }}"
    
    - name: Check file permissions
      file:
        path: "{{ deployment_path }}"
        state: directory
        mode: '0755'
        owner: "{{ app_user }}"
      check_mode: yes
      register: permission_check
      failed_when: permission_check is changed
```

### Post-task Verification
```yaml
# Verify operations completed successfully
- name: Post-execution verification
  block:
    - name: Verify service is running
      service:
        name: "{{ app_service }}"
        state: started
      check_mode: yes
      register: service_status
    
    - name: Verify application responds
      uri:
        url: "http://localhost:{{ app_port }}/health"
        method: GET
        status_code: 200
        timeout: 30
      retries: 10
      delay: 5
    
    - name: Verify configuration files
      stat:
        path: "{{ item }}"
      register: config_files
      failed_when: not config_files.stat.exists
      loop: "{{ required_config_files }}"
    
    - name: Verify log files are being written
      wait_for:
        path: "{{ app_log_file }}"
        search_regex: "Application started successfully"
        timeout: 60
    
    - name: Performance verification
      uri:
        url: "http://localhost:{{ app_port }}/api/test"
        method: GET
      register: performance_test
      failed_when: performance_test.elapsed > max_response_time
```

## Error Recovery Strategies

### Automatic Recovery
```yaml
# Implement automatic recovery mechanisms
- name: Service with automatic recovery
  block:
    - name: Check service health
      uri:
        url: "http://localhost:{{ app_port }}/health"
        method: GET
        status_code: 200
      register: health_check
      failed_when: false
    
    - name: Attempt service restart if unhealthy
      block:
        - name: Stop service gracefully
          service:
            name: "{{ app_service }}"
            state: stopped
        
        - name: Wait for graceful shutdown
          pause:
            seconds: 10
        
        - name: Start service
          service:
            name: "{{ app_service }}"
            state: started
        
        - name: Verify recovery
          uri:
            url: "http://localhost:{{ app_port }}/health"
            method: GET
            status_code: 200
          retries: 5
          delay: 10
      when: health_check.status != 200
    
    - name: Escalate to manual intervention
      fail:
        msg: "Automatic recovery failed, manual intervention required"
      when: 
        - health_check.status != 200
        - recovery_attempt is failed
```

### Rollback Mechanisms
```yaml
# Implement comprehensive rollback
- name: Deployment with rollback capability
  vars:
    rollback_info: {}
  
  block:
    - name: Capture current state
      set_fact:
        rollback_info:
          previous_version: "{{ current_app_version }}"
          backup_path: "/backup/{{ app_name }}-{{ ansible_date_time.epoch }}"
          config_backup: "/backup/config-{{ ansible_date_time.epoch }}"
    
    - name: Create application backup
      archive:
        path: "{{ app_path }}"
        dest: "{{ rollback_info.backup_path }}.tar.gz"
    
    - name: Backup configuration
      copy:
        src: "{{ app_config_path }}"
        dest: "{{ rollback_info.config_backup }}"
        remote_src: yes
    
    - name: Deploy new version
      unarchive:
        src: "{{ new_version_package }}"
        dest: "{{ app_path }}"
        remote_src: yes
    
    - name: Update configuration
      template:
        src: app.conf.j2
        dest: "{{ app_config_path }}"
    
    - name: Restart service
      service:
        name: "{{ app_service }}"
        state: restarted
    
    - name: Verify deployment
      uri:
        url: "http://localhost:{{ app_port }}/health"
        method: GET
        status_code: 200
      retries: 10
      delay: 15
  
  rescue:
    - name: Execute rollback
      block:
        - name: Stop current service
          service:
            name: "{{ app_service }}"
            state: stopped
        
        - name: Restore application
          unarchive:
            src: "{{ rollback_info.backup_path }}.tar.gz"
            dest: "{{ app_path | dirname }}"
            remote_src: yes
        
        - name: Restore configuration
          copy:
            src: "{{ rollback_info.config_backup }}"
            dest: "{{ app_config_path }}"
            remote_src: yes
        
        - name: Start restored service
          service:
            name: "{{ app_service }}"
            state: started
        
        - name: Verify rollback
          uri:
            url: "http://localhost:{{ app_port }}/health"
            method: GET
            status_code: 200
          retries: 5
          delay: 10
      
      always:
        - name: Clean up rollback files
          file:
            path: "{{ item }}"
            state: absent
          loop:
            - "{{ rollback_info.backup_path }}.tar.gz"
            - "{{ rollback_info.config_backup }}"
          ignore_errors: yes
```

## Best Practices

### Error Handling Guidelines
```yaml
# Follow consistent error handling patterns
- name: Consistent error handling example
  block:
    # Main operation
    - name: Primary task
      command: main_operation
      register: main_result
  
  rescue:
    # Log the error
    - name: Log error
      debug:
        msg: "Operation failed: {{ ansible_failed_result.msg }}"
    
    # Attempt recovery
    - name: Recovery action
      command: recovery_operation
      ignore_errors: yes
    
    # Notify stakeholders
    - name: Send notification
      uri:
        url: "{{ notification_webhook }}"
        method: POST
        body_format: json
        body:
          status: "error"
          message: "{{ ansible_failed_result.msg }}"
      delegate_to: localhost
    
    # Fail with meaningful message
    - name: Fail with context
      fail:
        msg: "Operation failed: {{ ansible_failed_result.msg }}"
  
  always:
    # Cleanup actions
    - name: Cleanup
      file:
        path: /tmp/operation_temp
        state: absent
```

### Monitoring and Alerting
```yaml
# Integrate error handling with monitoring
- name: Operation with monitoring integration
  block:
    - name: Send start metric
      uri:
        url: "{{ metrics_endpoint }}"
        method: POST
        body_format: json
        body:
          metric: "operation.start"
          host: "{{ inventory_hostname }}"
          timestamp: "{{ ansible_date_time.epoch }}"
    
    - name: Execute operation
      command: important_operation
      register: operation_result
    
    - name: Send success metric
      uri:
        url: "{{ metrics_endpoint }}"
        method: POST
        body_format: json
        body:
          metric: "operation.success"
          host: "{{ inventory_hostname }}"
          duration: "{{ operation_result.delta }}"
  
  rescue:
    - name: Send failure metric
      uri:
        url: "{{ metrics_endpoint }}"
        method: POST
        body_format: json
        body:
          metric: "operation.failure"
          host: "{{ inventory_hostname }}"
          error: "{{ ansible_failed_result.msg }}"
```

This comprehensive guide covers all aspects of error handling in Ansible for building resilient and maintainable automation.