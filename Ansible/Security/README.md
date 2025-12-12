# Ansible Security

Comprehensive guide to security best practices, hardening techniques, and secure automation workflows with Ansible.

## Security Fundamentals

### Security Principles in Ansible

1. **Least Privilege**: Grant minimum necessary permissions
2. **Defense in Depth**: Multiple layers of security controls
3. **Secure by Default**: Secure configurations as baseline
4. **Encryption**: Protect data in transit and at rest
5. **Auditing**: Log and monitor all activities
6. **Separation of Duties**: Isolate sensitive operations

### Threat Model
```yaml
# Common security threats in automation
threats:
  - credential_exposure: "Passwords, keys, tokens in plain text"
  - privilege_escalation: "Unauthorized elevation of permissions"
  - man_in_the_middle: "Interception of communications"
  - code_injection: "Malicious code execution"
  - data_exfiltration: "Unauthorized data access"
  - supply_chain: "Compromised dependencies or roles"
```

## Secure Configuration Management

### SSH Security Hardening
```yaml
---
- name: SSH Security Hardening
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
        - { regexp: '^#?PermitEmptyPasswords', line: 'PermitEmptyPasswords no' }
        - { regexp: '^#?AllowUsers', line: 'AllowUsers ansible' }
      notify: restart sshd
    
    - name: Set SSH key permissions
      file:
        path: "{{ item }}"
        mode: '0600'
        owner: root
        group: root
      loop:
        - /etc/ssh/ssh_host_rsa_key
        - /etc/ssh/ssh_host_ecdsa_key
        - /etc/ssh/ssh_host_ed25519_key
    
    - name: Configure SSH client security
      blockinfile:
        path: /etc/ssh/ssh_config
        block: |
          Host *
              Protocol 2
              Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
              MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
              KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
              HostKeyAlgorithms ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521
        marker: "# {mark} ANSIBLE MANAGED SSH SECURITY BLOCK"
  
  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted
```

### System Hardening
```yaml
---
- name: System Security Hardening
  hosts: all
  become: yes
  
  tasks:
    - name: Set password policy
      lineinfile:
        path: /etc/login.defs
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - { regexp: '^PASS_MAX_DAYS', line: 'PASS_MAX_DAYS 90' }
        - { regexp: '^PASS_MIN_DAYS', line: 'PASS_MIN_DAYS 1' }
        - { regexp: '^PASS_WARN_AGE', line: 'PASS_WARN_AGE 7' }
        - { regexp: '^PASS_MIN_LEN', line: 'PASS_MIN_LEN 12' }
    
    - name: Configure PAM password requirements
      lineinfile:
        path: /etc/pam.d/common-password
        regexp: '^password.*pam_pwquality.so'
        line: 'password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1'
      when: ansible_os_family == "Debian"
    
    - name: Disable unused network protocols
      lineinfile:
        path: /etc/modprobe.d/blacklist-rare-network.conf
        line: "{{ item }}"
        create: yes
      loop:
        - "install dccp /bin/true"
        - "install sctp /bin/true"
        - "install rds /bin/true"
        - "install tipc /bin/true"
    
    - name: Configure kernel security parameters
      sysctl:
        name: "{{ item.name }}"
        value: "{{ item.value }}"
        state: present
        reload: yes
      loop:
        - { name: 'net.ipv4.ip_forward', value: '0' }
        - { name: 'net.ipv4.conf.all.send_redirects', value: '0' }
        - { name: 'net.ipv4.conf.default.send_redirects', value: '0' }
        - { name: 'net.ipv4.conf.all.accept_redirects', value: '0' }
        - { name: 'net.ipv4.conf.default.accept_redirects', value: '0' }
        - { name: 'net.ipv4.conf.all.secure_redirects', value: '0' }
        - { name: 'net.ipv4.conf.default.secure_redirects', value: '0' }
        - { name: 'net.ipv4.conf.all.log_martians', value: '1' }
        - { name: 'net.ipv4.conf.default.log_martians', value: '1' }
        - { name: 'net.ipv4.icmp_echo_ignore_broadcasts', value: '1' }
        - { name: 'net.ipv4.icmp_ignore_bogus_error_responses', value: '1' }
        - { name: 'net.ipv4.tcp_syncookies', value: '1' }
        - { name: 'kernel.dmesg_restrict', value: '1' }
        - { name: 'kernel.kptr_restrict', value: '2' }
        - { name: 'fs.suid_dumpable', value: '0' }
    
    - name: Remove unnecessary packages
      package:
        name: "{{ item }}"
        state: absent
      loop:
        - telnet
        - rsh-client
        - rsh-redone-client
        - talk
        - ntalk
        - ypbind
        - ypserv
        - tftp
        - tftp-server
        - xinetd
```

### Firewall Configuration
```yaml
---
- name: Configure Firewall Security
  hosts: all
  become: yes
  
  tasks:
    - name: Install firewall packages
      package:
        name: "{{ firewall_package }}"
        state: present
      vars:
        firewall_package: "{{ 'ufw' if ansible_os_family == 'Debian' else 'firewalld' }}"
    
    - name: Configure UFW (Ubuntu/Debian)
      block:
        - name: Set UFW default policies
          ufw:
            direction: "{{ item.direction }}"
            policy: "{{ item.policy }}"
          loop:
            - { direction: 'incoming', policy: 'deny' }
            - { direction: 'outgoing', policy: 'allow' }
        
        - name: Allow SSH
          ufw:
            rule: allow
            port: "{{ ssh_port | default('22') }}"
            proto: tcp
        
        - name: Allow specific services
          ufw:
            rule: allow
            port: "{{ item.port }}"
            proto: "{{ item.proto }}"
            src: "{{ item.src | default(omit) }}"
          loop: "{{ firewall_rules | default([]) }}"
        
        - name: Enable UFW
          ufw:
            state: enabled
      when: ansible_os_family == "Debian"
    
    - name: Configure firewalld (RHEL/CentOS)
      block:
        - name: Start and enable firewalld
          service:
            name: firewalld
            state: started
            enabled: yes
        
        - name: Configure firewalld zones
          firewalld:
            zone: "{{ item.zone }}"
            service: "{{ item.service | default(omit) }}"
            port: "{{ item.port | default(omit) }}"
            source: "{{ item.source | default(omit) }}"
            permanent: yes
            state: enabled
            immediate: yes
          loop: "{{ firewall_rules | default([]) }}"
      when: ansible_os_family == "RedHat"
```

## Secrets Management

### Ansible Vault Best Practices
```yaml
# Vault file structure
# group_vars/production/vault.yml (encrypted)
---
vault_database_passwords:
  mysql_root: "{{ vault_mysql_root_password }}"
  app_user: "{{ vault_app_db_password }}"
  readonly: "{{ vault_readonly_password }}"

vault_api_keys:
  external_service: "{{ vault_external_api_key }}"
  monitoring: "{{ vault_monitoring_api_key }}"

vault_ssl_certificates:
  private_key: |
    -----BEGIN PRIVATE KEY-----
    {{ vault_ssl_private_key }}
    -----END PRIVATE KEY-----
  certificate: |
    -----BEGIN CERTIFICATE-----
    {{ vault_ssl_certificate }}
    -----END CERTIFICATE-----

# Reference vault variables in playbooks
- name: Configure database with encrypted password
  mysql_user:
    name: "{{ app_db_user }}"
    password: "{{ vault_database_passwords.app_user }}"
    priv: "{{ app_db_name }}.*:ALL"
    state: present
  no_log: true  # Prevent password logging
```

### External Secret Management Integration
```yaml
# HashiCorp Vault integration
- name: Retrieve secrets from HashiCorp Vault
  uri:
    url: "{{ vault_url }}/v1/secret/data/{{ secret_path }}"
    method: GET
    headers:
      X-Vault-Token: "{{ vault_token }}"
    return_content: yes
  register: vault_response
  delegate_to: localhost
  run_once: true
  no_log: true

- name: Set secret variables
  set_fact:
    db_password: "{{ vault_response.json.data.data.password }}"
    api_key: "{{ vault_response.json.data.data.api_key }}"
  no_log: true

# AWS Secrets Manager integration
- name: Retrieve secrets from AWS Secrets Manager
  aws_secret:
    name: "{{ secret_name }}"
    region: "{{ aws_region }}"
  register: aws_secret
  delegate_to: localhost
  run_once: true
  no_log: true

- name: Parse secret data
  set_fact:
    secret_data: "{{ aws_secret.secret | from_json }}"
  no_log: true
```

## Access Control and Authentication

### User Management and Sudo Configuration
```yaml
---
- name: Secure User Management
  hosts: all
  become: yes
  
  tasks:
    - name: Create ansible service account
      user:
        name: ansible
        shell: /bin/bash
        groups: wheel
        append: yes
        create_home: yes
        system: yes
    
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
        key: "{{ lookup('file', ansible_public_key_path) }}"
        state: present
        exclusive: yes
    
    - name: Disable password authentication for service accounts
      user:
        name: "{{ item }}"
        password_lock: yes
      loop:
        - ansible
        - nobody
        - daemon
    
    - name: Remove unnecessary user accounts
      user:
        name: "{{ item }}"
        state: absent
        remove: yes
      loop: "{{ users_to_remove | default([]) }}"
    
    - name: Configure account lockout policy
      lineinfile:
        path: /etc/pam.d/common-auth
        line: 'auth required pam_tally2.so deny=5 unlock_time=900'
        insertafter: '^auth.*pam_unix.so'
      when: ansible_os_family == "Debian"
```

### Role-Based Access Control (RBAC)
```yaml
# Define security roles and permissions
security_roles:
  admin:
    sudo_commands: "ALL"
    ssh_access: true
    groups: ["wheel", "admin"]
  
  operator:
    sudo_commands: "/usr/bin/systemctl, /usr/bin/service"
    ssh_access: true
    groups: ["operators"]
  
  readonly:
    sudo_commands: ""
    ssh_access: true
    groups: ["readonly"]

# Apply RBAC configuration
- name: Configure role-based access
  hosts: all
  become: yes
  
  tasks:
    - name: Create security groups
      group:
        name: "{{ item }}"
        state: present
      loop:
        - operators
        - readonly
    
    - name: Create users with roles
      user:
        name: "{{ item.key }}"
        groups: "{{ security_roles[item.value.role].groups }}"
        shell: /bin/bash
        create_home: yes
      loop: "{{ users | dict2items }}"
    
    - name: Configure sudo permissions by role
      lineinfile:
        path: "/etc/sudoers.d/{{ item.key }}"
        line: "{{ item.key }} ALL=(ALL) {{ security_roles[item.value.role].sudo_commands }}"
        create: yes
        mode: '0440'
        validate: 'visudo -cf %s'
      loop: "{{ users | dict2items }}"
      when: security_roles[item.value.role].sudo_commands != ""
```

## Network Security

### SSL/TLS Configuration
```yaml
---
- name: Configure SSL/TLS Security
  hosts: webservers
  become: yes
  
  tasks:
    - name: Generate strong DH parameters
      openssl_dhparam:
        path: /etc/ssl/certs/dhparam.pem
        size: 2048
        owner: root
        group: root
        mode: '0644'
    
    - name: Configure SSL certificate
      copy:
        content: "{{ vault_ssl_certificate }}"
        dest: /etc/ssl/certs/server.crt
        owner: root
        group: root
        mode: '0644'
    
    - name: Configure SSL private key
      copy:
        content: "{{ vault_ssl_private_key }}"
        dest: /etc/ssl/private/server.key
        owner: root
        group: root
        mode: '0600'
    
    - name: Configure secure SSL settings
      template:
        src: ssl.conf.j2
        dest: /etc/nginx/conf.d/ssl.conf
        owner: root
        group: root
        mode: '0644'
      notify: reload nginx
```

### SSL Configuration Template
```jinja2
# templates/ssl.conf.j2
# SSL Security Configuration

# SSL Protocols
ssl_protocols TLSv1.2 TLSv1.3;

# SSL Ciphers
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

# SSL Preferences
ssl_prefer_server_ciphers off;

# SSL Session
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# SSL Stapling
ssl_stapling on;
ssl_stapling_verify on;

# DH Parameters
ssl_dhparam /etc/ssl/certs/dhparam.pem;

# Security Headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options DENY always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'" always;
```

### Network Monitoring and Intrusion Detection
```yaml
---
- name: Install and configure security monitoring
  hosts: all
  become: yes
  
  tasks:
    - name: Install fail2ban
      package:
        name: fail2ban
        state: present
    
    - name: Configure fail2ban
      template:
        src: jail.local.j2
        dest: /etc/fail2ban/jail.local
        owner: root
        group: root
        mode: '0644'
      notify: restart fail2ban
    
    - name: Install AIDE (Advanced Intrusion Detection Environment)
      package:
        name: aide
        state: present
    
    - name: Initialize AIDE database
      command: aide --init
      args:
        creates: /var/lib/aide/aide.db.new.gz
    
    - name: Move AIDE database
      command: mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
      args:
        creates: /var/lib/aide/aide.db.gz
    
    - name: Schedule AIDE checks
      cron:
        name: "AIDE integrity check"
        minute: "0"
        hour: "2"
        job: "/usr/bin/aide --check"
        user: root
    
    - name: Install and configure auditd
      package:
        name: "{{ auditd_package }}"
        state: present
      vars:
        auditd_package: "{{ 'auditd' if ansible_os_family == 'RedHat' else 'auditd' }}"
    
    - name: Configure audit rules
      template:
        src: audit.rules.j2
        dest: /etc/audit/rules.d/audit.rules
        owner: root
        group: root
        mode: '0640'
      notify: restart auditd
```

## Compliance and Hardening

### CIS Benchmark Implementation
```yaml
---
- name: CIS Benchmark Hardening
  hosts: all
  become: yes
  
  tasks:
    # CIS 1.1.1.1 - Ensure mounting of cramfs filesystems is disabled
    - name: Disable cramfs filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install cramfs /bin/true"
        create: yes
    
    # CIS 1.1.1.2 - Ensure mounting of freevxfs filesystems is disabled
    - name: Disable freevxfs filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install freevxfs /bin/true"
    
    # CIS 1.1.1.3 - Ensure mounting of jffs2 filesystems is disabled
    - name: Disable jffs2 filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install jffs2 /bin/true"
    
    # CIS 1.1.1.4 - Ensure mounting of hfs filesystems is disabled
    - name: Disable hfs filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install hfs /bin/true"
    
    # CIS 1.1.1.5 - Ensure mounting of hfsplus filesystems is disabled
    - name: Disable hfsplus filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install hfsplus /bin/true"
    
    # CIS 1.1.1.6 - Ensure mounting of squashfs filesystems is disabled
    - name: Disable squashfs filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install squashfs /bin/true"
    
    # CIS 1.1.1.7 - Ensure mounting of udf filesystems is disabled
    - name: Disable udf filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install udf /bin/true"
    
    # CIS 1.1.1.8 - Ensure mounting of FAT filesystems is limited
    - name: Disable vfat filesystem
      lineinfile:
        path: /etc/modprobe.d/CIS.conf
        line: "install vfat /bin/true"
      when: disable_vfat | default(false)
    
    # CIS 1.4.1 - Ensure permissions on bootloader config are configured
    - name: Set bootloader permissions
      file:
        path: "{{ item }}"
        owner: root
        group: root
        mode: '0600'
      loop:
        - /boot/grub2/grub.cfg
        - /boot/grub/grub.cfg
      ignore_errors: yes
    
    # CIS 1.5.1 - Ensure core dumps are restricted
    - name: Configure core dump restrictions
      lineinfile:
        path: /etc/security/limits.conf
        line: "* hard core 0"
    
    - name: Disable core dumps in sysctl
      sysctl:
        name: fs.suid_dumpable
        value: '0'
        state: present
        reload: yes
```

### STIG (Security Technical Implementation Guide) Compliance
```yaml
---
- name: STIG Compliance Configuration
  hosts: all
  become: yes
  
  tasks:
    # RHEL-07-010010 - The Red Hat Enterprise Linux operating system must be configured so that the file permissions, ownership, and group membership of system files and commands match the vendor values
    - name: Verify system file permissions
      command: rpm -Va --nomtime --nosize --nomd5 --nolinkto
      register: rpm_verify
      changed_when: false
      failed_when: false
    
    # RHEL-07-010020 - The Red Hat Enterprise Linux operating system must be configured to use the shadow file to store only encrypted representations of passwords
    - name: Ensure shadow file is used for passwords
      lineinfile:
        path: /etc/login.defs
        regexp: '^ENCRYPT_METHOD'
        line: 'ENCRYPT_METHOD SHA512'
    
    # RHEL-07-010030 - The Red Hat Enterprise Linux operating system must be configured so that user and group account administration utilities are configured to store only encrypted representations of passwords
    - name: Configure libuser to use SHA512
      lineinfile:
        path: /etc/libuser.conf
        regexp: '^crypt_style'
        line: 'crypt_style = sha512'
        insertafter: '^\[defaults\]'
    
    # RHEL-07-010040 - The Red Hat Enterprise Linux operating system must be configured so that the SSH daemon does not allow authentication using an empty password
    - name: Disable empty password authentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitEmptyPasswords'
        line: 'PermitEmptyPasswords no'
      notify: restart sshd
    
    # RHEL-07-010050 - The Red Hat Enterprise Linux operating system must disable account identifiers (individuals, groups, roles, and devices) if the password expires
    - name: Configure inactive password lock
      lineinfile:
        path: /etc/default/useradd
        regexp: '^INACTIVE'
        line: 'INACTIVE=0'
```

## Security Monitoring and Logging

### Centralized Logging Configuration
```yaml
---
- name: Configure Security Logging
  hosts: all
  become: yes
  
  tasks:
    - name: Install rsyslog
      package:
        name: rsyslog
        state: present
    
    - name: Configure rsyslog for security events
      blockinfile:
        path: /etc/rsyslog.conf
        block: |
          # Security logging
          auth,authpriv.*                 /var/log/auth.log
          kern.*                          /var/log/kern.log
          daemon.*                        /var/log/daemon.log
          
          # Remote logging to SIEM
          *.* @@{{ siem_server }}:514
        marker: "# {mark} ANSIBLE MANAGED SECURITY LOGGING"
      notify: restart rsyslog
    
    - name: Configure log rotation
      template:
        src: security-logrotate.j2
        dest: /etc/logrotate.d/security
        owner: root
        group: root
        mode: '0644'
    
    - name: Install and configure osquery
      block:
        - name: Add osquery repository
          yum_repository:
            name: osquery-s3-rpm
            description: osquery S3 RPM repository
            baseurl: https://pkg.osquery.io/rpm/GPG
            gpgcheck: yes
            gpgkey: https://pkg.osquery.io/rpm/GPG
          when: ansible_os_family == "RedHat"
        
        - name: Install osquery
          package:
            name: osquery
            state: present
        
        - name: Configure osquery
          template:
            src: osquery.conf.j2
            dest: /etc/osquery/osquery.conf
            owner: root
            group: root
            mode: '0644'
          notify: restart osquery
        
        - name: Start and enable osquery
          service:
            name: osqueryd
            state: started
            enabled: yes
```

### Security Event Monitoring
```yaml
# Security monitoring playbook
---
- name: Security Event Monitoring
  hosts: all
  become: yes
  
  tasks:
    - name: Monitor failed login attempts
      lineinfile:
        path: /etc/rsyslog.d/50-security.conf
        line: ':msg,contains,"Failed password" /var/log/security/failed-logins.log'
        create: yes
      notify: restart rsyslog
    
    - name: Monitor sudo usage
      lineinfile:
        path: /etc/rsyslog.d/50-security.conf
        line: ':programname,isequal,"sudo" /var/log/security/sudo.log'
      notify: restart rsyslog
    
    - name: Monitor file integrity changes
      cron:
        name: "File integrity monitoring"
        minute: "*/15"
        job: "find /etc /bin /sbin /usr/bin /usr/sbin -type f -newer /var/log/last-integrity-check 2>/dev/null | tee /var/log/security/file-changes.log && touch /var/log/last-integrity-check"
        user: root
    
    - name: Create security monitoring script
      template:
        src: security-monitor.sh.j2
        dest: /usr/local/bin/security-monitor.sh
        owner: root
        group: root
        mode: '0755'
    
    - name: Schedule security monitoring
      cron:
        name: "Security monitoring"
        minute: "*/5"
        job: "/usr/local/bin/security-monitor.sh"
        user: root
```

## Incident Response and Recovery

### Automated Incident Response
```yaml
---
- name: Incident Response Automation
  hosts: all
  become: yes
  
  tasks:
    - name: Create incident response script
      template:
        src: incident-response.sh.j2
        dest: /usr/local/bin/incident-response.sh
        owner: root
        group: root
        mode: '0755'
    
    - name: Configure automated response triggers
      blockinfile:
        path: /etc/rsyslog.d/99-incident-response.conf
        block: |
          # Automated incident response
          :msg,contains,"POSSIBLE BREAK-IN ATTEMPT" ^/usr/local/bin/incident-response.sh
          :msg,contains,"Invalid user" ^/usr/local/bin/incident-response.sh
          :msg,contains,"authentication failure" ^/usr/local/bin/incident-response.sh
        create: yes
      notify: restart rsyslog
    
    - name: Create forensic data collection script
      template:
        src: collect-forensics.sh.j2
        dest: /usr/local/bin/collect-forensics.sh
        owner: root
        group: root
        mode: '0755'
    
    - name: Configure emergency lockdown procedure
      template:
        src: emergency-lockdown.sh.j2
        dest: /usr/local/bin/emergency-lockdown.sh
        owner: root
        group: root
        mode: '0755'
```

### Backup and Recovery Security
```yaml
---
- name: Secure Backup Configuration
  hosts: all
  become: yes
  
  tasks:
    - name: Create encrypted backup script
      template:
        src: secure-backup.sh.j2
        dest: /usr/local/bin/secure-backup.sh
        owner: root
        group: root
        mode: '0700'
    
    - name: Configure backup encryption keys
      copy:
        content: "{{ vault_backup_encryption_key }}"
        dest: /etc/backup/encryption.key
        owner: root
        group: root
        mode: '0600'
    
    - name: Schedule encrypted backups
      cron:
        name: "Secure system backup"
        minute: "0"
        hour: "3"
        job: "/usr/local/bin/secure-backup.sh"
        user: root
    
    - name: Test backup integrity
      cron:
        name: "Backup integrity check"
        minute: "0"
        hour: "4"
        weekday: "0"
        job: "/usr/local/bin/test-backup-integrity.sh"
        user: root
```

## Security Testing and Validation

### Automated Security Testing
```yaml
---
- name: Security Testing and Validation
  hosts: all
  become: yes
  
  tasks:
    - name: Install security testing tools
      package:
        name: "{{ item }}"
        state: present
      loop:
        - nmap
        - lynis
        - chkrootkit
        - rkhunter
    
    - name: Run Lynis security audit
      command: lynis audit system --quick
      register: lynis_result
      changed_when: false
    
    - name: Save Lynis results
      copy:
        content: "{{ lynis_result.stdout }}"
        dest: "/var/log/security/lynis-{{ ansible_date_time.date }}.log"
        owner: root
        group: root
        mode: '0600'
    
    - name: Run rootkit check
      command: rkhunter --check --skip-keypress --report-warnings-only
      register: rkhunter_result
      changed_when: false
      failed_when: false
    
    - name: Save rootkit check results
      copy:
        content: "{{ rkhunter_result.stdout }}"
        dest: "/var/log/security/rkhunter-{{ ansible_date_time.date }}.log"
        owner: root
        group: root
        mode: '0600'
    
    - name: Perform network security scan
      command: nmap -sS -O localhost
      register: nmap_result
      changed_when: false
      delegate_to: localhost
    
    - name: Validate security configurations
      assert:
        that:
          - ansible_selinux.status == "enabled" or ansible_os_family != "RedHat"
          - ansible_ssh_host_key_rsa_public is defined
        fail_msg: "Security validation failed"
        success_msg: "Security validation passed"
```

This comprehensive security guide provides enterprise-grade security practices for Ansible automation environments.