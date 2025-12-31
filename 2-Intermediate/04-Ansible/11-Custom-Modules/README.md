# Custom Modules

Sometimes Ansible's 3,000+ baked-in modules aren't enough. You need to talk to a custom internal API, a legacy legacy binary, or perform complex math.

## 1. When to write a Custom Module?

*   **Complex Logic**: If your playbook has 50 `shell` commands parsing text with `grep` and `awk`, replace it with Python.
*   **API Interaction**: If `uri` module gets too messy (handling auth tokens, pagination, complex JSON payloads).
*   **Performance**: If looping over 10,000 items in YAML is too slow (Python is instant).

---

## 2. Anatomy of a Module

Ansible modules are just scripts (usually Python) that:
1.  Read a JSON file (the arguments).
2.  Do work.
3.  Print a JSON object to stdout (the result).

```mermaid
graph LR
    Args[Arguments (YAML)] -->|JSON| Module[Python Script]
    Module -->|Logic| Action[API / System]
    Action -->|Result| Module
    Module -->|JSON| Ansible[Ansible Engine]
```

### Basic Template (`library/my_module.py`)
```python
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule

def run_module():
    # 1. Define Arguments
    module_args = dict(
        name=dict(type='str', required=True),
        state=dict(type='str', default='present', choices=['present', 'absent'])
    )

    # 2. Init Module
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # 3. Logic
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
```

---

## 3. Real-Life Scenarios

### Scenario 1: "The Legacy CRM"
**Problem**: The company used a CRM from 1998. Adding a user required running a complex binary `/opt/crm/bin/adduser -f First -l Last -r Role -x`.
**Solution**: Wrote a module `crm_user`.
*   Playbook: `crm_user: name=bob role=admin`.
*   The Python script builds the CLI command safely and handles exit codes.

### Scenario 2: "Complex Calculation"
**Problem**: Configuration required calculating a "shard ID" based on the hostname hash modulo the number of active nodes in a cluster. Doing this in Jinja2 was a nightmare.
**Solution**: Custom module `calculate_shard`.
*   Logic: `import hashlib; ...`
*   Result: `shard_id: 5`.

### Scenario 3: "Internal API"
**Problem**: The internal Cloud Platform had an API. Using `uri` meant exposing tokens in logs and rewriting auth logic in every task.
**Solution**: `internal_cloud_vm`:
*   Encapsulated all authentication and error handling in Python.
*   Playbook became clean: `internal_cloud_vm: name=web1 state=present`.

---

## 4. ❓ Interview Questions

1.  **What language are Ansible modules written in?**
    *   **Answer**: Any language that can speak JSON (Ruby, Go, Bash), but **Python** is the standard and provides helper libraries (`AnsibleModule`).

2.  **Where do you store custom modules?**
    *   **Answer**: In the `library/` directory relative to your playbook, or in `~/.ansible/plugins/modules`.

3.  **What is `supports_check_mode=True`?**
    *   **Answer**: It tells Ansible that your module knows how to "dry run" (check if changes *would* occur without actually making them).

4.  **How does a module return data?**
    *   **Answer**: By printing a JSON object to Standard Output (stdout). The helper `module.exit_json()` does this for you.

5.  **What happens if `module.fail_json()` is called?**
    *   **Answer**: Ansible marks the task as **Failed** (Red) and stops execution.

6.  **Can custom modules use PyPI libraries?**
    *   **Answer**: Yes, but those libraries must be installed on the **Remote** node (where the module runs), not just the Control node.

7.  **How do you debug a custom module?**
    *   **Answer**: You can run it manually with `python my_module.py args.json` or use `module.fail_json(msg="Debug info")` to print data during a run.

8.  **What is `argument_spec`?**
    *   **Answer**: A dictionary defining what parameters the module accepts, their types (str, int, bool), defaults, and required status.

9.  **Why use `AnsibleModule` helper class?**
    *   **Answer**: It handles parsing input, formatting output, argument validation, and basic error handling automatically.

10. **Is it better to write a module or a plugin?**
    *   **Answer**: Modules do work on remote hosts (install package). Plugins run on the control node (filters, inventory, callbacks).

---

## 5. 🧠 Knowledge Check (Quiz)

### Concepts
1.  **Ansible communicates with modules via:**
    *   [x] JSON over SSH.
    *   [ ] Binary protocol.

2.  **Custom modules usually live in:**
    *   [x] `./library`.
    *   [ ] `./modules`.

3.  **To indicate a change happened:**
    *   [x] Return `changed: true` in the JSON.
    *   [ ] Exit with code 1.

4.  **Check Mode (`--check`) allows:**
    *   [x] Predicting changes without applying them.
    *   [ ] Validating syntax only.

### Python Development
5.  **The base class for modules is:**
    *   [x] `AnsibleModule`.
    *   [ ] `BaseModule`.

6.  **To exit successfully:**
    *   [x] `module.exit_json()`.
    *   [ ] `sys.exit(0)`.

7.  **To exit with failure:**
    *   [x] `module.fail_json()`.
    *   [ ] `sys.exit(1)`.

8.  **Argument types include:**
    *   [x] `str`, `int`, `bool`, `list`, `dict`.
    *   [ ] Only `str`.

9.  **If a required argument is missing:**
    *   [x] `AnsibleModule` automatically fails with a helpful error.
    *   [ ] The script crashes.

10. **Where does the code run?**
    *   [x] On the **Remote** managed node.
    *   [ ] On the Control node.

### Scenarios
11. **When should you write a module?**
    *   [x] When standard modules don't exist and `shell` is too messy.
    *   [ ] For every task.

12. **If your module needs `requests` library:**
    *   [x] Use the `pip` module to install it on remotes first.
    *   [ ] It's automatically there.

13. **To return extra data (like an ID):**
    *   [x] Add it to the dictionary passed to `exit_json`.
    *   [ ] Print it to stderr.

14. **Idempotency in custom modules:**
    *   [x] You must implement logic to check current state vs desired state.
    *   [ ] It's automatic.

15. **Can bash be used for modules?**
    *   [x] Yes (technically), but it's harder to parse JSON.
    *   [ ] No.

### General
16. **`ansible-doc -M library my_module`:**
    *   [x] Shows documentation for your custom module (if you wrote the docstring).
    *   [ ] Runs the module.

17. **Can you contribute modules to Ansible Core?**
    *   [x] Yes, via Collections in Ansible Galaxy.
    *   [ ] No, it's closed source.

18. **`no_log=True` in argument spec:**
    *   [x] Hides the value from logs (for passwords).
    *   [ ] Disables logging.

19. **What is `DOCUMENTATION` string in the python file?**
    *   [x] YAML metadata used to generate help/docs.
    *   [ ] Comments.

20. **Can a module call another module?**
    *   [x] No, modules are standalone scripts.
    *   [ ] Yes.