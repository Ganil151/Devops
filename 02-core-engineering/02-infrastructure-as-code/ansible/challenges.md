# 🧪 Principal Ansible Challenge: "The Custom Module"

> **Scenario**: Your team uses a legacy internal API called "MegaCorpDB" to store server metadata. There is no existing Ansible module for it. Developers are currently using `shell: curl ...` which is not idempotent and fails silently.
> **The Mission**: Write a custom Ansible Module in Python (`library/megacorp_db.py`) that interacts with this API idempotently.

---

## 🏗️ The Requirement

Your module must support the following playbook syntax:

```yaml
- name: Ensure server is registered in MegaCorpDB
  megacorp_db:
    server_name: "web-01"
    status: "active"
    region: "us-east-1"
    state: present
  register: db_result
```

It must return:
- `changed: true` only if the record was created or updated.
- `changed: false` if the record already matched the desired state.

---

## 🛠️ The Python Skeleton (`library/megacorp_db.py`)

You need to fill in the logic using `AnsibleModule`.

```python
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import requests

def run_module():
    module_args = dict(
        server_name=dict(type='str', required=True),
        status=dict(type='str', required=True),
        region=dict(type='str', required=True),
        state=dict(type='str', default='present', choices=['present', 'absent'])
    )

    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # -------------------------------------------------------
    # YOUR CODE GOES HERE
    # 1. Check if record exists (requests.get)
    # 2. Compare current state vs desired state
    # 3. If check_mode, return 'changed=True' without doing it
    # 4. If different, update (requests.post/put)
    # -------------------------------------------------------

    module.exit_json(**result)

if __name__ == '__main__':
    run_module()
```

---

## 🚨 Principal Architect Insights

- **Idempotency is King**: Does running the playbook twice result in zero changes the second time? If not, you failed.
- **Check Mode**: Does running with `--check` tell me what *would* happen without actually breaking production?
- **Error Handling**: What happens if the API returns a 500 or timeout? Your module should fail gracefully with `module.fail_json()`.

---
**Status**: 🧪 Challenge Active
