# Ansible Performance Optimization

Comprehensive guide to optimizing Ansible performance for large-scale deployments, complex automation, and enterprise environments.

## Performance Fundamentals

### Understanding Ansible Performance Bottlenecks

#### Common Performance Issues
- **SSH Connection Overhead**: Multiple connections to same host
- **Fact Gathering**: Collecting unnecessary system information
- **Task Serialization**: Sequential execution when parallel is possible
- **Large Inventories**: Inefficient inventory processing
- **Module Inefficiency**: Using inappropriate modules for tasks
- **Network Latency**: Slow connections to managed nodes

#### Performance Metrics to Monitor
```yaml
# Enable performance monitoring
- name: Performance monitoring setup
  hosts: localhost
  vars:
    ansible_callback_whitelist: profile_tasks,timer
  tasks:
    - name: Monitor task execution time
      debug:
        msg: "This task will be timed"
```

## Configuration Optimization

### Ansible Configuration Tuning
```ini
# ansible.cfg - Performance optimized configuration
[defaults]
# Connection optimization
host_key_checking = False
retry_files_enabled = False
timeout = 30
remote_user = ansible

# Fact caching for performance
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400

# Parallel execution
forks = 50
poll_interval = 5

# Output optimization
stdout_callback = yaml
callback_whitelist = profile_tasks,timer,skippy
display_skipped_hosts = False
display_ok_hosts = False

# Logging
log_path = /var/log/ansible.log

[ssh_connection]
# SSH optimization
ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o PreferredAuthentications=publickey -o UserKnownHostsFile=/dev/null
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
retries = 3

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[inventory]
# Inventory optimization
enable_plugins = host_list,script,auto,yaml,ini,toml
cache = True
cache_plugin = jsonfile
cache_timeout = 3600
cache_connection = /tmp/ansible_inventory_cache
```

### SSH Connection Optimization
```yaml
# SSH connection pooling and optimization
- name: Optimized SSH configuration
  hosts: all
  vars:
    ansible_ssh_common_args: >
      -o ControlMaster=auto
      -o ControlPersist=300s
      -o PreferredAuthentications=publickey
      -o UserKnownHostsFile=/dev/null
      -o StrictHostKeyChecking=no
      -o ServerAliveInterval=60
      -o ServerAliveCountMax=3
  
  tasks:
    - name: Test optimized connection
      ping:
```

## Execution Strategy Optimization

### Parallel Execution Strategies
```yaml
# Free strategy for maximum parallelism
- name: High-performance deployment
  hosts: webservers
  strategy: free  # Hosts run independently
  gather_facts: no
  
  tasks:
    - name: Install packages in parallel
      package:
        name: "{{ packages }}"
        state: present
      vars:
        packages:
          - nginx
          - python3
          - git

# Linear strategy with batching
- name: Controlled parallel execution
  hosts: databases
  strategy: linear
  serial: "25%"  # Process 25% of hosts at a time
  max_fail_percentage: 10
  
  tasks:
    - name: Database maintenance
      command: maintenance_script.sh

# Custom batch sizes
- name: Dynamic batching
  hosts: all
  serial:
    - 1      # First host alone
    - "25%"  # Then 25% of remaining
    - "50%"  # Then 50% of remaining
    - "100%" # Finally all remaining
```

### Asynchronous Task Execution
```yaml
# Async tasks for long-running operations
- name: Asynchronous operations
  hosts: webservers
  
  tasks:
    - name: Start long-running update
      yum:
        name: "*"
        state: latest
      async: 3600  # 1 hour timeout
      poll: 0      # Fire and forget
      register: update_job
    
    - name: Start service configuration
      template:
        src: service.conf.j2
        dest: /etc/service/config.conf
      async: 300
      poll: 0
      register: config_job
    
    - name: Perform other tasks while updates run
      debug:
        msg: "Doing other work while updates run in background"
    
    - name: Wait for updates to complete
      async_status:
        jid: "{{ update_job.ansible_job_id }}"
      register: update_result
      until: update_result.finished
      retries: 120
      delay: 30
    
    - name: Wait for configuration to complete
      async_status:
        jid: "{{ config_job.ansible_job_id }}"
      register: config_result
      until: config_result.finished
      retries: 10
      delay: 30
```

## Fact Gathering Optimization

### Selective Fact Gathering
```yaml
# Disable fact gathering when not needed
- name: Quick operations without facts
  hosts: all
  gather_facts: no
  
  tasks:
    - name: Simple command
      command: echo "No facts needed"

# Gather only required facts
- name: Selective fact gathering
  hosts: all
  gather_facts: yes
  
  tasks:
    - name: Gather minimal facts
      setup:
        gather_subset:
          - "!all"
          - "network"
          - "hardware"
    
    - name: Use specific facts
      debug:
        msg: "IP: {{ ansible_default_ipv4.address }}, Memory: {{ ansible_memtotal_mb }}MB"

# Custom fact gathering
- name: Custom fact collection
  hosts: all
  gather_facts: no
  
  tasks:
    - name: Gather only network facts
      setup:
        filter: "ansible_default_ipv4"
    
    - name: Gather custom facts
      setup:
        gather_subset:
          - "!all"
          - "!min"
        filter:
          - "ansible_hostname"
          - "ansible_distribution*"
```

### Fact Caching Implementation
```yaml
# Implement fact caching strategy
- name: Fact caching optimization
  hosts: all
  
  pre_tasks:
    - name: Check if facts are cached
      stat:
        path: "/tmp/ansible_facts/{{ inventory_hostname }}"
      register: fact_cache
      delegate_to: localhost
    
    - name: Gather facts only if cache is stale
      setup:
      when: 
        - not fact_cache.stat.exists or
          (ansible_date_time.epoch | int - fact_cache.stat.mtime) > 3600
  
  tasks:
    - name: Use cached facts
      debug:
        msg: "Using facts for {{ ansible_hostname }}"
```

## Inventory Optimization

### Dynamic Inventory Performance
```python
#!/usr/bin/env python3
# Optimized dynamic inventory script
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
import requests

class OptimizedInventory:
    def __init__(self):
        self.inventory = {
            '_meta': {
                'hostvars': {}
            }
        }
        self.cache_timeout = 300  # 5 minutes
        self.cache_file = '/tmp/inventory_cache.json'
    
    def load_cache(self):
        """Load inventory from cache if valid"""
        try:
            with open(self.cache_file, 'r') as f:
                cache_data = json.load(f)
                if time.time() - cache_data['timestamp'] < self.cache_timeout:
                    return cache_data['inventory']
        except (FileNotFoundError, KeyError, json.JSONDecodeError):
            pass
        return None
    
    def save_cache(self, inventory):
        """Save inventory to cache"""
        cache_data = {
            'timestamp': time.time(),
            'inventory': inventory
        }
        with open(self.cache_file, 'w') as f:
            json.dump(cache_data, f)
    
    def fetch_host_data(self, host_id):
        """Fetch data for a single host"""
        try:
            response = requests.get(f"https://api.example.com/hosts/{host_id}", timeout=5)
            return response.json()
        except requests.RequestException:
            return None
    
    def build_inventory(self):
        """Build inventory with parallel API calls"""
        cached = self.load_cache()
        if cached:
            return cached
        
        # Get list of hosts
        hosts_response = requests.get("https://api.example.com/hosts")
        host_ids = [host['id'] for host in hosts_response.json()]
        
        # Fetch host data in parallel
        with ThreadPoolExecutor(max_workers=10) as executor:
            future_to_host = {
                executor.submit(self.fetch_host_data, host_id): host_id 
                for host_id in host_ids
            }
            
            for future in as_completed(future_to_host):
                host_id = future_to_host[future]
                try:
                    host_data = future.result()
                    if host_data:
                        self.process_host(host_data)
                except Exception as e:
                    print(f"Error processing host {host_id}: {e}", file=sys.stderr)
        
        self.save_cache(self.inventory)
        return self.inventory
    
    def process_host(self, host_data):
        """Process individual host data"""
        hostname = host_data['hostname']
        
        # Add to groups
        for group in host_data.get('groups', []):
            if group not in self.inventory:
                self.inventory[group] = {'hosts': []}
            self.inventory[group]['hosts'].append(hostname)
        
        # Add host variables
        self.inventory['_meta']['hostvars'][hostname] = {
            'ansible_host': host_data['ip_address'],
            'environment': host_data.get('environment', 'unknown'),
            'role': host_data.get('role', 'generic')
        }

if __name__ == '__main__':
    inventory = OptimizedInventory()
    print(json.dumps(inventory.build_inventory(), indent=2))
```

### Static Inventory Optimization
```yaml
# Optimized static inventory structure
# inventory/production/hosts.yml
all:
  children:
    # Group by function for efficient targeting
    webservers:
      children:
        frontend_servers:
          hosts:
            web[01:10].prod.example.com:
        backend_servers:
          hosts:
            api[01:05].prod.example.com:
      vars:
        http_port: 80
        https_port: 443
    
    databases:
      children:
        mysql_cluster:
          hosts:
            db[01:03].prod.example.com:
        redis_cluster:
          hosts:
            cache[01:02].prod.example.com:
      vars:
        backup_enabled: true
    
    # Group by location for network optimization
    us_east:
      children:
        webservers:
        databases:
      vars:
        region: us-east-1
        ntp_server: time.nist.gov
    
    # Group by environment
    production:
      children:
        webservers:
        databases:
      vars:
        environment: production
        log_level: warn
  
  vars:
    ansible_user: ansible
    ansible_ssh_private_key_file: ~/.ssh/production_key
```

## Task and Module Optimization

### Efficient Module Usage
```yaml
# Batch operations instead of loops
- name: Install multiple packages efficiently
  package:
    name:
      - nginx
      - python3
      - git
      - curl
      - wget
    state: present
  # Better than looping over individual packages

# Use appropriate modules
- name: Efficient file operations
  copy:
    src: /local/directory/
    dest: /remote/directory/
  # Better than looping over individual files

# Optimize template operations
- name: Generate multiple configs efficiently
  template:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
  loop:
    - { src: nginx.conf.j2, dest: /etc/nginx/nginx.conf }
    - { src: ssl.conf.j2, dest: /etc/nginx/ssl.conf }
  loop_control:
    label: "{{ item.dest }}"  # Cleaner output
```

### Task Optimization Patterns
```yaml
# Conditional task execution optimization
- name: Set optimization facts
  set_fact:
    needs_update: "{{ current_version != target_version }}"
    needs_restart: "{{ config_changed | default(false) }}"
    needs_backup: "{{ backup_enabled | default(true) }}"

- name: Conditional operations block
  block:
    - name: Create backup
      archive:
        path: "{{ app_path }}"
        dest: "{{ backup_path }}/backup-{{ ansible_date_time.epoch }}.tar.gz"
      when: needs_backup
    
    - name: Update application
      unarchive:
        src: "{{ update_package }}"
        dest: "{{ app_path }}"
      when: needs_update
    
    - name: Restart service
      service:
        name: "{{ app_service }}"
        state: restarted
      when: needs_restart
  when: needs_update or needs_restart

# Optimize with changed_when and failed_when
- name: Optimized command execution
  command: /opt/app/status_check.sh
  register: status_check
  changed_when: false  # Don't report as changed
  failed_when: status_check.rc not in [0, 1]  # Accept warning codes
```

## Memory and Resource Optimization

### Memory Usage Optimization
```yaml
# Optimize variable usage
- name: Memory-efficient variable handling
  hosts: all
  vars:
    # Use references instead of copying large data structures
    large_config: "{{ hostvars['config_server']['master_config'] }}"
  
  tasks:
    - name: Process configuration efficiently
      template:
        src: config.j2
        dest: /etc/app/config.conf
      vars:
        # Use local variables to avoid memory overhead
        local_config: "{{ large_config[inventory_hostname] }}"

# Limit concurrent operations
- name: Resource-controlled operations
  hosts: all
  serial: "{{ ansible_processor_cores | default(2) }}"  # Limit by CPU cores
  
  tasks:
    - name: CPU-intensive operation
      command: cpu_intensive_task.sh
      throttle: 1  # Limit to 1 concurrent execution across all hosts
```

### Disk I/O Optimization
```yaml
# Optimize file operations
- name: Efficient file synchronization
  synchronize:
    src: /local/large_directory/
    dest: /remote/large_directory/
    delete: yes
    recursive: yes
    checksum: yes
  # More efficient than copy for large directories

# Batch file operations
- name: Efficient file creation
  file:
    path: "{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - /opt/app/logs
    - /opt/app/data
    - /opt/app/temp
  # Create multiple directories in one task
```

## Network Optimization

### Connection Pooling and Reuse
```yaml
# Optimize for high-latency networks
- name: High-latency network optimization
  hosts: remote_servers
  vars:
    ansible_ssh_common_args: >
      -o ControlMaster=auto
      -o ControlPersist=1800s
      -o TCPKeepAlive=yes
      -o ServerAliveInterval=60
      -o ServerAliveCountMax=10
      -o Compression=yes
  
  tasks:
    - name: Multiple operations using same connection
      package:
        name: "{{ item }}"
        state: present
      loop:
        - package1
        - package2
        - package3
```

### Bandwidth Optimization
```yaml
# Optimize for limited bandwidth
- name: Bandwidth-conscious operations
  hosts: all
  
  tasks:
    - name: Compress large file transfers
      copy:
        src: large_file.tar.gz
        dest: /tmp/large_file.tar.gz
      vars:
        ansible_ssh_common_args: "-o Compression=yes"
    
    - name: Use rsync for efficient transfers
      synchronize:
        src: /local/directory/
        dest: /remote/directory/
        compress: yes
        delete: yes
```

## Monitoring and Profiling

### Performance Monitoring Setup
```yaml
# Enable comprehensive performance monitoring
- name: Performance monitoring configuration
  hosts: localhost
  vars:
    ansible_callback_whitelist: profile_tasks,timer,cgroup_perf_recap
  
  tasks:
    - name: Configure performance callbacks
      lineinfile:
        path: ansible.cfg
        regexp: '^callback_whitelist'
        line: 'callback_whitelist = profile_tasks,timer,cgroup_perf_recap'
        create: yes

# Custom performance monitoring
- name: Custom performance tracking
  hosts: all
  
  tasks:
    - name: Record start time
      set_fact:
        operation_start: "{{ ansible_date_time.epoch }}"
    
    - name: Perform operation
      command: time_consuming_operation.sh
      register: operation_result
    
    - name: Calculate execution time
      set_fact:
        execution_time: "{{ ansible_date_time.epoch | int - operation_start | int }}"
    
    - name: Log performance metrics
      uri:
        url: "{{ metrics_endpoint }}"
        method: POST
        body_format: json
        body:
          host: "{{ inventory_hostname }}"
          operation: "time_consuming_operation"
          duration: "{{ execution_time }}"
          timestamp: "{{ ansible_date_time.iso8601 }}"
      delegate_to: localhost
```

### Profiling and Debugging
```yaml
# Profile playbook execution
- name: Profiled playbook execution
  hosts: all
  vars:
    ansible_verbosity: 2
  
  tasks:
    - name: Enable profiling
      debug:
        msg: "Starting profiled execution"
      tags: [profiling]
    
    - name: Timed operation
      command: sleep 5
      register: timed_op
      tags: [profiling]
    
    - name: Profile results
      debug:
        msg: |
          Operation completed in {{ timed_op.delta }}
          Start: {{ timed_op.start }}
          End: {{ timed_op.end }}
      tags: [profiling]
```

## Scaling Strategies

### Large-Scale Deployment Patterns
```yaml
# Hierarchical deployment for large environments
- name: Hierarchical deployment strategy
  hosts: deployment_controllers
  serial: 1
  
  tasks:
    - name: Deploy to regional controllers
      command: >
        ansible-playbook
        -i {{ region }}_inventory.yml
        --limit {{ region }}_servers
        deploy_application.yml
      loop: "{{ regions }}"
      loop_control:
        loop_var: region
      async: 3600
      poll: 0
      register: regional_deployments
    
    - name: Monitor regional deployments
      async_status:
        jid: "{{ item.ansible_job_id }}"
      register: deployment_status
      until: deployment_status.finished
      retries: 120
      delay: 30
      loop: "{{ regional_deployments.results }}"

# Canary deployment pattern
- name: Canary deployment
  hosts: webservers
  serial:
    - 1        # Deploy to 1 server first
    - "10%"    # Then 10% of remaining
    - "25%"    # Then 25% of remaining
    - "100%"   # Finally all remaining
  max_fail_percentage: 5
  
  tasks:
    - name: Deploy new version
      include_tasks: deploy_tasks.yml
    
    - name: Health check
      uri:
        url: "http://{{ inventory_hostname }}/health"
        status_code: 200
      retries: 5
      delay: 10
    
    - name: Pause between batches
      pause:
        seconds: 30
      when: ansible_play_batch != groups['webservers']
```

## Best Practices Summary

### Performance Checklist
```yaml
# Performance optimization checklist
performance_checklist:
  configuration:
    - "✓ SSH connection pooling enabled"
    - "✓ Fact caching configured"
    - "✓ Appropriate fork count set"
    - "✓ Pipelining enabled"
  
  execution:
    - "✓ Selective fact gathering"
    - "✓ Async tasks for long operations"
    - "✓ Appropriate execution strategy"
    - "✓ Batch operations where possible"
  
  inventory:
    - "✓ Efficient inventory structure"
    - "✓ Dynamic inventory caching"
    - "✓ Appropriate grouping strategy"
  
  tasks:
    - "✓ Efficient module selection"
    - "✓ Conditional optimization"
    - "✓ Resource usage monitoring"
  
  monitoring:
    - "✓ Performance callbacks enabled"
    - "✓ Execution time tracking"
    - "✓ Resource usage monitoring"
```

This comprehensive guide provides strategies and techniques for optimizing Ansible performance across all aspects of automation workflows, from configuration and execution to monitoring and scaling.