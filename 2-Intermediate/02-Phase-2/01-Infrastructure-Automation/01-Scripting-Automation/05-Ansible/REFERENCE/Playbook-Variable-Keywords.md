# 📟 Reference: Playbook & Variable Keywords

Playbooks are the instruction manuals for your infrastructure. Variables allow those manuals to be dynamic across different environments (Dev/Prod).

---

## 🏗️ Playbook Structure

### `plays`
*   **Definition**: The top-level mapping in a playbook that connects a group of hosts to a set of tasks.

### `pre_tasks` & `post_tasks`
*   **Definition**: Tasks that run before the main roles/tasks and after the handlers/tasks.
*   **DevOps Why**: Use `pre_tasks` to pull a server out of a load balancer and `post_tasks` to put it back after updates.

### `roles`
*   **Definition**: A way of breaking down playbooks into reusable components. A role follows a strict directory structure (`tasks/`, `vars/`, `templates/`, etc.).

---

## 🔢 Variables & Facts

### `hostvars`
*   **Definition**: A magic variable that allows you to access variables of *other* hosts in the inventory.
*   **DevOps Why**: Useful for templates where you need the IP address of a database server to configure a web server.

### `ansible_facts`
*   **Definition**: Data gathered automatically from the remote host at the start of a play (CPU, RAM, OS version).
*   **Keyword: `gather_facts`**: Can be set to `no` to speed up playbooks if you don't need system data.

### `register`
*   **Definition**: Captures the output of a task into a variable.
*   **DevOps Why**: Used to check if a command succeeded or to use the output in a following task.

---

## 🏗️ Variable Precedence (The hierarchy)
Ansible has a complex priority for variables. The "Staff Level" rule:
1.  **Extra Vars** (`-e`) always win.
2.  **Role Defaults** are the weakest.
3.  **Group Vars** are better than **Host Vars**.

---

## 🎙️ Staff Interview context
*   **"When should you use a 'Handler' instead of a regular Task?"**
    *   *Answer*: Use a handler for "cleanup" or "side-effect" actions like restarting a service. A handler only runs once at the end, even if notified multiple times, and only if a task actually changed the system state (avoiding unnecessary downtime).
*   **"Explain the benefit of ANSIBLE_FACTS for cross-platform automation."**
    *   *Answer*: Facts allow you to write one playbook that works on Ubuntu and RHEL by using `ansible_os_family` to decide whether to use `apt` or `yum`.
