# 05: Interview Questions and Quizzes

**[⬅️ Back to MCP Module Index](../README.md)** | **[Next: Real-Life Scenarios ➡️](../06-Real-Life-Scenarios/README.md)**

---

# 🎓 Validating Your MCP Knowledge

Test your understanding of the Model Context Protocol (MCP) and its role in the future of Agentic AI.

## 🎤 Top 20 Interview Questions & Answers

### Fundamentals

**1. What is the Model Context Protocol (MCP), and what problem does it solve?**
> **Answer**: MCP is an open standard that enables AI models to connect to external data and tools. It solves the "fragmented integration" problem by replacing custom p2p integrations with a universal client-host-server protocol.

**2. Explain the difference between an MCP 'Host', 'Client', and 'Server'.**
> **Answer**:
> *   **Host**: The application usage layer (e.g., Claude Desktop).
> *   **Client**: The protocol implementation inside the Host that manages connections.
> *   **Server**: The process that exposes specific Tools and Resources to the Client.

**3. What are the three primary primitives of MCP?**
> **Answer**: Tools (for actions), Resources (for reading data), and Prompts (for reusable instructions).

**4. Explain the difference between 'Stdio' and 'SSE' transports.**
> **Answer**: Stdio is used for local connections (standard input/output subprocesses), while SSE (Server-Sent Events) is used for remote connections over HTTP.

### Architecture & Security

**5. How would you handle security for a "destructive" tool (e.g., `delete_database`)?**
> **Answer**: Ensure the tool requires User Confirmation (Human-in-the-Loop) at the Host level. Never allow auto-approval for side-effect-causing tools.

**6. Why is the "Local Gateway" pattern preferred for DevOps?**
> **Answer**: It allows the MCP server to run on the engineer's local machine, inheriting their authentication context (VPN, cached credentials), simplifying security.

**7. Can an MCP server initiate a conversation with the user?**
> **Answer**: No. MCP is request-response driven by the Client. However, a server can send notifications for subscribed Resources.

**8. What is "Sampling" in MCP?**
> **Answer**: It is a feature where the Server requests the *Host* to run an LLM completion. This allows a lightweight server to "think" using the heavy model in the Host application.

### Implementation

**9. How does an MCP client discover available tools?**
> **Answer**: During the initialization handbook, the Client sends a `tools/list` request, and the Server responds with a JSON array of tool definitions and their schemas.

**10. Why is JSON Schema important in MCP?**
> **Answer**: It allows the LLM to strictly validate arguments before calling a tool, reducing runtime errors and hallucinations.

---

## 📝 20-Question Knowledge Quiz

**1. Who developed the Model Context Protocol open standard?**
*   [ ] OpenAI
*   [ ] Google
*   [ ] Anthropic (Open sourced as a standard)
*   [ ] Microsoft

**2. The MCP 'Server' primary job is to:**
*   [ ] Run the Large Language Model
*   [ ] Expose tools and resources to the AI host
*   [ ] Store the user's chat history
*   [ ] Manage the GPU cluster

**3. Which transport is typically used for local MCP servers?**
*   [ ] gRPC
*   [ ] Stdio (Standard Input/Output)
*   [ ] Webhooks
*   [ ] FTP

**4. In the MCP architecture, the 'Host' is usually:**
*   [ ] The database
*   [ ] The AI application (like Claude Desktop or an IDE)
*   [ ] The cloud provider
*   [ ] The human user

**5. A 'Tool' in MCP requires a `______` to define its arguments.**
*   [ ] CSV file
*   [ ] JSON Schema
*   [ ] Python Class
*   [ ] Markdown Table

**6. True or False: An MCP server generally contains its own LLM.**
*   [ ] True
*   [ ] False

**7. What happens during the 'Discovery' phase?**
*   [ ] The user searches for AI models
*   [ ] The Host queries the Server for a list of available tools/resources
*   [ ] The Server downloads the latest AI model
*   [ ] The network is scanned for vulnerabilities

**8. Which of these is a valid 'Resource' URI?**
*   [ ] `https://google.com`
*   [ ] `file:///etc/hosts`
*   [ ] `mcp://local/logs`
*   [ ] `postgres://db:5432`

**9. What does 'SSE' stand for?**
*   [ ] Standard Service Entry
*   [ ] Server-Sent Events
*   [ ] Secure Socket Encryption
*   [ ] Simple Serial Exchange

**10. Why is 'Max Tokens' relevant for an MCP server?**
*   [ ] To limit the AI's imagination
*   [ ] To ensure the tool's response doesn't exceed the model's context window
*   [ ] To speed up the internet
*   [ ] It isn't relevant

**11. The 'Human-in-the-loop' pattern is primarily for:**
*   [ ] Performance
*   [ ] Safety and Security
*   [ ] Compliance
*   [ ] Cost reduction

**12. Which SDK would you use if you are a Python developer?**
*   [ ] MCP-js
*   [ ] mcp-python (or fastmcp)
*   [ ] MCP-go
*   [ ] MCP-rust

**13. Tools in MCP are similar to `______` in other AI frameworks.**
*   [ ] Models
*   [ ] Agents
*   [ ] Function Calling
*   [ ] Embeddings

**14. What is 'Sampling' in the MCP specification?**
*   [ ] Testing a small part of the data
*   [ ] Allowing a server to request a completion from the host's model
*   [ ] Picking a random tool
*   [ ] Monitoring response times

**15. A 'destructive' tool call should always reach the `______` state.**
*   [ ] Automatic Execution
*   [ ] Silent Failure
*   [ ] User Approval / Confirmation
*   [ ] Infinite Loop

**16. How do you pass credentials (like API keys) to an MCP server?**
*   [ ] Hardcode them in the tool code
*   [ ] Pass them via Environment Variables to the server process
*   [ ] Send them in the chat message
*   [ ] Use a public S3 bucket

**17. Which of these is a benefit of containerizing an MCP server?**
*   [ ] Isolation and portability
*   [ ] Making it run slower
*   [ ] Increasing the cost
*   [ ] Making it easier for hackers

**18. An MCP 'Prompt' is used to:**
*   [ ] Ask the user for money
*   [ ] Provide the AI with structured templates for specific tasks
*   [ ] Restart the computer
*   [ ] Measure latency

**19. Can an MCP server be written in languages other than Python/JS?**
*   [ ] No, never
*   [ ] Yes, by implementing the JSON-RPC spec directly
*   [ ] Only if the AI permits it
*   [ ] Only in C++

**20. MCP aims to solve the 'Fragmented Integration' problem by:**
*   [ ] Building a single AI for everything
*   [ ] Providing a standard way for any AI to talk to any tool
*   [ ] Deleting all APIs
*   [ ] Moving everything to the cloud

<details>
<summary><b>View Quiz Answers</b></summary>

1: C (Anthropic) - *Note: While opensourced, they led the dev in 2024.*
2: B
3: B
4: B
5: B
6: False
7: B
8: C, D (Custom schemes generally preferred over http/file)
9: B
10: B
11: B
12: B
13: C
14: B
15: C
16: B
17: A
18: B
19: B
20: B

</details>