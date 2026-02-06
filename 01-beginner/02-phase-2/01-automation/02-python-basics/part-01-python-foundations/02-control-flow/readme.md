# 🚦 Control Flow: The Decision-Making Engine

> **"A script without control flow is a static list. A script with professional control flow is an intelligent agent capable of remediating infrastructure, validating global states, and managing massive server inventories."**

![Control Flow Logic](../02-control-flow/assets/control-flow-logic.png)

---

## 🧠 The Mental Model: Control Flow as Traffic Signals

**The Junior Struggle**: "Why can't I just run all commands in sequence?"

**The Engineer Solution**: Infrastructure is **dynamic**. Servers go down, APIs rate-limit, configs change. Your scripts must **adapt** to conditions.

### 🏗️ The Infrastructure Analogy

Think of control flow like **traffic signals** at an intersection:

| Control Structure | Traffic Analogy | DevOps Use Case |
|:------------------|:----------------|:----------------|
| **if/else** | Red light / Green light | Check if server is healthy before deploying |
| **elif** | Yellow light (warning) | Handle different error codes differently |
| **for loop** | Roundabout (process each car) | Iterate through server inventory |
| **while loop** | Traffic light cycle | Poll API until resource is ready |
| **break** | Emergency stop | Exit loop when critical error found |
| **continue** | Skip this car | Skip unhealthy servers in deployment |

**The Key Insight**: Just like traffic signals prevent collisions by controlling flow, control structures prevent infrastructure disasters by making intelligent decisions.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "I'll just run commands in order"
- "If something fails, I'll fix it manually"
- "Loops are just for counting"

**After this module**, you'll understand:
- **Conditional logic** prevents destructive operations
- **Guard clauses** make code readable and safe
- **Loops** process hundreds of servers automatically
- **Pattern matching** handles complex decision trees

**The Difference**: Your scripts will handle edge cases, validate inputs, and adapt to changing infrastructure.

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Master Conditional Logic**: if/elif/else for decision-making
- ✅ **Apply Guard Clauses**: Avoid nested if-hell, exit early
- ✅ **Use Truthy/Falsy Values**: Pythonic condition checking
- ✅ **Implement Pattern Matching**: Modern match/case for complex logic
- ✅ **Combine Logical Operators**: and/or/not for multi-condition checks
- ✅ **Write Ternary Expressions**: Single-line conditionals
- ✅ **Understand Loop Control**: break, continue, for-else

---

## 🏗️ Part 1: The if Statement - Truth Testing

### 🧠 The Mental Model: The Gatekeeper

**The Concept**: An `if` statement is a gatekeeper that only lets code through if a condition is True.

### 🔧 Basic if/else Structure

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Simple if/else
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

server_status = "running"

if server_status == "running":
    print("✅ Server is healthy")
else:
    print("❌ Server is down")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Multi-condition with elif
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cpu_percent = 85.5

if cpu_percent > 90:
    status = "🚨 CRITICAL"
    action = "Scale up immediately"
elif cpu_percent > 75:
    status = "⚠️ WARNING"
    action = "Monitor closely"
elif cpu_percent > 50:
    status = "ℹ️ MODERATE"
    action = "Normal operation"
else:
    status = "✅ HEALTHY"
    action = "No action needed"

print(f"Status: {status} - {action}")
```

### 💡 Truthy and Falsy Values

**The Junior Question**: "Do I always need to write `if x == True`?"

**The Engineer Answer**: No! Python has **truthy** and **falsy** values. Use them for cleaner code.

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Falsy Values (evaluate to False)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# None
if None:
    print("This never runs")

# False
if False:
    print("This never runs")

# Zero (0, 0.0)
if 0:
    print("This never runs")

# Empty collections ([], {}, "", ())
if []:
    print("This never runs")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Truthy Values (everything else)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Non-zero numbers
if 1:
    print("This runs")

# Non-empty collections
if ["server-01"]:
    print("This runs")

# Non-empty strings
if "production":
    print("This runs")
```

### 🚀 Professional Pattern: Checking for Empty Collections

```python
from typing import List

def deploy_to_servers(servers: List[str]) -> None:
    """
    Deploy application to a list of servers.
    
    Args:
        servers: List of server hostnames
    """
    # ❌ Junior way
    if len(servers) > 0:
        print(f"Deploying to {len(servers)} servers")
    
    # ✅ Engineer way (Pythonic)
    if servers:
        print(f"Deploying to {len(servers)} servers")
    else:
        print("⚠️ No servers found in inventory")
        return

# 🎯 Usage
active_servers = get_server_inventory()
deploy_to_servers(active_servers)
```

**💡 Pro Tip**: Use truthy/falsy checks for collections. It's more readable and Pythonic.

---

## 🛡️ Part 2: Guard Clauses - The Early Exit Pattern

### 🧠 The Mental Model: The Security Checkpoint

**The Problem**: Nested if statements create the "Arrowhead Antipattern" (code that looks like `>>>>>>>>`).

**The Solution**: Guard clauses validate conditions and exit early if they fail.

### 🔧 The Arrowhead Antipattern

```python
# ❌ Nested If Hell (Hard to read and maintain)
def backup_database(server, is_authenticated, disk_space):
    if is_authenticated:
        if server is not None:
            if server.is_alive():
                if disk_space > 100:
                    if server.has_backup_tool():
                        # Actual backup logic buried 5 levels deep
                        print(f"Backing up {server.name}")
                        return True
                    else:
                        print("Backup tool not installed")
                        return False
                else:
                    print("Insufficient disk space")
                    return False
            else:
                print("Server not responding")
                return False
        else:
            print("Server is None")
            return False
    else:
        print("Not authenticated")
        return False
```

### ✅ The Engineer Way: Guard Clauses

```python
# ✅ Guard Clauses (Clean, flat, professional)
def backup_database(server, is_authenticated: bool, disk_space: int) -> bool:
    """
    Backup a database server.
    
    Args:
        server: Server object
        is_authenticated: Whether user is authenticated
        disk_space: Available disk space in GB
    
    Returns:
        True if backup succeeded, False otherwise
    """
    # Guard clause: Authentication check
    if not is_authenticated:
        print("❌ Not authenticated")
        return False
    
    # Guard clause: Server exists
    if server is None:
        print("❌ Server is None")
        return False
    
    # Guard clause: Server is alive
    if not server.is_alive():
        print(f"❌ Server {server.name} not responding")
        return False
    
    # Guard clause: Disk space check
    if disk_space <= 100:
        print(f"❌ Insufficient disk space: {disk_space}GB")
        return False
    
    # Guard clause: Backup tool check
    if not server.has_backup_tool():
        print(f"❌ Backup tool not installed on {server.name}")
        return False
    
    # ✅ All checks passed - do the actual work
    print(f"✅ Backing up {server.name}")
    # Backup logic here
    return True
```

**💡 Pro Tip**: Guard clauses make code **self-documenting**. Each check clearly states a requirement.

---

## 🔗 Part 3: Logical Operators

### 🧠 The Mental Model: The Logic Gates

**The Use Case**: Combine multiple conditions into a single check.

### 🔧 and, or, not Operators

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# AND: Both conditions must be True
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

is_admin = True
is_read_only = False

if is_admin and not is_read_only:
    print("✅ Permission granted to delete database")
else:
    print("❌ Permission denied")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OR: At least one condition must be True
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

env = "staging"

if env == "development" or env == "staging":
    print("🔧 Non-production environment detected")
    debug_mode = True
else:
    print("🚀 Production environment")
    debug_mode = False

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NOT: Reverse the boolean value
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

maintenance_mode = False

if not maintenance_mode:
    print("✅ System is operational")
    accept_requests()
```

### 🚀 Professional Pattern: Multi-Factor Validation

```python
from typing import Optional

def can_deploy(
    user: str,
    environment: str,
    tests_passing: bool,
    approval_count: int
) -> bool:
    """
    Check if deployment is allowed.
    
    Args:
        user: Username attempting deployment
        environment: Target environment
        tests_passing: Whether all tests passed
        approval_count: Number of approvals received
    
    Returns:
        True if deployment is allowed
    """
    # Production requires strict checks
    if environment == "production":
        return (
            user in ["alice", "bob"] and
            tests_passing and
            approval_count >= 2
        )
    
    # Staging has relaxed requirements
    elif environment == "staging":
        return tests_passing
    
    # Development has no restrictions
    else:
        return True


# 🎯 Usage
if can_deploy("alice", "production", True, 2):
    print("✅ Deploying to production")
else:
    print("❌ Deployment blocked - requirements not met")
```

**💡 Pro Tip**: Use parentheses to make complex conditions readable.

---

## 🎯 Part 4: Ternary Operator - Single-Line Conditionals

### 🧠 The Mental Model: The Shortcut

**The Use Case**: Simple if/else logic in one line.

**Syntax**: `value_if_true if condition else value_if_false`

### 🔧 Ternary Examples

```python
import os

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment-based configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ❌ Verbose way
if os.getenv("DEBUG") == "True":
    log_level = "DEBUG"
else:
    log_level = "INFO"

# ✅ Ternary way
log_level = "DEBUG" if os.getenv("DEBUG") == "True" else "INFO"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Status message based on condition
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

server_count = 5
message = f"Deploying to {server_count} server{'s' if server_count != 1 else ''}"
# Output: "Deploying to 5 servers"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Default values
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

port = int(os.getenv("PORT")) if os.getenv("PORT") else 8080
region = os.getenv("AWS_REGION") if os.getenv("AWS_REGION") else "us-east-1"
```

**💡 Pro Tip**: Use ternary operators for simple assignments. For complex logic, use full if/else blocks.

---

## 🎲 Part 5: Pattern Matching (match/case)

### 🧠 The Mental Model: The Router

**The Use Case**: Handle multiple specific values without if/elif chains.

**Available**: Python 3.10+

### 🔧 HTTP Status Code Handler

```python
def handle_http_status(status_code: int) -> str:
    """
    Handle HTTP status codes with pattern matching.
    
    Args:
        status_code: HTTP status code
    
    Returns:
        Action to take based on status code
    """
    match status_code:
        case 200 | 201 | 204:
            return "✅ Success - continue"
        
        case 400 | 401 | 403:
            return "❌ Client error - check credentials"
        
        case 404:
            return "⚠️ Not found - resource may have been deleted"
        
        case 429:
            return "⏸️ Rate limited - implement exponential backoff"
        
        case 500 | 502 | 503:
            return "🚨 Server error - retry with backoff"
        
        case 504:
            return "⏱️ Gateway timeout - increase timeout or retry"
        
        case _:
            return f"❓ Unknown status code: {status_code}"


# 🎯 Usage
response_code = 429
action = handle_http_status(response_code)
print(action)  # "⏸️ Rate limited - implement exponential backoff"
```

### 🚀 Professional Pattern: Deployment Action Router

```python
from typing import Dict, Any

def route_deployment_action(event: Dict[str, Any]) -> None:
    """
    Route deployment events to appropriate handlers.
    
    Args:
        event: Deployment event dictionary
    """
    match event:
        case {"type": "deploy", "environment": "production"}:
            print("🚀 Production deployment - running full validation")
            run_production_deployment(event)
        
        case {"type": "deploy", "environment": env}:
            print(f"🔧 Deploying to {env}")
            run_standard_deployment(event)
        
        case {"type": "rollback", "version": version}:
            print(f"⏮️ Rolling back to version {version}")
            run_rollback(version)
        
        case {"type": "scale", "replicas": count}:
            print(f"📊 Scaling to {count} replicas")
            scale_deployment(count)
        
        case _:
            print(f"❓ Unknown event type: {event.get('type')}")


# 🎯 Usage
event = {"type": "deploy", "environment": "production", "version": "v2.0"}
route_deployment_action(event)
```

**💡 Pro Tip**: Use match/case for complex routing logic. It's more readable than long if/elif chains.

---

## 🔄 Part 6: Loop Control (break, continue, for-else)

### 🧠 The Mental Model: The Assembly Line Controller

**The Use Case**: Control how loops process items.

### 🔧 break - Emergency Stop

```python
# Find first unhealthy server and stop
servers = ["web-01", "web-02", "db-01", "cache-01"]

for server in servers:
    health = check_server_health(server)
    
    if health == "critical":
        print(f"🚨 Critical issue found on {server}")
        print("Stopping deployment")
        break  # Exit loop immediately
    
    print(f"✅ {server} is healthy")
```

### 🔧 continue - Skip Current Item

```python
# Deploy only to healthy servers
servers = [
    {"name": "web-01", "status": "running"},
    {"name": "web-02", "status": "stopped"},
    {"name": "db-01", "status": "running"},
]

for server in servers:
    # Skip stopped servers
    if server["status"] != "running":
        print(f"⏭️ Skipping {server['name']} - status: {server['status']}")
        continue  # Skip to next iteration
    
    print(f"🚀 Deploying to {server['name']}")
    deploy(server)
```

### 🔧 for-else - Success Indicator

```python
# Search for a specific server
target_ip = "10.0.1.100"
servers = [
    {"name": "web-01", "ip": "10.0.1.5"},
    {"name": "web-02", "ip": "10.0.1.10"},
    {"name": "db-01", "ip": "10.0.1.15"},
]

for server in servers:
    if server["ip"] == target_ip:
        print(f"✅ Found server: {server['name']}")
        break
else:
    # This runs only if loop completed without break
    print(f"❌ No server found with IP {target_ip}")
```

**💡 Pro Tip**: The `else` clause on loops is confusing. Many teams avoid it for clarity.

---

## 🏆 Part 7: Real-World DevOps Stories

### 📖 Story 1: The Infinite Loop that Melted a Sandbox API

**The Scenario**: A junior engineer wrote a `while True` loop to poll a cloud API for status changes.

**The Problem**: They forgot to add `time.sleep()`. The script sent **50,000 requests in 30 seconds**, DDoS-ing the internal dev API and triggering a security lockout.

**The Code**:
```python
# ❌ The disaster
while True:
    status = api.get_deployment_status()
    if status == "complete":
        break
    # Missing: time.sleep()!
```

**The Solution**:
```python
# ✅ Professional polling with backoff
import time

max_attempts = 60
attempt = 0

while attempt < max_attempts:
    status = api.get_deployment_status()
    
    if status == "complete":
        print("✅ Deployment complete")
        break
    
    attempt += 1
    wait_time = min(2 ** attempt, 60)  # Exponential backoff, max 60s
    print(f"⏳ Waiting {wait_time}s... (attempt {attempt}/{max_attempts})")
    time.sleep(wait_time)
else:
    print("❌ Deployment timed out after 60 attempts")
```

**The Lesson**: Always include:
1. **Maximum attempts** (exit condition)
2. **Sleep/backoff** (rate limiting)
3. **Timeout handling** (graceful failure)

---

### 📖 Story 2: The Guard Clause Refactor

**The Scenario**: A deployment script had 8 levels of nested if statements. Nobody could understand it.

**The Impact**: A bug in the deepest level went unnoticed for months, causing silent deployment failures.

**The Solution**: Refactored to guard clauses, reducing from 8 levels to 1 level of indentation.

**The Outcome**: Bug was immediately obvious. Code review time dropped from 30 minutes to 5 minutes.

---

## ❓ Interview Preparation

### 🎯 Core Concepts

1. **Q: Why are guard clauses preferred over nested if statements?**
   - **A**: Guard clauses reduce cognitive load by handling errors at the top and exiting early. The functional logic stays at a single indentation level, making it easier to read, test, and maintain.

2. **Q: What is the difference between `break` and `continue`?**
   - **A**: `break` exits the loop entirely. `continue` skips the current iteration and moves to the next one. Use `break` for critical errors, `continue` for skipping invalid items.

3. **Q: When would you use `match-case` instead of `if/elif`?**
   - **A**: Use `match-case` when you have 4+ conditions, need pattern matching on data structures, or want to destructure complex objects. It's more readable for routing logic.

4. **Q: What is the danger of a `while` loop in cloud automation?**
   - **A**: `while` loops can become infinite if the exit condition is never met. Always implement maximum attempts, timeout counters, and exponential backoff.

5. **Q: What are truthy and falsy values?**
   - **A**: Falsy values (None, False, 0, empty collections) evaluate to False in boolean context. Everything else is truthy. This allows Pythonic checks like `if servers:` instead of `if len(servers) > 0:`.

### 🚀 Advanced Questions

6. **Q: What does the `else` clause on a `for` loop do?**
   - **A**: It runs only if the loop completes normally without hitting a `break`. Useful for "search and not found" patterns, but many teams avoid it for clarity.

7. **Q: How do you implement exponential backoff in a retry loop?**
   - **A**: Use `wait_time = min(2 ** attempt, max_wait)` to double the wait time each attempt, with a maximum cap to prevent excessive delays.

8. **Q: What's the difference between `if x:` and `if x is True:`?**
   - **A**: `if x:` checks if x is truthy (Pythonic). `if x is True:` checks if x is literally the boolean True object (rarely needed). Use the former in most cases.

9. **Q: Why use type hints in conditional logic?**
   - **A**: Type hints prevent logic errors where incompatible types are compared (e.g., string vs integer). Tools like mypy catch these errors before runtime.

10. **Q: When should you use ternary operators?**
    - **A**: For simple assignments based on a single condition. Avoid for complex logic or when it hurts readability.

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which value is considered "Falsy"?**
   - [ ] a) `"False"` (string)
   - [x] b) `[]` (empty list)
   - [ ] c) `[0]` (list with zero)
   - [ ] d) `1`

2. **What does `continue` do in a loop?**
   - [ ] a) Exits the loop
   - [x] b) Skips to the next iteration
   - [ ] c) Does nothing
   - [ ] d) Raises an error

3. **What is the result of `status = "OK" if cpu < 80 else "ALARM"` when cpu=60?**
   - [x] a) `"OK"`
   - [ ] b) `"ALARM"`
   - [ ] c) `60`
   - [ ] d) Error

4. **Which operator checks if BOTH conditions are True?**
   - [x] a) `and`
   - [ ] b) `or`
   - [ ] c) `not`
   - [ ] d) `xor`

### 🚀 Intermediate Level

5. **What does the `else` clause on a `for` loop do?**
   - [ ] a) Runs if the loop encounters a `break`
   - [x] b) Runs only if the loop completes without `break`
   - [ ] c) Always runs after the loop
   - [ ] d) It's a syntax error

6. **What is a guard clause?**
   - [ ] a) A try/except block
   - [x] b) An early return that exits when conditions aren't met
   - [ ] c) A security check
   - [ ] d) A loop control statement

7. **Which Python version introduced `match-case`?**
   - [ ] a) 3.6
   - [ ] b) 3.8
   - [x] c) 3.10
   - [ ] d) 3.12

8. **What's the Pythonic way to check if a list is not empty?**
   - [ ] a) `if len(my_list) > 0:`
   - [x] b) `if my_list:`
   - [ ] c) `if my_list != []:`
   - [ ] d) `if not my_list.is_empty():`

### 🏆 Advanced Level

9. **What's the maximum recommended nesting depth for if statements?**
   - [x] a) 1-2 levels (use guard clauses instead)
   - [ ] b) 5 levels
   - [ ] c) No limit
   - [ ] d) 3 levels

10. **What does `if x is True:` check?**
    - [ ] a) If x is truthy
    - [x] b) If x is literally the boolean True object
    - [ ] c) Same as `if x:`
    - [ ] d) If x equals 1

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Control Flow = Traffic Signals**: Prevent infrastructure collisions
2. **Guard Clauses = Security Checkpoints**: Validate early, exit fast
3. **Truthy/Falsy = Pythonic Checks**: Cleaner than explicit comparisons
4. **Pattern Matching = Router**: Handle complex decision trees

### 🛡️ Safety Patterns

1. **Use guard clauses** to avoid nested if-hell
2. **Check for empty collections** with truthy/falsy
3. **Always add exit conditions** to while loops
4. **Implement exponential backoff** for polling
5. **Use type hints** to prevent comparison errors

### 🚀 Production Rules

1. **Maximum 1-2 levels** of if nesting (use guard clauses)
2. **Always include timeout/max attempts** in while loops
3. **Add sleep/backoff** to polling loops
4. **Use match/case** for 4+ conditions (Python 3.10+)
5. **Prefer truthy/falsy checks** over explicit comparisons

---

## 🔗 Next Steps

Now that you can make decisions, you're ready to learn how to repeat operations efficiently.

**Proceed to**: [Iterative Logic and Loops →](readme.md)

---

## 📚 Additional Resources

- [Python Control Flow Documentation](https://docs.python.org/3/tutorial/controlflow.html)
- [PEP 634: Structural Pattern Matching](https://www.python.org/dev/peps/pep-0634/)
- [Guard Clauses Pattern](https://refactoring.guru/replace-nested-conditional-with-guard-clauses)
- [Truthy and Falsy Values](https://docs.python.org/3/library/stdtypes.html#truth-value-testing)

---

**🎓 Remember**: A newbie writes sequential scripts. An engineer writes adaptive scripts that handle edge cases, validate inputs, and make intelligent decisions. Master control flow, and you master infrastructure automation.
