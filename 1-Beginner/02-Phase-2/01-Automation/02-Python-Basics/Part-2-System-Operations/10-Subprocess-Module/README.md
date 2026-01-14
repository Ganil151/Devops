# Subprocess Module
*Running Shell Commands from Python*

The subprocess module bridges Python and the shell, enabling you to run commands, capture output, and build pipelines—essential for system automation. This is one of the most powerful tools in a DevOps engineer's Python toolkit.

---

## 🎯 Learning Objectives

- Execute shell commands safely from Python
- Capture and process command output (stdout/stderr)
- Handle command errors and timeouts gracefully
- Build command pipelines and process chains
- Understand the security implications of shell execution

---

## 📊 Subprocess Execution Architecture

```mermaid
flowchart TD
    A[Python Script] --> B{subprocess.run or Popen}
    
    B --> C[Create Child Process]
    C --> D[Execute Command]
    D --> E{Exit Code?}
    
    E -->|Exit 0| F[✅ Success]
    E -->|Exit != 0| G[❌ Error]
    
    F --> H[Capture stdout]
    G --> I[Capture stderr]
    
    H --> J[Process Output]
    I --> J
    J --> K[Return to Python]
    
    style A fill:#306998,stroke:#ffe873,color:#fff
    style B fill:#4b8bbe,stroke:#306998,color:#fff
    style F fill:#2ecc71,stroke:#27ae60,color:#fff
    style G fill:#e74c3c,stroke:#c0392b,color:#fff
```

---

## 🔄 Comparison: subprocess.run() vs Popen()

```mermaid
flowchart LR
    subgraph "subprocess.run()"
        A1[Start] --> A2[Execute]
        A2 --> A3[Wait for Completion]
        A3 --> A4[Return Result]
    end
    
    subgraph "subprocess.Popen()"
        B1[Start] --> B2[Execute Async]
        B2 --> B3[Continue Python Code]
        B3 --> B4[Check/Stream Output]
        B4 --> B5[Optional: Wait]
    end
    
    style A1 fill:#306998,stroke:#ffe873,color:#fff
    style B1 fill:#4b8bbe,stroke:#306998,color:#fff
```

| Feature | `run()` | `Popen()` |
|---------|---------|-----------|
| Blocking | Yes | No |
| Simple commands | ✅ Best choice | Overkill |
| Streaming output | ❌ Limited | ✅ Full support |
| Pipelines | ❌ Complex | ✅ Native support |
| Use case | One-shot commands | Long-running/interactive |

---

## 📚 Core Concepts

### 1. Basic Command Execution

```python
import subprocess

# Simple command - pass as list (RECOMMENDED)
result = subprocess.run(
    ["ls", "-la"],
    capture_output=True,
    text=True
)
print(result.stdout)
print(f"Exit code: {result.returncode}")

# Check for errors automatically (raises CalledProcessError)
result = subprocess.run(
    ["git", "status"],
    capture_output=True,
    text=True,
    check=True  # Raises exception on non-zero exit
)

# With shell=True - USE WITH CAUTION!
# Only for shell features like pipes, redirects, env vars
result = subprocess.run(
    "echo $HOME",
    shell=True,
    capture_output=True,
    text=True
)
```

### 2. Understanding Return Object

```python
import subprocess

result = subprocess.run(
    ["docker", "ps"],
    capture_output=True,
    text=True
)

# CompletedProcess attributes
print(f"Command: {result.args}")          # ['docker', 'ps']
print(f"Exit code: {result.returncode}")   # 0 = success
print(f"Standard output: {result.stdout}")  # Command output
print(f"Standard error: {result.stderr}")   # Error messages
```

### 3. Timeout and Error Handling

```python
import subprocess

def run_command_safely(cmd, timeout_seconds=30):
    """Run command with comprehensive error handling."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
            check=True
        )
        return {"success": True, "output": result.stdout}
    
    except subprocess.TimeoutExpired:
        return {"success": False, "error": "Command timed out"}
    
    except subprocess.CalledProcessError as e:
        return {
            "success": False,
            "error": f"Command failed with exit code {e.returncode}",
            "stderr": e.stderr
        }
    
    except FileNotFoundError:
        return {"success": False, "error": "Command not found"}

# Usage
result = run_command_safely(["ping", "-c", "3", "google.com"], timeout_seconds=10)
```

### 4. Real-Time Output Streaming (Popen)

```python
import subprocess
import sys

def stream_command(cmd):
    """Execute command with real-time output streaming."""
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1  # Line buffered
    )
    
    # Stream output line by line
    for line in process.stdout:
        print(line, end='')  # Real-time output
        sys.stdout.flush()
    
    process.wait()
    return process.returncode

# Stream a long-running command
exit_code = stream_command(["docker", "build", "-t", "myapp", "."])
```

### 5. Building Pipelines

```python
import subprocess

# Simulating: ls -la | grep ".py" | wc -l
# Chain commands using Popen

p1 = subprocess.Popen(
    ["ls", "-la"],
    stdout=subprocess.PIPE
)

p2 = subprocess.Popen(
    ["grep", ".py"],
    stdin=p1.stdout,
    stdout=subprocess.PIPE
)

p3 = subprocess.Popen(
    ["wc", "-l"],
    stdin=p2.stdout,
    stdout=subprocess.PIPE,
    text=True
)

# Allow p1 to receive SIGPIPE if p2 exits
p1.stdout.close()
p2.stdout.close()

output, _ = p3.communicate()
print(f"Python files count: {output.strip()}")
```

### 6. Environment Variables

```python
import subprocess
import os

# Pass custom environment
custom_env = os.environ.copy()
custom_env["MY_VAR"] = "custom_value"
custom_env["DEBUG"] = "true"

result = subprocess.run(
    ["printenv"],
    capture_output=True,
    text=True,
    env=custom_env
)
```

---

## ⚠️ Security Best Practices

```mermaid
flowchart TD
    A[User Input] --> B{Validate Input}
    B -->|Invalid| C[Reject]
    B -->|Valid| D[Sanitize]
    D --> E{Use shell=True?}
    E -->|Yes| F[⚠️ HIGH RISK]
    E -->|No| G[Pass as List]
    G --> H[✅ Safe Execution]
    
    style F fill:#e74c3c,stroke:#c0392b,color:#fff
    style H fill:#2ecc71,stroke:#27ae60,color:#fff
```

### ⚠️ Shell Injection Vulnerability

```python
# ❌ DANGEROUS - Shell injection possible
user_input = "; rm -rf /"  # Malicious input
subprocess.run(f"echo {user_input}", shell=True)  # Executes the rm command!

# ✅ SAFE - Command as list, no shell interpretation
user_input = "; rm -rf /"
subprocess.run(["echo", user_input], capture_output=True)  # Prints literally
```

### Security Guidelines

| Practice | Recommendation |
|----------|----------------|
| Command format | Always use list `["cmd", "arg1"]` |
| shell=True | Avoid unless absolutely necessary |
| User input | Always validate and sanitize |
| Timeouts | Always set timeouts for external commands |
| Least privilege | Run with minimal required permissions |

---

## 🛠️ Hands-On Challenges

Master the `subprocess` module by building these practical DevOps automation tools.

| Challenge | Description | Starter Code | Solution |
| :--- | :--- | :--- | :--- |
| **01. Server Health Checker** | Build a tool that pings servers and parses latency information. | [Link](./challenges/challenge_01_health_checker.py) | [Link](./challenges/solutions/solution_01_health_checker.py) |
| **02. Git Status Checker** | Create a script that detects uncommitted changes in any git repository. | [Link](./challenges/challenge_02_git_checker.py) | [Link](./challenges/solutions/solution_02_git_checker.py) |
| **03. Docker Container Manager** | Automate container discovery by parsing Docker CLI output as JSON. | [Link](./challenges/challenge_03_docker_manager.py) | [Link](./challenges/solutions/solution_03_docker_manager.py) |
| **04. Real-Time Log Monitor** | Stream log files in real-time and trigger alerts on error patterns. | [Link](./challenges/challenge_04_log_monitor.py) | [Link](./challenges/solutions/solution_04_log_monitor.py) |

> **Pro Tip**: Always pass your command as a list (e.g., `["ls", "-l"]`) to prevent shell injection vulnerabilities in your automation scripts.

---

## 📖 Real-World Story: The Deployment Script

**Scenario**: A team manually ran 15 different commands to deploy their application:
1. Pull latest code
2. Run tests
3. Build Docker image
4. Push to registry
5. Update Kubernetes deployment
6. Check rollout status
7. Run smoke tests

**Problem**: Manual execution led to missed steps and inconsistent deployments.

**Solution**: A Python automation script using `subprocess`:

```python
import subprocess
import sys

def run_step(name, command):
    """Run a deployment step with logging."""
    print(f"\n{'='*50}")
    print(f"🚀 {name}")
    print(f"{'='*50}")
    
    result = subprocess.run(
        command,
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print(f"❌ FAILED: {result.stderr}")
        sys.exit(1)
    
    print(f"✅ Success")
    return result.stdout

# Deployment pipeline
run_step("Pull Latest Code", ["git", "pull", "origin", "main"])
run_step("Run Tests", ["python", "-m", "pytest", "tests/"])
run_step("Build Image", ["docker", "build", "-t", "myapp:latest", "."])
run_step("Push Image", ["docker", "push", "myapp:latest"])
run_step("Deploy to K8s", ["kubectl", "apply", "-f", "k8s/"])
run_step("Check Rollout", ["kubectl", "rollout", "status", "deployment/myapp"])

print("\n🎉 Deployment Complete!")
```

**Outcome**: Deployment time reduced from 45 minutes to 5 minutes, with zero missed steps.

---

## ❓ Interview Questions

1. **Why should you avoid using `shell=True` with subprocess?**
   > Security risk—it enables shell injection attacks where malicious input can execute arbitrary commands. Always pass commands as a list of arguments instead.

2. **What's the difference between `subprocess.run()` and `subprocess.Popen()`?**
   > `run()` is synchronous—it waits for the command to complete before returning. `Popen()` is asynchronous—it starts the process and returns immediately, allowing you to stream output or run Python code in parallel.

3. **How do you capture both stdout and stderr from a subprocess?**
   > Use `capture_output=True` (Python 3.7+) or `stdout=subprocess.PIPE, stderr=subprocess.PIPE`. Add `text=True` to get strings instead of bytes.

4. **How would you handle a subprocess that might hang indefinitely?**
   > Use the `timeout` parameter: `subprocess.run(cmd, timeout=30)`. This raises `TimeoutExpired` if the command exceeds the timeout, allowing graceful handling.

5. **When would you use `check=True` in subprocess.run()?**
   > When you want the script to fail fast on command errors. It raises `CalledProcessError` for non-zero exit codes, making error handling explicit rather than silently continuing.

6. **How do you pass environment variables to a subprocess?**
   > Use the `env` parameter with a dictionary. Copy `os.environ` first to preserve existing variables: `env = os.environ.copy(); env["NEW_VAR"] = "value"`.

7. **Explain how to build a pipeline of commands (like `cmd1 | cmd2 | cmd3`).**
   > Use multiple `Popen` calls, connecting stdout of one to stdin of the next. Close intermediate pipes to handle SIGPIPE correctly. Use the final process's `communicate()` to get output.

---

## 🧠 Quiz

1. What does `check=True` do in subprocess.run()?
   - a) Validates command exists
   - b) Raises exception on non-zero exit ✅
   - c) Enables verbose mode
   - d) Checks syntax

2. How do you capture command output as strings (not bytes)?
   - a) `capture_output=True` only
   - b) `text=True` ✅
   - c) `string=True`
   - d) `decode=True`

3. Which is safer when running shell commands?
   - a) `subprocess.run("ls " + user_input, shell=True)`
   - b) `subprocess.run(["ls", user_input])` ✅
   - c) Both are equally safe
   - d) Neither is safe

4. What exception is raised when a command times out?
   - a) `TimeoutError`
   - b) `subprocess.TimeoutExpired` ✅
   - c) `CommandTimeout`
   - d) `ProcessTimeout`

5. How do you stream output in real-time?
   - a) Use `subprocess.run()` with `stream=True`
   - b) Use `subprocess.Popen()` with `stdout=PIPE` ✅
   - c) Use `subprocess.call()` with `live=True`
   - d) Real-time streaming is not possible

6. What does `returncode` of 0 typically mean?
   - a) Error occurred
   - b) Command not found
   - c) Success ✅
   - d) Warning

7. Which attribute contains error messages from a failed command?
   - a) `result.error`
   - b) `result.stderr` ✅
   - c) `result.errors`
   - d) `result.exception`

8. How do you run a command in a specific directory?
   - a) `subprocess.run(["cd", dir_path, "&&", "cmd"])`
   - b) `subprocess.run(["cmd"], cwd=dir_path)` ✅
   - c) `subprocess.run(["cmd"], directory=dir_path)`
   - d) `subprocess.run(["cmd"], path=dir_path)`

---

## 🔗 Related Topics

| Module | Relationship |
|--------|-------------|
| [Error Handling](../05-Error-Handling/README.md) | Exception handling for subprocess failures |
| [Logging Basics](../14-Logging-Basics/README.md) | Logging command execution for debugging |
| [Environment Variables](../08-Environment-Variables/README.md) | Passing env vars to subprocesses |

---

**Next Step**: [Pathlib Basics →](../11-Pathlib-Basics/README.md)
