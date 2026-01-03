# 1. The Control Node

The **Control Node** is the brain of Ansible. It is the machine where you run the `ansible-playbook` command.

## Architecture

Ansible is unique because it is **Agentless**. You do not install software on the servers you manage. You only install Ansible on the Control Node.

```mermaid
graph TD
    User((System Admin)) -->|Runs CLI| Control[Control Node (Laptop / Jenkins)]

subgraph "Managed Infrastructure"
    Web1[Web Server]
    DB1[Database]
    Switch[Cisco Switch]
    end

Control -->|SSH| Web1
    Control -->|SSH| DB1
    Control -->|HTTPS/API| Switch

style Control fill:#ee0000,color:#fff
```

## Requirements

The Control Node **MUST** be a POSIX-compliant system (Linux, macOS, BSD).
*   **Windows**: Ansible cannot run natively on Windows. You must use **WSL (Windows Subsystem for Linux)**.
*   **Python**: Requires Python 3.8+.

## Configuration (`ansible.cfg`)

Ansible's behavior is controlled by `ansible.cfg`. It searches in this specific order:
<b>1. `ANSIBLE_CONFIG`</b>
<details>
<summary>Show Answer</summary>
Answer: Environment Variable
</details>

<b>2. `./ansible.cfg`</b>
<details>
<summary>Show Answer</summary>
Answer: Current directory - **Industry Standard**
</details>

<b>3. `~/.ansible.cfg`</b>
<details>
<summary>Show Answer</summary>
Answer: User home
</details>

<b>4. `/etc/ansible/ansible.cfg`</b>
<details>
<summary>Show Answer</summary>
Answer: Global default
</details>


### Key Parameters
```ini
[defaults]
inventory = ./inventory
remote_user = devops
host_key_checking = False  # Don't ask "Are you sure?" for every new server
forks = 10                 # Parallelism level (default is 5)
```

## Scalability (Forks)
By default, Ansible talks to 5 hosts at a time (`forks=5`).
If you have 100 servers, it will take 20 batches to finish.
*   **Scanning**: Increasing forks to `50` or `100` significantly speeds up large deployments.
*   **Limit**: Depends on CPU/RAM of the Control Node.

## Real-Life Scenarios

### Scenario 1: "The Windows Admin"
**Problem**: An admin strictly used a Windows 11 laptop. He tried `pip install ansible` in PowerShell and it failed.
**Solution**: Installed WSL2 (Ubuntu 22.04).
*   He now runs Ansible inside the Linux subsystem, managing both Linux and Windows servers seamlessly.

### Scenario 2: "The Bottleneck"
**Problem**: Deploying a simple patch to 500 servers took 45 minutes.
**Investigation**: `forks` was set to default (5). 500 / 5 = 100 batches.
**Solution**: Increased `forks = 50` in `ansible.cfg`.
*   Result: Deployment time dropped to 5 minutes.

## ❓ Interview Questions

1.  **Can I run Ansible from Windows?**
    *   **Answer**: Not natively. You must use WSL, a Linux VM, or a Docker container. Managed nodes *can* be Windows, but the Control Node must be Linux.

2.  **What happens if I don't have an `ansible.cfg`?**
    *   **Answer**: Ansible uses the default settings (checking `/etc/ansible/ansible.cfg` or internal defaults).

3.  **What is the "Forks" parameter?**
    *   **Answer**: It determines the maximum number of hosts Ansible will connect to in parallel. Higher = Faster, but consumes more CPU on the control node.

## 🧠 Quiz

1.  **Which OS allows native Ansible installation?**
    *   [x] MacOS.
    *   [ ] Windows 10.

2.  **The highest priority config location is:**
    *   [x] `ANSIBLE_CONFIG` env var.
    *   [ ] `/etc/ansible/ansible.cfg`.

3.  **If `forks=5` and you target 10 servers, Ansible runs:**
    *   [x] 2 batches of 5.
    *   [ ] All 10 at once.