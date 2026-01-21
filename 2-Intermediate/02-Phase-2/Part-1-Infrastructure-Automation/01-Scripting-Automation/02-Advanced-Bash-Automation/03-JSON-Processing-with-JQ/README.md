# JSON Processing with JQ

Modern DevOps is largely about talking to APIs. Since most APIs return JSON, `jq` is the "swiss army knife" for transforming that data into a format Bash can understand.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `jq` patterns.
- **[CHALLENGES](./CHALLENGES.md)**: Practice your filters.

---

## 🔍 The Basics: Selectors and Filters

### Simple Extraction
Use `.` to represent the root object and keys to traverse.

```bash
echo '{"id": 123, "name": "prod-web"}' | jq '.name'
# Output: "prod-web" (with quotes)
```

### Raw Output (`-r`)
Bash often needs data without quotes.

```bash
echo '{"name": "prod-web"}' | jq -r '.name'
# Output: prod-web
```

---

## 🛡️ Robustness: Defaults and Nulls

APIs often return `null` or missing keys. Use the `//` operator to provide a default value.

```bash
# If 'tag' is missing, return 'untagged'
cat response.json | jq -r '.Instances[].Tags[0].Value // "untagged"'
```

---

## 📖 Real-World Story: The Broken Inventory

**Scenario**: A script pulled server IPs from a Cloud API to run a security scan.
**Problem**: One day, the API returned an empty list for one region. The script's `jq` command returned `null`.
**Outcome**: The script tried to run `ssh null "cmd"`, which caused the scan to hang and triggered dozens of alerts.
**Resolution**: Refactored the `jq` call to handle nulls.
```bash
IPS=$(cat api.json | jq -r '.Servers[].IP // empty')
```
**Prevention**: Never trust an API to always return data.

---

## ❓ Interview Questions

1. **What does the `-r` flag in `jq` do?**
   - *Answer*: "Raw output." It removes quotes from strings, making them ready for Bash variables.
2. **How do you merge two JSON objects?**
   - *Answer*: `jq '.obj1 + .obj2'`.
3. **How do you check array length?**
   - *Answer*: `length` function. `... | jq '.Items | length'`.

---

[⬅️ Back to Advanced Bash](../README.md)