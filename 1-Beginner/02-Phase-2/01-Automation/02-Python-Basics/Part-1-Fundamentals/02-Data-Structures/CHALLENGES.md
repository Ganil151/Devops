# Data Structures - DevOps Challenges

## Challenge 1: Unique IP Filter (Sets)
**Scenario**: You have a raw list of IP addresses from logs, containing duplicates.

**Requirements:**
1. Accept a list of IPs (e.g., from a file or hardcoded).
2. Use a `set` to remove duplicates.
3. Sort the unique IPs and print them.

**Verification:**
```bash
python unique_ips.py
# Input: ["10.0.0.1", "10.0.0.2", "10.0.0.1"]
# Output: ["10.0.0.1", "10.0.0.2"]
```

---

## Challenge 2: Tag Grouper (Dictionaries)
**Scenario**: Group resources by their environment tag.

**Requirements:**
1. Input: List of resources `{"id": "i-1", "env": "prod"}`, `{"id": "i-2", "env": "dev"}`, etc.
2. Output: Dictionary mapping env to list of IDs `{"prod": ["i-1"], "dev": ["i-2"]}`.

**Verification:**
```bash
python tag_grouper.py
```

---

## Challenge 3: Port Scanner Results (Tuples)
**Scenario**: manage immutable port scan results.

**Requirements:**
1. Represent a scan result as a tuple `(port, status)` e.g., `(80, "OPEN")`.
2. Store multiple results in a list.
3. Iterate and print only "OPEN" ports.

**Verification:**
```bash
python port_scan_parser.py
```
