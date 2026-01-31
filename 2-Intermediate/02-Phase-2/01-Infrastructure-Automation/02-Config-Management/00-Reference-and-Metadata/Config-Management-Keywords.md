# 📟 Reference: Config Management Keywords

Configuration Management (CM) is the act of defining the "Inside" state of a server. These keywords are fundamental to tools like Ansible, Chef, and Puppet.

---

## 🏗️ The CM Core Engine

### `Inventory`
*   **Definition**: The source of truth for "where" the automation runs. It can be static (files) or dynamic (API-based discovery).
*   **DevOps Why**: Allows you to group servers by role (web, db) or environment (dev, prod).

### `Idempotency`
*   **Definition**: The core promise of CM. If the server is already in the desired state, the tool does nothing.
*   **DevOps Why**: Ensures that "rerunning" a playbook is always safe and predictable.

### `Declarative` vs `Procedural`
*   **Declarative**: You define the *end state* ("nginx should be present"). Preferred for CM.
*   **Procedural**: You define the *steps* ("apt install nginx"). Common in basic shell scripting.

---

## 🎛️ Execution Logic

### `Handlers`
*   **Definition**: Delayed tasks that only trigger if another task reports a "Change."
*   **Example**: Restarting Nginx ONLY if the configuration file was modified.

### `Facts`
*   **Definition**: System metadata gathered from the host (IP, OS, RAM).
*   **DevOps Why**: Allows your automation to be "Intelligent" (e.g., "Install `apt` packages on Ubuntu and `yum` on CentOS").

### `Roles`
*   **Definition**: Reusable packages of automation. A role encapsulates tasks, templates, and variables into a modular directory structure.
*   **Staff Rule**: Never write a monolithic playbook. Always decompose into roles.

---

## 🎙️ Staff Interview Context

*   **"What is 'Bake' vs 'Fry' in server configuration?"**
    *   *Answer*: **Baking** (Packer) involves installing software into an image before deployment. **Frying** (Ansible/Cloud-init) happens at boot time. Staff engineers prefer baking for speed and consistency, using frying only for unique runtime configurations.
*   **"How do you ensure Ansible doesn't leak passwords in logs?"**
    *   *Answer*: Use the `no_log: true` parameter on sensitive tasks.
*   **"Explain the benefit of 'Agentless' (Ansible) vs 'Agent-based' (Chef) CM."**
    *   *Answer*: Agentless is easier to bootstrap (needs only SSH/Python) and has lower overhead. Agent-based is often faster at scale and provides continuous state enforcement even if the control node is offline.
