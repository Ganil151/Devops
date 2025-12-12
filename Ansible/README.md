# Ansible Documentation

Comprehensive Ansible automation guide for DevOps engineers covering configuration management, application deployment, and infrastructure orchestration.

## 📁 Directory Structure

```
Ansible/
├── Fundamentals/              # Core Ansible concepts
│   ├── Basics/               # Basic concepts and installation
│   ├── Inventory/            # Inventory management and patterns
│   ├── Playbooks/           # Playbook creation and structure
│   └── Roles/               # Role development and organization
├── Advanced/                 # Advanced Ansible features
│   ├── Vault/               # Ansible Vault for secrets management
│   ├── Galaxy/              # Ansible Galaxy and community roles
│   └── Collections/         # Ansible Collections management
├── Modules/                  # Module usage and examples
│   ├── Core/                # Core system modules
│   ├── Cloud/               # Cloud provider modules
│   ├── Network/             # Network automation modules
│   └── Database/            # Database management modules
├── Best-Practices/          # Ansible best practices and patterns
├── Security/                # Security considerations and hardening
├── CI-CD-Integration/       # Integration with CI/CD pipelines
├── Troubleshooting/         # Common issues and debugging
├── Examples/                # Real-world examples and use cases
│   ├── Web-Applications/    # Web application deployment
│   ├── Database-Setup/      # Database configuration examples
│   ├── Infrastructure/      # Infrastructure provisioning
│   └── Monitoring/          # Monitoring stack deployment
└── Templates/               # Jinja2 templates and examples
```

## 🚀 Quick Start

### Installation
```bash
# Install Ansible (Ubuntu/Debian)
sudo apt update
sudo apt install ansible -y

# Install Ansible (RHEL/CentOS/Amazon Linux)
sudo yum install ansible -y

# Install Ansible using pip
pip install ansible

# Verify installation
ansible --version
```

### Basic Commands
```bash
# Test connectivity
ansible all -m ping

# Run ad-hoc command
ansible all -a "uptime"

# Run playbook
ansible-playbook site.yml

# Check syntax
ansible-playbook site.yml --syntax-check

# Dry run
ansible-playbook site.yml --check
```

## 🛠️ Core Components

### Inventory
- **Static Inventory**: INI or YAML format host definitions
- **Dynamic Inventory**: Cloud provider integration
- **Host Variables**: Per-host configuration
- **Group Variables**: Shared group configuration

### Playbooks
- **Tasks**: Individual automation steps
- **Handlers**: Event-driven actions
- **Variables**: Dynamic configuration
- **Templates**: Jinja2 templating engine

### Modules
- **Core Modules**: System administration tasks
- **Cloud Modules**: Cloud provider integration
- **Network Modules**: Network device configuration
- **Database Modules**: Database management

### Roles
- **Structure**: Organized, reusable automation
- **Dependencies**: Role interdependencies
- **Galaxy**: Community role sharing
- **Collections**: Packaged automation content

## 📋 Key Features

### Configuration Management
```yaml
# System configuration
- name: Configure web server
  hosts: webservers
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
```

### Application Deployment
```yaml
# Application deployment
- name: Deploy Spring Boot application
  hosts: app_servers
  tasks:
    - name: Copy application JAR
      copy:
        src: app.jar
        dest: /opt/app/app.jar
    
    - name: Start application
      systemd:
        name: myapp
        state: restarted
```

### Infrastructure Orchestration
```yaml
# Multi-tier deployment
- name: Deploy infrastructure
  hosts: localhost
  tasks:
    - name: Create EC2 instances
      ec2_instance:
        name: "{{ item }}"
        image_id: ami-12345678
        instance_type: t3.micro
      loop:
        - web-server-1
        - web-server-2
        - db-server-1
```

## 🎯 Use Cases

### Web Application Stack
```bash
# LAMP/LEMP stack deployment
- Database server configuration
- Web server installation and configuration
- Application deployment and configuration
- Load balancer setup
```

### Container Orchestration
```bash
# Docker and Kubernetes management
- Docker installation and configuration
- Container deployment and management
- Kubernetes cluster setup
- Application scaling and updates
```

### Cloud Infrastructure
```bash
# Multi-cloud infrastructure management
- AWS/Azure/GCP resource provisioning
- Network configuration and security
- Auto-scaling and load balancing
- Monitoring and logging setup
```

### Database Management
```bash
# Database automation
- MySQL/PostgreSQL installation and configuration
- Database schema and user management
- Backup and recovery automation
- Performance tuning and monitoring
```

## 🔧 Configuration

### Ansible Configuration (ansible.cfg)
```ini
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
callback_whitelist = profile_tasks, timer
stdout_callback = yaml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

### Inventory Example
```yaml
# inventory/hosts.yml
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
        web2:
          ansible_host: 192.168.1.11
      vars:
        http_port: 80
        max_clients: 200
    
    databases:
      hosts:
        db1:
          ansible_host: 192.168.1.20
          mysql_port: 3306
      vars:
        mysql_root_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653...
    
    monitoring:
      hosts:
        monitor1:
          ansible_host: 192.168.1.30
  
  vars:
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

## 🔒 Security Best Practices

### Ansible Vault
```bash
# Create encrypted file
ansible-vault create secrets.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Encrypt existing file
ansible-vault encrypt vars.yml

# Use in playbook
ansible-playbook site.yml --ask-vault-pass
```

### SSH Security
```yaml
# Secure SSH configuration
- name: Configure SSH security
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: "{{ item.regexp }}"
    line: "{{ item.line }}"
  loop:
    - { regexp: '^PasswordAuthentication', line: 'PasswordAuthentication no' }
    - { regexp: '^PermitRootLogin', line: 'PermitRootLogin no' }
    - { regexp: '^Protocol', line: 'Protocol 2' }
  notify: restart sshd
```

### Privilege Escalation
```yaml
# Secure privilege escalation
- name: Install packages
  package:
    name: "{{ packages }}"
    state: present
  become: yes
  become_method: sudo
  become_user: root
```

## 📊 Monitoring and Logging

### Task Profiling
```bash
# Enable task timing
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks,timer

# Run with profiling
ansible-playbook site.yml
```

### Logging Configuration
```ini
# ansible.cfg
[defaults]
log_path = /var/log/ansible.log
```

### Debug and Verbose Output
```bash
# Verbose levels
ansible-playbook site.yml -v      # Basic
ansible-playbook site.yml -vv     # More verbose
ansible-playbook site.yml -vvv    # Debug
ansible-playbook site.yml -vvvv   # Connection debug
```

## 🌐 Integration

### CI/CD Pipeline Integration
```yaml
# Jenkins Pipeline
pipeline {
    agent any
    stages {
        stage('Deploy') {
            steps {
                ansiblePlaybook(
                    playbook: 'site.yml',
                    inventory: 'inventory/production',
                    credentialsId: 'ansible-ssh-key'
                )
            }
        }
    }
}
```

### GitLab CI Integration
```yaml
# .gitlab-ci.yml
deploy:
  stage: deploy
  image: ansible/ansible-runner:latest
  script:
    - ansible-playbook -i inventory/production site.yml
  only:
    - main
```

### GitHub Actions Integration
```yaml
# .github/workflows/deploy.yml
name: Deploy with Ansible
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Ansible playbook
        uses: dawidd6/action-ansible-playbook@v2
        with:
          playbook: site.yml
          directory: ./
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          inventory: inventory/production
```

## 📚 Learning Path

### Beginner Level ✅
- [ ] Understand Ansible architecture and concepts
- [ ] Learn basic inventory management
- [ ] Write simple playbooks and tasks
- [ ] Use core modules for system administration
- [ ] Basic variable and template usage

### Intermediate Level 🎯
- [ ] Create and use Ansible roles
- [ ] Implement Ansible Vault for secrets
- [ ] Use advanced playbook features (loops, conditionals)
- [ ] Integrate with cloud providers
- [ ] Implement error handling and debugging

### Advanced Level 🚀
- [ ] Develop custom modules and plugins
- [ ] Use Ansible Collections effectively
- [ ] Implement complex orchestration workflows
- [ ] Performance optimization and scaling
- [ ] Enterprise automation patterns

## 🔗 External Resources

### Official Documentation
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Ansible Collections](https://docs.ansible.com/ansible/latest/collections/)

### Community Resources
- [Ansible Community](https://www.ansible.com/community)
- [Ansible GitHub](https://github.com/ansible/ansible)
- [Ansible Reddit](https://www.reddit.com/r/ansible/)

### Training and Certification
- [Red Hat Ansible Training](https://www.redhat.com/en/services/training/do407-automation-ansible-i)
- [Ansible Certification](https://www.redhat.com/en/services/certification/rhce)

## 🎯 Common Use Cases

### Infrastructure as Code
```yaml
# Complete infrastructure deployment
- name: Deploy infrastructure
  hosts: localhost
  tasks:
    - name: Create VPC
      ec2_vpc_net:
        name: production-vpc
        cidr_block: 10.0.0.0/16
        
    - name: Create subnets
      ec2_vpc_subnet:
        vpc_id: "{{ vpc.vpc.id }}"
        cidr: "{{ item.cidr }}"
        az: "{{ item.az }}"
      loop:
        - { cidr: "10.0.1.0/24", az: "us-east-1a" }
        - { cidr: "10.0.2.0/24", az: "us-east-1b" }
```

### Application Deployment
```yaml
# Zero-downtime deployment
- name: Deploy application
  hosts: webservers
  serial: 1
  tasks:
    - name: Remove from load balancer
      uri:
        url: "http://lb.example.com/remove/{{ inventory_hostname }}"
        
    - name: Deploy new version
      copy:
        src: app-v2.jar
        dest: /opt/app/app.jar
        
    - name: Restart application
      systemd:
        name: myapp
        state: restarted
        
    - name: Wait for application
      wait_for:
        port: 8080
        timeout: 60
        
    - name: Add back to load balancer
      uri:
        url: "http://lb.example.com/add/{{ inventory_hostname }}"
```

### Configuration Management
```yaml
# System hardening
- name: Harden system security
  hosts: all
  become: yes
  tasks:
    - name: Update all packages
      package:
        name: "*"
        state: latest
        
    - name: Configure firewall
      firewalld:
        service: "{{ item }}"
        permanent: yes
        state: enabled
      loop:
        - ssh
        - http
        - https
        
    - name: Disable unused services
      systemd:
        name: "{{ item }}"
        enabled: no
        state: stopped
      loop:
        - telnet
        - rsh
        - rlogin
```

This comprehensive Ansible documentation provides a complete foundation for understanding and implementing automation solutions across infrastructure, applications, and cloud environments.