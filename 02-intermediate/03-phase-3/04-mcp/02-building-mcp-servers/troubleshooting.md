# 🛠️ MCP Troubleshooting Hub

Developing and deploying MCP servers can be complex due to the interaction between local scripts, virtual environments, and AI clients. This guide covers the most common issues.

## 🛑 Common Errors & Fixes

### 1. "Server not found" in AI Client
- **Cause**: The configuration file has a typo or the path is incorrect.
- **Fix**: 
    - Verify the **absolute path** to the script.
    - If using a venv, point the `command` to the absolute path of the `python`/`node` executable *inside* that venv.
    - Check the client logs (e.g., View -> Toggle Developer Tools in Claude/Cursor).

### 2. "ImportError: No module named 'mcp'"
- **Cause**: The script is running in the global environment instead of the project venv.
- **Fix**: 
    - Activate the venv: `source venv/bin/activate`.
    - Install dependencies: `pip install -r requirements.txt`.
    - Ensure your client config uses the venv's python: `/path/to/project/src/venv/bin/python`.

### 3. Infinite "Starting Server..." loop
- **Cause**: Your script is printing to `stdout`, which interferes with the JSON-RPC communication.
- **Fix**: 
    - **Never** use `print()` or `console.log()` for debugging.
    - Use `logging` in Python or `console.error()` in Node.js.
    - MCP uses `stdout` for the protocol; anything else breaks the parser.

### 4. JSON-RPC Timeout
- **Cause**: A tool is taking too long to respond.
- **Fix**: 
    - Check for complex subprocesses or slow network calls.
    - Increase the timeout in your tool implementation if possible.
    - Use async/await to prevent blocking the main thread.

---

## 🔍 How to Debug like a Pro

### Use the Inspector
The `npx @modelcontextprotocol/inspector` tool is your best friend. It isolates the server from the AI client.
```bash
npx @modelcontextprotocol/inspector <command> <args>
```

### Trace the Logs
- **Python**: Add `import logging` and configure it to write to a file or `stderr`.
- **Claude Desktop**: Check the "Logs" tab in the MCP settings if available.

### Verify Permissions
If your server interacts with Docker, Kubernetes, or the file system, ensure the user running the AI client has the necessary permissions.

---
## 💡 Still Stuck?
1. Try running your script manually in the terminal: `python src/simple_devops_server.py`. If it errors there, it will definitely fail in MCP.
2. Ensure you are using the latest version of the MCP SDK:
   - `pip install --upgrade mcp`
   - `npm update @modelcontextprotocol/sdk`
