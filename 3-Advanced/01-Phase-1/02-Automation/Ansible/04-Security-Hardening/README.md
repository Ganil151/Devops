# Ansible Security Hardening

Comprehensive guide to security best practices, hardening techniques, and secure automation with Ansible for enterprise environments.

## Security Fundamentals

### Security Principles in Ansible

#### Core Security Concepts
- **Least Privilege**: Grant minimum necessary permissions
- **Defense in Depth**: Multiple layers of security controls
- **Secure by Default**: Secure configurations as baseline
- **Audit and Compliance**: Comprehensive logging and monitoring
- **Secrets Management**: Proper handling of sensitive data

#### Threat Model for Ansible
```yaml
# Ansible security threat model
threat_categories:
  control_node_compromise:
    - Unauthorized access to playbooks
    - Credential theft
    - Malicious code injection
  
  managed_node_compromise:
    - Privilege escalation
    - Lateral movement
    - Data exfiltration
  
  network_attacks:
    - Man-in-the-middle attacks
    - Traffic interception
    - SSH key compromise
  
  supply_chain_attacks:
    - Malicious roles/collections
    - Compromised dependencies
    - Untrusted content
```

## Secure Configuration

### Ansible Configuration Hardening
```ini
# ansible.cfg - Security hardened configuration
[defaults]
# Disable potentially dangerous features
allow_world_readable_tmpfiles = False
host_key_checking = True
retry_files_enabled = False

# Secure defaults
remote_user = ansible
private_key_file = ~/.ssh/ansible_ed25519
timeout = 30

# Logging and auditing
log_path = /var/log/ansible/ansible.log
display_args_to_stdout = False

# Fact gathering security
gathering = explicit
fact_caching = jsonfile
fact_caching_connection = /var/cache/ansible/facts
fact_caching_timeout = 3600

# Module security
module_utils = /usr/share/ansible/module_utils
library = /usr/share/ansible/modules

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
# SSH security settings
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=~/.ssh/known_hosts -o IdentitiesOnly=yes
pipelining = True
control_path = ~/.ssh/ansible-%%h-%%p-%%r
retries = 3

[galaxy]
# Galaxy security
server_list = community_galaxy,private_galaxy
ignore_certs = False
```

### SSH Security Hardening
```yaml
# SSH configuration hardening
- name: Harden SSH configuration
  hosts: all
  become: yes
  
  tasks:
    - name: Configure secure SSH settings
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        backup: yes
      loop:
        # Authentication security
        - { regexp: '^#?PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^#?PubkeyAuthentication', line: 'PubkeyAuthentication yes' }
        - { regexp: '^#?PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^#?PermitEmptyPasswords', line: 'PermitEmptyPasswords no' }
        - { regexp: '^#?ChallengeResponseAuthentication', line: 'ChallengeResponseAuthentication no' }
        
        # Protocol security
        - { regexp: '^#?Protocol', line: 'Protocol 2' }
        - { regexp: '^#?X11Forwarding', line: 'X11Forwarding no' }
        - { regexp: '^#?AllowTcpForwarding', line: 'AllowTcpForwarding no' }
        - { regexp: '^#?AllowAgentForwarding', line: 'AllowAgentForwarding no' }
        
        # Connection limits
        - { regexp: '^#?MaxAuthTries', line: 'MaxAuthTries 3' }
        - { regexp: '^#?MaxSessions', line: 'MaxSessions 2' }
        - { regexp: '^#?LoginGraceTime', line: 'LoginGraceTime 30' }
        
        # Keepalive settings
        - { regexp: '^#?ClientAliveInterval', line: 'ClientAliveInterval 300' }
        - { regexp: '^#?ClientAliveCountMax', line: 'ClientAliveCountMax 2' }
        
        # Crypto settings
        - { regexp: '^#?Ciphers', line: 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr' }
        - { regexp: '^#?MACs', line: 'MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512' }
        - { regexp: '^#?KexAlgorithms', line: 'KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512' }
      notify: restart sshd
    
    - name: Configure SSH user restrictions
      lineinfile:
        path: /etc/ssh/sshd_config
        line: "{{ item }}"
        backup: yes
      loop:
        - "AllowUsers ansible"
        - "DenyUsers root"
        - "AllowGroups ansible sudo"
      notify: restart sshd
    
    - name: Set SSH banner
      copy:
        content: |
          **************************************************************************
          * WARNING: Unauthorized access to this system is prohibited and may be  *
          * subject to criminal and civil penalties. All activities are logged.   *
          **************************************************************************
        dest: /etc/ssh/banner
        mode: '0644'
    
    - name: Enable SSH banner
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?Banner'
        line: 'Banner /etc/ssh/banner'
      notify: restart sshd
  
  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted
```

## Secrets Management

### Ansible Vault Security
```yaml
# Advanced Vault usage patterns
- name: Secure secrets management
  hosts: all
  vars_files:
    - vars/public.yml
    - vars/vault.yml  # Encrypted with ansible-vault
  
  tasks:
    - name: Use vault variables securely
      template:
        src: secure_config.j2
        dest: /etc/app/config.conf
        owner: app
        group: app
        mode: '0600'
      vars:
        db_password: "{{ vault_db_password }}"
        api_key: "{{ vault_api_key }}"
      no_log: true  # Prevent secrets from appearing in logs
    
    - name: Validate vault variables exist
      assert:
        that:
          - vault_db_password is defined
          - vault_api_key is defined
        fail_msg: "Required vault variables not defined"
        quiet: true
```

### External Secrets Integration
```yaml
# HashiCorp Vault integration
- name: Retrieve secrets from HashiCorp Vault
  hosts: all
  
  tasks:
    - name: Authenticate with Vault
      uri:
        url: "{{ vault_url }}/v1/auth/aws/login"
        method: POST
        body_format: json
        body:
          role: "{{ vault_role }}"
        headers:
          X-Vault-Request: "true"
      register: vault_auth
      delegate_to: localhost
      run_once: true
      no_log: true
    
    - name: Retrieve database credentials
      uri:
        url: "{{ vault_url }}/v1/secret/data/database"
        method: GET
        headers:
          X-Vault-Token: "{{ vault_auth.json.auth.client_token }}"
      register: db_secrets
      delegate_to: localhost
      run_once: true
      no_log: true
    
    - name: Configure database with retrieved secrets
      template:
        src: database.conf.j2
        dest: /etc/app/database.conf
        mode: '0600'
      vars:
        db_username: "{{ db_secrets.json.data.data.username }}"
        db_password: "{{ db_secrets.json.data.data.password }}"
      no_log: true

# AWS Secrets Manager integration
- name: Retrieve secrets from AWS Secrets Manager
  hosts: localhost
  
  tasks:
    - name: Get database credentials
      aws_secret:
        name: "prod/database/credentials"
        region: us-east-1
      register: db_credentials
      no_log: true
    
    - name: Set facts from secrets
      set_fact:
        database_config:
          username: "{{ (db_credentials.secret | from_json).username }}"
          password: "{{ (db_credentials.secret | from_json).password }}"
          host: "{{ (db_credentials.secret | from_json).host }}"
      no_log: true
```

### Key Management
```yaml
# SSH key management and rotation
- name: SSH key management
  hosts: all
  become: yes
  
  tasks:
    - name: Create ansible user
      user:
        name: ansible
        shell: /bin/bash
        groups: sudo
        append: yes
        create_home: yes
    
    - name: Set up SSH directory
      file:
        path: /home/ansible/.ssh
        state: directory
        owner: ansible
        group: ansible
        mode: '0700'
    
    - name: Install current SSH public keys
      authorized_key:
        user: ansible
        key: "{{ item }}"
        state: present
        exclusive: yes  # Remove other keys
      loop: "{{ ansible_ssh_public_keys }}"
      vars:
        ansible_ssh_public_keys:
          - "{{ lookup('file', 'keys/ansible_ed25519.pub') }}"
          - "{{ lookup('file', 'keys/ansible_backup_ed25519.pub') }}"
    
    - name: Remove old SSH keys
      authorized_key:
        user: ansible
        key: "{{ item }}"
        state: absent
      loop: "{{ deprecated_ssh_keys | default([]) }}"
    
    - name: Configure sudo for ansible user
      copy:
        content: |
          # Ansible automation user
          ansible ALL=(ALL) NOPASSWD: ALL
          Defaults:ansible !requiretty
        dest: /etc/sudoers.d/ansible
        mode: '0440'
        validate: 'visudo -cf %s'
```

## Access Control and Authentication

### Role-Based Access Control (RBAC)
```yaml
# Implement RBAC for Ansible operations
- name: RBAC implementation
  hosts: localhost
  vars:
    user_roles:
      developers:
        - deploy_applications
        - view_logs
        - restart_services
      operators:
        - deploy_applications
        - view_logs
        - restart_services
        - manage_infrastructure
        - backup_restore
      administrators:
        - "*"  # All permissions
    
    role_permissions:
      deploy_applications:
        playbooks: ["deploy.yml", "rollback.yml"]
        inventory_groups: ["webservers", "appservers"]
      manage_infrastructure:
        playbooks: ["infrastructure.yml", "security.yml"]
        inventory_groups: ["all"]
      backup_restore:
        playbooks: ["backup.yml", "restore.yml"]
        inventory_groups: ["databases"]
  
  tasks:
    - name: Validate user permissions
      assert:
        that:
          - ansible_user_id in user_groups
          - requested_operation in user_roles[user_groups[ansible_user_id]]
        fail_msg: "User {{ ansible_user_id }} not authorized for {{ requested_operation }}"
      vars:
        user_groups:
          alice: developers
          bob: operators
          charlie: administrators
```

### Multi-Factor Authentication
```yaml
# Implement MFA for sensitive operations
- name: MFA for sensitive operations
  hosts: production
  
  pre_tasks:
    - name: Require MFA for production
      pause:
        prompt: "Enter MFA token for production deployment"
        echo: no
      register: mfa_token
      when: 
        - environment == "production"
        - sensitive_operation | default(false)
    
    - name: Validate MFA token
      uri:
        url: "{{ mfa_validation_endpoint }}"
        method: POST
        body_format: json
        body:
          user: "{{ ansible_user_id }}"
          token: "{{ mfa_token.user_input }}"
      register: mfa_validation
      when: mfa_token is defined
      no_log: true
    
    - name: Fail if MFA invalid
      fail:
        msg: "MFA validation failed"
      when: 
        - mfa_validation is defined
        - not mfa_validation.json.valid
```

## Network Security

### Firewall Configuration
```yaml
# Comprehensive firewall hardening
- name: Configure firewall security
  hosts: all
  become: yes
  
  tasks:
    - name: Install firewall packages
      package:
        name: "{{ firewall_package }}"
        state: present
      vars:
        firewall_package: "{{ 'firewalld' if ansible_os_family == 'RedHat' else 'ufw' }}"
    
    - name: Configure firewalld (RHEL/CentOS)
      block:
        - name: Start and enable firewalld
          service:
            name: firewalld
            state: started
            enabled: yes
        
        - name: Set default zone to drop
          firewalld:
            zone: drop
            state: enabled
            permanent: yes
            immediate: yes
        
        - name: Configure SSH access
          firewalld:
            service: ssh
            zone: public
            permanent: yes
            immediate: yes
            state: enabled
            source: "{{ ansible_management_networks }}"
        
        - name: Configure application ports
          firewalld:
            port: "{{ item.port }}/{{ item.protocol }}"
            zone: public
            permanent: yes
            immediate: yes
            state: enabled
            source: "{{ item.source | default(omit) }}"
          loop: "{{ firewall_rules }}"
        
        - name: Remove unnecessary services
          firewalld:
            service: "{{ item }}"
            zone: public
            permanent: yes
            immediate: yes
            state: disabled
          loop:
            - dhcpv6-client
            - cockpit
      when: ansible_os_family == "RedHat"
    
    - name: Configure ufw (Ubuntu/Debian)
      block:
        - name: Set ufw default policies
          ufw:
            direction: "{{ item.direction }}"
            policy: "{{ item.policy }}"
          loop:
            - { direction: incoming, policy: deny }
            - { direction: outgoing, policy: allow }
        
        - name: Configure SSH access
          ufw:
            rule: allow
            port: ssh
            src: "{{ item }}"
          loop: "{{ ansible_management_networks }}"
        
        - name: Configure application ports
          ufw:
            rule: allow
            port: "{{ item.port }}"
            proto: "{{ item.protocol }}"
            src: "{{ item.source | default(omit) }}"
          loop: "{{ firewall_rules }}"
        
        - name: Enable ufw
          ufw:
            state: enabled
      when: ansible_os_family == "Debian"
```

### Network Segmentation
```yaml
# Network segmentation and isolation
- name: Network segmentation configuration
  hosts: all
  become: yes
  
  tasks:
    - name: Configure network interfaces
      template:
        src: network-interface.j2
        dest: "/etc/sysconfig/network-scripts/ifcfg-{{ item.name }}"
        backup: yes
      loop: "{{ network_interfaces }}"
      notify: restart network
      when: ansible_os_family == "RedHat"
    
    - name: Configure routing tables
      lineinfile:
        path: /etc/iproute2/rt_tables
        line: "{{ item.id }} {{ item.name }}"
        create: yes
      loop: "{{ routing_tables }}"
    
    - name: Configure network policies
      template:
        src: network-policy.j2
        dest: /etc/network-policy.conf
      vars:
        network_zones:
          management:
            networks: "{{ management_networks }}"
            allowed_ports: [22, 443]
          application:
            networks: "{{ application_networks }}"
            allowed_ports: [80, 443, 8080]
          database:
            networks: "{{ database_networks }}"
            allowed_ports: [3306, 5432]
```

## System Hardening

### Operating System Hardening
```yaml
# Comprehensive OS hardening
- name: Operating system hardening
  hosts: all
  become: yes
  
  tasks:
    - name: Configure kernel parameters
      sysctl:
        name: "{{ item.name }}"
        value: "{{ item.value }}"
        state: present
        reload: yes
      loop:
        # Network security
        - { name: net.ipv4.ip_forward, value: 0 }
        - { name: net.ipv4.conf.all.send_redirects, value: 0 }
        - { name: net.ipv4.conf.default.send_redirects, value: 0 }
        - { name: net.ipv4.conf.all.accept_redirects, value: 0 }
        - { name: net.ipv4.conf.default.accept_redirects, value: 0 }
        - { name: net.ipv4.conf.all.secure_redirects, value: 0 }
        - { name: net.ipv4.conf.default.secure_redirects, value: 0 }
        - { name: net.ipv4.conf.all.log_martians, value: 1 }
        - { name: net.ipv4.conf.default.log_martians, value: 1 }
        - { name: net.ipv4.icmp_echo_ignore_broadcasts, value: 1 }
        - { name: net.ipv4.icmp_ignore_bogus_error_responses, value: 1 }
        - { name: net.ipv4.conf.all.rp_filter, value: 1 }
        - { name: net.ipv4.conf.default.rp_filter, value: 1 }
        - { name: net.ipv4.tcp_syncookies, value: 1 }
        
        # Memory protection
        - { name: kernel.randomize_va_space, value: 2 }
        - { name: kernel.exec-shield, value: 1 }
        - { name: kernel.dmesg_restrict, value: 1 }
        - { name: kernel.kptr_restrict, value: 2 }
    
    - name: Disable unnecessary services
      service:
        name: "{{ item }}"
        state: stopped
        enabled: no
      loop: "{{ unnecessary_services }}"
      vars:
        unnecessary_services:
          - avahi-daemon
          - cups
          - nfs-server
          - rpcbind
          - telnet
      ignore_errors: yes
    
    - name: Remove unnecessary packages
      package:
        name: "{{ item }}"
        state: absent
      loop:
        - telnet
        - rsh
        - ypbind
        - tftp
        - xinetd
      ignore_errors: yes
    
    - name: Configure file permissions
      file:
        path: "{{ item.path }}"
        mode: "{{ item.mode }}"
        owner: "{{ item.owner | default('root') }}"
        group: "{{ item.group | default('root') }}"
      loop:
        - { path: /etc/passwd, mode: '0644' }
        - { path: /etc/shadow, mode: '0600' }
        - { path: /etc/group, mode: '0644' }
        - { path: /etc/gshadow, mode: '0600' }
        - { path: /etc/ssh/sshd_config, mode: '0600' }
        - { path: /boot/grub2/grub.cfg, mode: '0600' }
    
    - name: Configure password policies
      lineinfile:
        path: /etc/login.defs
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - { regexp: '^PASS_MAX_DAYS', line: 'PASS_MAX_DAYS 90' }
        - { regexp: '^PASS_MIN_DAYS', line: 'PASS_MIN_DAYS 7' }
        - { regexp: '^PASS_WARN_AGE', line: 'PASS_WARN_AGE 14' }
        - { regexp: '^PASS_MIN_LEN', line: 'PASS_MIN_LEN 12' }
```

### Application Security Hardening
```yaml
# Application-specific security hardening
- name: Application security hardening
  hosts: webservers
  become: yes
  
  tasks:
    - name: Configure web server security headers
      template:
        src: security-headers.conf.j2
        dest: /etc/nginx/conf.d/security-headers.conf
      vars:
        security_headers:
          - "add_header X-Frame-Options DENY always;"
          - "add_header X-Content-Type-Options nosniff always;"
          - "add_header X-XSS-Protection '1; mode=block' always;"
          - "add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains' always;"
          - "add_header Content-Security-Policy \"default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';\" always;"
          - "add_header Referrer-Policy 'strict-origin-when-cross-origin' always;"
      notify: reload nginx
    
    - name: Configure SSL/TLS security
      template:
        src: ssl-security.conf.j2
        dest: /etc/nginx/conf.d/ssl-security.conf
      vars:
        ssl_protocols: "TLSv1.2 TLSv1.3"
        ssl_ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
        ssl_prefer_server_ciphers: "off"
      notify: reload nginx
    
    - name: Configure application user security
      user:
        name: "{{ app_user }}"
        shell: /bin/false
        home: /var/lib/{{ app_user }}
        create_home: no
        system: yes
      vars:
        app_user: webapp
    
    - name: Set application file permissions
      file:
        path: "{{ item.path }}"
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: "{{ item.mode }}"
        recurse: "{{ item.recurse | default(false) }}"
      loop:
        - { path: /opt/webapp, mode: '0755', recurse: true }
        - { path: /opt/webapp/config, mode: '0600', recurse: true }
        - { path: /var/log/webapp, mode: '0750', recurse: true }
      vars:
        app_user: webapp
        app_group: webapp
```

## Compliance and Auditing

### Security Compliance Framework
```yaml
# CIS (Center for Internet Security) compliance
- name: CIS compliance implementation
  hosts: all
  become: yes
  
  tasks:
    - name: CIS 1.1.1.1 - Ensure mounting of cramfs filesystems is disabled
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install cramfs /bin/true"
        create: yes
    
    - name: CIS 1.1.1.2 - Ensure mounting of freevxfs filesystems is disabled
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install freevxfs /bin/true"
    
    - name: CIS 1.1.1.3 - Ensure mounting of jffs2 filesystems is disabled
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install jffs2 /bin/true"
    
    - name: CIS 1.1.1.4 - Ensure mounting of hfs filesystems is disabled
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install hfs /bin/true"
    
    - name: CIS 1.1.1.5 - Ensure mounting of hfsplus filesystems is disabled
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install hfsplus /bin/true"
    
    - name: CIS 1.1.1.6 - Ensure mounting of squashfs filesystems is disabled
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install squashfs /bin/true"
    
    - name: CIS 1.1.1.7 - Ensure mounting of udf filesystems is disabled
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install udf /bin/true"
    
    - name: CIS 1.1.1.8 - Ensure mounting of FAT filesystems is limited
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install vfat /bin/true"
      when: disable_fat_filesystems | default(true)

# STIG (Security Technical Implementation Guide) compliance
- name: STIG compliance implementation
  hosts: all
  become: yes
  
  tasks:
    - name: STIG V-38437 - Automated file system mounting must be disabled
      service:
        name: autofs
        state: stopped
        enabled: no
      ignore_errors: yes
    
    - name: STIG V-38438 - Auditing must be enabled at boot
      lineinfile:
        path: /etc/default/grub
        regexp: '^GRUB_CMDLINE_LINUX='
        line: 'GRUB_CMDLINE_LINUX="audit=1"'
      notify: update grub
    
    - name: STIG V-38439 - The system must provide automated mechanisms for supporting account management functions
      package:
        name: audit
        state: present
```

### Audit Logging Configuration
```yaml
# Comprehensive audit logging
- name: Configure audit logging
  hosts: all
  become: yes
  
  tasks:
    - name: Install audit daemon
      package:
        name: "{{ audit_package }}"
        state: present
      vars:
        audit_package: "{{ 'audit' if ansible_os_family == 'RedHat' else 'auditd' }}"
    
    - name: Configure audit rules
      template:
        src: audit.rules.j2
        dest: /etc/audit/rules.d/ansible.rules
        backup: yes
      vars:
        audit_rules:
          # Monitor authentication events
          - "-w /etc/passwd -p wa -k identity"
          - "-w /etc/group -p wa -k identity"
          - "-w /etc/shadow -p wa -k identity"
          - "-w /etc/sudoers -p wa -k identity"
          
          # Monitor system configuration changes
          - "-w /etc/ssh/sshd_config -p wa -k sshd_config"
          - "-w /etc/hosts -p wa -k network_config"
          - "-w /etc/network/ -p wa -k network_config"
          
          # Monitor privilege escalation
          - "-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=4294967295 -k privilege_escalation"
          - "-a always,exit -F arch=b32 -S execve -F euid=0 -F auid>=1000 -F auid!=4294967295 -k privilege_escalation"
          
          # Monitor file access
          - "-a always,exit -F arch=b64 -S open,openat,creat -F exit=-EACCES -k file_access"
          - "-a always,exit -F arch=b64 -S open,openat,creat -F exit=-EPERM -k file_access"
          
          # Monitor system calls
          - "-a always,exit -F arch=b64 -S mount -k mounts"
          - "-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -k delete"
      notify: restart auditd
    
    - name: Configure audit daemon
      template:
        src: auditd.conf.j2
        dest: /etc/audit/auditd.conf
        backup: yes
      vars:
        audit_config:
          log_file: /var/log/audit/audit.log
          log_format: RAW
          log_group: root
          priority_boost: 4
          flush: INCREMENTAL_ASYNC
          freq: 50
          num_logs: 5
          disp_qos: lossy
          dispatcher: /sbin/audispd
          name_format: NONE
          max_log_file: 50
          max_log_file_action: ROTATE
          space_left: 75
          space_left_action: SYSLOG
          admin_space_left: 50
          admin_space_left_action: SUSPEND
          disk_full_action: SUSPEND
          disk_error_action: SUSPEND
      notify: restart auditd
    
    - name: Start and enable audit daemon
      service:
        name: auditd
        state: started
        enabled: yes
  
  handlers:
    - name: restart auditd
      service:
        name: auditd
        state: restarted
    
    - name: update grub
      command: grub2-mkconfig -o /boot/grub2/grub.cfg
      when: ansible_os_family == "RedHat"
```

## Security Monitoring and Incident Response

### Security Monitoring Setup
```yaml
# Security monitoring and alerting
- name: Security monitoring configuration
  hosts: all
  become: yes
  
  tasks:
    - name: Install security monitoring tools
      package:
        name: "{{ item }}"
        state: present
      loop:
        - fail2ban
        - logwatch
        - rkhunter
        - chkrootkit
    
    - name: Configure fail2ban
      template:
        src: jail.local.j2
        dest: /etc/fail2ban/jail.local
      vars:
        fail2ban_config:
          DEFAULT:
            bantime: 3600
            findtime: 600
            maxretry: 3
            backend: systemd
          sshd:
            enabled: true
            port: ssh
            logpath: /var/log/auth.log
            maxretry: 3
          nginx-http-auth:
            enabled: true
            port: http,https
            logpath: /var/log/nginx/error.log
      notify: restart fail2ban
    
    - name: Configure intrusion detection
      template:
        src: rkhunter.conf.j2
        dest: /etc/rkhunter.conf
      vars:
        rkhunter_config:
          UPDATE_MIRRORS: 1
          MIRRORS_MODE: 0
          WEB_CMD: ""
          DISABLE_TESTS: "suspscan hidden_procs deleted_files packet_cap_apps apps"
          PKGMGR: RPM
    
    - name: Create security monitoring script
      copy:
        content: |
          #!/bin/bash
          # Security monitoring script
          
          # Check for failed login attempts
          FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log | wc -l)
          if [ $FAILED_LOGINS -gt 10 ]; then
              echo "WARNING: $FAILED_LOGINS failed login attempts detected"
          fi
          
          # Check for privilege escalation
          SUDO_USAGE=$(grep "sudo:" /var/log/auth.log | wc -l)
          if [ $SUDO_USAGE -gt 50 ]; then
              echo "WARNING: High sudo usage detected: $SUDO_USAGE events"
          fi
          
          # Check for unusual network connections
          CONNECTIONS=$(netstat -an | grep ESTABLISHED | wc -l)
          if [ $CONNECTIONS -gt 100 ]; then
              echo "WARNING: High number of network connections: $CONNECTIONS"
          fi
          
          # Check system integrity
          rkhunter --check --sk --nocolors
        dest: /usr/local/bin/security_monitor.sh
        mode: '0755'
    
    - name: Schedule security monitoring
      cron:
        name: "Security monitoring"
        minute: "0"
        hour: "*/4"
        job: "/usr/local/bin/security_monitor.sh | logger -t security_monitor"
  
  handlers:
    - name: restart fail2ban
      service:
        name: fail2ban
        state: restarted
```

### Incident Response Automation
```yaml
# Automated incident response
- name: Incident response automation
  hosts: all
  become: yes
  
  tasks:
    - name: Create incident response script
      copy:
        content: |
          #!/bin/bash
          # Automated incident response script
          
          INCIDENT_TYPE=$1
          SEVERITY=$2
          
          case $INCIDENT_TYPE in
              "brute_force")
                  # Block attacking IPs
                  iptables -A INPUT -s $3 -j DROP
                  echo "Blocked IP: $3" | logger -t incident_response
                  ;;
              "malware_detected")
                  # Isolate system
                  iptables -P INPUT DROP
                  iptables -P OUTPUT DROP
                  echo "System isolated due to malware detection" | logger -t incident_response
                  ;;
              "privilege_escalation")
                  # Lock user account
                  usermod -L $3
                  echo "Locked user account: $3" | logger -t incident_response
                  ;;
              "data_exfiltration")
                  # Block outbound traffic
                  iptables -A OUTPUT -p tcp --dport 80,443 -j DROP
                  echo "Blocked outbound HTTP/HTTPS traffic" | logger -t incident_response
                  ;;
          esac
          
          # Send alert
          curl -X POST "{{ incident_webhook_url }}" \
               -H "Content-Type: application/json" \
               -d "{\"incident_type\": \"$INCIDENT_TYPE\", \"severity\": \"$SEVERITY\", \"host\": \"$(hostname)\"}"
        dest: /usr/local/bin/incident_response.sh
        mode: '0755'
    
    - name: Configure automated response triggers
      copy:
        content: |
          # Fail2ban action for incident response
          [Definition]
          actionstart = 
          actionstop = 
          actioncheck = 
          actionban = /usr/local/bin/incident_response.sh brute_force high <ip>
          actionunban = 
        dest: /etc/fail2ban/action.d/incident_response.conf
      notify: restart fail2ban
```

This comprehensive security hardening guide provides enterprise-grade security practices for Ansible automation, covering all aspects from configuration and secrets management to compliance and incident response.