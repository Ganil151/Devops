# 3. Inventory Variables

Attaching data to your hosts is where Ansible becomes a "Configuration Management" tool, not just a script runner.

## Directory Structure
**Best Practice**: Do NOT define variables in the inventory file itself. It gets messy. Use the `group_vars` and `host_vars` directories.

```text
.
├── inventory/
│   └── hosts.ini
├── group_vars/
│   ├── all.yml          # Global settings (NTP, DNS)
│   ├── webservers.yml   # Web specific (Nginx port)
│   └── dbservers.yml    # DB specific (Postgres version)
└── host_vars/
    └── web1.example.com.yml # Unique overrides
```

## Variable Precedence (The Short Version)
If the same variable `http_port` is defined in 3 places, which one wins?

1.  **Host Vars** (Most Specific) - Wins!
2.  **Playbook Vars**
<b>3. Group Vars</b>
<details>
<summary>Show Answer</summary>
Answer: Child Group
</details>

<b>4. Group Vars</b>
<details>
<summary>Show Answer</summary>
Answer: Parent Group
</details>

<b>5. Group Vars</b>
<details>
<summary>Show Answer</summary>
Answer: `all`) (Least Specific
</details>


## Real-Life Scenarios

### Scenario: "The Port Conflict"
**Problem**: We wanted to move `web1` to port 8080 required for a canary test, but the `webservers` group forced it to 80.
**Solution**: Created `host_vars/web1.yml` with `http_port: 8080`.
*   Result: `web1` got 8080. All other 99 servers kept 80.

## ❓ Interview Questions

1.  **Do `group_vars` need to be in the same directory as the inventory?**
    *   **Answer**: Yes, or in the directory relative to the playbook file. Ansible checks both.

2.  **What happens if I define a variable in `group_vars/all` and `group_vars/web`?**
    *   **Answer**: The `web` variable wins for any host in the `web` group.

## 🧠 Quiz

1.  **Which has higher priority?**
    *   [x] `host_vars`.
    *   [ ] `group_vars`.

2.  **Can variables be merged?**
    *   [x] Yes, if `hash_behaviour=merge` is set (rare), but usually they are replaced.
    *   [ ] No.