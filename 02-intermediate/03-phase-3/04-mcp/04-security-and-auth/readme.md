# 04: Security and Authorization

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: Interview Questions ➡️](../05-interview-questions-and-quizzes/readme.md)**

---

# 🛡️ Securing Agentic Workflows

Connecting an LLM to your infrastructure changes the threat model of your engineering organization. Unlike a human engineer, an AI agent might be susceptible to **Prompt Injection** or **Hallucinated Parameters**. This module defines the defense-in-depth strategy required for safe MCP operations.

## 🛑 The Primary Defense: Human-in-the-Loop (HITL)

The most critical security feature of MCP is not cryptographic; it is **UX-driven**. The protocol is designed so that the Server *cannot* execute code without the Client's permission, and the Client ensures the User is in control.

### The Approval Flow

1.  **Intent**: AI says, "I want to call `restart_server(target='prod-db')`."
2.  **Interception**: The MCP Host (e.g., Claude Desktop) captures this JSON-RPC message.
3.  **Display**: The Host renders a UI card: "Claude wants to run `restart_server`. Allow?"
4.  **Authorization**: The Human clicks "Approve".
5.  **Execution**: Only *then* is the request sent to the Server.

> **🔒 Security Rule #1**: Never run an MCP Host in "Auto-Approve" mode for tools that modify state (POST/PUT/DELETE operations).

---

## 🦠 Identifying Threats

| Threat | Description | MCP Mitigation |
| :--- | :--- | :--- |
| **Prompt Injection** | Malicious text in a log file tricks the AI into doing something else. | **Structured Inputs**. MCP tools don't take raw shell commands; they take strict JSON arguments (e.g., `filename`, not `command_string`). |
| **Hallucination** | The AI invents a flag or parameter that doesn't exist (e.g., `--force-delete-all`). | **JSON Schema Validation**. The Client validates arguments against the Server's schema *before* sending the request. |
| **Excessive Scope** | The AI deletes the wrong database. | **Principle of Least Privilege**. The MCP Server process should run with a restricted IAM Role/Service Account, not `admin`. |

---

## 👷 Implementing "Guardrails" in Code

Don't rely solely on the AI to be smart. Enforce safety inside your MCP Server code.

### 1. Validate 'Safe' Paths
If you have a file-reading tool, ensure it can't read `/etc/shadow`.

```python
import os

@mcp.tool()
def read_log_file(filename: str):
    """Safely reads a log file from the logs directory."""
    base_dir = "/var/log/myapp"
    # Resolve the absolute path
    abs_path = os.path.abspath(os.path.join(base_dir, filename))
    
    # Security Check: Ensure the resolved path is still inside base_dir
    if not abs_path.startswith(base_dir):
        return "Error: Access Denied. You cannot traverse outside the log directory."
        
    return open(abs_path).read()
```

### 2. The "Dry Run" Pattern
For complex operations, expose a `dry_run` boolean argument or separate tool.

```python
@mcp.tool()
def scale_cluster(nodes: int, dry_run: bool = True):
    """Adjusts cluster size. Defaults to dry_run for safety."""
    if nodes > 10 and not dry_run:
        return "Error: Scaling above 10 nodes requires manual override."
        
    if dry_run:
        return f"[DRY RUN] Would scale cluster to {nodes} nodes."
        
    # ... perform actual scaling ...
```

---

## 📋 The Security Checklist

Before "installing" an MCP server found on GitHub or building your own for the team:

-   [ ] **Code Review**: Have you read the source code of the server? (It runs as *you*!)
-   [ ] **Dependency Check**: Does it import malicious packages?
-   [ ] **Credential Isolation**: Does it require your AWS keys? If so, does it use the `default` profile or a restricted one?
-   [ ] **Network**: Does it expose an SSE endpoint to the public internet? (If so, it must be behind an auth proxy like Nginx with mTLS).
-   [ ] **Input Sanitization**: Does the server blindly pass string arguments to `subprocess.run(shell=True)`? (Automatic FAIL).

---

## 📚 Knowledge Check

**1. What prevents an MCP tool from executing `rm -rf /` if the AI accidentally requests it?**
*   [ ] The AI is too smart to do that.
*   [ ] The MCP Protocol encryption.
*   [ ] The "Human-in-the-loop" approval step and the Host's OS permissions.

**2. Why are Structured Inputs (JSON) safer than allowing the AI to generate shell scripts?**
*   [ ] JSON is faster to parse.
*   [ ] It prevents command injection attacks where the AI chains commands (e.g., `; cat /etc/passwd`).
*   [ ] It looks cooler.

