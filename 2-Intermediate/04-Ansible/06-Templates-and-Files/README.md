# Templates and Files (Jinja2)

Static files (`copy` module) are boring. Dynamic files (`template` module) are where Ansible shines.

## 1. How Templating Works

Ansible uses **Jinja2**, a Python templating engine.

```mermaid
graph LR
    Vars[Variables (Inventory/Playbook)] --> Engine[Jinja2 Engine]
    J2[Template File (.j2)] --> Engine
    Engine --> Config[Final Config File]
    Config --> Server[Remote Server]
```

*   **Variables**: `{{ my_variable }}`
*   **Logic**: `{% if ... %}`
*   **Comments**: `{# ... #}`

---

## 2. Jinja2 Syntax Guide

### Variables & Filters
Filters transform data.
*   `{{ server_name | upper }}` -> "WEB01"
*   `{{ my_port | default(80) }}` -> Uses 80 if `my_port` is undefined.
*   `{{ my_list | to_json }}` -> Converts list to JSON string.

### Conditionals (`{% if %}`)
```jinja2
# nginx.conf.j2
server {
    listen 80;
    {% if ssl_enabled %}
    listen 443 ssl;
    ssl_certificate {{ ssl_cert_path }};
    {% endif %}
}
```

### Loops (`{% for %}`)
```jinja2
# /etc/hosts.j2
127.0.0.1 localhost
{% for host in groups['all'] %}
{{ hostvars[host].ansible_default_ipv4.address }} {{ host }}
{% endfor %}
```

---

## 3. The `synchronize` Module

`copy` is slow for thousands of files. `synchronize` uses `rsync`.
*   **Use Case**: Deploying a static website (HTML/JS/CSS) or syncing a large backup directory.
*   **Requirement**: `rsync` must be installed on both Control Node and Remote Node.

```yaml
- name: Deploy Website
  synchronize:
    src: ./site-content/
    dest: /var/www/html/
    delete: yes  # Delete files on remote that are not in src
```

---

## 4. Real-Life Scenarios

### Scenario 1: "The Nginx Vhosts"
**Problem**: Hosting 50 websites on one server. 50 config files to manage? No.
**Solution**: One template `vhost.j2` and a list variable `sites`.
*   Playbook:
    ```yaml
    - name: Create Vhosts
      template:
        src: vhost.j2
        dest: "/etc/nginx/sites-enabled/{{ item.domain }}"
      loop: "{{ sites }}"
    ```
*   Result: Adding a site just means adding 2 lines to a variable file.

### Scenario 2: "The Secrets Filter"
**Problem**: Application crashes if the database password is empty.
**Solution**: Use the `mandatory` filter in the template.
*   `db_password = "{{ db_pass | mandatory }}"`
*   Ansible will fail explicitly with "Mandatory variable 'db_pass' not defined" before even trying to push the file.

### Scenario 3: "Bulk Upload"
**Problem**: Copying a 1GB `node_modules` folder took 30 minutes with `copy`.
**Solution**: Switched to `synchronize`.
*   Time reduced to 2 minutes. `rsync` is optimized for delta transfers and compression.

---

## 5. ❓ Interview Questions

1.  **What extension should templates use?**
    *   **Answer**: `.j2` (e.g., `nginx.conf.j2`). It helps editors highlight syntax correctly.

2.  **How do you access the loop index in Jinja2?**
    *   **Answer**: Using `loop.index` (1-based) or `loop.index0` (0-based) inside a `{% for %}` block.

3.  **Difference between `copy` and `template`?**
    *   **Answer**: `copy` transfers files as-is. `template` processes them through Jinja2 to substitute variables/logic.

4.  **How do you handle whitespace control in Jinja2?**
    *   **Answer**: Use `{%-` to strip whitespace before the block and `-%}` to strip after. Prevents empty lines in config files.

5.  **Can you use logic in a default variable?**
    *   **Answer**: Yes, but usually better to use `set_fact` or `defaults/main.yml`. `{{ var | default('val') }}` is the standard.

6.  **What is `ansible_managed`?**
    *   **Answer**: A string ("Ansible managed: ...") you can include in templates to warn users not to edit the file manually.
        `# {{ ansible_managed }}`

7.  **How do you comment out a block in Jinja2?**
    *   **Answer**: `{# This will not appear in the final file #}`.

8.  **Does `synchronize` use SSH?**
    *   **Answer**: Yes, it tunnels rsync over SSH by default.

9.  **Can you loop over a dictionary?**
    *   **Answer**: Yes. `{% for key, value in my_dict.items() %}`.

10. **How do you safely handle multiline strings?**
    *   **Answer**: Use the YAML pipe `|` operator for the variable, and it prints correctly in the template if formatted right.

---

## 6. 🧠 Knowledge Check (Quiz)

### Syntax
1.  **To print a variable:**
    *   [x] `{{ var }}`
    *   [ ] `{% var %}`

2.  **To start a loop:**
    *   [x] `{% for i in list %}`
    *   [ ] `{{ for i in list }}`

3.  **To strip whitespace:**
    *   [x] `{%- ... -%}`
    *   [ ] `strip()`

4.  **`default(5)` means:**
    *   [x] Use 5 if variable is undefined.
    *   [ ] Add 5 to the variable.

### Modules
5.  **`synchronize` wraps around:**
    *   [x] `rsync`.
    *   [ ] `scp`.

6.  **If a template changes:**
    *   [x] Ansible reports "Changed" (Yellow).
    *   [ ] Ansible reports "Failed".

7.  **`ansible_managed` helps with:**
    *   [x] Warning humans not to touch the file.
    *   [ ] Performance optimization.

8.  **Can you access `ansible_facts` in a template?**
    *   [x] Yes, they are variables like any other.
    *   [ ] No.

9.  **To force a failure if a var is missing:**
    *   [x] `| mandatory`
    *   [ ] `| required`

10. **`validate` parameter in `template` module:**
    *   [x] Runs a command (like `nginx -t`) to check config validity before replacing the file.
    *   [ ] Validates YAML syntax.

### Scenarios
11. **Best used for static binary files (images/PDFs):**
    *   [x] `copy`.
    *   [ ] `template`.

12. **Generating a `/etc/hosts` file requires:**
    *   [x] A loop over all hosts.
    *   [ ] A copy command.

13. **To uppercase a string:**
    *   [x] `| upper`
    *   [ ] `toUpperCase()`

14. **`synchronize` `delete: yes` means:**
    *   [x] It mirrors the directory exactly (removing extra files on remote).
    *   [ ] It deletes the source.

15. **Can you include one template inside another?**
    *   [x] Yes, `{% include 'header.j2' %}`.
    *   [ ] No.

### General
16. **Jinja2 is native to:**
    *   [x] Python.
    *   [ ] Ruby.

17. **Is logic allowed in templates?**
    *   [x] Yes (If/For), unlike simple substitution.
    *   [ ] No.

18. **The destination of a template is:**
    *   [x] The remote node.
    *   [ ] The control node.

19. **Can you lookup environment variables in a template?**
    *   [x] Yes, `{{ lookup('env', 'HOME') }}`.
    *   [ ] No.

20. **`to_nice_yaml` filter:**
    *   [x] Formats a variable as readable YAML.
    *   [ ] Encrypts it.