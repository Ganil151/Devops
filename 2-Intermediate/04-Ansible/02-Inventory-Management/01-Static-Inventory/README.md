# 1. Static Inventory

The static inventory is the simplest way to get started. It's a text file that lists your servers.

## INI vs YAML

Ansible supports both formats. YAML is the modern "Best Practice", but INI is still widely used for simple lists.

### INI Format
```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com

[production:children]
webservers
dbservers
```

### YAML Format
```yaml
all:
  children:
    production:
      children:
        webservers:
          hosts:
            web1.example.com:
            web2.example.com:
        dbservers:
          hosts:
            db1.example.com:
```

## Aliases and Parameters
You can give hosts friendly names and defining connection details inline.

```ini
[webservers]
# Alias   Actual IP       SSH Port      SSH User
nginx-01  ansible_host=10.0.0.1  ansible_port=2222  ansible_user=ubuntu
```
*   **Pros**: Easy to read.
*   **Cons**: Hard to maintain if you have 100 vars involved. Use `host_vars` instead.

## ❓ Interview Questions

1.  **Which format does Ansible parse faster?**
    *   **Answer**: INI is slightly faster to parse, but YAML is richer.

2.  **What is the `ungrouped` group?**
    *   **Answer**: Hosts that are listed in `all` but not in any specific child group.

## 🧠 Quiz

1.  **Which keyword is used in INI to group other groups?**
    *   [x] `:children`
    *   [ ] `:groups`

2.  **Can you mix INI and YAML files in one directory?**
    *   [x] Yes.
    *   [ ] No.
