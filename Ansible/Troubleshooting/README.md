# Ansible Troubleshooting

Comprehensive guide to diagnosing and resolving common Ansible issues, debugging techniques, and performance optimization.

## Common Connection Issues

### SSH Connection Problems

```bash
# Test SSH connectivity
ansible all -m ping -vvv

# Common SSH issues and solutions
# Issue: Host key verification failed
ansible all -m ping -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"

# Issue: Permission denied (publickey)
ansible all -m ping --private-key=/path/to/key.pem -u ec2-user

# Issue: Connection timeout
ansible all -m ping -e "ansible_ssh_timeout=60"

# Debug SSH connection
ssh -vvv -i ~/.ssh/key.pem user@host

# Test with different SSH options
ansible all -m ping -e "ansible_ssh_common_args='-o ConnectTimeout=30 -o ServerAliveInterval=60'"
```

### Authentication Issues

```bash
# Test with specific user
ansible all -m ping -u root
ansible all -m ping -u ec2-user
ansible all -m ping -u ubuntu

# Test sudo access
ansible all -m shell -a "whoami" --become
ansible all -m shell -a "whoami" --become --ask-become-pass

# Check SSH key permissions
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Verify SSH agent
ssh-add -l
ssh-add ~/.ssh/id_rsa
```

### Inventory Issues

```bash
# Validate inventory syntax
ansible-inventory -i inventory.ini --list
ansible-inventory -i inventory.yml --graph

# Check specific host
ansible-inventory -i inventory.ini --host web1

# Test inventory parsing
ansible all -i inventory.ini --list-hosts

# Debug inventory variables
ansible all -m debug -a "var=hostvars[inventory_hostname]"
```

## Playbook Debugging

### Syntax and Logic Issues

```bash
# Syntax validation
ansible-playbook playbook.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbook.yml --check

# Show differences
ansible-playbook playbook.yml --check --diff

# List tasks without execution
ansible-playbook playbook.yml --list-tasks

# List hosts that would be affected
ansible-playbook playbook.yml --list-hosts

# Step through playbook interactively
ansible-playbook playbook.yml --step
```

### Verbose Output Levels

```bash
# Basic verbose output
ansible-playbook playbook.yml -v

# More detailed output
ansible-playbook playbook.yml -vv

# Debug level output
ansible-playbook playbook.yml -vvv

# Connection debugging
ansible-playbook playbook.yml -vvvv
```

### Debug Module Usage

```yaml
# Debug techniques in playbooks
---
- name: Debugging examples
  hosts: all
  
  tasks:
    - name: Display variable value
      debug:
        var: ansible_hostname
    
    - name: Display custom message
      debug:
        msg: "Host {{ ansible_hostname }} is running {{ ansible_distribution }}"
    
    - name: Conditional debug
      debug:
        msg: "This is a production server"
      when: environment == "production"
    
    - name: Debug with verbosity control
      debug:
        msg: "This only shows with -v or higher"
        verbosity: 1
    
    - name: Debug command output
      shell: uptime
      register: uptime_result
    
    - name: Show command output
      debug:
        var: uptime_result.stdout
    
    - name: Debug all variables for host
      debug:
        var: hostvars[inventory_hostname]
      when: debug_all_vars | default(false)
```

## Module-Specific Issues

### Package Management Issues

```yaml
# Package installation troubleshooting
---
- name: Package management debugging
  hosts: all
  become: yes
  
  tasks:
    - name: Update package cache (Debian/Ubuntu)
      apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"
    
    - name: Clean package cache (RHEL/CentOS)
      command: yum clean all
      when: ansible_os_family == "RedHat"
    
    - name: Install package with error handling
      block:
        - name: Install nginx
          package:
            name: nginx
            state: present
      rescue:
        - name: Debug package installation failure
          debug:
            msg: "Package installation failed, checking repositories"
        
        - name: Check available repositories
          shell: yum repolist
          register: repo_list
          when: ansible_os_family == "RedHat"
        
        - name: Display repository information
          debug:
            var: repo_list.stdout
          when: ansible_os_family == "RedHat"
        
        - name: Try alternative package name
          package:
            name: nginx-core
            state: present
          when: ansible_os_family == "Debian"
```

### Service Management Issues

```yaml
# Service troubleshooting
---
- name: Service management debugging
  hosts: all
  become: yes
  
  tasks:
    - name: Check service status
      service:
        name: httpd
        state: started
      register: service_result
      failed_when: false
    
    - name: Debug service failure
      block:
        - name: Get service status details
          command: systemctl status httpd
          register: service_status
          when: service_result is failed
        
        - name: Display service status
          debug:
            var: service_status.stdout
          when: service_result is failed
        
        - name: Check service logs
          command: journalctl -u httpd --no-pager -n 20
          register: service_logs
          when: service_result is failed
        
        - name: Display service logs
          debug:
            var: service_logs.stdout
          when: service_result is failed
        
        - name: Check if service file exists
          stat:
            path: /etc/systemd/system/httpd.service
          register: service_file
        
        - name: Service file status
          debug:
            msg: "Service file exists: {{ service_file.stat.exists }}"
```

### File and Template Issues

```yaml
# File operation troubleshooting
---
- name: File operation debugging
  hosts: all
  become: yes
  
  tasks:
    - name: Check file permissions before copy
      stat:
        path: /etc/myapp/config.conf
      register: config_file
    
    - name: Display file information
      debug:
        msg: |
          File exists: {{ config_file.stat.exists }}
          Owner: {{ config_file.stat.pw_name | default('N/A') }}
          Group: {{ config_file.stat.gr_name | default('N/A') }}
          Mode: {{ config_file.stat.mode | default('N/A') }}
    
    - name: Template with validation
      template:
        src: config.conf.j2
        dest: /etc/myapp/config.conf
        owner: myapp
        group: myapp
        mode: '0644'
        backup: yes
        validate: '/usr/bin/myapp --config-test %s'
      register: template_result
    
    - name: Debug template result
      debug:
        var: template_result
      when: template_result is changed
```

## Performance Issues

### Slow Playbook Execution

```yaml
# Performance optimization techniques
---
- name: Optimized playbook execution
  hosts: all
  become: yes
  gather_facts: no  # Skip fact gathering if not needed
  
  tasks:
    - name: Gather minimal facts
      setup:
        filter: 
          - ansible_distribution*
          - ansible_default_ipv4
      when: facts_needed | default(true)
    
    - name: Use package module instead of yum/apt
      package:
        name: "{{ packages }}"
        state: present
      vars:
        packages:
          - git
          - curl
          - wget
    
    - name: Batch file operations
      copy:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        mode: "{{ item.mode }}"
      loop:
        - { src: "file1.txt", dest: "/tmp/file1.txt", mode: "0644" }
        - { src: "file2.txt", dest: "/tmp/file2.txt", mode: "0644" }
        - { src: "file3.txt", dest: "/tmp/file3.txt", mode: "0644" }
    
    - name: Use async for long-running tasks
      shell: |
        yum update -y
      async: 300
      poll: 0
      register: update_job
    
    - name: Continue with other tasks while update runs
      debug:
        msg: "Update running in background"
    
    - name: Wait for update to complete
      async_status:
        jid: "{{ update_job.ansible_job_id }}"
      register: update_result
      until: update_result.finished
      retries: 30
      delay: 10
```

### Memory and Resource Issues

```bash
# Monitor Ansible resource usage
# Enable profiling in ansible.cfg
[defaults]
callback_whitelist = profile_tasks, timer

# Run with profiling
ansible-playbook playbook.yml

# Monitor system resources during execution
top -p $(pgrep -f ansible-playbook)
htop -p $(pgrep -f ansible-playbook)

# Check memory usage
free -h
cat /proc/meminfo

# Monitor network usage
iftop
nethogs
```

## Error Analysis

### Common Error Messages and Solutions

#### "unreachable" Error
```bash
# Error: host unreachable
# Solutions:
1. Check network connectivity: ping target_host
2. Verify SSH service: ssh user@target_host
3. Check firewall rules: iptables -L
4. Verify DNS resolution: nslookup target_host
5. Check SSH key permissions: ls -la ~/.ssh/
```

#### "failed" Error
```bash
# Error: task failed
# Debug steps:
1. Run with verbose output: ansible-playbook playbook.yml -vvv
2. Check task syntax and logic
3. Verify required packages are installed
4. Check file permissions and ownership
5. Review system logs: journalctl -xe
```

#### "timeout" Error
```bash
# Error: connection timeout
# Solutions:
1. Increase timeout: ansible_ssh_timeout=60
2. Check network latency: ping -c 10 target_host
3. Verify SSH configuration: ssh -v user@target_host
4. Check system load: uptime, top
5. Review network configuration
```

### Advanced Debugging Techniques

```yaml
# Advanced debugging playbook
---
- name: Advanced debugging techniques
  hosts: all
  
  tasks:
    - name: Capture system information
      setup:
      register: system_facts
    
    - name: Save facts to file
      copy:
        content: "{{ system_facts | to_nice_json }}"
        dest: "/tmp/{{ inventory_hostname }}_facts.json"
      delegate_to: localhost
    
    - name: Test command execution
      shell: |
        set -x  # Enable command tracing
        whoami
        pwd
        env | grep -E '^(PATH|HOME|USER)'
      register: debug_output
    
    - name: Display debug output
      debug:
        var: debug_output
    
    - name: Check Python environment
      shell: |
        python3 --version
        python3 -c "import sys; print(sys.path)"
        which python3
      register: python_info
    
    - name: Display Python information
      debug:
        var: python_info.stdout_lines
```

## Log Analysis

### Ansible Logging Configuration

```ini
# ansible.cfg - Enable comprehensive logging
[defaults]
log_path = /var/log/ansible/ansible.log
display_skipped_hosts = True
display_ok_hosts = True
display_failed_stderr = True

# Custom callback for detailed logging
callback_whitelist = profile_tasks, timer, log_plays
```

### Log Analysis Scripts

```bash
#!/bin/bash
# analyze-ansible-logs.sh

LOG_FILE="/var/log/ansible/ansible.log"

echo "=== Ansible Log Analysis ==="
echo "Log file: $LOG_FILE"
echo "Analysis date: $(date)"
echo

# Count total runs
echo "Total playbook runs: $(grep -c "PLAY \[" $LOG_FILE)"

# Count failed tasks
echo "Failed tasks: $(grep -c "FAILED!" $LOG_FILE)"

# Count successful tasks
echo "Successful tasks: $(grep -c "ok:" $LOG_FILE)"

# Count changed tasks
echo "Changed tasks: $(grep -c "changed:" $LOG_FILE)"

# Show recent failures
echo
echo "=== Recent Failures ==="
grep -A 5 -B 5 "FAILED!" $LOG_FILE | tail -20

# Show performance statistics
echo
echo "=== Performance Analysis ==="
grep "Playbook run took" $LOG_FILE | tail -10

# Show most common errors
echo
echo "=== Common Error Patterns ==="
grep "FAILED!" $LOG_FILE | sed 's/.*TASK \[\(.*\)\].*/\1/' | sort | uniq -c | sort -nr | head -10
```

### Real-time Monitoring

```bash
# Monitor Ansible execution in real-time
tail -f /var/log/ansible/ansible.log

# Filter for specific patterns
tail -f /var/log/ansible/ansible.log | grep -E "(FAILED|ERROR|UNREACHABLE)"

# Monitor with timestamps
tail -f /var/log/ansible/ansible.log | while read line; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') $line"
done
```

## Network and Connectivity Issues

### Network Diagnostics

```yaml
# Network troubleshooting playbook
---
- name: Network connectivity diagnostics
  hosts: all
  gather_facts: yes
  
  tasks:
    - name: Test basic connectivity
      ping:
        data: "Ansible connectivity test"
      register: ping_result
    
    - name: Display connectivity result
      debug:
        msg: "Ping successful: {{ ping_result.ping }}"
    
    - name: Check network interfaces
      shell: ip addr show
      register: network_interfaces
    
    - name: Display network configuration
      debug:
        var: network_interfaces.stdout_lines
    
    - name: Test DNS resolution
      shell: nslookup google.com
      register: dns_test
      failed_when: false
    
    - name: Display DNS test results
      debug:
        var: dns_test.stdout
    
    - name: Check routing table
      shell: ip route show
      register: routing_table
    
    - name: Display routing information
      debug:
        var: routing_table.stdout_lines
    
    - name: Test internet connectivity
      uri:
        url: https://httpbin.org/ip
        method: GET
        timeout: 10
      register: internet_test
      failed_when: false
    
    - name: Display internet connectivity result
      debug:
        msg: "Internet access: {{ 'Available' if internet_test.status == 200 else 'Not available' }}"
```

### Port and Service Diagnostics

```yaml
# Port and service diagnostics
---
- name: Service and port diagnostics
  hosts: all
  become: yes
  
  tasks:
    - name: Check listening ports
      shell: netstat -tulpn
      register: listening_ports
    
    - name: Display listening ports
      debug:
        var: listening_ports.stdout_lines
    
    - name: Check specific service status
      service:
        name: "{{ item }}"
      register: service_status
      failed_when: false
      loop:
        - sshd
        - httpd
        - nginx
        - mysqld
    
    - name: Display service status
      debug:
        msg: "Service {{ item.item }} is {{ item.state | default('not found') }}"
      loop: "{{ service_status.results }}"
    
    - name: Test port connectivity
      wait_for:
        host: "{{ ansible_default_ipv4.address }}"
        port: "{{ item }}"
        timeout: 5
      register: port_test
      failed_when: false
      loop:
        - 22
        - 80
        - 443
        - 3306
    
    - name: Display port test results
      debug:
        msg: "Port {{ item.item }} is {{ 'open' if item.elapsed is defined else 'closed' }}"
      loop: "{{ port_test.results }}"
```

## Performance Troubleshooting

### Task Performance Analysis

```yaml
# Performance analysis playbook
---
- name: Performance analysis
  hosts: all
  
  tasks:
    - name: Measure task execution time
      shell: |
        start_time=$(date +%s.%N)
        sleep 2  # Simulate work
        end_time=$(date +%s.%N)
        echo "Execution time: $(echo "$end_time - $start_time" | bc) seconds"
      register: timing_result
    
    - name: Display timing information
      debug:
        var: timing_result.stdout
    
    - name: Profile system resources
      shell: |
        echo "CPU Usage:"
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
        echo "Memory Usage:"
        free -m | awk 'NR==2{printf "%.2f%%\n", $3*100/$2}'
        echo "Disk Usage:"
        df -h | awk '$NF=="/"{printf "%s\n", $5}'
      register: resource_usage
    
    - name: Display resource usage
      debug:
        var: resource_usage.stdout_lines
```

### Optimization Strategies

```yaml
# Performance optimization examples
---
- name: Optimized playbook execution
  hosts: all
  become: yes
  gather_facts: no  # Skip if facts not needed
  strategy: free    # Allow hosts to run independently
  
  tasks:
    - name: Gather only required facts
      setup:
        filter:
          - ansible_distribution*
          - ansible_default_ipv4
      when: facts_required | default(true)
    
    - name: Use package module for cross-platform compatibility
      package:
        name: "{{ common_packages }}"
        state: present
      vars:
        common_packages:
          - git
          - curl
          - wget
    
    - name: Batch file operations
      copy:
        src: "{{ item }}"
        dest: "/tmp/{{ item | basename }}"
      loop: "{{ config_files }}"
      vars:
        config_files:
          - config1.conf
          - config2.conf
          - config3.conf
    
    - name: Use async for independent tasks
      shell: |
        yum update -y
      async: 600
      poll: 0
      register: update_job
      when: ansible_os_family == "RedHat"
    
    - name: Continue with other tasks
      debug:
        msg: "System update running in background"
    
    - name: Check async task completion
      async_status:
        jid: "{{ update_job.ansible_job_id }}"
      register: update_result
      until: update_result.finished
      retries: 60
      delay: 10
      when: update_job is defined
```

## Variable and Template Issues

### Variable Debugging

```yaml
# Variable troubleshooting
---
- name: Variable debugging techniques
  hosts: all
  vars:
    test_var: "test_value"
    nested_var:
      key1: value1
      key2: value2
  
  tasks:
    - name: Display all variables
      debug:
        var: vars
    
    - name: Display specific variable
      debug:
        var: test_var
    
    - name: Check if variable is defined
      debug:
        msg: "Variable is defined"
      when: test_var is defined
    
    - name: Display variable type
      debug:
        msg: "Variable type: {{ test_var | type_debug }}"
    
    - name: Display nested variable
      debug:
        var: nested_var.key1
    
    - name: Display all host variables
      debug:
        var: hostvars[inventory_hostname]
    
    - name: Display group variables
      debug:
        var: group_names
    
    - name: Check variable precedence
      debug:
        msg: |
          Command line: {{ cli_var | default('not set') }}
          Play vars: {{ play_var | default('not set') }}
          Host vars: {{ host_var | default('not set') }}
          Group vars: {{ group_var | default('not set') }}
```

### Template Debugging

```yaml
# Template troubleshooting
---
- name: Template debugging
  hosts: all
  
  tasks:
    - name: Test template rendering locally
      template:
        src: test.conf.j2
        dest: /tmp/test.conf
      delegate_to: localhost
      run_once: true
    
    - name: Display rendered template
      slurp:
        src: /tmp/test.conf
      register: template_content
      delegate_to: localhost
      run_once: true
    
    - name: Show template content
      debug:
        msg: "{{ template_content.content | b64decode }}"
    
    - name: Validate template variables
      debug:
        msg: |
          Template variables:
          {% for var in template_vars %}
          {{ var }}: {{ vars[var] | default('UNDEFINED') }}
          {% endfor %}
      vars:
        template_vars:
          - server_name
          - listen_port
          - document_root
```

## Troubleshooting Tools and Scripts

### Health Check Script

```bash
#!/bin/bash
# ansible-health-check.sh

echo "=== Ansible Health Check ==="
echo "Date: $(date)"
echo

# Check Ansible installation
echo "1. Ansible Installation:"
if command -v ansible >/dev/null 2>&1; then
    echo "   ✓ Ansible installed: $(ansible --version | head -1)"
else
    echo "   ✗ Ansible not installed"
    exit 1
fi

# Check Python installation
echo "2. Python Installation:"
if command -v python3 >/dev/null 2>&1; then
    echo "   ✓ Python3 available: $(python3 --version)"
else
    echo "   ✗ Python3 not available"
fi

# Check SSH connectivity
echo "3. SSH Connectivity:"
if [ -f ~/.ssh/id_rsa ]; then
    echo "   ✓ SSH private key found"
else
    echo "   ⚠ SSH private key not found at ~/.ssh/id_rsa"
fi

# Check inventory
echo "4. Inventory Check:"
if [ -f "inventory.ini" ] || [ -f "inventory.yml" ]; then
    echo "   ✓ Inventory file found"
    ansible-inventory --list >/dev/null 2>&1 && echo "   ✓ Inventory syntax valid" || echo "   ✗ Inventory syntax invalid"
else
    echo "   ⚠ No inventory file found"
fi

# Test connectivity to all hosts
echo "5. Host Connectivity:"
ansible all -m ping -o 2>/dev/null | while read line; do
    if echo "$line" | grep -q "SUCCESS"; then
        host=$(echo "$line" | cut -d'|' -f1 | tr -d ' ')
        echo "   ✓ $host: Connected"
    elif echo "$line" | grep -q "UNREACHABLE"; then
        host=$(echo "$line" | cut -d'|' -f1 | tr -d ' ')
        echo "   ✗ $host: Unreachable"
    fi
done

# Check disk space
echo "6. Control Node Resources:"
df_output=$(df -h / | tail -1)
disk_usage=$(echo $df_output | awk '{print $5}' | sed 's/%//')
if [ $disk_usage -lt 90 ]; then
    echo "   ✓ Disk usage: ${disk_usage}%"
else
    echo "   ⚠ Disk usage high: ${disk_usage}%"
fi

# Check memory
mem_usage=$(free | awk 'FNR==2{printf "%.0f", $3/($3+$4)*100}')
if [ $mem_usage -lt 80 ]; then
    echo "   ✓ Memory usage: ${mem_usage}%"
else
    echo "   ⚠ Memory usage high: ${mem_usage}%"
fi

echo
echo "=== Health Check Complete ==="
```

### Diagnostic Playbook

```yaml
# diagnostic.yml - Comprehensive system diagnostics
---
- name: System diagnostics
  hosts: all
  gather_facts: yes
  
  tasks:
    - name: Collect system information
      setup:
      register: facts
    
    - name: Check system resources
      shell: |
        echo "=== System Resources ==="
        echo "CPU: $(nproc) cores"
        echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
        echo "Disk: $(df -h / | awk 'NR==2 {print $4}') available"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo
        echo "=== Network Configuration ==="
        ip addr show | grep -E '^[0-9]+:|inet '
        echo
        echo "=== Running Services ==="
        systemctl list-units --type=service --state=running | head -10
      register: system_info
    
    - name: Display system information
      debug:
        var: system_info.stdout_lines
    
    - name: Check Python modules
      shell: |
        python3 -c "
        import sys
        modules = ['json', 'yaml', 'jinja2', 'paramiko']
        for module in modules:
            try:
                __import__(module)
                print(f'{module}: Available')
            except ImportError:
                print(f'{module}: Not available')
        "
      register: python_modules
    
    - name: Display Python module status
      debug:
        var: python_modules.stdout_lines
    
    - name: Generate diagnostic report
      template:
        src: diagnostic_report.j2
        dest: "/tmp/{{ inventory_hostname }}_diagnostic.txt"
      delegate_to: localhost
```

This comprehensive troubleshooting guide provides systematic approaches to identifying and resolving Ansible issues in production environments.