# JSON Processing with JQ

Modern DevOps is largely about talking to APIs. Since most APIs return JSON, `jq` is the "swiss army knife" for transforming that data into a format Bash can understand.

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

## 🪜 Handling Nested Data and Arrays

### Iterating over Arrays
Use `[]` to expand an array.

```bash
# Get all instance IDs from an AWS-like response
cat response.json | jq -r '.Instances[].InstanceId'
```

### Filtering with `select`
Find objects that match a criteria.

```bash
# Find only running instances
cat response.json | jq -r '.Instances[] | select(.State == "running") | .InstanceId'
```

## 🛡️ Robustness: Defaults and Nulls

APIs often return `null` or missing keys. Use the `//` operator to provide a default value.

```bash
# If 'tag' is missing, return 'untagged'
cat response.json | jq -r '.Instances[].Tags[0].Value // "untagged"'
```

---

## 📖 Stories from the Field: The Broken Inventory

**Scenario**: A script pulled server IPs from a Cloud API to run a security scan.
**Problem**: One day, the API returned an empty list for one region. The script's `jq` command returned `null`.
**Outcome**: The script tried to run `ssh null "cmd"`, which caused the scan to hang and triggered dozens of alerts.
**Resolution**: Refactored the `jq` call to handle nulls and added a length check.
```bash
IPS=$(cat api.json | jq -r '.Servers[].IP // empty')
if [[ -z "$IPS" ]]; then
    echo "No servers found, skipping region."
    exit 0
fi
```
**Prevention**: Never trust an API to always return data. Always provide a default or handle the "empty" case in your `jq` filters.

---

## ❓ Interview Questions

1. **What does the `-r` flag in `jq` do?**
   * *Answer*: It stands for "raw output." It removes the surrounding quotes from strings and disables escape sequences, making it easier for shell variables to consume the data.
2. **How do you merge two JSON objects in `jq`?**
   * *Answer*: Use the `*` or `+` operator. `jq '.obj1 + .obj2'`.
3. **Difference between `jq '.[]'` and `jq '.'`?**
   * *Answer*: `.` refers to the root object. `[]` is the iterator; if the root is an array, `[]` returns each element as a separate JSON stream.
4. **How do you construct a NEW JSON object from parts of an old one?**
   * *Answer*: Use the `{}` syntax. `jq '{id: .InstanceId, status: .State.Name}'`.
5. **How do you check the number of items in an array?**
   * *Answer*: Use the `length` function. `cat data.json | jq '.Items | length'`.

---

## 🧠 Quiz

1. **Which `jq` filter selects an item from an array at index 0?** `(.[0])`
2. **The `//` operator is used for providing...** `(Default values)`
3. **How do you filter items based on a condition?** `(The select() function)`
4. **True/False: `jq` can only read from files.** `(False - it reads from stdin by default)`
5. **Which flag makes `jq` output pretty-printed JSON?** `(Trick question: it pretty-prints by default unless -c is used)`
6. **Bonus: What does `-c` do?** `(Compact output - one line per object)`
