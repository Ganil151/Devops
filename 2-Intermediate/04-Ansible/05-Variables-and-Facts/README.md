# Variables and Facts

Automation needs data. "Install Apache" is easy. "Install Apache version X on Port Y with Admin Email Z" requires Variables.

## 1. Where do Variables come from?

Ansible variables can be defined in 20+ places. Here are the most common, in order of precedence (Winner takes all).

```mermaid
graph BT
    Defaults[Role Defaults (Weakest)] --> Group[Group Vars]
    Group --> Host[Host Vars]
    Host --> Play[Play Vars]
    Play --> Extra[Extra Vars CLI (Strongest)]
    
    style Extra fill:#ee0000,color:#fff
```

1.  **Defaults**: `roles/apache/defaults/main.yml`.
2.  **Inventory**: `group_vars/web.yml`.
3.  **Playbook**: `vars:` section in the yaml file.
4.  **Extra Vars**: `ansible-playbook -e "version=1.2"`.

---

## 2. Ansible Facts

"Facts" are variables Ansible *discovers* about the remote system automatically.

*   **Prefix**: `ansible_*`
*   **Examples**:
    *   `ansible_os_family`: "Debian", "RedHat", "Windows".
    *   `ansible_default_ipv4.address`: "192.168.1.50".
    *   `ansible_memtotal_mb`: "8192".
    *   `ansible_processor_vcpus`: "4".

**Usage**:
```yaml
- name: Install Apache (Conditional)
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"
```

---

## 3. Magic Variables

Variables Ansible creates for you to inspect the state of the automation itself.

| Variable | Description |
| :--- | :--- |
| `hostvars` | Access variables of *other* hosts. `{{ hostvars['db1'].ansible_eth0.ipv4.address }}` |
| `groups` | List of all groups and their members. |
| `group_names` | List of groups the *current* host belongs to. |
| `inventory_hostname` | The name of the host as spelled in the inventory file. |

---

## 4. Real-Life Scenarios

### Scenario 1: "The OS Conditional"
**Problem**: You have a mixed fleet of Ubuntu and CentOS servers.
**Old Way**: Two separate playbooks. `install_ubuntu.yml` and `install_centos.yml`.
**Solution**: One `site.yml`.
*   `vars_files: - "vars/{{ ansible_os_family }}.yml"`
*   If OS is Debian, it loads `vars/Debian.yml` (package name `apache2`).
*   If OS is RedHat, it loads `vars/RedHat.yml` (package name `httpd`).

### Scenario 2: "The Dynamic IP"
**Problem**: Configuring Nginx to listen on the private LAN IP, which is different for every server.
**Solution**: `listen {{ ansible_default_ipv4.address }}:80;`.
*   Ansible resolves this variable individually for each host at runtime.

### Scenario 3: "The Override"
**Problem**: The playbook defaults to deploying `v1.0`. A developer needs to urgently test `v1.1-beta`.
**Solution**: Don't edit the YAML. Just run:
*   `ansible-playbook deploy.yml -e "app_version=v1.1-beta"`.
*   Extra Vars always win.

---

## 5. ❓ Interview Questions

1.  **What is the difference between a Variable and a Fact?**
    *   **Answer**: A Variable is data *you* define (port: 80). A Fact is data Ansible *discovers* from the system (OS: Ubuntu).

2.  **How do you disable Fact Gathering?**
    *   **Answer**: Set `gather_facts: no` in the Playbook. This speeds up execution if you don't need system info.

3.  **What is `set_fact`?**
    *   **Answer**: A module that allows you to define a new variable (or override an existing one) dynamically during the playbook execution. `set_fact: my_var="value"`.

4.  **Can I access variables from Host A while configuring Host B?**
    *   **Answer**: Yes, using the `hostvars` magic variable dictionary. `hostvars['HostA']['variable_name']`.

5.  **What is Variable Precedence?**
    *   **Answer**: The order in which Ansible overrides variables. Command line (`-e`) is highest. Inventory (`group_vars`) is lower.

6.  **How do you encrypt sensitive variables?**
    *   **Answer**: Ansible Vault (`ansible-vault encrypt vars.yml`).

7.  **What is a "Registered" variable?**
    *   **Answer**: The output of a task saved into a variable for later use.
        ```yaml
        - shell: cat /etc/password
          register: password_file
        ```

8.  **How do you check if a variable is defined?**
    *   **Answer**: `when: my_var is defined`.

9.  **Scope of variables?**
    *   **Answer**: Global, Play, Host. Facts are Host-scoped.

10. **Can you cache facts?**
    *   **Answer**: Yes (Redis, Memcached, JSON file). Useful for large environments to avoid re-scanning 1000 servers every run.

---

## 6. 🧠 Knowledge Check (Quiz)

### Concepts
1.  **Which variable source has the highest priority?**
    *   [x] Extra Vars (`-e`).
    *   [ ] Playbook Vars.

2.  **Facts are gathered by the module:**
    *   [x] `setup` (automatically run).
    *   [ ] `facts`.

3.  **To see all facts for a host:**
    *   [x] `ansible hostname -m setup`.
    *   [ ] `ansible hostname -m facts`.

4.  **Which fact tells you the OS distribution?**
    *   [x] `ansible_distribution`.
    *   [ ] `ansible_os`.

### Usage
5.  **Syntax to use a variable in a template/playbook:**
    *   [x] `{{ variable_name }}`
    *   [ ] `$variable_name`

6.  **`set_fact` variables persist:**
    *   [x] For the duration of the playbook run.
    *   [ ] Forever on disk.

7.  **`hostvars` is used to:**
    *   [x] Access data from other hosts.
    *   [ ] Access environment variables.

8.  **If `gather_facts: no`, then `ansible_os_family` is:**
    *   [x] Undefined.
    *   [ ] Still available.

9.  **To define a default value if a variable is missing:**
    *   [x] `{{ my_var | default('fallback') }}`
    *   [ ] `{{ my_var | fallback }}`

10. **Registered variables contain:**
    *   [x] Stdout, Stderr, Return Code, and status.
    *   [ ] Just the text output.

### Scenarios
11. **Using `-e` is best for:**
    *   [x] One-off overrides (e.g., version numbers).
    *   [ ] Storing passwords.

12. **If you have `group_vars/all.yml` and `group_vars/web.yml`:**
    *   [x] `web.yml` overrides `all.yml`.
    *   [ ] `all.yml` overrides `web.yml`.

13. **Why use `ansible_os_family` instead of `ansible_distribution`?**
    *   [x] It groups generic distros (Debian=Ubuntu/Mint, RedHat=CentOS/Fedora/Rocky).
    *   [ ] It is shorter to type.

14. **Where should you store passwords?**
    *   [x] Encrypted in Vault.
    *   [ ] In `all.yml` plaintext.

15. **Can you use environment variables as Ansible variables?**
    *   [x] Yes, via lookup plugin `{{ lookup('env', 'HOME') }}`.
    *   [ ] No.

### General
16. **Is `ansible_ssh_host` a fact?**
    *   [x] No, it's a connection variable.
    *   [ ] Yes.

17. **Facts are collected locally or remotely?**
    *   [x] Remotely (on the managed node), then sent back.
    *   [ ] Locally on Control Node.

18. **The Jinja2 filter `to_json`:**
    *   [x] Converts a list/dict to JSON string.
    *   [ ] Parses JSON.

19. **Magic variable `group_names` returns:**
    *   [x] List of groups the current host is in.
    *   [ ] List of all groups.

20. **Can you disable facts for just one play?**
    *   [x] Yes.
    *   [ ] No, it's global.