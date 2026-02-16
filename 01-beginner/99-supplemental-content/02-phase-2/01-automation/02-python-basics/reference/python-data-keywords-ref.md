# Python Data Keywords & Built-ins: The DevOps Reference

> **Navigation**: [DevOps Home](../readme.md) → [Automation](../readme.md) → [Python Basics](../../readme.md) → Data Keywords Ref
>
> **Purpose**: A high-density reference for data manipulation keywords, casting, and inspection tools, optimized for high-performance automation scripts.

---

## 01 - Access & Slicing
**Keywords**: `[]` (Index), `[:]` (Slice), `in` (Membership)

### ⚡ Performance & Complexity
| Operation | Data Structure | Big-O Limit | Note |
| :--- | :--- | :--- | :--- |
| **Index** `l[i]` | List/Tuple | **O(1)** | Instant access by offset. |
| **Slice** `l[a:b]` | List/Tuple | **O(k)** | `k` is slice length. Copies data! |
| **Membership** `x in s` | **Set/Dict** | **O(1)** | Hashing makes this instant. |
| **Membership** `x in l` | List/Tuple | **O(n)** | Scans entire list. Slow for large data. |

### 🚀 Real-World DevOps Application
**Scenario**: Validating infrastructure configuration against allowed standard lists and parsing rigid log formats.

#### DevOps Pattern: Efficient Lookup & Parsing
```python
def validate_deployment(region: str, instance_type: str) -> bool:
    # O(1) Lookup - Use sets for "Allowed Values" lists
    allowed_regions: set[str] = {"us-east-1", "eu-central-1", "ap-south-1"}
    
    # O(1) Lookup - Dictionary for cost limits
    instance_limits: dict[str, int] = {
        "t3.micro": 2, 
        "m5.large": 10
    }

    # Guard Clause with 'in'
    if region not in allowed_regions:
        print(f"❌ Error: Region {region} is not whitelisted.")
        return False

    # String Slicing for Log ID Extraction
    # Format: "2023-10-27 [INFO] RES-id-5542: Started"
    log_line: str = "2023-10-27 [INFO] RES-id-5542: Started"
    
    # Extract 'RES' prefix using slicing (rigid format assumption)
    resource_prefix: str = log_line[21:24] 
    
    if resource_prefix == "RES":
        print(f"✅ Deployment validated in {region}")
        return True
    
    return False

validate_deployment("us-east-1", "t3.micro")
```

---

## 02 - Aggregate & Math Operations
**Keywords**: `len()`, `max()`, `min()`, `sum()`, `all()`, `any()`

### ⚡ Performance & Complexity
| Operation | Big-O Limit | Note |
| :--- | :--- | :--- |
| `len(s)` | **O(1)** | Python stores length; no counting needed. |
| `min(s)` / `max(s)` | **O(n)** | Must check every item. |
| `all(s)` / `any(s)` | **O(n)** | Short-circuits (returns early if result found). |

### 🚀 Real-World DevOps Application
**Scenario**: Health checks before deployment. A "Green" deployment requires **all** servers to be healthy. An alert triggers if **any** critical error is found.

#### DevOps Pattern: The "Safety Gate" Check
```python
def check_cluster_health(nodes: list[dict[str, str | bool]]) -> bool:
    # Input data: List of node status dicts
    # nodes = [{'id': 'n1', 'healthy': True}, {'id': 'n2', 'healthy': False}]

    # Generator Expression for Memory Efficiency
    health_statuses = (n['healthy'] for n in nodes)

    # STRICT: All nodes must be healthy to proceed
    if not all(health_statuses):
        print("⛔ STOP: Not all nodes are verified healthy.")
        return False

    # CHECK: Are there any high-priority errors?
    error_logs: list[str] = ["WARN: CPU High", "CRIT: Disk Full", "INFO: Login"]
    
    # Check if 'CRIT' appears in ANY log line
    has_critical: bool = any("CRIT" in line for line in error_logs)

    if has_critical:
        print("🚨 ALERT: Critical error detected in logs.")
        return False

    print("✅ Cluster is healthy. Proceeding...")
    return True
```

---

## 03 - Data Transformation & Casting
**Keywords**: `list()`, `set()`, `dict()`, `str()`, `tuple()`, `frozenset()`

### ⚡ Performance & Complexity
*   **Casting**: Generally **O(n)** as it involves copying elements.
*   **Notes**: `list(set_data)` removes duplicates but loses order. `tuple()` makes data immutable (safe).

### 🚀 Real-World DevOps Application
**Scenario**: Cleaning raw data from CLI outputs (CSV/Text) and preparing immutable configurations for thread safety.

#### DevOps Pattern: Deduplication & Immutability
```python
def process_inventory(raw_ips: list[str]) -> tuple[str, ...]:
    """
    Cleans a list of IPs: removes duplicates, sorts them, and locks as immutable.
    """
    print(f"Raw Input count: {len(raw_ips)}")

    # 1. set() to remove duplicates (O(n))
    unique_ips: set[str] = set(raw_ips)

    # 2. sorted() returns a list (O(n log n))
    sorted_ips: list[str] = sorted(unique_ips)

    # 3. tuple() to freeze data before passing to other functions (O(n))
    # This prevents accidental modification downstream
    immutable_inventory: tuple[str, ...] = tuple(sorted_ips)

    return immutable_inventory

# config = frozenset({'read_only', 'ssl_enabled'}) # Hashable & Immutable set
```

---

## 04 - Object Metadata & Inspection
**Keywords**: `type()`, `id()`, `dir()`, `hasattr()`, `isinstance()`

### ⚡ Performance & Complexity
| Operation | Big-O Limit | Note |
| :--- | :--- | :--- |
| `type(x)` | **O(1)** | Metadata lookup. |
| `isinstance(x, C)` | **O(1)** | Checks inheritance tree (MRO). |
| `dir(x)` | **O(n)** | Returns list of all attributes. |

### 🚀 Real-World DevOps Application
**Scenario**: Handling dynamic cloud API responses (e.g., Boto3 or K8s client) where resource schema might vary or is unknown.

#### DevOps Pattern: Adaptive API Handling
```python
def inspect_cloud_resource(resource: object) -> None:
    # 1. Flexible Type Checking (Best Practice)
    # Allows for subclasses (e.g., a MockEC2Instance used in testing)
    if not isinstance(resource, object): 
        raise TypeError("Invalid resource type")

    # 2. Dynamic Attribute Check
    # AWS responses sometimes miss keys if values are null.
    # Check if 'tags' attribute exists before accessing.
    if hasattr(resource, 'tags'):
        print(f"Resource Tags: {getattr(resource, 'tags')}")
    else:
        print("ℹ️ Note: Resource has no tags.")

    # 3. Deep Inspection (Debugging)
    # If we don't know what methods are available, we check `dir()`
    # Filter for public methods only
    methods: list[str] = [m for m in dir(resource) if not m.startswith('_')]
    print(f"Available actions: {methods[:5]}...") 
```

---

## 05 - Functional & Iteration Tools
**Keywords**: `enumerate()`, `zip()`, `reversed()`, `sorted()`, `iter()`, `next()`

### ⚡ Performance & Complexity
*   **Iterators**: `enumerate`, `zip`, `reversed` are **Lazy**. They take **O(1)** to create and yield items one by one. They do *not* copy data.
*   **Sorting**: `sorted()` is **O(n log n)** (Timsort).

### 🚀 Real-World DevOps Application
**Scenario**: Correlating data from two sources (e.g., Server Hostnames and IP Addresses) and processing logs with line numbers.

#### DevOps Pattern: Parallel Iteration & Context
```python
def map_servers_to_ips(hosts: list[str], ips: list[str]) -> dict[str, str]:
    # 1. zip(): Lock-step iteration over two lists
    # Stops at the shortest list length.
    server_map = {}
    
    for host, ip in zip(hosts, ips):
        server_map[host] = ip
        
    return server_map

def parse_log_file(lines: list[str]) -> None:
    # 2. enumerate(): Get index (line number) and value simultaneously
    # Start counting at line 1 (start=1)
    for line_num, content in enumerate(lines, start=1):
        if "ERROR" in content:
            print(f"❌ Issue found on Line {line_num}: {content.strip()}")

# Usage
# server_data = map_servers_to_ips(["web01", "db01"], ["10.0.0.1", "10.0.0.2"])
```

---

## 🔍 The Interviewer's Trap: Precision in Type Checking

This section differentiates a specific "scripting" mindset from a robust "engineering" mindset.

### 1. `is` vs `==`
*   **`==` (Equality)**: Checks if the **values** are the same. (Do these two boxes contain the same cake?)
*   **`is` (Identity)**: Checks if they are the **same object in memory**. (Are these two pointers pointing to the literal same box?)

**Trap**: Small integers and strings are cached by Python (interned).
```python
a = 256
b = 256
print(a is b) # True (Optimization detail, do not rely on this!)

x = []
y = []
print(x == y) # True (Both empty)
print(x is y) # False (Two different list objects in memory)

# BEST PRACTICE:
# Always use '==' for value comparison.
# Only use 'is' for Singletons like 'None', 'True', 'False'.
if variable is None: ... 
```

### 2. `type()` vs `isinstance()`
*   **`type(obj) == Class`**: Strict check. Breaks inheritance.
*   **`isinstance(obj, Class)`**: Robust check. Supports inheritance (Subclasses).

**Why it matters in DevOps**:
In testing, you often replace a real `AWSConnection` object with a `MockAWSConnection`.
*   `type()` will FAILL because `MockAWSConnection != AWSConnection`.
*   `isinstance()` will PASS because `Mock` inherits from `Base`.

```python
class CloudService: pass
class S3Service(CloudService): pass

bucket = S3Service()

# ❌ BAD: Brittle
if type(bucket) == CloudService:
    print("Is Cloud Service") # Fails

# ✅ GOOD: Robust (Polymorphism)
if isinstance(bucket, CloudService):
    print("Is Cloud Service") # Works!
```
