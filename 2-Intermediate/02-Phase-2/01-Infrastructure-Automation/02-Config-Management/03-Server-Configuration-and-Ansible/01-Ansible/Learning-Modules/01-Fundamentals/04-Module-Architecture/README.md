# 4. Module Architecture

Modules are the **Tools** in Ansible's toolbox. While Playbooks are the instruction manual, Modules do the actual hammering.

## The Lifecycle of a Module

When you run `ansible web -m copy ...`, what actually happens?

1.  **Generation**: Ansible reads your inputs (src, dest) and bundles them with the python module code into a single file.
2.  **Transport**: This file is copied to the remote node (usually to `~/.ansible/tmp/`).
3.  **Execution**: Ansible runs `python /tmp/.../ansible_module_copy.py`.
4.  **Output**: The script prints a JSON document to STDOUT and exits.
5.  **Cleanup**: Ansible deletes the temp file.

```mermaid
graph TD
    CLI[Control: CLI] -->|Arguments| Bundler[Bundler]
    Module[Code: copy.py] --> Bundler
    Bundler -->|Payload (Zip)| Remote[Remote Node]
    Remote -->|Executes| Python[Python Interpreter]
    Python -->|Returns JSON| Control
```

## The "Ansible Module Protocol"
Any script can be a module if it speaks JSON.
*   **Input**: Arguments provided possibly via a file or arguments.
*   **Output**: Must print valid JSON.
    *   `{"changed": true, "msg": "Copied file"}`

## Real-Life Scenarios

### Scenario 1: "The Custom Binary"
**Problem**: A legacy app needed a specific C++ binary to trigger a reload.
**Solution**: Wrote a simple bash script that outputs JSON.
*   `echo '{"changed": true}'`
*   Ansible treated it just like a native module.

### Scenario 2: "The Python Version Clash"
**Problem**: The remote server had Python 2.4 (Ancient). Ansible failed.
**Solution**: Ansible modules require Python 2.7+ or 3.5+.
*   Installed Python 3 side-by-side and set `ansible_python_interpreter=/usr/bin/python3`.

## ❓ Interview Questions

1.  **Do modules stay on the remote server?**
    *   **Answer**: No. They are transient. They exist only for the milliseconds connected to execution.

2.  **What is the return format of a module?**
    *   **Answer**: JSON.

3.  **Can I write modules in Bash?**
    *   **Answer**: Yes, but Python is preferred because Ansible provides helper libraries (`AnsibleModule`) to handle JSON parsing and error handling robustly.

## 🧠 Quiz

1.  **Where does the module code execute?**
    *   [x] On the Remote Node.
    *   [ ] On the Control Node.

2.  **Ansible modules are:**
    *   [x] Stateless (idempotent).
    *   [ ] Stateful.

3.  **Does the remote node need to have Ansible installed?**
    *   [x] No.
    *   [ ] Yes.