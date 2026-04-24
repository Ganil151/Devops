# MCP (Model Context Protocol) Challenges 🔌

Master the communication between AI agents and local/remote tools.

---

## 🏆 Challenge 01: Architecture Audit
**Objective**: Understand the "Client-Host-Server" relationship in MCP.

1.  **Task**: Diagram the flow of data when a user asks a Chatbot to "List my local files."
2.  **Requirement**: Identify where the **MCP Server** sits in this flow.
3.  **Question**: Why is the MCP protocol necessary instead of just using standard REST APIs? (Research: context awareness and structured data).

---

## 🏆 Challenge 02: Building a "Hello World" MCP Server
**Objective**: Create a basic server that exposes a simple tool.

1.  **Requirement**: Use the `mcp-hello-server.py` boilerplate.
2.  **Task**: Add a new tool called `get_server_time` that returns the current UTC time.
3.  **Verification**: Start the server and use a "Client" (or a Python test script) to call the tool.

---

## 🏆 Challenge 03: The Secure Data Gate
**Objective**: Implement local security for AI tool calls.

1.  **Scenario**: You are building an MCP server that grants an AI access to a local database.
2.  **Task**: Implement a "Confirmation Loop" where the AI must request a specific environment variable `CONFIRM_ACCESS='YES'` before the tool returns data.
3.  **Goal**: Understand why "Uncontrolled AI Access" to system resources is a security risk.

---

## 📁 Solutions
Templates for building custom servers are located in the `Boilerplates/` directory.
