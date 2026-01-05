# 2. YAML Syntax

Ansible uses **YAML** because it is human-readable. However, it is also very strict. A single space can break your automation.

## The Golden Rules
1.  **Indentation**: Use **2 Spaces**. Never use Tabs.
2.  **Lists**: Start with `-`.
3.  **Dictionaries**: Key-Value pairs (`key: value`).
4.  **Booleans**: `true`, `false`, `yes`, `no`.

## Data Structures

### Lists
A sequence of items.
```yaml
packages:
  - nginx
  - git
  - curl
```

### Dictionaries
A collection of keys and values.
```yaml
nginx_config:
  port: 80
  root: /var/www/html
  enabled: true
```

### Multi-Line Strings
Sometimes config files are long.
*   `|` (Pipe): Preserves newlines (Literal block).
*   `>` (Greater Than): Folds newlines into spaces (Folded block).

```yaml
# Good for scripts
shell_script: |
  echo "Line 1"
  echo "Line 2"

# Good for long descriptions
description: >
  This is a very long sentence that I want to
  wrap in my editor but should appear as one line.
```

## Real-Life Scenarios

### Scenario: "The Parser Error"
**Problem**: `ScannerError: mapping values are not allowed here`.
**Cause**: The user put a space *before* the colon (`key : value`) or messed up indentation.
**Solution**: Used a YAML Linter in VS Code.
*   **Rule**: The colon must be followed by a space. `key: value`.

## ❓ Interview Questions

1.  **Why does Ansible use YAML instead of JSON?**
    *   **Answer**: YAML supports comments and is easier for humans to read/write. JSON is cleaner for machines but harder for humans to edit manually.

2.  **How do you comment in YAML?**
    *   **Answer**: Use the `#` symbol.

## 🧠 Quiz

1.  **Which character indicates a list item?**
    *   [x] `-`
    *   [ ] `*`

2.  **To preserve newlines in a variable:**
    *   [x] `|`
    *   [ ] `>`

3.  **Correct boolean syntax:**
    *   [x] `become: true`
    *   [ ] `become: "true"` (This works but isn't a native boolean).