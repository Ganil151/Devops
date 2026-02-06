# 🔄 Iterative Logic and Loops: The Automation Engine

> **"If you do it once, it's a task. If you do it 1,000 times, it's automation. Loops are the gears that turn a single line of code into a fleet-wide operation."**

![Loop Logic Flow](../assets/loop-visual-flow.png)

---

## 🧠 The Mental Model: Loops as the Assembly Line

**The Junior Struggle**: "Why do I need loops when I can just run the command three times?"

**The Engineer Solution**: Loops are like an **assembly line**—they apply the same operation to many items efficiently and consistently.

### 🏗️ The Infrastructure Analogy

Think of loops like an **assembly line in a factory**:

| Concept | Assembly Line Analogy | Loop Equivalent |
|:--------|:----------------------|:----------------|
| **for loop** | Process each item on the conveyor | `for server in servers:` |
| **while loop** | Keep running until quality check passes | `while status != "ready":` |
| **break** | Emergency stop button | Exit loop immediately |
| **continue** | Skip defective item | Skip to next iteration |
| **enumerate** | Item counter on the line | Track index and value |
| **List comprehension** | High-speed automated filter | Transform list in one line |

**The Key Insight**: Just like an assembly line processes items one by one, loops process data items systematically and efficiently.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "I'll just copy-paste the command for each server"
- "Loops are only for counting numbers"
- "I don't need to handle failures in loops"

**After this module**, you'll understand:
- **for loops process collections** (servers, files, logs)
- **while loops wait for conditions** (polling, retries)
- **Loop control** (break, continue, else) handles edge cases
- **List comprehensions** transform data efficiently
- **enumerate and zip** provide context while looping

**The Difference**: Your automation will scale from 3 servers to 300 servers without changing code.

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Master for Loops**: Iterate over collections (lists, dicts, files)
- ✅ **Implement while Loops**: Polling and retry patterns
- ✅ **Use Loop Control**: break, continue, for-else
- ✅ **Write List Comprehensions**: Transform data in one line
- ✅ **Apply enumerate and zip**: Context-aware iteration
- ✅ **Handle Infinite Loops**: Timeouts and safety patterns

---

## 🏗️ Part 1: The for Loop (Inventory Pattern)

### 🧠 The Mental Model: The Inventory Processor

**The Use Case**: You have a defined list of items (servers, files, users) and need to apply an action to each one.

### 🔧 Basic for Loop Patterns

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Looping over a list
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

servers = ["web-01", "web-02", "db-01", "cache-01"]

for server in servers:
    print(f"Patching {server}...")
    # Execute patch command here

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Looping over a dictionary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

server_ips = {
    "web-01": "10.0.1.5",
    "web-02": "10.0.1.6",
    "db-01": "10.0.2.10"
}

# Loop over keys
for server_name in server_ips:
    print(f"Server: {server_name}")

# Loop over values
for ip in server_ips.values():
    print(f"IP: {ip}")

# Loop over key-value pairs (MOST COMMON)
for server_name, ip in server_ips.items():
    print(f"{server_name} -> {ip}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Looping over a range
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# range(5) generates: 0, 1, 2, 3, 4
for i in range(5):
    print(f"Attempt {i + 1}")

# range(start, stop, step)
for port in range(8000, 8005):
    print(f"Checking port {port}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Looping over a file (streaming)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("access.log", "r") as f:
    for line in f:  # Reads one line at a time
        if "ERROR" in line:
            print(line.strip())
```

### 🚀 Professional Pattern: Multi-Region Deployment

```python
from typing import List, Dict

def deploy_to_regions(app_name: str, regions: List[str]) -> Dict[str, str]:
    """
    Deploy application to multiple AWS regions.
    
    Args:
        app_name: Name of application to deploy
        regions: List of AWS regions
    
    Returns:
        Dictionary mapping regions to deployment status
    
    Example:
        >>> results = deploy_to_regions("myapp", ["us-east-1", "us-west-2"])
    """
    results = {}
    
    for region in regions:
        print(f"Deploying {app_name} to {region}...")
        
        try:
            # Simulate deployment
            # deploy_command = f"aws deploy --region {region} --app {app_name}"
            # subprocess.run(deploy_command.split(), check=True)
            
            results[region] = "SUCCESS"
            print(f"✅ {region}: Deployment successful")
        
        except Exception as e:
            results[region] = f"FAILED: {str(e)}"
            print(f"❌ {region}: Deployment failed - {e}")
    
    return results


# 🎯 Usage
regions = ["us-east-1", "us-west-2", "eu-west-1"]
deployment_results = deploy_to_regions("myapp", regions)

# Summary
success_count = sum(1 for status in deployment_results.values() if status == "SUCCESS")
print(f"\n📊 Summary: {success_count}/{len(regions)} regions deployed successfully")
```

**💡 Pro Tip**: Use `for` loops when you have a known collection to process.

---

## ⏳ Part 2: The while Loop (Polling Pattern)

### 🧠 The Mental Model: The Waiter

**The Use Case**: Wait for an external state to change (server to boot, API to respond, deployment to complete).

### 🔧 Basic while Loop Patterns

```python
import time

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Simple polling loop
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

status = "PENDING"
max_attempts = 10
attempts = 0

while status != "RUNNING" and attempts < max_attempts:
    print(f"Status: {status}, waiting...")
    time.sleep(2)
    
    # Check status (simulated)
    # status = check_server_status()
    
    attempts += 1

if status == "RUNNING":
    print("✅ Server is running!")
else:
    print("❌ Timeout: Server did not start")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Infinite loop with break
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

while True:
    user_input = input("Enter command (or 'quit'): ")
    
    if user_input == "quit":
        break
    
    print(f"Executing: {user_input}")
```

### 🚀 Professional Pattern: Exponential Backoff Retry

```python
import time
from typing import Optional

def wait_for_service(
    service_name: str,
    max_retries: int = 5,
    initial_delay: float = 1.0
) -> bool:
    """
    Wait for a service to become available with exponential backoff.
    
    Args:
        service_name: Name of service to check
        max_retries: Maximum number of retry attempts
        initial_delay: Initial delay in seconds (doubles each retry)
    
    Returns:
        True if service became available, False if timeout
    
    Example:
        >>> if wait_for_service("database", max_retries=5):
        ...     print("Database is ready!")
    """
    delay = initial_delay
    retries = 0
    
    while retries < max_retries:
        print(f"Attempt {retries + 1}/{max_retries}: Checking {service_name}...")
        
        # Simulate service check
        # is_available = check_service_health(service_name)
        is_available = (retries >= 3)  # Simulated: succeeds on 4th attempt
        
        if is_available:
            print(f"✅ {service_name} is available!")
            return True
        
        print(f"⏳ {service_name} not ready, waiting {delay}s...")
        time.sleep(delay)
        
        # Exponential backoff: 1s, 2s, 4s, 8s, 16s
        delay *= 2
        retries += 1
    
    print(f"❌ Timeout: {service_name} did not become available")
    return False


# 🎯 Usage
if wait_for_service("database"):
    print("Proceeding with deployment...")
else:
    print("Aborting deployment due to service unavailability")
```

**💡 Pro Tip**: Always use a maximum retry count to prevent infinite loops. Use exponential backoff to avoid overwhelming services.

---

## 🎛️ Part 3: Loop Control (break, continue, else)

### 🧠 The Mental Model: The Control Panel

**The Concept**: Control loop execution with break (stop), continue (skip), and else (completion check).

### 🔧 Loop Control Examples

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# break - Exit loop immediately
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

servers = ["web-01", "web-02", "db-01", "cache-01"]

for server in servers:
    print(f"Checking {server}...")
    
    # Simulate health check
    is_healthy = (server != "db-01")  # db-01 is down
    
    if not is_healthy:
        print(f"❌ {server} is down! Stopping deployment.")
        break  # Exit loop immediately
    
    print(f"✅ {server} is healthy")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# continue - Skip to next iteration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

log_lines = ["INFO: Started", "DEBUG: Details", "ERROR: Failed", "INFO: Done"]

for line in log_lines:
    # Skip INFO and DEBUG lines
    if "INFO" in line or "DEBUG" in line:
        continue  # Skip to next iteration
    
    # Only ERROR lines reach here
    print(f"🚨 {line}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# for-else - Runs if loop completes without break
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

target_server = "db-01"
servers = ["web-01", "web-02", "cache-01"]

for server in servers:
    if server == target_server:
        print(f"Found {target_server}!")
        break
else:
    # This runs ONLY if break was never called
    print(f"❌ {target_server} not found in inventory")
```

### 🚀 Professional Pattern: Log Parser with Controls

```python
from typing import List, Dict

def parse_deployment_log(log_file: str) -> Dict[str, List[str]]:
    """
    Parse deployment log, categorizing messages and stopping on critical errors.
    
    Args:
        log_file: Path to deployment log file
    
    Returns:
        Dictionary with categorized log messages
    
    Example:
        >>> results = parse_deployment_log("deployment.log")
        >>> print(f"Errors: {len(results['errors'])}")
    """
    results = {
        "errors": [],
        "warnings": [],
        "info": []
    }
    
    try:
        with open(log_file, "r") as f:
            for line_num, line in enumerate(f, start=1):
                line = line.strip()
                
                # Skip empty lines
                if not line:
                    continue
                
                # Critical error - stop processing
                if "CRITICAL" in line:
                    print(f"🚨 Line {line_num}: Critical error detected!")
                    print(f"   {line}")
                    break
                
                # Categorize messages
                if "ERROR" in line:
                    results["errors"].append(f"Line {line_num}: {line}")
                elif "WARN" in line:
                    results["warnings"].append(f"Line {line_num}: {line}")
                elif "INFO" in line:
                    results["info"].append(f"Line {line_num}: {line}")
            else:
                # This runs ONLY if we didn't break
                print("✅ Log parsing completed successfully")
        
        # Summary
        print(f"\n📊 Summary:")
        print(f"   Errors: {len(results['errors'])}")
        print(f"   Warnings: {len(results['warnings'])}")
        print(f"   Info: {len(results['info'])}")
        
        return results
    
    except FileNotFoundError:
        print(f"❌ Log file not found: {log_file}")
        return results


# 🎯 Usage
results = parse_deployment_log("deployment.log")
```

**💡 Pro Tip**: Use `for-else` to detect if a search loop found nothing. Use `break` for critical failures.

---

## 🚀 Part 4: List Comprehensions

### 🧠 The Mental Model: The High-Speed Filter

**The Use Case**: Transform or filter a list in a single, efficient line.

### 🔧 List Comprehension Patterns

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Basic transformation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Old way (3 lines)
ports = [8000, 8001, 8002]
port_strings = []
for port in ports:
    port_strings.append(f":{port}")

# New way (1 line)
port_strings = [f":{port}" for port in ports]
print(port_strings)  # [':8000', ':8001', ':8002']

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Filtering with condition
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

servers = ["web-prod-01", "web-dev-01", "db-prod-01", "cache-dev-01"]

# Filter production servers
prod_servers = [s for s in servers if "prod" in s]
print(prod_servers)  # ['web-prod-01', 'db-prod-01']

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Transform and filter
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Extract port numbers from URLs
urls = ["http://api:8000", "http://web:8080", "http://db:5432"]
ports = [int(url.split(":")[-1]) for url in urls]
print(ports)  # [8000, 8080, 5432]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Nested list comprehension
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Flatten a list of lists
regions = [["web-01", "web-02"], ["db-01"], ["cache-01", "cache-02"]]
all_servers = [server for region in regions for server in region]
print(all_servers)  # ['web-01', 'web-02', 'db-01', 'cache-01', 'cache-02']
```

### 🚀 Professional Pattern: Configuration Filter

```python
from typing import List, Dict

def filter_healthy_servers(servers: List[Dict[str, str]]) -> List[str]:
    """
    Filter servers that are healthy and in production.
    
    Args:
        servers: List of server dictionaries
    
    Returns:
        List of healthy production server names
    
    Example:
        >>> servers = [
        ...     {"name": "web-01", "status": "healthy", "env": "prod"},
        ...     {"name": "web-02", "status": "down", "env": "prod"},
        ...     {"name": "web-03", "status": "healthy", "env": "dev"}
        ... ]
        >>> healthy = filter_healthy_servers(servers)
        >>> print(healthy)  # ['web-01']
    """
    return [
        server["name"]
        for server in servers
        if server.get("status") == "healthy" and server.get("env") == "prod"
    ]


# 🎯 Usage
servers = [
    {"name": "web-01", "status": "healthy", "env": "prod"},
    {"name": "web-02", "status": "down", "env": "prod"},
    {"name": "web-03", "status": "healthy", "env": "dev"},
    {"name": "db-01", "status": "healthy", "env": "prod"}
]

healthy_prod = filter_healthy_servers(servers)
print(f"Healthy production servers: {healthy_prod}")
```

**💡 Pro Tip**: List comprehensions are faster and more Pythonic than traditional loops for transformations.

---

## 🔢 Part 5: enumerate and zip

### 🧠 The Mental Model: The Context Provider

**The Use Case**: You need both the index and value, or you need to combine two lists.

### 🔧 enumerate and zip Patterns

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# enumerate - Get index and value
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

log_lines = ["INFO: Started", "ERROR: Failed", "INFO: Recovered"]

for index, line in enumerate(log_lines):
    print(f"Line {index}: {line}")

# Start counting from 1 instead of 0
for line_num, line in enumerate(log_lines, start=1):
    if "ERROR" in line:
        print(f"🚨 Error on line {line_num}: {line}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# zip - Combine two lists
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

hostnames = ["web-01", "db-01", "cache-01"]
ip_addresses = ["10.0.1.5", "10.0.2.10", "10.0.3.15"]

for hostname, ip in zip(hostnames, ip_addresses):
    print(f"{hostname} -> {ip}")

# Create dictionary from two lists
server_map = dict(zip(hostnames, ip_addresses))
print(server_map)  # {'web-01': '10.0.1.5', 'db-01': '10.0.2.10', ...}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Combining enumerate and zip
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

for index, (hostname, ip) in enumerate(zip(hostnames, ip_addresses), start=1):
    print(f"{index}. {hostname} ({ip})")
```

**💡 Pro Tip**: Use `enumerate` when you need line numbers. Use `zip` to combine related lists.

---

## 🏆 Part 6: Real-World DevOps Story

### 📖 The Infinite Loop Incident

**The Scenario**: A deployment script waited for a Kubernetes pod to become "Ready". The script used a `while True:` loop with no timeout.

**The Code**:
```python
# ❌ The problem
while True:
    status = check_pod_status("myapp")
    if status == "Ready":
        break
    time.sleep(5)
```

**The Problem**: The pod had a configuration error and would never become "Ready". The deployment script ran for 3 days, blocking the entire CI/CD pipeline.

**The Solution**:
```python
# ✅ The fix
import time

max_wait_time = 300  # 5 minutes
start_time = time.time()

while True:
    elapsed = time.time() - start_time
    
    if elapsed > max_wait_time:
        print(f"❌ Timeout after {max_wait_time}s")
        break
    
    status = check_pod_status("myapp")
    if status == "Ready":
        print("✅ Pod is ready!")
        break
    
    print(f"Waiting... ({elapsed:.0f}s elapsed)")
    time.sleep(5)
```

**The Outcome**: The script now fails fast after 5 minutes, allowing engineers to investigate the configuration error instead of waiting indefinitely.

**The Lesson**: **Always add timeouts** to while loops. Never use `while True:` without a break condition based on time or attempts.

---

## ❓ Interview Preparation

### 🎯 Core Concepts

1. **Q: Why is a for loop generally safer than a while loop?**
   - **A**: A for loop is finite by design—it runs exactly once for each item. A while loop runs based on a condition, which can create infinite loops if the exit condition is never met.

2. **Q: What is the purpose of the for-else block?**
   - **A**: The else block executes only if the loop completes without hitting a break. It's useful for search operations: "Check all items; if you didn't find it (break), then run else to say 'Not Found'."

3. **Q: How do you modify a list while iterating over it?**
   - **A**: You should NEVER modify a list while iterating over it (causes index errors). Instead, iterate over a copy (`for item in list[:]`) or create a new list using a list comprehension.

4. **Q: What does `range(5)` generate?**
   - **A**: `[0, 1, 2, 3, 4]` - It starts at 0 and goes up to (but not including) 5.

5. **Q: When should you use a while loop instead of a for loop?**
   - **A**: Use while when you don't know how many iterations you need (polling, waiting for a condition). Use for when you have a known collection to process.

### 🚀 Advanced Questions

6. **Q: What is exponential backoff and why is it important?**
   - **A**: Exponential backoff doubles the wait time between retries (1s, 2s, 4s, 8s). It prevents overwhelming services with rapid retry attempts and gives transient issues time to resolve.

7. **Q: How do you prevent infinite loops?**
   - **A**: Always include a maximum retry count or timeout. Use `time.time()` to track elapsed time and break if it exceeds a threshold.

8. **Q: What's the difference between break and continue?**
   - **A**: `break` exits the loop immediately. `continue` skips the rest of the current iteration and moves to the next one.

9. **Q: When should you use a list comprehension vs a regular loop?**
   - **A**: Use list comprehensions for simple transformations and filters (more Pythonic and faster). Use regular loops for complex logic with multiple statements.

10. **Q: What does enumerate(items, start=1) do?**
    - **A**: It provides both index and value while looping, starting the index at 1 instead of 0. Useful for line numbers in logs.

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which keyword skips the rest of the current iteration and moves to the next?**
   - [ ] a) `break`
   - [ ] b) `pass`
   - [x] c) `continue`
   - [ ] d) `skip`

2. **What does `range(5)` generate?**
   - [ ] a) `[1, 2, 3, 4, 5]`
   - [x] b) `[0, 1, 2, 3, 4]`
   - [ ] c) `[1, 2, 3, 4]`
   - [ ] d) `[0, 1, 2, 3, 4, 5]`

3. **If you need to loop until a server returns "Status: OK", which loop is best?**
   - [ ] a) `for`
   - [x] b) `while`
   - [ ] c) `enumerate`
   - [ ] d) `zip`

4. **What is the output of `[x*2 for x in [1, 2, 3]]`?**
   - [ ] a) `[1, 2, 3]`
   - [x] b) `[2, 4, 6]`
   - [ ] c) `[1, 2, 3, 1, 2, 3]`
   - [ ] d) `[3, 6, 9]`

### 🚀 Intermediate Level

5. **When does the else block in a for-else loop execute?**
   - [ ] a) Always after the loop
   - [x] b) Only if the loop completes without break
   - [ ] c) Only if break is called
   - [ ] d) Never

6. **What does enumerate() provide?**
   - [ ] a) Only the index
   - [ ] b) Only the value
   - [x] c) Both index and value
   - [ ] d) The length of the list

7. **What does zip() do?**
   - [ ] a) Compresses files
   - [x] b) Combines multiple lists element-by-element
   - [ ] c) Sorts a list
   - [ ] d) Filters a list

8. **How do you prevent infinite while loops?**
   - [ ] a) Use break
   - [ ] b) Add a timeout
   - [ ] c) Add a maximum retry count
   - [x] d) All of the above

### 🏆 Advanced Level

9. **What's wrong with `for item in list: list.remove(item)`?**
   - [ ] a) Syntax error
   - [x] b) Modifying list while iterating causes index errors
   - [ ] c) Nothing wrong
   - [ ] d) Too slow

10. **What is exponential backoff?**
    - [ ] a) Decreasing wait time between retries
    - [x] b) Doubling wait time between retries (1s, 2s, 4s, 8s)
    - [ ] c) Fixed wait time between retries
    - [ ] d) Random wait time between retries

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **for loop = Assembly Line**: Process each item in a collection
2. **while loop = Waiter**: Keep checking until condition is met
3. **break = Emergency Stop**: Exit loop immediately
4. **continue = Skip Item**: Move to next iteration
5. **List comprehension = High-Speed Filter**: Transform list in one line

### 🛡️ Safety Patterns

1. **Always add timeouts** to while loops
2. **Use for loops** for known collections
3. **Use while loops** for polling/waiting
4. **Never modify a list** while iterating over it
5. **Use for-else** to detect search failures

### 🚀 Production Rules

1. **Use exponential backoff** for retries
2. **Add maximum retry counts** to prevent infinite loops
3. **Use list comprehensions** for simple transformations
4. **Use enumerate** when you need line numbers
5. **Use zip** to combine related lists

---

## 🔗 Next Steps

Now that you can iterate through data efficiently, you're ready to learn how to organize and store it.

**Proceed to**: [Data Structures →](../04-data-structures/readme.md)

---

## 📚 Additional Resources

- [Python for Loops](https://docs.python.org/3/tutorial/controlflow.html#for-statements)
- [Python while Loops](https://docs.python.org/3/reference/compound_stmts.html#while)
- [List Comprehensions](https://docs.python.org/3/tutorial/datastructures.html#list-comprehensions)
- [enumerate() Documentation](https://docs.python.org/3/library/functions.html#enumerate)
- [zip() Documentation](https://docs.python.org/3/library/functions.html#zip)

---

**🎓 Remember**: A newbie copies commands manually. An engineer uses loops to scale. A senior engineer uses loops with timeouts, retries, and exponential backoff. Master loops, and you master automation at scale.
