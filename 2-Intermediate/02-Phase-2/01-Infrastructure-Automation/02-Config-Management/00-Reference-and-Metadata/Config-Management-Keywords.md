# 📟 Config Management: The Ansible Engine Room

> **"A shell script runs commands. Ansible declares a desired state. If you don't understand Idempotency, you're just writing slow shell scripts in YAML."**

This reference covers the keywords and patterns for **Ansible** and server configuration.

---

## 🏗️ 1. The Core Architecture

| Term | Definition | Staff Engineer Nuance |
| :--- | :--- | :--- |
| **Control Node** | Where Ansible runs. | In Prod, this is the CI Runner, not your laptop. |
| **Managed Node** | The target server. | Requires Python installed. No agent needed. |
| **Inventory** | List of hosts. | Use **Dynamic Inventory** (AWS plugin), not static `hosts.ini`. |
| **Playbook** | YAML list of Plays. | Should dictate *What*, not *How*. |

---

## ⚡ 2. Idempotency Keywords

The goal: Running the script 100 times produces the same result as running it once.

| Keyword | Meaning | Example |
| :--- | :--- | :--- |
| `state=present` | Ensure it exists. | `apt: name=nginx state=present` |
| `state=absent` | Ensure it is gone. | `user: name=deployed state=absent` |
| `creates` | Skip if file exists. | `command: make build creates=/bin/app` |
| `register` | Capture output. | `command: whoami register=output` |
| `changed_when` | Define change logic. | `command: cleanup.sh changed_when: "'Deleted' in out.stdout"` |

**Staff Pattern (Safe Shell Execution)**:
```yaml
- name: Run migration script only if needed
  command: /opt/db/migrate.sh
  register: migration_result
  # Only mark 'Changed' if the script actually did work
  changed_when: "'Migrated' in migration_result.stdout"
  # Don't fail if it simply says 'Already Up to Date'
  failed_when: 
    - migration_result.rc != 0
    - "'Error' in migration_result.stderr"
```

---

## 🎭 3. Roles & Reusability

Stop writing giant playbooks. Use Roles.

### Directory Structure
```text
roles/
  webserver/
    tasks/main.yml    # Logic
    handlers/main.yml # Restart logic
    templates/        # Jinja2 files
    vars/             # Variables
```

### Handlers (The "On Change" Hook)
Only restart Nginx IF the config file changed.
```yaml
# tasks/main.yml
- name: Update Config
  template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf
  notify: Restart Nginx

# handlers/main.yml
- name: Restart Nginx
  service: name=nginx state=restarted
```

---

## 🔍 4. Jinja2 Templating

Dynamic Config Files.

| Syntax | Action | Example |
| :--- | :--- | :--- |
| `{{ var }}` | Print variable. | `Listen {{ http_port }}` |
| `{% if %}` | Conditional. | `{% if ssl_enabled %} ssl on; {% endif %}` |
| `{% for %}` | Loop. | `{% for ip in allowed_ips %} allow {{ ip }}; {% endfor %}` |

**Staff Pattern (Looping Configs)**:
```jinja2
# nginx.conf.j2
upstream backend {
{% for host in groups['app_servers'] %}
    server {{ hostvars[host]['ansible_eth0']['ipv4']['address'] }}:8080;
{% endfor %}
}
```

---

## 🧩 5. Variables & Facts

### Variable Precedence (Lowest to Highest)
1. `defaults/main.yml` (Role defaults)
2. `group_vars/all.yml`
3. `group_vars/webservers.yml`
4. `host_vars/server1.yml`
5. `vars/main.yml` (Role vars)
6. `--extra-vars` (CLI override)

**Staff Pattern (Environment Overrides)**:
```yaml
# group_vars/all.yml
http_port: 8080
ssl_enabled: false

# group_vars/production.yml
http_port: 443
ssl_enabled: true
```

### Facts (Auto-Discovered Variables)
Ansible collects system info automatically.

| Fact | Example Value | Use Case |
| :--- | :--- | :--- |
| `ansible_hostname` | `web-01` | Dynamic inventory naming. |
| `ansible_distribution` | `Ubuntu` | OS-specific package logic. |
| `ansible_default_ipv4.address` | `10.0.1.5` | Load balancer config. |
| `ansible_memtotal_mb` | `16384` | Tuning app memory limits. |

**Staff Pattern (OS-Agnostic Playbooks)**:
```yaml
- name: Install Web Server
  package:
    name: "{{ 'httpd' if ansible_os_family == 'RedHat' else 'apache2' }}"
    state: present
```

---

## 🔀 6. Conditionals & Loops

### When Clause
```yaml
- name: Install Docker (Only on Ubuntu)
  apt: name=docker.io state=present
  when: ansible_distribution == "Ubuntu"

- name: Restart if config changed
  service: name=nginx state=restarted
  when: config_result.changed
```

### Loops
```yaml
# Simple List
- name: Install packages
  apt: name={{ item }} state=present
  loop:
    - git
    - curl
    - vim

# Dictionary Loop (Better for Complex Data)
- name: Create users
  user:
    name: "{{ item.name }}"
    groups: "{{ item.groups }}"
  loop:
    - { name: 'alice', groups: 'sudo' }
    - { name: 'bob', groups: 'docker' }
```

**Staff Pattern (Multi-Region Deployment)**:
```yaml
- name: Deploy app to all regions
  ec2_instance:
    region: "{{ item.region }}"
    instance_type: "{{ item.size }}"
    image_id: "{{ item.ami }}"
  loop: "{{ deployment_regions }}"
  # deployment_regions defined in vars:
  # - { region: 'us-east-1', size: 't3.medium', ami: 'ami-123' }
  # - { region: 'eu-west-1', size: 't3.small', ami: 'ami-456' }
```

---

## 🔐 7. Vault & Secrets Management

Never commit passwords to Git. Use **Ansible Vault**.

### Encrypt a File
```bash
ansible-vault encrypt secrets.yml
# Enter password
```

### Run Playbook with Vault
```bash
ansible-playbook site.yml --ask-vault-pass
# Or use password file:
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

### Inline Encrypted Variables
```yaml
# vars/secrets.yml (encrypted)
db_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  66386439653...
```

**Staff Pattern (CI/CD Integration)**:
```yaml
# In GitLab CI:
script:
  - echo "$VAULT_PASSWORD" > .vault_pass
  - ansible-playbook deploy.yml --vault-password-file .vault_pass
  - rm .vault_pass
```

---

## ⚙️ 8. Best Practices & Anti-Patterns

### ✅ Do This
| Practice | Why |
| :--- | :--- |
| Use **Roles** for reusability. | Avoid copy-paste across playbooks. |
| Use **Dynamic Inventory** (AWS plugin). | Never hardcode IPs. |
| Use `check_mode` for dry-runs. | `ansible-playbook --check` |
| Tag tasks for selective runs. | `ansible-playbook --tags "deploy"` |
| Use `delegate_to: localhost` for API calls. | Don't SSH to run `aws` CLI. |

### ❌ Avoid This
| Anti-Pattern | Why It's Bad | Fix |
| :--- | :--- | :--- |
| `command: rm -rf /data/*` | Not idempotent. | Use `file: state=absent`. |
| Hardcoded passwords in playbooks. | Security risk. | Use Ansible Vault. |
| One giant `site.yml` file. | Unmaintainable. | Split into roles. |
| `ignore_errors: yes` everywhere. | Masks real failures. | Use `failed_when` logic. |

**Staff Pattern (Safe Command Execution)**:
```yaml
# BAD: Always runs, not idempotent
- command: /opt/install.sh

# GOOD: Only runs if marker file doesn't exist
- command: /opt/install.sh
  args:
    creates: /opt/.installed
```

---

## 🎯 Quick Reference Card

```yaml
# Minimal Production Playbook
---
- name: Configure Web Servers
  hosts: webservers
  become: yes
  vars_files:
    - vars/secrets.yml  # Vault-encrypted
  
  roles:
    - common           # Base packages, users
    - nginx            # Web server config
    - monitoring       # Datadog agent
  
  tasks:
    - name: Deploy application
      git:
        repo: "{{ app_repo }}"
        dest: /var/www/app
        version: "{{ app_version }}"
      notify: Restart App
  
  handlers:
    - name: Restart App
      systemd:
        name: myapp
        state: restarted
```

---

[⬅️ Back to Reference Hub](./README.md)
