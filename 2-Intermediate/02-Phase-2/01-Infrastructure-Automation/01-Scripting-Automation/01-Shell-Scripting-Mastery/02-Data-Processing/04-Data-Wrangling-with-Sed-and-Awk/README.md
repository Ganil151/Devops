# Data Wrangling (Sed and Awk)

While `jq` handles JSON, `sed` and `awk` are the kings of unstructured or field-based text (like logs, CSVs, or legacy config files).

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `data_miner.sh`
- **[CHALLENGES](./CHALLENGES.md)**: Log mining and config patching.

---

## ✂️ Stream Editing with `sed`

`sed` is for "Search and Replace".

```bash
# Suffix -i to edit the file in-place
sed -i 's/old-value/new-value/g' config.yaml

# Delete lines containing "DEBUG"
sed '/DEBUG/d' app.log
```

---

## 📊 Field Processing with `awk`

`awk` treats each line as columns (fields).

```bash
# Print the 1st and 9th columns of 'ls -l'
ls -l | awk '{print $1, $9}'

# Sum the 5th column
ls -l *.log | awk '{sum += $5} END {print "Total Size: ", sum}'
```

---

## 📖 Real-World Story: The One-Liner Patch

**Scenario**: 100 legacy servers needed a config change (`PermitRootLogin yes` to `no`). No Ansible available.
**Discovery**: Every server had `sed`.
**Resolution**:
```bash
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
```
**Outcome**: Fleet patched in minutes via SSH loop.

---

## ❓ Interview Questions

1. **What does `sed -i` do?**
   - *Answer*: Edits the file "in-place" rather than printing to stdout.
2. **How do you change the field separator in `awk`?**
   - *Answer*: `awk -F","` (for CSVs).
3. **What is `$NF` in `awk`?**
   - *Answer*: Not Found? No. Number of Fields. It refers to the *last* column.

---

[⬅️ Back to Advanced Bash](../README.md)
