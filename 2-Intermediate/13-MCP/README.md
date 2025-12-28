# Model Context Protocol (MCP) - Intermediate Level

This module shifts from *using* MCP to *building* custom MCP servers. We focus on Python/Node.js SDKs, secure tool implementation, and Kubernetes integration.

---

## 1. Building a Custom MCP Server (Python)

To build a custom server, you define **Tools** that perform specific DevOps actions.

### 📝 Example: Kubernetes Pod Inspector
This tool allows an AI to check the status of a specific pod without the user manually running `kubectl`.

```python
from mcp.server.fastmcp import FastMCP
import subprocess

mcp = FastMCP("K8s-Helper")

@mcp.tool()
def get_pod_status(pod_name: str, namespace: str = "default") -> str:
    """Get the status of a specific Kubernetes pod."""
    try:
        result = subprocess.check_output(
            ["kubectl", "get", "pod", pod_name, "-n", namespace, "-o", "jsonpath={.status.phase}"]
        )
        return f"Status of {pod_name}: {result.decode('utf-8')}"
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    mcp.run()
```

---

## 2. Secure Credential Handling

When building MCP servers that interact with Cloud APIs (AWS, Azure, GCP), **never** hardcode secrets in the server code.

### ✅ Best Practices:
1. **Environment Variables**: Use `os.environ.get("AWS_ACCESS_KEY_ID")`.
2. **Local Credential Files**: Rely on `~/.aws/credentials` or `~/.kube/config`.
3. **IAM Roles**: In production (Advanced), use IAM instance profiles so no keys are needed at all.

---

## 3. Advanced Tool Patterns: Progress Reporting
For long-running DevOps tasks (like a Terraform apply), use MCP's progress notification features to keep the user informed.

---

## Real-World Scenarios

### Scenario 1: The "Self-Cleaning" Dev Environment
**Task**: Create a custom MCP server that finds and deletes unused Docker volumes and images.
**Solution**: Build a tool `prune_docker_resources` that wraps the `docker system prune` command. This allows the AI assistant to help developers save disk space by running one command.

### Scenario 2: Secure Secret Discovery
**Task**: I need to find which secret in AWS Secret Manager contains the string 'PROD_DB'.
**Solution**: An MCP tool `search_secrets` that iterates through metadata (not values) and returns only the secret *names* for the AI to analyze.

---

## Interview Questions (Intermediate)

1. **How do you pass arguments to an MCP tool?**
   - Through a JSON schema defined in the tool's decorator (e.g., `@mcp.tool()`). The AI host automatically parses these requirements.
2. **What is 'FastMCP'?**
   - A high-level SDK (available in Python/TypeScript) that simplifies MCP server creation by handling the protocol boilerplate automatically.
3. **Why use MCP for K8s management instead of just giving the AI a terminal?**
   - MCP allows for **structured** interaction. You can restrict the tool to `read-only` commands, making it safer than giving full shell access.
4. **How does an MCP server handle multiple simultaneous clients?**
   - Most MCP servers are built on asynchronous frameworks (like `asyncio`), allowing them to handle multiple concurrent requests efficiently.

---

## Knowledge Quiz

1. **Which Python library is commonly used for rapid MCP development?**
   - A) Django
   - B) Flask
   - C) FastMCP
   - D) Numpy

2. **Where should AWS keys be stored when running an MCP server locally?**
   - A) Directly in the Python source code
   - B) Inside the `mcp_config.json` file
   - C) In the standard `~/.aws/credentials` file
   - D) On a sticky note

3. **In the Kubernetes inspector example, what library is used to run shell commands?**
   - A) Request
   - B) Subprocess
   - C) Pandas
   - D) Matplotlib

4. **The `@mcp.tool()` decorator is used to:**
   - A) Install a new tool
   - B) Register a Python function so the AI can call it
   - C) Change the AI's font
   - D) Delete a file

5. **Which transport method is used for local MCP servers running as separate processes?**
   - A) Bluetooth
   - B) stdio (Standard I/O)
   - C) SMTP
   - D) FTP

<details>
<summary><b>View Answers</b></summary>
1: C, 2: C, 3: B, 4: B, 5: B
</details>

---

## Next Steps
Now that you can build custom servers, proceed to the **[Advanced Level](../../3-Advanced/11-MCP/README.md)** to learn about enterprise-scale MCP Gateways and High Availability.

