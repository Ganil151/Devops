# 🧪 MCP Fundamentals: Level Up Challenges

Test your understanding of the Model Context Protocol with these conceptual and architectural challenges.

---

## 🧩 Challenge 1: The Primitive Matcher
Identify whether the following DevOps scenarios should be implemented as a **Resource**, a **Tool**, or a **Prompt**.

1.  Listing all the names of Docker containers currently running.
2.  Actually stopping a specific Docker container.
3.  A predefined set of instructions that guides the AI on how to perform a "Production Readiness Review".
4.  Reading the `.yaml` manifest of a Kubernetes Service.
5.  Executing a Terraform apply on a specific module.
6.  Provisions a "Daily Briefing" that summarizes all failed CI/CD jobs from the last 24 hours.

---

## 🏗️ Challenge 2: Architect the "Shadow IT" Detector
**Scenario**: Your company has an issue where developers are spinning up AWS EC2 instances and forgetting to turn them off, leading to massive bills.

**Task**: Design an MCP-based solution.
1.  What would the **MCP Server** be called?
2.  List 2 **Resources** the server should expose.
3.  List 2 **Tools** the server should provide to help remediate the issue.
4.  What **Transport** method would you use if this was running on a Central Security Team's server shared by multiple departments?

---

## 🛡️ Challenge 3: Security Auditor
**Scenario**: You are reviewing an MCP tool definition written by a Junior SRE:

```python
@mcp.tool()
def execute_system_command(command: str):
    """Executes any shell command on the host."""
    return subprocess.check_output(command, shell=True)
```

1.  Why is this a **CRITICAL** security risk?
2.  How would you refactor this to follow the principle of **Least Privilege**?
3.  Rewrite the tool name and docstring to be more specific (e.g., restricted to viewing log files only).

---

## 🚀 Challenge 4: Zero to Agentic
**Scenario**: A 2 AM "Incident" occurred. The database is slow.

Describe the **Agentic Loop** using MCP primitives:
1.  What **Resource** does the AI read first to understand the situation?
2.  The AI suspects a slow query. What **Tool** does it call to verify this?
3.  The AI finds a long-running process. It asks the **Host** for permission. What happens next?
4.  Once approved, what **Tool** is used to solve the problem?

---

## 💡 Discussion / Research Bonus
- Go to the [Official MCP Documentation](https://modelcontextprotocol.io) and find out what the "Sampling" capability is. Explain in one sentence how it differs from a Tool.

---
### 🏁 Done?
When you've completed these, head over to **[02: Building MCP Servers](../02-building-mcp-servers/readme.md)** to start implementation!
