# File Operations - DevOps Challenges

## Challenge 1: Config Finder
**Scenario**: Find all `.yaml` or `.yml` files in a directory tree.

**Requirements:**
1. Use `pathlib` to recursively walk a directory (`rglob`).
2. Print the absolute path of every YAML file found.

**Verification:**
```bash
python find_configs.py
```

---

## Challenge 2: Permissions Audit
**Scenario**: Identify files that are world-writable.

**Requirements:**
1. Iterate through files in a directory.
2. Check file permissions (stat).
3. Alert if a file has generic write access (e.g., 777).

**Verification:**
```bash
python perm_audit.py
```

---

## Challenge 3: Temporary File Cleaner
**Scenario**: Delete files older than 7 days.

**Requirements:**
1. Check modification time (`st_mtime`) of files in `/tmp` (or a test dir).
2. Calculate age in days.
3. Delete if age > 7 days.

**Verification:**
```bash
python clean_tmp.py
```
