# Ansible: Agentless Automation Excellence

Ansible is an open-source IT automation engine that automates cloud provisioning, configuration management, application deployment, and intra-service orchestration.

---

## 🏗️ 1. Architecture & Philosophies

Ansible is **Agentless**, meaning it uses SSH to connect to nodes. It is **Idempotent**, ensuring that running a playbook multiple times has the same effect as running it once.

## 🛠️ 2. Essential Ansible Commands

### 🏃 Ad-Hoc Commands
*When to use: Quick, one-off tasks without writing a full playbook.*

```bash
# Ping all hosts in the inventory
ansible all -m ping

# Check disk space on 'webservers' group
ansible webservers -a "df -h"

# Restart nginx on all managed nodes
ansible all -m service -a "name=nginx state=restarted" --become
```

### 📋 Playbook Management
*When to use: Executing complex, multi-task automation workflows.*

```bash
# Run a playbook
ansible-playbook site.yml

# Check for syntax errors
ansible-playbook site.yml --syntax-check

# Dry-run (Check what would change without actually changing it)
ansible-playbook site.yml --check

```bash
# Limit execution to a specific host or group
ansible-playbook site.yml --limit webservers
```

---

## 📚 3. Playbook Library (Real-World Examples)

### Example A: Web Server Hardening
*Objective: Ensure Nginx is installed, started, and the OS is up to date.*

```yaml
---
- name: Hardening Web Servers
  hosts: webservers
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Ensure Nginx is installed
      apt:
        name: nginx
        state: present

    - name: Ensure Nginx service is started
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Apply security config
      copy:
        src: files/nginx_security.conf
        dest: /etc/nginx/conf.d/security.conf
      notify: Reload Nginx

  handlers:
    - name: Reload Nginx
      service:
        name: nginx
        state: reloaded
```

### Example B: User Management
*Objective: Scale user creation across a cluster.*

```yaml
---
- name: Managed User Access
  hosts: all
  become: yes
  vars:
    new_users: ["devops_bob", "devops_alice"]
  tasks:
    - name: Create developer accounts
      user:
        name: "{{ item }}"
        state: present
        groups: sudo
        append: yes
      loop: "{{ new_users }}"
```

---

## 💡 Ansible Best Practices

- **Use Roles**: Don't put all tasks in one file. Break them into reusable roles (e.g., `common`, `webserver`, `database`).
- **Variables over Hardcoding**: Use `group_vars` and `host_vars` to make your playbooks flexible.
- **Ansible Vault for Secrets**: Never store passwords in YAML files. Use `ansible-vault` to encrypt them.
- **Name Every Task**: Documentation is built-in. Use descriptive `name:` fields for every task.
- **Check Mode First**: Always use `--check` before running a new or modified playbook on production.

---

## 🧠 Training & Assessment

### Knowledge Quiz

**1. What does it mean for an Ansible task to be "Idempotent"?**
- A) It runs faster every time
- B) It only makes changes if the system is not already in the desired state
- C) It deletes itself after running
- D) It requires a restart of the managed node

**2. Where does Ansible store the list of servers it manages?**
- A) In the `etcd` database
- B) In the `ansible.cfg` file
- C) In the **Inventory** file (e.g., `hosts.ini`)
- D) In the `playbook.yml`

**3. Which command is used to encrypt sensitive variables?**
- A) `ansible-encrypt`
- B) `ansible-secret`
- C) `ansible-vault`
- D) `ansible-lock`

---

### Real-World Troubleshooting Scenarios

#### Scenario 1: SSH Connectivity Failure
**Problem:** You run a playbook, but it fails with `UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh"}`.
**Investigation:**
1.  **Check Key:** Ensure your SSH private key is added to the agent (`ssh-add`).
2.  **Check Permissions:** Ensure the target server has your public key in `~/.ssh/authorized_keys`.
**Solution:** Test connectivity manually with `ssh user@ip`. If it works, check the `ansible_user` and `ansible_ssh_private_key_file` variables in your inventory.

#### Scenario 2: Handler Not Triggered
**Problem:** You update an Nginx config file, but the service doesn't restart.
**Investigation:**
1.  **Logic Check:** Handlers only run if the task that `notify`s them actually makes a **change**.
2.  **Observation:** If the task says `ok` (no change), the handler won't fire.
**Solution:** Ensure the task actually modified the file. If you need to force a restart regardless, use a regular task instead of a handler.

---

## ✅ Knowledge Check
- [ ] Install Ansible and set up a basic inventory
- [ ] Use Ad-hoc commands for quick system checks
- [ ] Write YAML playbooks with multiple tasks
- [ ] Create and use Roles for reusability
- [ ] Secure secrets with Ansible Vault

## 🔗 Next Steps
- **[Terraform Integration](../04-Terraform/)** - Use Ansible to configure what Terraform spawns.
- **[CI/CD Pipelines](../05-CI-CD/)** - Trigger Ansible runs from Jenkins or GitHub Actions.
- **[Enterprise Security Hardening](../../3-Advanced/04-Security/)** - Automate server compliance.

---
*Automation is the force multiplier of the DevOps engineer. Script once, deploy everywhere.*