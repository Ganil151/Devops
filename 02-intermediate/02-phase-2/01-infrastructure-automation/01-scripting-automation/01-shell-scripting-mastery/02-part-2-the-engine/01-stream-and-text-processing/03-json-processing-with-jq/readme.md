# 🦅 JSON Processing with JQ: The DevOps Swiss Army Knife

> **"If you are grep-ping JSON, you are doing it wrong. JQ is not optional; it is the only way to safely handle modern infrastructure APIs in the shell."**

Welcome to the **JQ Mastery** module. In the modern cloud era, every tool (Kubernetes, AWS CLI, Terraform, Docker) speaks JSON. `jq` is the command-line JSON processor that allows you to slice, filter, map, and transform structured data with the same ease that `sed`, `awk`, and `grep` let you play with text.

**Why This Matters for Junior DevOps Engineers:**
- ☁️ **Cloud Native**: `kubectl get pods -o json` is the raw material of Kubernetes debugging.
- ⚡ **Speed**: Parsing a 50MB JSON file with `jq` is instantaneous compared to writing a Python script.
- 🎯 **Interview**: "How do you filter a list of EC2 instances by tag?" is a JQ question.
- 🔧 **Automation**: You need to extract a specific `ImageId` to pass to the next step in your CI/CD pipeline.

---

## 📚 Table of Contents

1. [JQ Architecture](#-jq-architecture)
2. [Basic Selectors & Formatting](#-basic-selectors--formatting)
3. [Filtering & Selection Logic](#-filtering--selection-logic)
4. [Transformation & Construction](#-transformation--construction)
5. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
6. [Security Best Practices](#-security-best-practices)
7. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
8. [Hands-On Exercises](#-hands-on-exercises)
9. [Interview Preparation](#-interview-preparation)
10. [Knowledge Check](#-knowledge-check)

---

## 🏗️ JQ Architecture

JQ works like a pipeline. It takes JSON input, passes it through a series of "Filters", and produces JSON output.

```mermaid
graph LR
    Input[Input: JSON] -->|Pipe . | Filter1[Filter: .items[]]
    Filter1 -->|Pipe | Filter2[Select: select(.status == 'Running')]
    Filter2 -->|Pipe | Transform[Map: {name: .metadata.name}]
    Transform --> Output[Output: Clean JSON]
    
    style Input fill:#fef3c7,stroke:#d97706
    style Filter1 fill:#e0f2fe,stroke:#0369a1
    style Output fill:#f0fdf4,stroke:#15803d
```

### 🔍 Concept Breakdown

**1. The Identity (`.`)**
- The simplest filter. Returns the input unchanged. Used for pretty-printing.
- `echo '{"a":1}' | jq .`

**2. The Pipe (`|`)**
- Connects the output of one JQ function to the input of another.
- `jq '.items[] | .metadata.name'` means "Get items array, explode it, THEN get the name of each".

**3. The Constructor (`{}`)**
- Creates a **NEW** JSON object from the input data.
- `jq '{ new_id: .id }'`

---

## 🔑 Basic Selectors & Formatting

### 1. Simple Extraction (`.key`)
Navigate down the tree.
```bash
# Input: {"cluster": {"name": "prod-1"}}
cat config.json | jq '.cluster.name'
# Output: "prod-1"
```

### 2. Array Slicing (`[]`)
Iterate over lists.
- `.[]`: "Explode" the array (output one result per item).
- `.[0]`: Get the first item.
- `.[0:2]`: Get the first two items.

```bash
# Input: {"servers": ["web1", "web2", "db1"]}
cat hosts.json | jq '.servers[]'
# Output:
# "web1"
# "web2"
# "db1"
```

### 3. Raw Output (`-r`)
**CRITICAL**: By default, JQ outputs JSON strings (quotes included). Bash hates quotes in variables. Use `-r` to strip them.

```bash
# Standard
ip=$(echo '{"ip": "10.0.0.1"}' | jq '.ip')
echo "Connecting to $ip..." 
# Output: Connecting to "10.0.0.1"... (BROKEN! ssh "10.0.0.1" fails)

# Raw
ip=$(echo '{"ip": "10.0.0.1"}' | jq -r '.ip')
echo "Connecting to $ip..."
# Output: Connecting to 10.0.0.1... (SUCCESS)
```

---

## 🔎 Filtering & Selection Logic

Moving beyond extraction to **Logic**.

### The `select()` Function
This is your `if` statement. It keeps items that match the condition and discards the rest.

**Syntax**: `select(BOOLEAN_EXPRESSION)`

```bash
# Example: Find all running pods
kubectl get pods -o json | jq '.items[] | select(.status.phase == "Running") | .metadata.name'
```

### Complex Logic (`and`, `or`)
```bash
# Find pods that are Running AND have the label 'app=web'
jq '.items[] | select(.status.phase == "Running" and .metadata.labels.app == "web")'
```

### Handling Nulls (`//`)
The "Default Value" operator. Use this to prevent empty strings from breaking your script.

```bash
# Get the tag value, or "untagged" if it doesn't exist
jq -r '.Tags[0].Value // "untagged"'
```

---

## 🛠️ Transformation & Construction

JQ can **Rewrite** data structures.

### 1. Mapping (`map`)
Applies a filter to every item in an array and returns an array (keeps the structure).
```bash
# Input: [1, 2, 3]
echo '[1,2,3]' | jq 'map(. * 10)'
# Output: [10, 20, 30]
```

### 2. Converting to CSV
Great for reporting.
```bash
# Export Pod Name and Image to CSV
kubectl get pods -o json | jq -r '.items[] | [.metadata.name, .spec.containers[0].image] | @csv'
```

### 3. Converting to Shell Variables
```bash
# Output: export ID="123"; export ENV="prod";
echo '{"id": 123, "env": "prod"}' | jq -r 'to_entries | .[] | "export \(.key|ascii_upcase)=\"\(.value)\""'
```

---

## 🎭 Real-World DevOps Scenarios

### 🛡️ Scenario 1: The "Dangling Volume" Audit

**Task**: Identify all AWS EBS Volumes that are "Available" (not in use) and larger than 100GB.
**Input**: AWS CLI JSON output.
**Solution**:
```bash
aws ec2 describe-volumes --output json | jq -r '
  .Volumes[] 
  | select(.State == "available" and .Size > 100) 
  | {ID: .VolumeId, Size: .Size}
'
```

### 🔥 Scenario 2: CI/CD Status Check

**Task**: Parse a GitHub Actions API response. Fail the pipeline if the latest run status is `failure`.
**Solution**:
```bash
STATUS=$(curl -s $API_URL | jq -r '.workflow_runs[0].conclusion')

if [[ "$STATUS" == "failure" ]]; then
    echo "🚨 Build Failed!"
    exit 1
fi
```

### ☁️ Scenario 3: Kubernetes Secret Decoder

**Task**: Secrets in K8s are base64 encoded. Decode all secrets in a namespace instantly.
**Solution**:
```bash
kubectl get secrets -o json | jq -r '
  .items[] 
  | .metadata.name as $name 
  | .data 
  | map_values(@base64d) 
  | {name: $name, data: .}
'
```

---

## 🔒 Security Best Practices

### 1. Redacting Secrets
Before logging JSON, strip out sensitive keys.
```bash
# Remove 'password' and 'secret' fields
cat config.json | jq 'del(.password, .secret)'
```

### 2. Avoiding Injection
When constructing JSON from bash variables, use `--arg`.
**Bad**:
```bash
jq ".name = \"$VAR\"" # VULNERABLE if VAR contains quotes
```
**Good**:
```bash
jq -n --arg name "$VAR" '{name: $name}' # Safe
```

---

## ⚠️ Common Pitfalls

### Pitfall 1: Iterating without Quotes
When piping `jq` output to a `while` loop, spaces in values can break things.
**fix**: Use `@sh` or base64 encoding if values are complex.

### Pitfall 2: Sorting Numbers
By default, JSON keys are unordered. If you need deterministic output (for git diffs), use `--sort-keys` (similar to `-S`).

---

## 🎯 Hands-On Exercises

### Exercise 1: The Inventory Filter
**Objective**: Filter a server list.
**Input**:
```json
[
  {"name": "web-1", "role": "web", "active": true},
  {"name": "db-1", "role": "db", "active": false},
  {"name": "web-2", "role": "web", "active": true}
]
```
**Task**: Write a JQ filter to get the **names** of all **active web** servers.

### Exercise 2: The Log Transformer
**Objective**: Convert formats.
**Task**: Take a JSON log entry `{"ts": 1600000000, "lvl": "ERROR", "msg": "Fail"}` and convert it to a flat string: `[ERROR] 1600000000 - Fail`.

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "What is the difference between `.[]` and `.`?"**
- **Answer**: `.` returns the array itself (as one object). `.[]` iterates/explodes the array into multiple objects (stream).

**2. "How do you count items in an array?"**
- **Answer**: `length`. Example: `jq '.items | length'`.

### Advanced Questions

**3. "How would you extract nested keys where the parent key might vary or be unknown?"**
- **Answer**: Use Recursive Descent `..`. Example: `jq '.. | .image?'` will find the key "image" anywhere in the JSON structure.

---

## 🧠 Knowledge Check

**1. Which flag produces output suitable for Bash variables?**
- [ ] `-c` (Compact)
- [x] `-r` (Raw)
- [ ] `-S` (Sort)

**2. How do you delete a key?**
- [ ] `remove(.key)`
- [x] `del(.key)`
- [ ] `minus(.key)`

**3. What does `//` do?**
- [ ] Comments out code
- [x] Provides a default value (Null Coalescing)
- [ ] Divides numbers

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Extract a simple key (`.key`).
- [ ] Iterate an array (`.[]`).
- [ ] Filter using boolean logic (`select()`).
- [ ] Create a new JSON object (`{key: .value}`).
- [ ] Describe why `-r` is essential for scripting.

**Score yourself**: 5+/5 = Ready to advance | <5 = Review exercises

[⬅️ Back to Data Processing](../readme.md) | [Next: Sed & Awk](../04-data-wrangling-with-sed-and-awk/readme.md) ➡️