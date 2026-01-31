# 📊 Reference: Data Manipulation Keywords

DevOps engineers spend 80% of their time moving data between APIs, config files, and databases. Python makes this flow seamless.

---

## 🏗️ Serialization (JSON & YAML)

### `json.loads()` vs `json.dumps()`
*   **Definition**: `loads` (load string) converts a JSON string into a Python Dictionary. `dumps` (dump string) converts a Python object into a JSON string.
*   **DevOps Why**: Essential for parsing API responses and generating configuration payloads.

### `yaml.safe_load()`
*   **Definition**: Converts YAML files into Python structures. Use `safe_load` to prevent the execution of arbitrary code embedded in YAML.
*   **DevOps Why**: The standard way to read Kubernetes manifests or Ansible vars in Python utility scripts.

---

## 🛠️ Advanced Data Handling

### List Comprehensions
*   **Definition**: A concise way to create lists based on existing lists/iterators.
*   **Example**: `running_vms = [vm for vm in all_vms if vm.state == 'running']`.
*   **DevOps Why**: Allows for high-performance filtering of cloud resource lists with minimal code.

### `zip()` & `enumerate()`
*   **Definition**: `zip` combines multiple lists; `enumerate` provides a counter during iteration.
*   **DevOps Why**: Useful for mapping a list of IP addresses to a list of Hostnames or tracking progress during a bulk resource update.

### `Pandas` (for DevOps)
*   **Definition**: A powerful data analysis library.
*   **DevOps Why**: Overkill for simple scripts, but critical for analyzing 1GB+ AWS Billing CSVs or parsing millions of log entries into a summary table.

---

## 🎙️ Staff Interview context
*   **"What is the risk of using yaml.load() instead of yaml.safe_load()?"**
    *   *Answer*: `yaml.load()` can instantiate arbitrary Python objects, which could lead to Remote Code Execution (RCE) if the YAML source is untrusted (e.g., a user-submitted Kubernetes manifest).
*   **"How do you handle a JSON response that is too large to load into memory?"**
    *   *Answer*: Use `ijson` for iterative parsing or process the data line-by-line if it is formatted as JSON-Lines (JSONL).
