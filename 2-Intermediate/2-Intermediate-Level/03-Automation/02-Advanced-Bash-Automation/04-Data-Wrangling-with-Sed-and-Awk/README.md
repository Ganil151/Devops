# Data Wrangling (Sed and Awk)

While `jq` handles JSON, `sed` and `awk` are the kings of unstructured or field-based text (like logs, CSVs, or legacy config files).

## ✂️ Stream Editing with `sed`

`sed` is primarily used for search-and-replace operations in a stream of text.

### Search and Replace
```bash
# Suffix -i to edit the file in-place
sed -i 's/old-value/new-value/g' config.yaml
```

### Deleting Lines
```bash
# Delete all lines containing "DEBUG"
sed '/DEBUG/d' app.log
```

## 📊 Field Processing with `awk`

`awk` treats each line as a collection of fields separated by whitespace (by default).

### Basic Extraction
```bash
# Print the 1st and 3rd columns (e.g., in 'ls -l')
ls -l | awk '{print $1, $9}'
```

### Pattern Matching and Calculations
```bash
# Sum the 5th column (file sizes) of all .log files
ls -l *.log | awk '{sum += $5} END {print "Total Size: ", sum}'
```

## 🧠 Regex Cheat Sheet for Shell

| Pattern | Description | Example |
| :--- | :--- | :--- |
| `^` | Start of line | `^ERROR` |
| `$` | End of line | `completed$` |
| `.` | Any single character | `i.p` (matches 'imp', 'itp') |
| `*` | 0 or more of previous | `ab*` (matches 'a', 'ab', 'abb') |
| `[0-9]` | Any digit | `[0-9]{1,3}` |

---

## 📖 Stories from the Field: The Configuration Patch

**Scenario**: A company had 100 legacy servers running a proprietary app. A security vulberability required changing `PermitRootLogin yes` to `PermitRootLogin no` in the app's internal config.
**Problem**: The servers didn't have Ansible or Puppet installed.
**Discovery**: Every server had `sed`.
**Resolution**: The engineer ran a one-liner across the fleet:
```bash
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /opt/app/config.ini
```
**Outcome**: All 100 servers were patched in minutes using a simple SSH script.
**Prevention**: Mastering `sed` gives you a "universal remote" for any server that has a shell.

---

## ❓ Interview Questions

1. **What does the `-i` flag in `sed` do?**
   * *Answer*: It stands for "in-place." It modifies the file directly instead of printing the result to `stdout`.
2. **How do you change the field separator in `awk`?**
   * *Answer*: Use the `-F` flag. `awk -F"," '{print $2}' data.csv`.
3. **Difference between `sed 's/A/B/'` and `sed 's/A/B/g'`?**
   * *Answer*: The first only replaces the *first* occurrence on each line. The `g` (global) replaces *all* occurrences on each line.
4. **What are `BEGIN` and `END` blocks in `awk`?**
   * *Answer*: `BEGIN` runs once before any lines are processed (useful for printing headers). `END` runs once after all lines are processed (useful for printing totals/counts).
5. **How do you extract the last column of a line in `awk` regardless of how many columns there are?**
   * *Answer*: Use the special variable `$NF` (Number of Fields). `awk '{print $NF}'`.

---

## 🧠 Quiz

1. **Which command is better for summing numbers in a column?** `(awk)`
2. **What does the `^` symbol represent in a regular expression?** `(Start of the line)`
3. **Which `sed` command deletes the 5th line of a file?** `(sed '5d' file)`
4. **True/False: `awk` can perform arithmetic operations.** `(True)`
5. **How do you replace 'foo' with 'bar' globally using `sed`?** `(sed 's/foo/bar/g' file)`