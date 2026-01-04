# 02: Building MCP Servers

MCP servers are designed to be lightweight and easy to build. The official SDKs support **Python** and **TypeScript/Node.js**.

## 🏗️ Implementing a Tool

A "Tool" is a function that the AI can call. It must have a name, a description, and a schema for its arguments.

### Python Example:
```python
from mcp.server.fastmcp import FastMCP

# Create the server
mcp = FastMCP("DevOps-Toolbox")

@mcp.tool()
def check_disk_space(path: str = "/"):
    """Check the remaining disk space on a given path."""
    import shutil
    total, used, free = shutil.disk_usage(path)
    return f"Free space: {free // (2**30)} GB"

if __name__ == "__main__":
    mcp.run()
```

---

## 📄 Implementing Resources

A "Resource" allows the AI to "read" data. This could be a file on disk or a response from an API.

```python
@mcp.resource("config://app-settings")
def get_config():
    """Retrieve the application configuration file."""
    with open("config.json", "r") as f:
        return f.read()
```

---

## 🔄 The Protocol Flow

1.  **Discovery**: The Client asks the Server: "What tools and resources do you have?"
2.  **Call**: The Client sends a request: "Run `check_disk_space` with path=`/var/log`."
3.  **Response**: The Server executes the code and returns the result to the Client.
4.  **Synthesis**: The AI uses the result to inform its next response to the user.
