# 02: Building MCP Servers

**[⬅️ Back to MCP Module Index](../readme.md)** | **[Next: MCP for Kubernetes ➡️](../03-mcp-for-kubernetes-and-cloud/readme.md)**

---

# 🏗️ Building Your First MCP Server

Building an MCP server allows you to expose *your* specific tools and data to an AI. While there are pre-built servers for things like Postgres or GitHub, the real power comes from building custom servers for your internal DevOps workflows.

## 📂 Project Structure

We have provided a complete reference implementation in the `src/` directory:

```text
02-Building-MCP-Servers/
├── README.md
└── src/
    ├── simple_devops_server.py  # A "kitchen sink" server example
    └── requirements.txt         # Python dependencies
```

---

## 🚀 Step 1: Installation

You need the `mcp` python package to get started.

```bash
cd src
pip install -r requirements.txt
```

*Note: We recommend running this in a virtual environment (`python -m venv venv`).*

---

## 💻 Step 2: Code Walkthrough

Open `src/simple_devops_server.py`. Here is how we implement the core primitives using the `FastMCP` class.

### 1. Initialization
```python
from mcp.server.fastmcp import FastMCP

# This name appears in the client UI
mcp = FastMCP("DevOps-Assistant")
```

### 2. Creating a Tool (Action)
To let the AI *do* something, we use the `@mcp.tool()` decorator. The type hints and docstring are **CRITICAL**—they are converted into the JSON Schema that tells the AI how to use the tool.

```python
@mcp.tool()
def check_website_health(url: str) -> str:
    """
    Performs a health check on a given URL.
    Args:
        url: The full URL to check (e.g., https://google.com)
    """
    # ... implementation details ...
```

### 3. Creating a Resource (Data)
To let the AI *read* something, we use `@mcp.resource()`. Resources have a URI scheme.

```python
@mcp.resource("host://env-vars")
def get_safe_env_vars() -> str:
    """Returns a filtered list of environment variables."""
    # ... implementation details ...
```

---

## 🔌 Step 3: Connecting to a Client

To use this server with **Claude Desktop** or **Cursor**, you need to tell the host application how to run your python script.

### Configuration File
Locate your config file:
*   **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
*   **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

Add your server to the `mcpServers` object:

```json
{
  "mcpServers": {
    "devops-assistant": {
      "command": "python",
      "args": [
        "C:\\Users\\Ganil\\Documents\\Devops\\02-Intermediate\\03-Phase-3\\04-MCP\\02-Building-MCP-Servers\\src\\simple_devops_server.py"
      ]
    }
  }
}
```

> **⚠️ Important**: Always use **absolute paths** for the script location. If you are using a virtual environment, use the absolute path to the `python` executable inside the venv (e.g., `C:/.../venv/Scripts/python.exe`).

---

## 🐞 Step 4: Debugging with the Inspector

The MCP team provides a web-based inspector to test your server without needing a full AI client.

```bash
npx @modelcontextprotocol/inspector python src/simple_devops_server.py
```

This will open a browser window where you can:
1.  See the list of available Tools and Resources.
2.  Click "Call Tool" to manually execute functions and see the JSON output.
3.  Read Resources to verify the data stream.

---

## 🧪 Real-World Challenge

**Goal**: Extend the `simple_devops_server.py` file.

1.  Add a tool named `backup_log_files` that takes a `directory_path`.
2.  Implement logic to zip the contents of that directory.
3.  Test it using the Inspector.

Good luck!

