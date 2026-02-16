# 🛡️ Reference: Ansible Core Keywords

Ansible is an agentless automation engine. Understanding these core components is essential for building idempotent and scalable configuration management.

---

## 🏗️ Orchestration Components

### `Idempotency`
*   **Definition**: The property of certain operations in mathematics and computer science whereby they can be applied multiple times without changing the result beyond the initial application.
*   **DevOps Why**: It ensures that running an Ansible playbook 10 times results in the same system state as running it once. It prevents "Configuration Drift."

### `Inventory`
*   **Definition**: A file (INI or YAML) or script that defines the hosts and groups of hosts upon which commands, modules, and playbooks operate.
*   **Standard**: Use YAML for complex inventories to allow nested groups and multi-line variables.

### `Modules`
*   **Definition**: The discrete units of work that Ansible executes. They are specialized Python scripts pushed to remote hosts.
*   **Key Fact**: Most modules are idempotent by design (e.g., `apt`, `yum`, `file`, `service`).

### `Tasks`
*   **Definition**: The smallest unit of execution in a playbook, which calls a specific module with arguments.

---

## 🎛️ Control keywords

### `become`
*   **Definition**: Allows the task to execute with advanced privileges (usually `sudo`).
*   **DevOps Why**: Essential for system-level changes (installing software, editing `/etc`) while connecting as a non-privileged user.

### `handlers`
*   **Definition**: Special tasks that only run when "notified" by another task.
*   **DevOps Why**: Used for actions that should only happen once at the end of a playbook, like restarting a service only if its config file changed.

### `tags`
*   **Definition**: Attributes assigned to tasks or playbooks to allow running specific parts of the automation.
*   **Pro Tip**: Use tags like `setup`, `config`, and `deploy` to give users fine-grained control over execution.

---

## 🎙️ Staff Interview context
*   **"What is the difference between 'declarative' and 'imperative' automation in Ansible?"**
    *   *Answer*: Ansible is **declarative**. You describe the *desired state* (e.g., "nginx should be started"), and Ansible figures out the commands to get there. Imperative (like a bash script) describes the *steps* (e.g., "run systemctl start nginx").
*   **"Why is 'agentless' an advantage for Ansible?"**
    *   *Answer*: It reduces overhead. There is no software to install or maintain on target nodes. It only requires SSH and Python on the remote host, making it easier to manage thousands of diverse servers.
