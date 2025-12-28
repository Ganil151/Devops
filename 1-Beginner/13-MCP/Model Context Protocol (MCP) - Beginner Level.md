The Model Context Protocol (MCP) is an open standard that enables seamless integration between AI assistants and external data sources, tools, and services. It provides a universal way for AI models to interact with various systems in a secure and standardized manner.

---

## 1. Using Standard MCP Servers
Most beginner DevOps tasks involve manipulating files or checking code status. Standard MCP servers (like the **Filesystem** and **Git** servers) are pre-built to handle these.

### 🛠️ Example 1: The Filesystem Server
Instead of copy-pasting code into a chat, an AI host using the Filesystem MCP server can "read" files directly to understand project structure.
- **Tool**: `read_file`
- **Use Case**: "Analyze the `config.yaml` and tell me if the port is set correctly."

### 🛠️ Example 2: The GitHub Server
Automate repository management directly from your AI interface.
- **Tool**: `create_pull_request`
- **Use Case**: "I've finished the script. Use the GitHub MCP server to create a new branch and open a PR with the changes."

---

## 2. Setting Up Your Environment (Runbook)

### Runbook: Configuring MCP in VS Code (Claude Dev/Cline)
1. **Install an AI Extension**: Install an extension that supports MCP (e.g., Cline or Roo Code).
2. **Open MCP Settings**: Locate the `mcp_config.json` file in your application data directory.
3. **Add a Server**: Add the following configuration to enable the Filesystem server:
   ```json
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/your/repo"]
       }
     }
   }
   ```
4. **Restart**: The AI assistant will now see "Tools" available for file operations.

---

## Real-World Scenarios

### Scenario 1: Automated Documentation
**Context**: You have 10 new microservices but none have a `README.md`.
**Solution**: Use the Filesystem and Git MCP servers.
**Prompt (to AI Host)**: "Use the filesystem tool to read the main files of all directories in `services/`. Then, generate a README for each one and use the Git tool to commit them."

### Scenario 2: Quick Infrastructure Audit
**Context**: You need to know which AWS regions are being used across 50 Terraform files.
**Solution**: Use MCP to 'grep' through files.
**Prompt**: "Search all `.tf` files in this workspace for the string 'region' and give me a summary of all unique regions found."

---

## Interview Questions (Beginner)

1. **What is an MCP 'Host'?**
   - The application where the user interacts with the AI (e.g., VS Code, Claude Desktop).
2. **What is the difference between an MCP 'Tool' and an MCP 'Resource'?**
   - A **Tool** is an action (a function the AI calls), while a **Resource** is a static piece of data (like a log file or documentation) the AI can read.
3. **Why is MCP better than simple Copy-Paste?**
   - It provides the AI with "live" context and the ability to take actions, reducing manual effort and errors.
4. **What transport protocols does MCP support?**
   - Primarily **stdio** (standard input/output) for local processes and **SSE** (Server-Sent Events) for remote services.

---

## Knowledge Quiz

1. **Which MCP component actually performs the action (e.g., searches a database)?**
   - A) Host
   - B) Client
   - C) Server
   - D) User

2. **In `mcp_config.json`, the 'command' field usually points to:**
   - A) The AI model name
   - B) The executable of the MCP server (e.g., `python` or `npx`)
   - C) A website URL
   - D) A password

3. **An MCP 'Tool' is essentially a:**
   - A) JSON file
   - B) Function that the AI can execute
   - C) New AI model
   - D) Hardware device

4. **True or False: MCP requires you to send your entire codebase to the AI provider at once.**
   - A) True
   - B) False (It only reads/writes what is needed for the specific task)

5. **Which server would you use to automate Git commits?**
   - A) Postgres MCP Server
   - B) Git MCP Server
   - C) Weather MCP Server
   - D) Slack MCP Server

<details>
<summary><b>View Answers</b></summary>
1: C, 2: B, 3: B, 4: B, 5: B
</details>

---

## Next Steps
After using standard servers, proceed to the **[Intermediate Level](../../2-Intermediate/13-MCP/README.md)** to learn how to build your own custom MCP servers.

