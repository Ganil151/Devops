# Core Modules

Ansible ships with thousands of modules. However, 90% of your work will use these "Core 10".

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `modules_cheatsheet.yml`.
- **[CHALLENGES](./CHALLENGES.md)**: User Creation, Static Site Deployment.

---

## 🔑 The "Core 10"

| Module | Purpose |
| :--- | :--- |
| **`file`** | Create dirs, chmod, chown, symlinks. |
| **`copy`** | Push local file -> Remote. |
| **`template`** | Push Jinja2 file -> Remote (Dynamic). |
| **`user`** | Manage Linux users/groups. |
| **`package`** | Generic wrapper for `apt`, `yum`, `dnf`. |
| **`service`** | Start/Stop/Restart services (systemd). |
| **`git`** | Clone repos. |
| **`get_url`** | `wget`/`curl` equivalent. |
| **`unarchive`** | `tar` / `unzip`. |
| **`command`** | Run raw commands (No shell variables). |

---

## 🏗️ Command vs Shell

Beginners always overuse `shell`.

```yaml
# BAD: Vulnerable to Injection, Not Idempotent
- shell: useradd {{ user }}

# GOOD: Safe, Idempotent, Handles existing users
- user:
    name: "{{ user }}"
```

Only use `shell` or `command` if no native module exists.

---

## 📖 Real-World Story: The "Chmod 777" Disaster

**Problem**: A script used `shell: chmod -R 777 /var/www` to fix permission errors.
**Crisis**: Hackers uploaded a shell script to the webroot and executed it.
**Solution**: Refactored to use the `file` module with exact modes (`0644` for files, `0755` for dirs) and proper ownership.
**Result**: Secure, functional web server.

---

## ❓ Interview Questions

1.  **Difference between `copy` and `template`?**
    - *Answer*: `copy` transfers files exactly as they are. `template` processes the file through the Jinja2 engine (replacing variables) before transfer.
2.  **Difference between `command` and `shell`?**
    - *Answer*: `command` is safer but doesn't support pipes (`|`) or redirects (`>`). `shell` runs through `/bin/sh` and supports all operators but implies risk.
3.  **What is the `package` module?**
    - *Answer*: It abstracts the package manager. It detects if the OS is Ubuntu (`apt`) or CentOS (`yum`) and calls the right tool.

---

[Next: Variables & Facts](../05-Variables-and-Facts/README.md)