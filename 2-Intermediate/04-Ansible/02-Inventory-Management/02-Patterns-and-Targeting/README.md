# 2. Patterns and Targeting

Having 1000 hosts is useless if you can't target the *right* 10 hosts.

## The `--limit` Flag
The most common way to slice inventory.
```bash
ansible-playbook site.yml --limit webservers
ansible-playbook site.yml --limit web1,web2
ansible-playbook site.yml --limit @retry_hosts.txt
```

## Advanced Patterns

You can use set theory logic in the CLI.

| Pattern | Meaning | Example |
| :--- | :--- | :--- |
| `*` | All hosts | `ansible all -m ping` |
| `:` | OR (Union) | `ansible web:db -m ping` (Target web AND db) |
| `:&` | AND (Intersection) | `ansible web:&staging -m ping` (Target hosts that are in both) |
| `:!` | NOT (Exclusion) | `ansible web:!phoenix -m ping` (Target web, but NOT phoenix) |

## Regular Expressions
Start with `~` to use Regex.
*   `ansible "~web\d+\.example\.com" -m ping`
*   Targets `web1.example.com`, `web99.example.com`, etc.

## Real-Life Scenarios

### Scenario: "The Targeted Patch"
**Problem**: A security vulnerability affects only the "RedHat" servers in the "DMZ".
**Solution**: `ansible-playbook patch.yml --limit "redhat:&dmz"`.
*   Effect: Only patched the intersection of those two groups.

## ❓ Interview Questions

1.  **How do you target the first host in the `web` group?**
    *   **Answer**: `web[0]`.

2.  **What does `web:!db` mean?**
    *   **Answer**: All hosts in `web` EXCEPT those that are also in `db`.

## 🧠 Quiz

1.  **Which symbol represents logical AND (Intersection)?**
    *   [x] `:&`
    *   [ ] `:`

2.  **Can you use wildcards like `*.example.com`?**
    *   [x] Yes.
    *   [ ] No.
