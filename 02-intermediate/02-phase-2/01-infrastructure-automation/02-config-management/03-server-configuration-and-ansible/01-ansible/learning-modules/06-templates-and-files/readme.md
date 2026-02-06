# Templates and Files

Copying static files is rarely enough. Configuration files (nginx.conf, postgresql.conf) need to be dynamic—adapting to the hostname, IP, and hardware of the target machine.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `nginx.conf.j2` (Complex Jinja2 with loops/conditions).
- **[CHALLENGES](./challenges.md)**: MOTD generation, Dynamic Host files.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **Jinja2** | The templating language used by Ansible (Python standard). |
| **Delimiters** | `{{ var }}` for printing, `{% if %}` for logic. |
| **Filters** | Modifiers like `{{ var | upper }}` or `{{ list | join(',') }}`. |
| **`template` module** | Used to process a `.j2` file and save it to the remote node. |

---

## 🏗️ Robust Templates

### 1. Default Values
Never let your template crash because a variable is missing.

```jinja2
# GOOD
listen_port = {{ port | default(80) }}
```

### 2. Looping over Inventory
Essential for Load Balancers.

```jinja2
upstream app {
{% for host in groups['webservers'] %}
    server {{ hostvars[host]['ansible_host'] }};
{% endfor %}
}
```

---

## 📖 Real-World Story: The "Staging vs Prod" disaster

**Problem**: A developer copied `db_config.php` from Staging to Prod manually.
**Crisis**: The Production website started writing data to the Staging Database.
**Solution**: Replaced the static file with a Jinja2 template:
```php
$db_host = "{{ db_endpoint }}";
```
**Result**: Ansible automatically injected the correct endpoint based on the `target_env` variable.

---

## ❓ Interview Questions

1.  **What is the difference between `copy` and `template`?**
    - *Answer*: `copy` is for static files (binary/text). `template` parses variable interpolation using Jinja2.
2.  **How do you comment in Jinja2?**
    - *Answer*: `{# This is a comment #}`. It won't appear in the final file.
3.  **Can you access variables from other hosts in a template?**
    - *Answer*: Yes, using the `hostvars` dictionary.

---

[Next: Ansible Roles](../07-ansible-roles/readme.md)

---
## 🧭 Additional Modules
- [01 Jinja2 Basics](01-jinja2-basics/readme.md)
- [02 Jinja2 Advanced Logic](02-jinja2-advanced-logic/readme.md)
- [03 Deployment Strategies](03-deployment-strategies/readme.md)
- [04 Safe Deploy Validation](04-safe-deploy-validation/readme.md)
