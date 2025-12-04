## **Ansible Basics**

### Installation & Version
```bash
# Install Ansible (Ubuntu/Debian)
sudo apt update
sudo apt install ansible -y

# Install Ansible (RHEL/CentOS/Amazon Linux)
sudo yum install ansible -y

# Install Ansible using pip
pip install ansible

# Check Ansible version
ansible --version

# Check installed modules
ansible-doc -l

# Get documentation for specific module
ansible-doc <module_name>
ansible-doc yum
ansible-doc apt

# List all available plugins
ansible-doc -t <plugin_type> -l
ansible-doc -t callback -l
```

### Configuration

```bash
# View Ansible configuration
ansible-config view

# List all configuration settings
ansible-config list

# Dump current configuration
ansible-config dump

# Show configuration file locations (in order of precedence)
ansible-config view --show-origin

# Generate ansible.cfg template
ansible-config init --disabled > ansible.cfg

# Test configuration
ansible all -m ping -vvv
```

---

## **Inventory Management**

### Inventory Files

```bash
# Default inventory location
/etc/ansible/hosts

# Custom inventory file
ansible-inventory -i inventory.ini --list

# View inventory in YAML format
ansible-inventory -i inventory.ini --list -y

# View inventory graph
ansible-inventory -i inventory.ini --graph

# View specific host variables
ansible-inventory -i inventory.ini --host <hostname>

# Verify inventory syntax
ansible-inventory -i inventory.ini --list --export

# List all hosts in inventory
ansible all -i inventory.ini --list-hosts

# List hosts in specific group
ansible <group_name> -i inventory.ini --list-hosts
```

### Sample Inventory Files

**INI Format (inventory.ini):**
```ini
# Spring Petclinic Infrastructure

[master]
spring-petclinic-master ansible_host=10.0.1.10 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/petclinic-key.pem

[workers]
spring-petclinic-worker ansible_host=10.0.1.11 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/petclinic-key.pem
docker-server ansible_host=10.0.1.12 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/petclinic-key.pem

[monitoring]
spring-petclinic-monitor ansible_host=10.0.1.13 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/petclinic-key.pem

[database]
spring-petclinic-mysql ansible_host=10.0.1.14 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/petclinic-key.pem

[kubernetes:children]
k8s_masters
k8s_workers

[k8s_masters]
k8s-master-1 ansible_host=10.0.2.10 ansible_user=ec2-user

[k8s_workers]
k8s-worker-1 ansible_host=10.0.2.11 ansible_user=ec2-user
k8s-worker-2 ansible_host=10.0.2.12 ansible_user=ec2-user

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[workers:vars]
java_version=21
docker_version=latest

[database:vars]
mysql_root_password=petclinic
mysql_database=petclinic
```

**YAML Format (inventory.yml):**
```yaml
all:
  children:
    master:
      hosts:
        spring-petclinic-master:
          ansible_host: 10.0.1.10
          ansible_user: ec2-user
          ansible_ssh_private_key_file: ~/.ssh/petclinic-key.pem
    
    workers:
      hosts:
        spring-petclinic-worker:
          ansible_host: 10.0.1.11
          ansible_user: ec2-user
        docker-server:
          ansible_host: 10.0.1.12
          ansible_user: ec2-user
      vars:
        java_version: 21
        docker_version: latest
    
    monitoring:
      hosts:
        spring-petclinic-monitor:
          ansible_host: 10.0.1.13
          ansible_user: ec2-user
    
    database:
      hosts:
        spring-petclinic-mysql:
          ansible_host: 10.0.1.14
          ansible_user: ec2-user
      vars:
        mysql_root_password: petclinic
        mysql_database: petclinic
    
    kubernetes:
      children:
        k8s_masters:
          hosts:
            k8s-master-1:
              ansible_host: 10.0.2.10
        k8s_workers:
          hosts:
            k8s-worker-1:
              ansible_host: 10.0.2.11
            k8s-worker-2:
              ansible_host: 10.0.2.12
  
  vars:
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

**Dynamic Inventory (AWS EC2):**
```bash
# Install boto3
pip install boto3

# Create aws_ec2.yml
cat > aws_ec2.yml <<EOF
plugin: aws_ec2
regions:
  - us-east-1
filters:
  tag:Project: spring-petclinic
  instance-state-name: running
keyed_groups:
  - key: tags.Role
    prefix: role
  - key: tags.Environment
    prefix: env
hostnames:
  - tag:Name
compose:
  ansible_host: public_ip_address
EOF

# Test dynamic inventory
ansible-inventory -i aws_ec2.yml --graph
ansible-inventory -i aws_ec2.yml --list
```
---
## **Ad-Hoc Commands**

### Basic Ad-Hoc Commands
```bash
# Ping all hosts
ansible all -m ping

# Ping specific group
ansible workers -m ping

# Ping with custom inventory
ansible all -i inventory.ini -m ping

# Check uptime
ansible all -a "uptime"

# Run command on all hosts
ansible all -a "hostname"

# Run command with sudo
ansible all -a "systemctl status sshd" --become

# Run shell command (supports pipes, redirection)
ansible all -m shell -a "ps aux | grep java"

# Copy file to remote hosts
ansible all -m copy -a "src=/local/file dest=/remote/path"

# Fetch file from remote hosts
ansible all -m fetch -a "src=/remote/file dest=/local/path"

# Install package (yum)
ansible all -m yum -a "name=git state=present" --become

# Install package (apt)
ansible all -m apt -a "name=git state=present update_cache=yes" --become

# Start service
ansible all -m service -a "name=nginx state=started" --become

# Restart service
ansible all -m service -a "name=nginx state=restarted" --become

# Create directory
ansible all -m file -a "path=/opt/app state=directory mode=0755" --become

# Create user
ansible all -m user -a "name=appuser state=present" --become

# Set timezone
ansible all -m timezone -a "name=America/New_York" --become

# Gather facts
ansible all -m setup

# Gather specific facts
ansible all -m setup -a "filter=ansible_distribution*"

# Check disk space
ansible all -m shell -a "df -h"

# Check memory
ansible all -m shell -a "free -m"

# Reboot hosts
ansible all -m reboot --become
```
---
### Ad-Hoc with Options
```bash
# Run with specific user
ansible all -m ping -u ec2-user

# Run with sudo
ansible all -m shell -a "whoami" --become

# Run with specific sudo user
ansible all -m shell -a "whoami" --become --become-user=root

# Use specific SSH key
ansible all -m ping --private-key=~/.ssh/id_rsa

# Limit to specific hosts
ansible all -m ping --limit "master,workers"

# Limit by pattern
ansible all -m ping --limit "spring-petclinic-*"

# Parallel execution (forks)
ansible all -m ping -f 10

# Check mode (dry run)
ansible all -m yum -a "name=git state=present" --check

# Verbose output
ansible all -m ping -v
ansible all -m ping -vv
ansible all -m ping -vvv
ansible all -m ping -vvvv

# One line output
ansible all -m ping -o

# Display task timing
ansible all -m ping --profile
```
---
## **Playbook Management**

### Running Playbooks
```bash
# Run playbook
ansible-playbook playbook.yml

# Run with custom inventory
ansible-playbook -i inventory.ini playbook.yml

# Dry run (check mode)
ansible-playbook playbook.yml --check

# Diff mode (show changes)
ansible-playbook playbook.yml --check --diff

# Start at specific task
ansible-playbook playbook.yml --start-at-task="Install packages"

# Run specific tags
ansible-playbook playbook.yml --tags "configuration,deploy"

# Skip specific tags
ansible-playbook playbook.yml --skip-tags "debug"

# Limit to specific hosts
ansible-playbook playbook.yml --limit "workers"

# Extra variables
ansible-playbook playbook.yml -e "version=1.2.3"
ansible-playbook playbook.yml -e "@vars.yml"

# Verbose output
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vvv

# Step through playbook
ansible-playbook playbook.yml --step

# Syntax check
ansible-playbook playbook.yml --syntax-check

# List tasks
ansible-playbook playbook.yml --list-tasks

# List tags
ansible-playbook playbook.yml --list-tags

# List hosts
ansible-playbook playbook.yml --list-hosts

# Ask for sudo password
ansible-playbook playbook.yml --ask-become-pass

# Ask for SSH password
ansible-playbook playbook.yml --ask-pass

# Ask for vault password
ansible-playbook playbook.yml --ask-vault-pass

# Use vault password file
ansible-playbook playbook.yml --vault-password-file=.vault_pass
```
---
### Sample Playbooks
**Basic MySQL Setup Playbook (mysql-setup.yml):**
```yaml
---
- name: Configure MySQL Server for Spring Petclinic
  hosts: database
  become: yes
  vars:
    mysql_root_password: petclinic
    mysql_user: petclinic
    mysql_password: petclinic
    databases:
      - petclinic_customers
      - petclinic_visits
      - petclinic_vets
  
  tasks:
    - name: Install MySQL Server
      yum:
        name: mysql-server
        state: present
      when: ansible_os_family == "RedHat"
    
    - name: Install PyMySQL
      pip:
        name: pymysql
        state: present
    
    - name: Start MySQL service
      service:
        name: mysqld
        state: started
        enabled: yes
    
    - name: Get temporary root password
      shell: "grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}'"
      register: temp_password
      failed_when: false
      changed_when: false
    
    - name: Set MySQL root password
      shell: |
        mysql -u root -p'{{ temp_password.stdout }}' --connect-expired-password \
        -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '{{ mysql_root_password }}';"
      when: temp_password.stdout != ""
      ignore_errors: yes
    
    - name: Configure MySQL for remote access
      lineinfile:
        path: /etc/my.cnf
        regexp: '^bind-address'
        line: 'bind-address = 0.0.0.0'
        insertafter: '^\[mysqld\]'
      notify: Restart MySQL
    
    - name: Create databases
      mysql_db:
        name: "{{ item }}"
        state: present
        login_user: root
        login_password: "{{ mysql_root_password }}"
      loop: "{{ databases }}"
    
    - name: Create MySQL user with privileges
      mysql_user:
        name: "{{ mysql_user }}"
        password: "{{ mysql_password }}"
        priv: '*.*:ALL'
        host: '%'
        state: present
        login_user: root
        login_password: "{{ mysql_root_password }}"
    
    - name: Import database schemas
      mysql_db:
        name: "{{ item.db }}"
        state: import
        target: "{{ item.schema }}"
        login_user: root
        login_password: "{{ mysql_root_password }}"
      loop:
        - { db: 'petclinic_customers', schema: '/tmp/customers_schema.sql' }
        - { db: 'petclinic_visits', schema: '/tmp/visits_schema.sql' }
        - { db: 'petclinic_vets', schema: '/tmp/vets_schema.sql' }
      when: item.schema is file
  
  handlers:
    - name: Restart MySQL
      service:
        name: mysqld
        state: restarted
```

**Docker Installation Playbook (docker-setup.yml):**
```yaml
---
- name: Install Docker on Worker Nodes
  hosts: workers
  become: yes
  
  tasks:
    - name: Install required packages
      yum:
        name:
          - yum-utils
          - device-mapper-persistent-data
          - lvm2
        state: present
    
    - name: Add Docker repository
      command: yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      args:
        creates: /etc/yum.repos.d/docker-ce.repo
    
    - name: Install Docker
      yum:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: present
    
    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes
    
    - name: Add user to docker group
      user:
        name: "{{ ansible_user }}"
        groups: docker
        append: yes
    
    - name: Install Docker Compose
      get_url:
        url: https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64
        dest: /usr/local/bin/docker-compose
        mode: '0755'
    
    - name: Verify Docker installation
      command: docker --version
      register: docker_version
    
    - name: Display Docker version
      debug:
        msg: "{{ docker_version.stdout }}"
```

**Complete Infrastructure Setup (site.yml):**
```yaml
---
- name: Setup Spring Petclinic Infrastructure
  hosts: all
  become: yes
  
  tasks:
    - name: Update all packages
      yum:
        name: '*'
        state: latest
      when: ansible_os_family == "RedHat"
    
    - name: Install common packages
      yum:
        name:
          - git
          - wget
          - curl
          - vim
          - net-tools
        state: present
    
    - name: Configure SSH for passwordless access
      authorized_key:
        user: "{{ ansible_user }}"
        state: present
        key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"

- name: Setup Java on all nodes
  hosts: all
  become: yes
  vars:
    java_version: 21
  
  tasks:
    - name: Install Java {{ java_version }}
      yum:
        name: "java-{{ java_version }}-openjdk-devel"
        state: present
    
    - name: Set JAVA_HOME
      lineinfile:
        path: /etc/environment
        line: 'JAVA_HOME=/usr/lib/jvm/java-{{ java_version }}-openjdk'
        create: yes

- name: Setup Jenkins on Master
  hosts: master
  become: yes
  
  tasks:
    - name: Add Jenkins repository
      get_url:
        url: https://pkg.jenkins.io/redhat-stable/jenkins.repo
        dest: /etc/yum.repos.d/jenkins.repo
    
    - name: Import Jenkins GPG key
      rpm_key:
        key: https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        state: present
    
    - name: Install Jenkins
      yum:
        name: jenkins
        state: present
    
    - name: Start Jenkins service
      service:
        name: jenkins
        state: started
        enabled: yes
    
    - name: Wait for Jenkins to start
      wait_for:
        port: 8080
        delay: 10
        timeout: 60
    
    - name: Get Jenkins initial password
      slurp:
        src: /var/lib/jenkins/secrets/initialAdminPassword
      register: jenkins_password
    
    - name: Display Jenkins initial password
      debug:
        msg: "Jenkins initial password: {{ jenkins_password.content | b64decode }}"

- name: Setup Docker on Workers
  import_playbook: docker-setup.yml

- name: Setup MySQL Database
  import_playbook: mysql-setup.yml

- name: Setup Monitoring Stack
  hosts: monitoring
  become: yes
  
  tasks:
    - name: Install Prometheus
      include_role:
        name: prometheus
    
    - name: Install Grafana
      include_role:
        name: grafana
```

---

## **Ansible Vault**

### Vault Operations
```bash
# Create encrypted file
ansible-vault create secrets.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Encrypt existing file
ansible-vault encrypt vars.yml

# Decrypt file
ansible-vault decrypt vars.yml

# View encrypted file
ansible-vault view secrets.yml

# Rekey (change password)
ansible-vault rekey secrets.yml

# Encrypt string
ansible-vault encrypt_string 'secret_password' --name 'mysql_password'

# Use vault in playbook
ansible-playbook playbook.yml --ask-vault-pass

# Use vault password file
ansible-playbook playbook.yml --vault-password-file=.vault_pass

# Multiple vault passwords
ansible-playbook playbook.yml --vault-id dev@.vault_pass_dev --vault-id prod@.vault_pass_prod
```

**Sample Vault File (secrets.yml):**
```yaml
---
mysql_root_password: SuperSecretPassword123!
mysql_petclinic_password: PetclinicDBPass456!
aws_access_key: AKIAIOSFODNN7EXAMPLE
aws_secret_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
jenkins_admin_password: JenkinsAdmin789!
```
---

## **Ansible Roles**

### Role Structure

```bash
# Create role directory structure
ansible-galaxy init <role_name>

# Example: Create MySQL role
ansible-galaxy init mysql

# Role structure
roles/
  mysql/
    tasks/
      main.yml
    handlers/
      main.yml
    templates/
      my.cnf.j2
    files/
      schema.sql
    vars/
      main.yml
    defaults/
      main.yml
    meta/
      main.yml
    README.md
```

### Using Roles

```bash
# Install role from Ansible Galaxy
ansible-galaxy install geerlingguy.docker

# Install specific version
ansible-galaxy install geerlingguy.docker,3.1.0

# Install from requirements file
ansible-galaxy install -r requirements.yml

# List installed roles
ansible-galaxy list

# Remove role
ansible-galaxy remove geerlingguy.docker

# Search for roles
ansible-galaxy search docker
```

**Requirements File (requirements.yml):**
```yaml
---
roles:
  - name: geerlingguy.docker
    version: 3.1.0
  
  - name: geerlingguy.jenkins
    version: 4.7.0
  
  - name: geerlingguy.mysql
    version: 4.3.0

collections:
  - name: community.general
    version: 5.5.0
  
  - name: community.docker
    version: 3.4.0
```

**Using Roles in Playbook:**
```yaml
---
- name: Setup Infrastructure with Roles
  hosts: all
  become: yes
  
  roles:
    - role: common
      tags: common
    
    - role: java
      java_version: 21
      tags: java
    
    - role: docker
      when: "'workers' in group_names"
      tags: docker
    
    - role: mysql
      when: "'database' in group_names"
      tags: database
    
    - role: monitoring
      when: "'monitoring' in group_names"
      tags: monitoring
```

**Sample MySQL Role (roles/mysql/tasks/main.yml):**
```yaml
---
- name: Install MySQL packages
  yum:
    name:
      - mysql-server
      - python3-PyMySQL
    state: present

- name: Start MySQL service
  service:
    name: mysqld
    state: started
    enabled: yes

- name: Copy MySQL configuration
  template:
    src: my.cnf.j2
    dest: /etc/my.cnf
    owner: root
    group: root
    mode: '0644'
  notify: Restart MySQL

- name: Set MySQL root password
  mysql_user:
    name: root
    password: "{{ mysql_root_password }}"
    login_unix_socket: /var/lib/mysql/mysql.sock
    state: present

- name: Create databases
  mysql_db:
    name: "{{ item }}"
    state: present
    login_user: root
    login_password: "{{ mysql_root_password }}"
  loop: "{{ mysql_databases }}"

- name: Create MySQL users
  mysql_user:
    name: "{{ item.name }}"
    password: "{{ item.password }}"
    priv: "{{ item.priv }}"
    host: "{{ item.host | default('%') }}"
    state: present
    login_user: root
    login_password: "{{ mysql_root_password }}"
  loop: "{{ mysql_users }}"
```

---

## **Diagnostic & Troubleshooting Commands**

### Connection Testing

```bash
# Test SSH connectivity
ansible all -m ping -vvv

# Test with specific user
ansible all -m ping -u ec2-user -vvv

# Test with SSH key
ansible all -m ping --private-key=~/.ssh/petclinic-key.pem -vvv

# Gather facts to test connectivity
ansible all -m setup --tree /tmp/facts

# Check Python version on remote hosts
ansible all -m shell -a "python3 --version"

# Test sudo access
ansible all -m shell -a "whoami" --become
```

### Playbook Debugging

```bash
# Syntax check
ansible-playbook playbook.yml --syntax-check

# Check mode (dry run)
ansible-playbook playbook.yml --check

# Diff mode
ansible-playbook playbook.yml --check --diff

# Step through playbook
ansible-playbook playbook.yml --step

# Start at specific task
ansible-playbook playbook.yml --start-at-task="Install packages"

# Verbose output levels
ansible-playbook playbook.yml -v      # Basic
ansible-playbook playbook.yml -vv     # More verbose
ansible-playbook playbook.yml -vvv    # Debug
ansible-playbook playbook.yml -vvvv   # Connection debug

# List tasks without running
ansible-playbook playbook.yml --list-tasks

# List hosts without running
ansible-playbook playbook.yml --list-hosts

# Display task timing
ansible-playbook playbook.yml --profile
```

### Debug Module in Playbooks

```yaml
---
- name: Debug Examples
  hosts: all
  
  tasks:
    - name: Display message
      debug:
        msg: "This is a debug message"
    
    - name: Display variable
      debug:
        var: ansible_hostname
    
    - name: Display multiple variables
      debug:
        msg: "Hostname: {{ ansible_hostname }}, OS: {{ ansible_distribution }}"
    
    - name: Conditional debug
      debug:
        msg: "This is a Red Hat system"
      when: ansible_os_family == "RedHat"
    
    - name: Display command output
      shell: uptime
      register: uptime_output
    
    - name: Show command result
      debug:
        var: uptime_output.stdout
    
    - name: Debug with verbosity
      debug:
        msg: "This only shows with -v or higher"
        verbosity: 1
```

### Fact Gathering

```bash
# Gather all facts
ansible all -m setup

# Filter facts
ansible all -m setup -a "filter=ansible_distribution*"
ansible all -m setup -a "filter=ansible_memory*"
ansible all -m setup -a "filter=ansible_interfaces"

# Gather network facts
ansible all -m setup -a "filter=ansible_default_ipv4"

# Gather hardware facts
ansible all -m setup -a "filter=ansible_processor*"

# Save facts to file
ansible all -m setup --tree /tmp/facts

# Custom facts location
# Create: /etc/ansible/facts.d/custom.fact
ansible all -m setup -a "filter=ansible_local"
```

### Variable Debugging

```yaml
---
- name: Variable Debugging
  hosts: all
  vars:
    app_name: spring-petclinic
    app_version: 3.0.0
  
  tasks:
    - name: Display all variables for host
      debug:
        var: hostvars[inventory_hostname]
    
    - name: Display group variables
      debug:
        var: groups
    
    - name: Display specific group
      debug:
        var: groups['workers']
    
    - name: Check if variable is defined
      debug:
        msg: "Variable is defined"
      when: app_name is defined
    
    - name: Display environment variables
      debug:
        var: ansible_env
```

### Performance Analysis

```bash
# Enable callback plugins in ansible.cfg
[defaults]
callback_whitelist = profile_tasks, timer

# Or set environment variable
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks,timer

# Run with profiling
ansible-playbook playbook.yml

# The output will show task timing:
# TASK [Install packages] ********************************************************
# changed: [host1]                                                          2.45s
# changed: [host2]                                                          2.51s
```

### Log Analysis

```bash
# Enable logging in ansible.cfg
[defaults]
log_path = /var/log/ansible.log

# Or environment variable
export ANSIBLE_LOG_PATH=/var/log/ansible.log

# View logs
tail -f /var/log/ansible.log

# Search for errors
grep -i error /var/log/ansible.log

# Search for specific host
grep "host1" /var/log/ansible.log

# Count failed tasks
grep -c "failed:" /var/log/ansible.log
```

---

## **Advanced Ansible Features**

### Conditionals

```yaml
---
- name: Conditional Examples
  hosts: all
  
  tasks:
    - name: Install package on RedHat
      yum:
        name: httpd
        state: present
      when: ansible_os_family == "RedHat"
    
    - name: Install package on Debian
      apt:
        name: apache2
        state: present
      when: ansible_os_family == "Debian"
    
    - name: Multiple conditions (AND)
      debug:
        msg: "RedHat 8 system"
      when:
        - ansible_os_family == "RedHat"
        - ansible_distribution_major_version == "8"
    
    - name: Multiple conditions (OR)
      debug:
        msg: "Either RedHat or Debian"
      when: ansible_os_family == "RedHat" or ansible_os_family == "Debian"
    
    - name: Check if file exists
      stat:
        path: /etc/myapp.conf
      register: config_file
    
    - name: Create file if doesn't exist
      file:
        path: /etc/myapp.conf
        state: touch
      when: not config_file.stat.exists
```

### Loops

```yaml
---
- name: Loop Examples
  hosts: all
  
  tasks:
    - name: Install multiple packages
      yum:
        name: "{{ item }}"
        state: present
      loop:
        - git
        - wget
        - curl
    
    - name: Create multiple users
      user:
        name: "{{ item.name }}"
        uid: "{{ item.uid }}"
        state: present
      loop:
        - { name: 'user1', uid: 1001 }
        - { name: 'user2', uid: 1002 }
        - { name: 'user3', uid: 1003 }
    
    - name: Loop with dictionary
      debug:
        msg: "Database: {{ item.key }}, Port: {{ item.value }}"
      loop: "{{ databases | dict2items }}"
      vars:
        databases:
          mysql: 3306
          postgresql: 5432
          mongodb: 27017
    
    - name: Loop with until
      shell: cat /tmp/result.txt
      register: result
      until: result.stdout.find("SUCCESS") != -1
      retries: 5
      delay: 10
```

### Handlers

```yaml
---
- name: Handler Examples
  hosts: all
  become: yes
  
  tasks:
    - name: Update Apache configuration
      template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify:
        - Restart Apache
        - Check Apache Status
    
    - name: Update MySQL configuration
      copy:
        src: my.cnf
        dest: /etc/my.cnf
      notify: Restart MySQL
  
  handlers:
    - name: Restart Apache
      service:
        name: httpd
        state: restarted
    
    - name: Check Apache Status
      command: systemctl status httpd
      register: apache_status
    
    - name: Restart MySQL
      service:
        name: mysqld
        state: restarted
```

### Templates (Jinja2)

```yaml
# Playbook
- name: Template Example
  hosts: database
  become: yes
  
  tasks:
    - name: Configure MySQL
      template:
        src: my.cnf.j2
        dest: /etc/my.cnf
        owner: root
        group: root
        mode: '0644'
      notify: Restart MySQL
```

**Template File (templates/my.cnf.j2):**

```jinja2
[mysqld]
bind-address = {{ mysql_bind_address | default('0.0.0.0') }}
port = {{ mysql_port | default('3306') }}
max_connections = {{ mysql_max_connections | default('200') }}

datadir = {{ mysql_datadir | default('/var/lib/mysql') }}
socket = {{ mysql_socket | default('/var/lib/mysql/mysql.sock') }}

# Character Set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Logging
log_error = {{ mysql_log_error | default('/var/log/mysql/error.log') }}
slow_query_log = {{ mysql_slow_query_log | default('1') }}
slow_query_log_file = {{ mysql_slow_query
```