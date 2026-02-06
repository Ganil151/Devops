# Ansible Interview Prep

Ansible is the king of configuration management. You should know Roles, Inventory, and Handlers.

## 🎤 Top 10 Questions

1.  **What is an Ansible Role?**
    - *Answer*: A standardized directory structure for grouping tasks, variables, and files into a reusable unit.
2.  **Explain the difference between `site.yml` and `inventory`.**
    - *Answer*: `site.yml` (Playbook) defines *what* happens. `inventory` defines *where* it happens.
3.  **What are Ansible Handlers and when do they run?**
    - *Answer*: Tasks that run ONLY if notified by another task. They run at the very end of the Play.
4.  **What is Idempotency in Ansible?**
    - *Answer*: The ability to run a playbook multiple times safely. The module checks the current state before applying changes.
5.  **How do you handle secrets in Ansible?**
    - *Answer*: Using **Ansible Vault**.
6.  **What is the difference between `command` and `shell` modules?**
    - *Answer*: `command` is safer but doesn't support pipes or environment variables. `shell` is powerful but riskier.
7.  **How do you gather specific information about a server?**
    - *Answer*: Via **Facts** (`ansible_facts`).
8.  **What is `any_errors_fatal`?**
    - *Answer*: A setting that stops the whole playbook on all hosts if a single host fails.
9.  **How do you target only a specific group of servers?**
    - *Answer*: Via the `hosts:` parameter or the `--limit` flag.
10. **What is an Ansible 'Ad-hoc' command?**
    - *Answer*: A one-liner used for quick tasks without writing a playbook (e.g., `ansible all -m ping`).

---

## 🛠️ Performance Task
**Task**: Build a Role that installs Nginx, configures a basic site using a Jinja2 template, and ensures the service is running.

[Check challenges for more tasks.](./challenges.md)
